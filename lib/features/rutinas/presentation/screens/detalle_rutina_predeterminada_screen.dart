import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/rutina_service.dart';
import '../../../ejercicios/data/services/exercise_service.dart';

// ─── Modelo de día con ejercicios ─────────────────────────────────────────────
class _DiaRutina {
  final String titulo;       // Ej: "Día A – Push (Empuje)"
  final String subtitulo;    // Ej: "Pecho · Hombros · Tríceps"
  final List<String> ejercicioIds;

  const _DiaRutina({
    required this.titulo,
    required this.subtitulo,
    required this.ejercicioIds,
  });
}

// ─── Definición de ejercicios por programa ────────────────────────────────────
const _ejerciciosPPL = [
  _DiaRutina(
    titulo: 'Push — Empuje',
    subtitulo: 'Pecho · Hombros · Tríceps',
    ejercicioIds: ['bench_press', 'incline_press', 'overhead_press', 'lateral_raise', 'tricep_pushdown'],
  ),
  _DiaRutina(
    titulo: 'Pull — Jalón',
    subtitulo: 'Espalda · Bíceps',
    ejercicioIds: ['pull_up', 'barbell_row', 'lat_pulldown', 'seated_row', 'barbell_curl', 'hammer_curl'],
  ),
  _DiaRutina(
    titulo: 'Legs — Piernas',
    subtitulo: 'Cuádriceps · Isquiotibiales · Glúteos',
    ejercicioIds: ['squat', 'leg_press', 'romanian_deadlift', 'lunges', 'calf_raise'],
  ),
];

const _ejerciciosArnold = [
  _DiaRutina(
    titulo: 'Día A – Pecho + Espalda',
    subtitulo: 'Pectorales · Dorsales · Romboides',
    ejercicioIds: ['bench_press', 'incline_press', 'chest_fly', 'pull_up', 'barbell_row', 'seated_row'],
  ),
  _DiaRutina(
    titulo: 'Día B – Hombros + Brazos',
    subtitulo: 'Deltoides · Bíceps · Tríceps',
    ejercicioIds: ['overhead_press', 'lateral_raise', 'front_raise', 'barbell_curl', 'hammer_curl', 'tricep_pushdown'],
  ),
  _DiaRutina(
    titulo: 'Día C – Piernas + Abdomen',
    subtitulo: 'Cuádriceps · Isquiotibiales · Core',
    ejercicioIds: ['squat', 'leg_press', 'romanian_deadlift', 'lunges', 'calf_raise', 'crunch', 'plank'],
  ),
];

const _ejerciciosUpperLower = [
  _DiaRutina(
    titulo: 'Upper A – Tren Superior',
    subtitulo: 'Pecho · Espalda · Hombros',
    ejercicioIds: ['bench_press', 'pull_up', 'overhead_press', 'barbell_row', 'lateral_raise'],
  ),
  _DiaRutina(
    titulo: 'Lower A – Tren Inferior',
    subtitulo: 'Cuádriceps · Isquiotibiales · Glúteos',
    ejercicioIds: ['squat', 'romanian_deadlift', 'leg_press', 'lunges', 'calf_raise'],
  ),
  _DiaRutina(
    titulo: 'Upper B – Tren Superior',
    subtitulo: 'Empuje · Jalón · Brazos',
    ejercicioIds: ['incline_press', 'lat_pulldown', 'seated_row', 'barbell_curl', 'tricep_pushdown'],
  ),
  _DiaRutina(
    titulo: 'Lower B – Tren Inferior',
    subtitulo: 'Fuerza + Abdomen',
    ejercicioIds: ['deadlift', 'lunges', 'calf_raise', 'plank', 'leg_raise', 'crunch'],
  ),
];

const _ejerciciosFullBody = [
  _DiaRutina(
    titulo: 'Sesión A – Full Body',
    subtitulo: 'Cuerpo completo · Fuerza base',
    ejercicioIds: ['squat', 'bench_press', 'barbell_row', 'overhead_press', 'plank'],
  ),
  _DiaRutina(
    titulo: 'Sesión B – Full Body',
    subtitulo: 'Cuerpo completo · Volumen',
    ejercicioIds: ['deadlift', 'push_up', 'pull_up', 'lunges', 'crunch'],
  ),
  _DiaRutina(
    titulo: 'Sesión C – Full Body',
    subtitulo: 'Cuerpo completo · Acondicionamiento',
    ejercicioIds: ['leg_press', 'incline_press', 'lat_pulldown', 'lateral_raise', 'leg_raise'],
  ),
];

const _ejerciciosPHUL = [
  _DiaRutina(
    titulo: 'Día 1 – Fuerza Tren Superior',
    subtitulo: 'Pecho · Espalda · Cargas máximas',
    ejercicioIds: ['bench_press', 'barbell_row', 'incline_press', 'pull_up', 'barbell_curl', 'tricep_pushdown'],
  ),
  _DiaRutina(
    titulo: 'Día 2 – Fuerza Tren Inferior',
    subtitulo: 'Piernas · Cargas máximas',
    ejercicioIds: ['squat', 'deadlift', 'leg_press', 'romanian_deadlift', 'calf_raise'],
  ),
  _DiaRutina(
    titulo: 'Día 3 – Hipertrofia Superior',
    subtitulo: 'Pecho · Hombros · Brazos · Volumen',
    ejercicioIds: ['incline_press', 'chest_fly', 'overhead_press', 'lateral_raise', 'front_raise', 'hammer_curl'],
  ),
  _DiaRutina(
    titulo: 'Día 4 – Hipertrofia Inferior',
    subtitulo: 'Piernas · Abdomen · Volumen',
    ejercicioIds: ['leg_press', 'lunges', 'romanian_deadlift', 'calf_raise', 'crunch', 'plank', 'leg_raise'],
  ),
];

/// Retorna los días de entrenamiento según el nombre del programa
List<_DiaRutina> getDiasPorPrograma(String nombre) {
  final n = nombre.toLowerCase();
  if (n.contains('ppl') || n.contains('push pull')) return _ejerciciosPPL;
  if (n.contains('arnold')) return _ejerciciosArnold;
  if (n.contains('upper') || n.contains('lower')) return _ejerciciosUpperLower;
  if (n.contains('full body')) return _ejerciciosFullBody;
  if (n.contains('phul')) return _ejerciciosPHUL;
  return _ejerciciosPPL; // fallback
}

// ─── Detalle Rutina Predeterminada Screen ─────────────────────────────────────
class DetalleRutinaPredeterminadaScreen extends StatefulWidget {
  final String nombre;
  final String descripcion;
  final String tag;
  final int diasSemana;
  final String nivel;
  final int minutos;
  final int intensidad;
  final Color color;
  final IconData icon;
  final String categoria;

  const DetalleRutinaPredeterminadaScreen({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.tag,
    required this.diasSemana,
    required this.nivel,
    required this.minutos,
    required this.intensidad,
    required this.color,
    required this.icon,
    required this.categoria,
  });

  @override
  State<DetalleRutinaPredeterminadaScreen> createState() =>
      _DetalleRutinaPredeterminadaScreenState();
}

class _DetalleRutinaPredeterminadaScreenState
    extends State<DetalleRutinaPredeterminadaScreen>
    with SingleTickerProviderStateMixin {
  int _diaSeleccionado = 0;
  bool _guardando = false;

  late final List<_DiaRutina> _dias;
  final _service = ExerciseService();

  @override
  void initState() {
    super.initState();
    _dias = getDiasPorPrograma(widget.nombre);
  }

  Future<void> _agregarARutinas() async {
    setState(() => _guardando = true);
    try {
      await RutinaService.agregarPredeterminada(
        nombre: widget.nombre,
        categoria: widget.categoria,
        diasSemana: widget.diasSemana,
        minutos: widget.minutos,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: widget.color,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text(
            '✅ "${widget.nombre}" añadida a tus rutinas',
            style: const TextStyle(
                color: AppColors.carbonBlack, fontWeight: FontWeight.w800),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text('Error al guardar: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Column(
              children: [
                _buildDayTabs(),
                Expanded(child: _buildEjerciciosList()),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          bottom:
              BorderSide(color: widget.color.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón atrás
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.steamGray.withOpacity(0.08)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.steamGray, size: 16),
            ),
          ),
          const SizedBox(height: 16),
          // Icono + tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: widget.color.withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: widget.color.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.tag,
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.nombre,
                      style: const TextStyle(
                        color: AppColors.steamGray,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.descripcion,
            style: TextStyle(
              color: AppColors.steamGray.withOpacity(0.5),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          // Stats chips
          Row(
            children: [
              _Chip(
                  icon: Icons.calendar_today_outlined,
                  label: '${widget.diasSemana} días/sem',
                  color: widget.color),
              const SizedBox(width: 10),
              _Chip(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: widget.nivel,
                  color: widget.color),
              const SizedBox(width: 10),
              _Chip(
                  icon: Icons.timer_outlined,
                  label: '~${widget.minutos} min',
                  color: widget.color),
            ],
          ),
          const SizedBox(height: 10),
          // Barra de intensidad
          Row(
            children: [
              Text(
                'INTENSIDAD',
                style: TextStyle(
                  color: AppColors.steamGray.withOpacity(0.35),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: List.generate(5, (i) {
                    final filled = i < widget.intensidad;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: filled
                              ? widget.color
                              : AppColors.steamGray.withOpacity(0.1),
                          boxShadow: filled
                              ? [
                                  BoxShadow(
                                    color: widget.color.withOpacity(0.4),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tabs de días ───────────────────────────────────────────────────────────
  Widget _buildDayTabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'DÍAS DE ENTRENAMIENTO',
                style: TextStyle(
                  color: AppColors.steamGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 82,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _dias.length,
              itemBuilder: (context, i) {
                final active = _diaSeleccionado == i;
                final dia = _dias[i];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _diaSeleccionado = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? widget.color.withOpacity(0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active
                            ? widget.color.withOpacity(0.6)
                            : AppColors.steamGray.withOpacity(0.08),
                        width: active ? 1.5 : 1,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: widget.color.withOpacity(0.15),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Día ${i + 1}',
                          style: TextStyle(
                            color: active
                                ? widget.color
                                : AppColors.steamGray.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _shortTitle(dia.titulo),
                          style: TextStyle(
                            color: active
                                ? AppColors.steamGray
                                : AppColors.steamGray.withOpacity(0.55),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dia.ejercicioIds.length} ejercicios',
                          style: TextStyle(
                            color: active
                                ? widget.color.withOpacity(0.7)
                                : AppColors.steamGray.withOpacity(0.25),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _shortTitle(String titulo) {
    // "Push — Empuje" → "Push"
    if (titulo.contains('—')) return titulo.split('—')[0].trim();
    if (titulo.contains('–')) return titulo.split('–')[1].trim();
    return titulo.split(' ').take(2).join(' ');
  }

  // ── Lista de ejercicios del día seleccionado ───────────────────────────────
  Widget _buildEjerciciosList() {
    final dia = _dias[_diaSeleccionado];

    return Column(
      children: [
        // Título del día
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dia.titulo,
                      style: const TextStyle(
                        color: AppColors.steamGray,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      dia.subtitulo,
                      style: TextStyle(
                        color: AppColors.steamGray.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: widget.color.withOpacity(0.25)),
                ),
                child: Text(
                  '${dia.ejercicioIds.length} ejercicios',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista
        Expanded(
          child: FutureBuilder<List<EjercicioData?>>(
            future: Future.wait(
              dia.ejercicioIds.map(
                  (id) => _service.getEjercicioPorId(id)),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: widget.color,
                    strokeWidth: 2,
                  ),
                );
              }

              final ejercicios = (snapshot.data ?? [])
                  .whereType<EjercicioData>()
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                physics: const BouncingScrollPhysics(),
                itemCount: ejercicios.length,
                itemBuilder: (context, i) =>
                    _EjercicioItem(
                  ejercicio: ejercicios[i],
                  numero: i + 1,
                  color: widget.color,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
              color: AppColors.steamGray.withOpacity(0.08), width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: _guardando ? null : _agregarARutinas,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _guardando
                ? widget.color.withOpacity(0.6)
                : widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_guardando)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.carbonBlack,
                    strokeWidth: 2.5,
                  ),
                )
              else
                const Icon(Icons.add_rounded,
                    color: AppColors.carbonBlack, size: 20),
              const SizedBox(width: 10),
              Text(
                _guardando ? 'Agregando...' : 'Agregar a mis rutinas',
                style: const TextStyle(
                  color: AppColors.carbonBlack,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ejercicio Item ───────────────────────────────────────────────────────────
class _EjercicioItem extends StatefulWidget {
  final EjercicioData ejercicio;
  final int numero;
  final Color color;

  const _EjercicioItem({
    required this.ejercicio,
    required this.numero,
    required this.color,
  });

  @override
  State<_EjercicioItem> createState() => _EjercicioItemState();
}

class _EjercicioItemState extends State<_EjercicioItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.ejercicio;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _expanded = !_expanded);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _expanded
                ? widget.color.withOpacity(0.3)
                : AppColors.steamGray.withOpacity(0.07),
            width: _expanded ? 1.5 : 1,
          ),
          boxShadow: _expanded
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.08),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // ── Fila principal ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Número
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                          color: widget.color.withOpacity(0.25)),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.numero}',
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.nombre,
                          style: const TextStyle(
                            color: AppColors.steamGray,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              e.musculo,
                              style: TextStyle(
                                color: widget.color.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '  ·  ${e.equipo}',
                              style: TextStyle(
                                color: AppColors.steamGray
                                    .withOpacity(0.35),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Nivel badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      e.nivel,
                      style: TextStyle(
                        color: AppColors.steamGray.withOpacity(0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Expand arrow
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.steamGray.withOpacity(0.35),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // ── Instrucciones expandibles ────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding:
                    const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: AppColors.steamGray.withOpacity(0.07),
                      height: 16,
                    ),
                    // Músculos secundarios
                    if (e.musculosSecundarios.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: widget.color.withOpacity(0.5),
                              size: 12),
                          const SizedBox(width: 5),
                          Text(
                            'Músculos secundarios: ${e.musculosSecundarios.join(', ')}',
                            style: TextStyle(
                              color: AppColors.steamGray.withOpacity(0.45),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    // Instrucciones
                    ...e.instrucciones.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(
                                  right: 10, top: 1),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:
                                        widget.color.withOpacity(0.25)),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: TextStyle(
                                    color: widget.color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  color: AppColors.steamGray
                                      .withOpacity(0.6),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chip de info ─────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: AppColors.steamGray.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}