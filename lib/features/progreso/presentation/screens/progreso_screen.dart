import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';

// ─── Progreso Screen ──────────────────────────────────────────────────────────
class ProgresoScreen extends StatefulWidget {
  const ProgresoScreen({super.key});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Mock data actividad semanal (minutos por día: L M X J V S D)
  static const _actividadSemanal = [30.0, 45.0, 30.0, 50.0, 40.0, 75.0, 35.0];
  static const _diasLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _diaActivo = 5; // Sábado resaltado

  // Mock data evolución de peso (últimas 4 semanas)
  static const _pesoData = [74.0, 73.5, 72.8, 72.0];

  // Mock historial
  static const _historial = [
    _HistorialItem(
        nombre: 'Rutina Arnold — Día 1',
        detalle: 'Pecho y Tríceps',
        duracion: 45,
        hace: 'Hace 2 días',
        color: AppColors.electricViolet),
    _HistorialItem(
        nombre: 'Full Body Express',
        detalle: 'Cuerpo completo',
        duracion: 60,
        hace: 'Hace 3 días',
        color: Color(0xFF00D4FF)),
    _HistorialItem(
        nombre: 'PPL — Push Day',
        detalle: 'Empuje',
        duracion: 70,
        hace: 'Hace 5 días',
        color: AppColors.cyberLime),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _fadeAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            // ── Header ─────────────────────────────────────────────────
            _ProgresoHeader(),
            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ── Stats top row ───────────────────────────────────
                  _StatsTopRow(),
                  const SizedBox(height: 20),

                  // ── Actividad semanal ───────────────────────────────
                  _SectionLabel(label: 'ACTIVIDAD SEMANAL'),
                  const SizedBox(height: 10),
                  _ActividadSemanalCard(
                    datos: _actividadSemanal,
                    labels: _diasLabels,
                    diaActivo: _diaActivo,
                  ),
                  const SizedBox(height: 20),

                  // ── Evolución de peso ───────────────────────────────
                  _SectionLabel(label: 'EVOLUCIÓN DE PESO'),
                  const SizedBox(height: 10),
                  _PesoEvolucionCard(datos: _pesoData),
                  const SizedBox(height: 20),

                  // ── Historial ───────────────────────────────────────
                  _SectionLabel(label: 'HISTORIAL DE RUTINAS'),
                  const SizedBox(height: 10),
                  ..._historial.map((h) => _HistorialCard(item: h)),

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _ProgresoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceLight, AppColors.carbonBlack],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cyberLime.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.cyberLime.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyberLime.withOpacity(0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.show_chart_rounded,
                color: AppColors.cyberLime, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mi progreso',
                style: TextStyle(
                  color: AppColors.steamGray,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Semana actual: 3 rutinas completadas',
                style: TextStyle(
                  color: AppColors.cyberLime.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stats Top Row ────────────────────────────────────────────────────────────
class _StatsTopRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const stats = [
      _StatData(value: '12', label: 'RUTINAS', color: AppColors.cyberLime),
      _StatData(value: '4', label: 'SEMANAS', color: Color(0xFF00D4FF)),
      _StatData(value: '72 kg', label: 'PESO', color: AppColors.electricViolet),
      _StatData(value: '-2 kg', label: 'PÉRDIDA', color: AppColors.steamGray),
    ];

    return Row(
      children: stats
          .map((s) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: s.color.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        s.value,
                        style: TextStyle(
                          color: s.color,
                          fontSize: s.value.length > 4 ? 14 : 18,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.label,
                        style: TextStyle(
                          color: AppColors.steamGray.withOpacity(0.35),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _StatData {
  final String value;
  final String label;
  final Color color;

  const _StatData(
      {required this.value, required this.label, required this.color});
}

// ─── Actividad Semanal Card ────────────────────────────────────────────────────
class _ActividadSemanalCard extends StatelessWidget {
  final List<double> datos;
  final List<String> labels;
  final int diaActivo;

  const _ActividadSemanalCard({
    required this.datos,
    required this.labels,
    required this.diaActivo,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = datos.reduce(math.max);
    final diasActivos = datos.where((d) => d > 0).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.steamGray.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Esta semana',
                style: TextStyle(
                  color: AppColors.steamGray.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cyberLime.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.cyberLime.withOpacity(0.3)),
                ),
                child: Text(
                  '$diasActivos/7 días activo',
                  style: const TextStyle(
                    color: AppColors.cyberLime,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Barras
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(datos.length, (i) {
                final isActive = i == diaActivo;
                final heightFrac = maxVal > 0 ? datos[i] / maxVal : 0.0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: heightFrac.clamp(0.08, 1.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: isActive
                                  ? AppColors.cyberLime
                                  : AppColors.cyberLime.withOpacity(0.35),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.cyberLime
                                            .withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(labels.length, (i) {
              final isActive = i == diaActivo;
              return Text(
                labels[i],
                style: TextStyle(
                  color: isActive
                      ? AppColors.cyberLime
                      : AppColors.steamGray.withOpacity(0.35),
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Peso Evolución Card ──────────────────────────────────────────────────────
class _PesoEvolucionCard extends StatelessWidget {
  final List<double> datos;

  const _PesoEvolucionCard({required this.datos});

  @override
  Widget build(BuildContext context) {
    final diferencia = datos.last - datos.first;
    final diferenciaStr = diferencia < 0
        ? '${diferencia.toStringAsFixed(1)} kg'
        : '+${diferencia.toStringAsFixed(1)} kg';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.steamGray.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimas 4 semanas',
                style: TextStyle(
                  color: AppColors.steamGray.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.trending_down_rounded,
                    color: AppColors.cyberLime,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    diferenciaStr,
                    style: const TextStyle(
                      color: AppColors.cyberLime,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Gráfica de línea custom
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _LineChartPainter(
                datos: datos,
                color: AppColors.cyberLime,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(datos.length, (i) {
              return Text(
                'Sem ${i + 1}',
                style: TextStyle(
                  color: AppColors.steamGray.withOpacity(0.35),
                  fontSize: 10,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Line Chart Painter ───────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> datos;
  final Color color;

  const _LineChartPainter({required this.datos, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (datos.isEmpty) return;

    final minVal = datos.reduce(math.min) - 1;
    final maxVal = datos.reduce(math.max) + 1;
    final range = maxVal - minVal;

    // Calcula puntos
    final points = List.generate(datos.length, (i) {
      final x = i / (datos.length - 1) * size.width;
      final y = size.height -
          ((datos[i] - minVal) / range * size.height * 0.85) -
          size.height * 0.075;
      return Offset(x, y);
    });

    // Path del área rellena
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final prev = points[i - 1];
        final curr = points[i];
        final cp1 = Offset(prev.dx + (curr.dx - prev.dx) / 2, prev.dy);
        final cp2 = Offset(prev.dx + (curr.dx - prev.dx) / 2, curr.dy);
        fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Path de la línea
    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        final prev = points[i - 1];
        final curr = points[i];
        final cp1 = Offset(prev.dx + (curr.dx - prev.dx) / 2, prev.dy);
        final cp2 = Offset(prev.dx + (curr.dx - prev.dx) / 2, curr.dy);
        linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Punto final
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(points.last, 8, glowPaint);
    canvas.drawCircle(points.last, 5, dotPaint);
    canvas.drawCircle(
        points.last,
        3,
        Paint()
          ..color = AppColors.carbonBlack
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Historial Card ───────────────────────────────────────────────────────────
class _HistorialCard extends StatelessWidget {
  final _HistorialItem item;

  const _HistorialCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: item.color.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(Icons.fitness_center_rounded,
                color: item.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: const TextStyle(
                    color: AppColors.steamGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.detalle,
                  style: TextStyle(
                    color: AppColors.steamGray.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.hace,
                style: TextStyle(
                  color: AppColors.steamGray.withOpacity(0.35),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${item.duracion} min',
                  style: TextStyle(
                    color: item.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Modelos ──────────────────────────────────────────────────────────────────
class _HistorialItem {
  final String nombre;
  final String detalle;
  final int duracion;
  final String hace;
  final Color color;

  const _HistorialItem({
    required this.nombre,
    required this.detalle,
    required this.duracion,
    required this.hace,
    required this.color,
  });
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.steamGray,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
