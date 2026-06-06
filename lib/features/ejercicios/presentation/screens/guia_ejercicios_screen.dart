import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'lista_ejercicios_screen.dart';

// ─── Modelo ───────────────────────────────────────────────────────────────────
class _GrupoMuscular {
  final String nombre;
  final int cantidad;
  final Color color;
  final String id;
  final String imagePath;

  const _GrupoMuscular({
    required this.nombre,
    required this.cantidad,
    required this.color,
    required this.id,
    required this.imagePath,
  });
}

const _grupos = [
  _GrupoMuscular(
    id: 'pecho',
    nombre: 'Pecho',
    cantidad: 18,
    color: AppColors.cyberLime,
    imagePath: 'assets/images/pecho.png',
  ),
  _GrupoMuscular(
    id: 'espalda',
    nombre: 'Espalda',
    cantidad: 22,
    color: Color(0xFF00D4FF),
    imagePath: 'assets/images/espalda.png',
  ),
  _GrupoMuscular(
    id: 'piernas',
    nombre: 'Piernas',
    cantidad: 31,
    color: AppColors.electricViolet,
    imagePath: 'assets/images/pierna.png',
  ),
  _GrupoMuscular(
    id: 'hombros',
    nombre: 'Hombros',
    cantidad: 14,
    color: AppColors.cyberLime,
    imagePath: 'assets/images/hombro.png',
  ),
  _GrupoMuscular(
    id: 'biceps',
    nombre: 'Bíceps',
    cantidad: 12,
    color: Color(0xFF00D4FF),
    imagePath: 'assets/images/biceps.png',
  ),
  _GrupoMuscular(
    id: 'triceps',
    nombre: 'Tríceps',
    cantidad: 10,
    color: AppColors.electricViolet,
    imagePath: 'assets/images/triceps.png',
  ),
  _GrupoMuscular(
    id: 'abdomen',
    nombre: 'Abdomen',
    cantidad: 16,
    color: AppColors.cyberLime,
    imagePath: 'assets/images/abdomen.png',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class GuiaEjerciciosScreen extends StatefulWidget {
  const GuiaEjerciciosScreen({super.key});

  @override
  State<GuiaEjerciciosScreen> createState() => _GuiaEjerciciosScreenState();
}

class _GuiaEjerciciosScreenState extends State<GuiaEjerciciosScreen>
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

  int get _totalEjercicios =>
      _grupos.fold(0, (sum, g) => sum + g.cantidad);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _SectionLabel(label: 'GRUPOS MUSCULARES'),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: _grupos.length,
                      itemBuilder: (context, i) =>
                          _GrupoCard(grupo: _grupos[i]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Botón back si vino de algún lado
          if (Navigator.canPop(context))
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.steamGray.withOpacity(0.08)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.steamGray, size: 16),
              ),
            ),
          if (Navigator.canPop(context)) const SizedBox(width: 14),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.25)),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Color(0xFF00D4FF), size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Guía de ejercicios',
                style: TextStyle(
                  color: AppColors.steamGray,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$_totalEjercicios ejercicios · ${_grupos.length} grupos musculares',
                style: const TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Grupo Card ───────────────────────────────────────────────────────────────
class _GrupoCard extends StatefulWidget {
  final _GrupoMuscular grupo;

  const _GrupoCard({required this.grupo});

  @override
  State<_GrupoCard> createState() => _GrupoCardState();
}

class _GrupoCardState extends State<_GrupoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.grupo;

    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); HapticFeedback.lightImpact(); },
      onTapUp: (_) {
        _ctrl.reverse();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListaEjerciciosScreen(
              grupoId: g.id,
              grupoNombre: g.nombre,
              color: g.color,
              cantidad: g.cantidad,
            ),
          ),
        );
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: g.color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: g.color.withOpacity(0.08),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Imagen de fondo del grupo muscular ──
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.18,
                    child: Image.asset(
                      g.imagePath,
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                // ── Imagen centrada visible ──
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: g.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: g.color.withOpacity(0.15)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset(
                        g.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.fitness_center_rounded,
                          color: g.color,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Contenido texto ──
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        g.nombre,
                        style: const TextStyle(
                          color: AppColors.steamGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${g.cantidad} ejercicios',
                        style: TextStyle(
                          color: g.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Barra inferior decorativa
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              g.color.withOpacity(0.6),
                              g.color.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Flecha esquina inferior derecha ──
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: g.color.withOpacity(0.5),
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets reutilizables ────────────────────────────────────────────────────
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
