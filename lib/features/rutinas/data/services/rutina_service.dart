import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Modelo de Rutina ─────────────────────────────────────────────────────────
class RutinaModel {
  final String id;
  final String nombre;
  final String categoria;       // fuerza | hipertrofia | resistencia
  final List<bool> diasActivos; // 7 elementos, L-D
  final List<String> ejercicios;
  final int minutos;
  final bool activa;
  final bool esPredeterminada;
  final DateTime creadaEn;
  final String uid;

  const RutinaModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.diasActivos,
    required this.ejercicios,
    required this.minutos,
    required this.activa,
    required this.esPredeterminada,
    required this.creadaEn,
    required this.uid,
  });

  int get diasCount => diasActivos.where((d) => d).length;

  factory RutinaModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RutinaModel(
      id: doc.id,
      nombre: data['nombre'] as String? ?? 'Sin nombre',
      categoria: data['categoria'] as String? ?? 'fuerza',
      diasActivos: List<bool>.from(
        (data['diasActivos'] as List<dynamic>?)?.map((e) => e as bool) ??
            List.filled(7, false),
      ),
      ejercicios: List<String>.from(
        (data['ejercicios'] as List<dynamic>?)?.map((e) => e.toString()) ?? [],
      ),
      minutos: (data['minutos'] as num?)?.toInt() ?? 45,
      activa: data['activa'] as bool? ?? false,
      esPredeterminada: data['esPredeterminada'] as bool? ?? false,
      creadaEn: (data['creadaEn'] as Timestamp?)?.toDate() ?? DateTime.now(),
      uid: data['uid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap(String uid) => {
        'nombre': nombre,
        'categoria': categoria,
        'diasActivos': diasActivos,
        'ejercicios': ejercicios,
        'minutos': minutos,
        'activa': activa,
        'esPredeterminada': esPredeterminada,
        'creadaEn': Timestamp.fromDate(creadaEn),
        'uid': uid,
      };
}

// ─── Servicio ─────────────────────────────────────────────────────────────────
class RutinaService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // Colección raíz — cada documento tiene campo 'uid' del dueño
  static CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('rutinas');

  static String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');
    return uid;
  }

  // ── Stream: solo rutinas del usuario actual ────────────────────────────────
  static Stream<List<RutinaModel>> rutinasStream() {
    return _col
        .where('uid', isEqualTo: _uid)
        .snapshots()
        .map((snap) {
          final lista = snap.docs.map(RutinaModel.fromDoc).toList();
          lista.sort((a, b) => b.creadaEn.compareTo(a.creadaEn));
          return lista;
        });
  }

  // ── Crear rutina personalizada ─────────────────────────────────────────────
  static Future<void> crearRutina({
    required String nombre,
    required String categoria,
    required List<bool> diasActivos,
    required List<String> ejercicios,
    int minutos = 45,
  }) async {
    final uid = _uid;
    final rutina = RutinaModel(
      id: '',
      nombre: nombre,
      categoria: categoria,
      diasActivos: diasActivos,
      ejercicios: ejercicios,
      minutos: minutos,
      activa: false,
      esPredeterminada: false,
      creadaEn: DateTime.now(),
      uid: uid,
    );
    await _col.add(rutina.toMap(uid));
  }

  // ── Agregar rutina predeterminada ──────────────────────────────────────────
  static Future<void> agregarPredeterminada({
    required String nombre,
    required String categoria,
    required int diasSemana,
    required int minutos,
  }) async {
    final uid = _uid;
    final dias = List<bool>.generate(7, (i) => i < diasSemana);
    final rutina = RutinaModel(
      id: '',
      nombre: nombre,
      categoria: categoria,
      diasActivos: dias,
      ejercicios: [],
      minutos: minutos,
      activa: false,
      esPredeterminada: true,
      creadaEn: DateTime.now(),
      uid: uid,
    );
    await _col.add(rutina.toMap(uid));
  }

  // ── Eliminar rutina ────────────────────────────────────────────────────────
  static Future<void> eliminarRutina(String id) => _col.doc(id).delete();

  // ── Activar/desactivar (desactiva las demás del usuario) ──────────────────
  static Future<void> toggleActiva(String id, bool activa) async {
    if (activa) {
      final snap = await _col
          .where('uid', isEqualTo: _uid)
          .where('activa', isEqualTo: true)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'activa': false});
      }
      batch.update(_col.doc(id), {'activa': true});
      await batch.commit();
    } else {
      await _col.doc(id).update({'activa': false});
    }
  }
}