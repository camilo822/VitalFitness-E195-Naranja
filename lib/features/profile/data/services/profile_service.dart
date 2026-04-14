//import 'dart:io';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/cloudinary_config.dart';

/// ─── ProfileService ───────────────────────────────────────────────────────────
///
/// Arquitectura híbrida: Cloudinary + Firestore
///
///   CLOUDINARY  →  almacena la imagen (gratis, CDN global, transformaciones)
///   FIRESTORE   →  almacena el perfil del usuario (uid, nombre, photoUrl, etc.)
///
/// Flujo al cambiar foto de perfil:
///   1. image_picker selecciona/captura la foto del dispositivo.
///   2. Se sube a Cloudinary via API REST (upload preset UNSIGNED).
///   3. Cloudinary devuelve una URL pública permanente.
///   4. Esa URL se guarda en Firestore: users/{uid}.photoUrl
///   5. Opcionalmente se actualiza el perfil de FirebaseAuth con la URL.
///   6. El StreamBuilder de la UI escucha Firestore y se reconstruye solo.
class ProfileService {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker       _picker    = ImagePicker();

  User? get currentUser => _auth.currentUser;

  // ─── Selección de imagen ──────────────────────────────────────────────────

  /// Abre la galería. Devuelve el XFile o null si el usuario canceló.
  Future<XFile?> pickFromGallery() => _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

  /// Abre la cámara. Devuelve el XFile o null si el usuario canceló.
  Future<XFile?> pickFromCamera() => _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

  // ─── Subir imagen a Cloudinary ────────────────────────────────────────────

  /// Sube [imageFile] a Cloudinary usando un upload preset UNSIGNED
  /// (no requiere API Secret en el cliente — seguro para móvil).
  ///
  /// Devuelve la URL pública permanente de la imagen subida.
  /// Lanza [CloudinaryUploadException] si algo falla.
  Future<String> _uploadToCloudinary(XFile imageFile) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    final bytes = await imageFile.readAsBytes();

    // Multipart request a la API REST de Cloudinary
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(CloudinaryConfig.uploadUrl),
    );

    // Timestamp en milisegundos para que cada subida genere una URL diferente.
    // Sin esto, Cloudinary reutiliza el mismo public_id → misma URL →
    // Flutter sirve la imagen vieja desde su caché interno sin descargar la nueva.
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
    request.fields['folder']        = CloudinaryConfig.avatarFolder;
    request.fields['public_id']     = '${uid}_$timestamp';

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: '$uid.jpg',
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw CloudinaryUploadException(
        'Error Cloudinary ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // secure_url: URL HTTPS permanente de la imagen en el CDN de Cloudinary
    final secureUrl = json['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw CloudinaryUploadException('Cloudinary no devolvió una URL válida');
    }

    return secureUrl;
  }

  // ─── Guardar foto de perfil (flujo completo) ──────────────────────────────

  /// Orquesta todo el flujo: sube a Cloudinary → guarda URL en Firestore
  /// → actualiza FirebaseAuth. Devuelve la URL pública final.
  Future<String> saveProfilePhoto(XFile imageFile) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    // 1. Subir a Cloudinary
    final photoUrl = await _uploadToCloudinary(imageFile);

    // 2. Guardar URL en Firestore (merge para no borrar otros campos)
    await _firestore.collection('users').doc(uid).set(
      {
        'photoUrl':  photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 3. Actualizar FirebaseAuth (opcional pero útil si usas user.photoURL
    //    en otras partes de la app, como el header de HomeScreen)
    await currentUser?.updatePhotoURL(photoUrl);
    await currentUser?.reload();

    return photoUrl;
  }

  // ─── Stream reactivo del perfil ───────────────────────────────────────────

  /// Cada vez que Firestore actualiza users/{uid}, el StreamBuilder
  /// de ProfileScreen se reconstruye automáticamente con los nuevos datos.
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // ─── Actualizar nombre ────────────────────────────────────────────────────

  /// Actualiza displayName en Firestore y en FirebaseAuth al mismo tiempo.
  Future<void> updateDisplayName(String name) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    await Future.wait([
      currentUser!.updateDisplayName(name),
      _firestore.collection('users').doc(uid).set(
        {'displayName': name, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      ),
    ]);
    await currentUser!.reload();
  }

  // ─── Actualizar datos físicos ─────────────────────────────────────────────

  /// Guarda peso (kg), altura (cm) y objetivo en Firestore.
  /// Los campos son opcionales — solo se actualizan los que se pasen.
  Future<void> updatePhysicalData({
    double? weightKg,
    double? heightCm,
    String? objetivo, // 'bajar_peso' | 'ganar_musculo' | 'mantenerse'
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (weightKg != null) data['weightKg'] = weightKg;
    if (heightCm != null) data['heightCm'] = heightCm;
    if (objetivo  != null) data['objetivo'] = objetivo;

    await _firestore.collection('users').doc(uid).set(
      data,
      SetOptions(merge: true),
    );
  }

  // ─── Cambiar contraseña ───────────────────────────────────────────────────

  /// Re-autentica al usuario con su contraseña actual y luego la cambia.
  /// Lanza [FirebaseAuthException] si la contraseña actual es incorrecta.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null || user.email == null) throw Exception('Usuario no autenticado');

    // Re-autenticación obligatoria para operaciones sensibles
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // ─── Eliminar cuenta ──────────────────────────────────────────────────────

  /// Re-autentica, elimina el documento de Firestore y luego la cuenta de Auth.
  Future<void> deleteAccount({required String password}) async {
    final user = currentUser;
    if (user == null || user.email == null) throw Exception('Usuario no autenticado');

    // Re-autenticación obligatoria
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // Borrar datos de Firestore primero
    await _firestore.collection('users').doc(user.uid).delete();

    // Eliminar la cuenta de Firebase Auth (esto cierra la sesión automáticamente)
    await user.delete();
  }
}

// ─── Excepción personalizada ──────────────────────────────────────────────────
class CloudinaryUploadException implements Exception {
  final String message;
  const CloudinaryUploadException(this.message);

  @override
  String toString() => 'CloudinaryUploadException: $message';
}