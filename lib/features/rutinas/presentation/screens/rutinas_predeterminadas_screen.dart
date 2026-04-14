import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

// ─── Modelo ───────────────────────────────────────────────────────────────────
class _ProgramaData {
  final String nombre;
  final String descripcion;
  final String tag;
  final int diasSemana;
  final String nivel;
  final int minutos;
  final int intensidad; // 1-5
  final IconData icon;
  final Color color;

  const _ProgramaData({
    required this.nombre,
    required this.descripcion,
    required this.tag,
    required this.diasSemana,
    required this.nivel,
    required this.minutos,
    required this.intensidad,
    required this.icon,
    required this.color,
  });
}

const _categorias = ['TODOS', 'FUERZA', 'VOLUMEN', 'PRINCIPIANTE'];

const _programas = [
  _ProgramaData(
    nombre: 'PPL — Push Pull Legs',
    descripcion:
        'Divide el entrenamiento en empuje, jalón y piernas. Ideal para ganar masa y fuerza con alta frecuencia semanal.',
    tag: 'POPULAR',
    diasSemana: 6,
    nivel: 'Intermedio',
    minutos: 75,
    intensidad: 4,
    icon: Icons.fitness_center_rounded,
    color: AppColors.cyberLime,
  ),
  _ProgramaData(
    nombre: 'Arnold Split',
    descripcion:
        'El programa favorito de Schwarzenegger. Combina pecho+espalda, hombros+brazos y piernas en 6 días intensos.',
    tag: 'CLÁSICO',
    diasSemana: 6,
    nivel: 'Avanzado',
    minutos: 90,
    intensidad: 5,
    icon: Icons.emoji_events_rounded,
    color: AppColors.electricViolet,
  ),
  _ProgramaData(
    nombre: 'Upper / Lower Split',
    descripcion:
        'Alterna días de tren superior e inferior. Excelente relación frecuencia-recuperación para ganar fuerza.',
    tag: 'EQUILIBRADO',
    diasSemana: 4,
    nivel: 'Principiante+',
    minutos: 60,
    intensidad: 3,
    icon: Icons.swap_vert_rounded,
    color: Color(0xFF00D4FF),
  ),
  _ProgramaData(
    nombre: 'Full Body 3x',
    descripcion:
        'Tres sesiones de cuerpo completo por semana. Perfecto para principiantes y para maximizar la síntesis proteica.',
    tag: 'PRINCIPIANTE',
    diasSemana: 3,
    nivel: 'Principiante',
    minutos: 50,
    intensidad: 2,
    icon: Icons.accessibility_new_rounded,
    color: Color(0xFF00E676),
  ),
  _ProgramaData(
    nombre: 'PHUL — Power Hypertrophy',
    descripcion:
        'Combina días de fuerza máxima con días de hipertrofia. Programa avanzado para ganar masa y fuerza simultáneamente.',
    tag: 'AVANZADO',
    diasSemana: 4,
    nivel: 'Avanzado',
    minutos: 80,
    intensidad: 5,
    icon: Icons.bolt_rounded,
    color: Color(0xFFFF9500),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class RutinasPredeterminadasScreen extends StatefulWidget {
  /// [standaloneMode] = true cuando se navega desde el Home con Navigator.push.
  /// = false cuando vive dentro del tab de Rutinas (AppShell ya provee Scaffold).
  final bool standaloneMode;

  const RutinasPredeterminadasScreen({super.key, this.standaloneMode = false});

  @override
  State<RutinasPredeterminadasScreen> createState() =>
      _RutinasPredeterminadasScreenState();
}

class _RutinasPredeterminadasScreenState
    extends State<RutinasPredeterminadasScreen> {
  int _catIndex = 0;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ───────────────────────────────────────────────────────
        // Botón atrás solo en modo standalone
        if (widget.standaloneMode)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.steamGray.withOpacity(0.08)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.steamGray, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rutinas Predeterminadas',
                          style: TextStyle(
                            color: AppColors.steamGray,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          )),
                      Text('5 PROGRAMAS DISPONIBLES',
                          style: TextStyle(
                            color: AppColors.cyberLime,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cyberLime.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.cyberLime.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.cyberLime,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rutinas Predeterminadas',
                    style: TextStyle(
                      color: AppColors.steamGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_programas.length} programas disponibles',
                    style: TextStyle(
                      color: AppColors.cyberLime.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ── Filtros ───────────────────────────────────────────────────────
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _categorias.length,
            itemBuilder: (context, i) {
              final active = _catIndex == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _catIndex = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.cyberLime
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? AppColors.cyberLime
                          : AppColors.steamGray.withOpacity(0.12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _categorias[i],
                      style: TextStyle(
                        color: active
                            ? AppColors.carbonBlack
                            : AppColors.steamGray.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // ── Sección populares ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.cyberLime,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyberLime.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PROGRAMAS POPULARES',
                style: TextStyle(
                  color: AppColors.steamGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // ── Lista de programas ────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            physics: const BouncingScrollPhysics(),
            itemCount: _programas.length,
            itemBuilder: (context, i) =>
                _ProgramaCard(data: _programas[i]),
          ),
        ),
      ],
    );

    // En modo standalone (abierto desde Home con Navigator.push)
    // necesita su propio Scaffold con fondo oscuro.
    if (widget.standaloneMode) {
      return Scaffold(
        backgroundColor: AppColors.carbonBlack,
        body: content,
      );
    }

    // Dentro del tab de Rutinas: devuelve el Column directo
    // (el Scaffold lo provee AppShell).
    return content;
  }
}

// ─── Programa Card ────────────────────────────────────────────────────────────
class _ProgramaCard extends StatefulWidget {
  final _ProgramaData data;

  const _ProgramaCard({required this.data});

  @override
  State<_ProgramaCard> createState() => _ProgramaCardState();
}

class _ProgramaCardState extends State<_ProgramaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); HapticFeedback.lightImpact(); },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: d.color.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: d.color.withOpacity(0.06),
                blurRadius: 16,
                spreadRadius: 1,
              ),
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icono ─────────────────────────────────────────────────
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: d.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: d.color.withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: d.color.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(d.icon, color: d.color, size: 26),
              ),
              const SizedBox(width: 14),
              // ── Contenido ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: d.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: d.color.withOpacity(0.3)),
                      ),
                      child: Text(
                        d.tag,
                        style: TextStyle(
                          color: d.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      d.nombre,
                      style: const TextStyle(
                        color: AppColors.steamGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.descripcion,
                      style: TextStyle(
                        color: AppColors.steamGray.withOpacity(0.45),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Chips de info
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _InfoDot(
                          label: '${d.diasSemana} días / semana',
                          color: d.color,
                        ),
                        _InfoDot(label: d.nivel, color: d.color),
                        _InfoDot(label: '~${d.minutos} min', color: d.color),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Barra de intensidad
                    _IntensityBar(
                      value: d.intensidad,
                      color: d.color,
                    ),
                  ],
                ),
              ),
              // ── Flecha ────────────────────────────────────────────────
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: d.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: d.color.withOpacity(0.25)),
                ),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: d.color, size: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoDot extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.steamGray.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _IntensityBar extends StatelessWidget {
  final int value; // 1-5
  final Color color;

  const _IntensityBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: filled ? color : AppColors.steamGray.withOpacity(0.1),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
