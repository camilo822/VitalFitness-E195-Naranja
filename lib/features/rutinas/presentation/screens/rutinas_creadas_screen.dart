import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/rutina_service.dart';

// ─── Rutinas Creadas Screen ────────────────────────────────────────────────────
class RutinasCreatedasScreen extends StatelessWidget {
  const RutinasCreatedasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RutinaModel>>(
      stream: RutinaService.rutinasStream(),
      builder: (context, snapshot) {
        // ── Loading ──────────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.cyberLime,
              strokeWidth: 2,
            ),
          );
        }

        // ── Error ────────────────────────────────────────────────────────────
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded,
                    color: AppColors.steamGray.withOpacity(0.3), size: 48),
                const SizedBox(height: 12),
                Text(
                  'Error al cargar rutinas',
                  style: TextStyle(
                      color: AppColors.steamGray.withOpacity(0.5),
                      fontSize: 14),
                ),
              ],
            ),
          );
        }

        final rutinas = snapshot.data ?? [];

        // ── Estado vacío ─────────────────────────────────────────────────────
        if (rutinas.isEmpty) {
          return _EmptyState(
            onCrear: () => Navigator.pushNamed(context, '/crear-rutina'),
          );
        }

        // ── Lista ────────────────────────────────────────────────────────────
        final activas = rutinas.where((r) => r.activa).length;
        // Cuenta solo las usadas esta semana (aproximación: activas recientes)
        final estaSemana = rutinas
            .where((r) =>
                DateTime.now().difference(r.creadaEn).inDays < 7)
            .length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── Stats row ───────────────────────────────────────────────────
            _StatsRow(
              total: rutinas.length,
              activas: activas,
              estaSemana: estaSemana,
            ),
            const SizedBox(height: 16),
            // ── Tarjetas ────────────────────────────────────────────────────
            ...rutinas.map((r) => _RutinaCard(rutina: r)),
          ],
        );
      },
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int total;
  final int activas;
  final int estaSemana;

  const _StatsRow({
    required this.total,
    required this.activas,
    required this.estaSemana,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBadge(
            value: '$total',
            label: 'Total rutinas',
            color: AppColors.cyberLime),
        const SizedBox(width: 10),
        _StatBadge(
            value: '$activas',
            label: 'Activas',
            color: AppColors.electricViolet),
        const SizedBox(width: 10),
        _StatBadge(
            value: '$estaSemana',
            label: 'Esta semana',
            color: const Color(0xFF00D4FF)),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.steamGray.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rutina Card ──────────────────────────────────────────────────────────────
class _RutinaCard extends StatefulWidget {
  final RutinaModel rutina;

  const _RutinaCard({required this.rutina});

  @override
  State<_RutinaCard> createState() => _RutinaCardState();
}

class _RutinaCardState extends State<_RutinaCard>
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

  Color get _accentColor {
    switch (widget.rutina.categoria.toLowerCase()) {
      case 'hipertrofia':
        return AppColors.cyberLime;
      case 'resistencia':
        return const Color(0xFFFF9500);
      case 'volumen':
        return const Color(0xFF00D4FF);
      default:
        return AppColors.electricViolet; // fuerza
    }
  }

  String _ultimaVez() {
    final diff = DateTime.now().difference(widget.rutina.creadaEn);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Hace 1 día';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return 'Hace ${(diff.inDays / 7).floor()} semana(s)';
  }

  void _showOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.steamGray.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Activar / Desactivar
            ListTile(
              leading: Icon(
                widget.rutina.activa
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                color: AppColors.cyberLime,
              ),
              title: Text(
                widget.rutina.activa ? 'Desactivar rutina' : 'Marcar como activa',
                style: const TextStyle(color: AppColors.steamGray),
              ),
              onTap: () async {
                Navigator.pop(context);
                await RutinaService.toggleActiva(
                    widget.rutina.id, !widget.rutina.activa);
              },
            ),
            // Eliminar
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent),
              title: const Text('Eliminar rutina',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Eliminar rutina',
                        style: TextStyle(color: AppColors.steamGray)),
                    content: Text(
                      '¿Eliminar "${widget.rutina.nombre}"? Esta acción no se puede deshacer.',
                      style: TextStyle(
                          color: AppColors.steamGray.withOpacity(0.6)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar',
                            style: TextStyle(color: AppColors.steamGray)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await RutinaService.eliminarRutina(widget.rutina.id);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.rutina;
    final accent = _accentColor;
    const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
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
              color: r.activa
                  ? accent.withOpacity(0.4)
                  : AppColors.steamGray.withOpacity(0.07),
              width: r.activa ? 1.5 : 1,
            ),
            boxShadow: r.activa
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row ────────────────────────────────────────────────
              Row(
                children: [
                  if (r.activa)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cyberLime.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.cyberLime.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cyberLime,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyberLime.withOpacity(0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'ACTIVA',
                            style: TextStyle(
                              color: AppColors.cyberLime,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (r.esPredeterminada)
                    Container(
                      margin: EdgeInsets.only(left: r.activa ? 8 : 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: accent.withOpacity(0.3)),
                      ),
                      child: Text(
                        'PREDETERMINADA',
                        style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showOptions(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: AppColors.steamGray.withOpacity(0.08),
                        ),
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.steamGray.withOpacity(0.4),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Nombre + categoría ────────────────────────────────────
              Text(
                r.nombre,
                style: const TextStyle(
                  color: AppColors.steamGray,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                r.categoria[0].toUpperCase() + r.categoria.substring(1),
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              // ── Días ──────────────────────────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.steamGray.withOpacity(0.35),
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  ...List.generate(7, (i) {
                    final activo = r.diasActivos[i];
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activo
                            ? accent.withOpacity(0.2)
                            : AppColors.surfaceLight,
                        border: Border.all(
                          color: activo
                              ? accent.withOpacity(0.6)
                              : AppColors.steamGray.withOpacity(0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          dias[i],
                          style: TextStyle(
                            color: activo
                                ? accent
                                : AppColors.steamGray.withOpacity(0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),
              // ── Footer ────────────────────────────────────────────────
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.fitness_center_rounded,
                    label: '${r.ejercicios.length} ejercicios',
                    color: AppColors.steamGray.withOpacity(0.4),
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '~${r.minutos} min',
                    color: AppColors.steamGray.withOpacity(0.4),
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.history_rounded,
                    label: _ultimaVez(),
                    color: AppColors.steamGray.withOpacity(0.4),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => HapticFeedback.mediumImpact(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: AppColors.carbonBlack, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Iniciar',
                            style: TextStyle(
                              color: AppColors.carbonBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onCrear;

  const _EmptyState({required this.onCrear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.cyberLime.withOpacity(0.2),
                ),
              ),
              child: Icon(
                Icons.fitness_center_outlined,
                color: AppColors.cyberLime.withOpacity(0.5),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin rutinas aún',
              style: TextStyle(
                color: AppColors.steamGray,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera rutina personalizada\no elige una predeterminada',
              style: TextStyle(
                color: AppColors.steamGray.withOpacity(0.4),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onCrear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cyberLime,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyberLime.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'CREAR RUTINA',
                  style: TextStyle(
                    color: AppColors.carbonBlack,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}