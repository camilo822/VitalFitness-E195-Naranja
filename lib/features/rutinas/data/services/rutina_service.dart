import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Modelo de Rutina ─────────────────────────────────────────────────────────
class RutinaModel {
  final String id;
  final String nombre;
  final String categoria;       // objetivo: fuerza | hipertrofia | resistencia
  final List<bool> diasActivos; // 7 elementos, L-D
  final List<String> ejercicios;
  final int minutos;
  final bool activa;
  final bool esPredeterminada;
  final DateTime creadaEn;

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
  });

  int get diasCount => diasActivos.where((d) => d).length;

  // ── Firestore → Model ──────────────────────────────────────────────────────
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
    );
  }

  // ── Model → Firestore ──────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'categoria': categoria,
        'diasActivos': diasActivos,
        'ejercicios': ejercicios,
        'minutos': minutos,
        'activa': activa,
        'esPredeterminada': esPredeterminada,
        'creadaEn': Timestamp.fromDate(creadaEn),
        'uid': FirebaseAuth.instance.currentUser?.uid ?? '',
      };
}

// ─── Servicio ─────────────────────────────────────────────────────────────────
class RutinaService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// Referencia a la subcolección rutinas del usuario actual
  static CollectionReference<Map<String, dynamic>> get _col {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');
    return _db.collection('usuarios').doc(uid).collection('rutinas');
  }

  // ── Stream en tiempo real ──────────────────────────────────────────────────
  static Stream<List<RutinaModel>> rutinasStream() {
    return _col
        .orderBy('creadaEn', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RutinaModel.fromDoc).toList());
  }

  // ── Crear rutina personalizada ─────────────────────────────────────────────
  static Future<void> crearRutina({
    required String nombre,
    required String categoria,
    required List<bool> diasActivos,
    required List<String> ejercicios,
    int minutos = 45,
  }) async {
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
    );
    await _col.add(rutina.toMap());
  }

  // ── Agregar rutina predeterminada al usuario ───────────────────────────────
  static Future<void> agregarPredeterminada({
    required String nombre,
    required String categoria,
    required int diasSemana,
    required int minutos,
  }) async {
    // Genera diasActivos con los primeros N días de la semana activos
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
    );
    await _col.add(rutina.toMap());
  }

  // ── Eliminar rutina ────────────────────────────────────────────────────────
  static Future<void> eliminarRutina(String id) => _col.doc(id).delete();

  // ── Marcar como activa (desactiva las demás) ───────────────────────────────
  static Future<void> toggleActiva(String id, bool activa) async {
    if (activa) {
      // Desactivar todas primero
      final snap = await _col.where('activa', isEqualTo: true).get();
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