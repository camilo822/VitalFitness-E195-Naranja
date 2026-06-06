import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/exercise_service.dart';

// ─── Información Ejercicio Screen ─────────────────────────────────────────────
class InformacionEjercicioScreen extends StatefulWidget {
  final EjercicioData ejercicio;

  const InformacionEjercicioScreen({super.key, required this.ejercicio});

  @override
  State<InformacionEjercicioScreen> createState() =>
      _InformacionEjercicioScreenState();
}

class _InformacionEjercicioScreenState
    extends State<InformacionEjercicioScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
    _fadeAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Color get _nivelColor {
    switch (widget.ejercicio.nivel) {
      case 'PRINCIPIANTE':
        return const Color(0xFF00D4FF);
      case 'AVANZADO':
        return Colors.redAccent;
      default:
        return AppColors.electricViolet;
    }
  }

  Color get _cardColor => Color(
      EjercicioData.colorForBodyPart(widget.ejercicio.musculos.toLowerCase()));

  @override
  Widget build(BuildContext context) {
    final e = widget.ejercicio;
    final color = _cardColor;

    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero imagen ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Imagen local del ejercicio
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: Image.asset(
                      e.imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              color.withOpacity(0.15),
                              AppColors.carbonBlack,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: color.withOpacity(0.15),
                            size: 120,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradiente inferior sobre la imagen
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.carbonBlack,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Gradiente lateral izquierdo para oscurecer bordes
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.carbonBlack.withOpacity(0.3),
                            Colors.transparent,
                            Colors.transparent,
                            AppColors.carbonBlack.withOpacity(0.3),
                          ],
                          stops: const [0, 0.15, 0.85, 1],
                        ),
                      ),
                    ),
                  ),
                  // Línea inferior decorativa con color del grupo
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            color.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Botón atrás
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.carbonBlack.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.steamGray.withOpacity(0.15)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.steamGray,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Contenido ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      e.nombre,
                      style: const TextStyle(
                        color: AppColors.steamGray,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: color, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          e.musculo,
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Fila nivel + equipo
                    Row(
                      children: [
                        // Dificultad badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _nivelColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _nivelColor.withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bar_chart_rounded,
                                  color: _nivelColor, size: 15),
                              const SizedBox(width: 5),
                              Text(
                                _capitalizar(e.nivel),
                                style: TextStyle(
                                  color: _nivelColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Equipo badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.steamGray.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fitness_center_rounded,
                                  color: AppColors.steamGray.withOpacity(0.5),
                                  size: 14),
                              const SizedBox(width: 5),
                              Text(
                                e.equipo,
                                style: TextStyle(
                                  color: AppColors.steamGray.withOpacity(0.65),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),

                    // ── Qué trabaja ────────────────────────────────────
                    _SectionLabel(label: 'QUÉ TRABAJA', color: color),
                    const SizedBox(height: 10),
                    _MuscleRow(
                      principal: e.musculo,
                      secundarios: e.musculosSecundarios,
                      color: color,
                    ),
                    const SizedBox(height: 24),

                    // ── Instrucciones ──────────────────────────────────
                    _SectionLabel(label: 'INSTRUCCIONES', color: color),
                    const SizedBox(height: 10),
                    ...e.instrucciones.asMap().entries.map((entry) =>
                        _InstruccionItem(
                          numero: entry.key + 1,
                          texto: entry.value,
                          color: color,
                        )),
                    const SizedBox(height: 28),

                    // ── Botón agregar a rutina ─────────────────────────
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: color,
                            content: Text(
                              '✅ ${e.nombre} agregado a tu rutina',
                              style: const TextStyle(
                                color: AppColors.carbonBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_rounded,
                                color: AppColors.carbonBlack, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'AGREGAR A RUTINA',
                              style: TextStyle(
                                color: AppColors.carbonBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizar(String s) {
    if (s.isEmpty) return s;
    final lower = s.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: AppColors.steamGray.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _MuscleRow extends StatelessWidget {
  final String principal;
  final List<String> secundarios;
  final Color color;

  const _MuscleRow({
    required this.principal,
    required this.secundarios,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MuscleItem(label: principal, isPrincipal: true, color: color),
        ...secundarios
            .map((s) => _MuscleItem(label: s, isPrincipal: false, color: color)),
      ],
    );
  }
}

class _MuscleItem extends StatelessWidget {
  final String label;
  final bool isPrincipal;
  final Color color;

  const _MuscleItem({
    required this.label,
    required this.isPrincipal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrincipal
              ? color.withOpacity(0.25)
              : AppColors.steamGray.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrincipal
                  ? color
                  : AppColors.steamGray.withOpacity(0.35),
              boxShadow: isPrincipal
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isPrincipal
                  ? AppColors.steamGray
                  : AppColors.steamGray.withOpacity(0.5),
              fontSize: 13,
              fontWeight: isPrincipal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          if (isPrincipal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'PRINCIPAL',
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InstruccionItem extends StatelessWidget {
  final int numero;
  final String texto;
  final Color color;

  const _InstruccionItem({
    required this.numero,
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.steamGray.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '$numero',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: AppColors.steamGray.withOpacity(0.7),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}