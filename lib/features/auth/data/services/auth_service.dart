import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Roles ────────────────────────────────────────────────────────────────────
enum UserRole { admin, user }

class AuthService {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Error al iniciar sesión';
    }
  }

  // ─── REGISTER ─────────────────────────────────────────────────────────────
  Future<User?> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw 'No se pudo crear el usuario';

      await user.updateDisplayName(displayName);
      await user.reload();

      // Rol por defecto: 'user'
      // Para hacer admin: cambia 'role' a 'admin' manualmente en Firestore
      // o usa la función setAdminRole() de abajo.
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'email':       email,
        'photoUrl':    '',
        'role':        'user',          // ← campo de rol
        'createdAt':   FieldValue.serverTimestamp(),
        'updatedAt':   FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Error al registrarse';
    }
  }

  // ─── LOGOUT ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── GET ROLE ─────────────────────────────────────────────────────────────
  /// Consulta el rol del usuario actual desde Firestore.
  /// Devuelve [UserRole.admin] si el campo 'role' == 'admin', si no [UserRole.user].
  Future<UserRole> getCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return UserRole.user;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final role = doc.data()?['role'] as String? ?? 'user';
      return role == 'admin' ? UserRole.admin : UserRole.user;
    } catch (_) {
      return UserRole.user;
    }
  }

  /// Stream reactivo del rol — se actualiza si cambias el rol en Firestore.
  Stream<UserRole> get roleStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(UserRole.user);

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      final role = doc.data()?['role'] as String? ?? 'user';
      return role == 'admin' ? UserRole.admin : UserRole.user;
    });
  }

  // ─── UTIL: Promover a admin (úsalo desde la consola o una función cloud) ──
  /// Llama esto una sola vez para dar rol de admin a un email específico.
  /// Solo funciona si el usuario actual YA es admin.
  Future<void> setAdminRole(String targetUid) async {
    await _firestore.collection('users').doc(targetUid).update({
      'role': 'admin',
    });
  }
}
