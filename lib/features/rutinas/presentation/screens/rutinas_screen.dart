import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'rutinas_creadas_screen.dart';
import 'rutinas_predeterminadas_screen.dart';

// ─── Rutinas Screen ───────────────────────────────────────────────────────────
class RutinasScreen extends StatelessWidget {
  const RutinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _RutinasHeader(),
        const Expanded(child: RutinasCreatedasScreen()),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _RutinasHeader extends StatelessWidget {
  const _RutinasHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceLight, AppColors.carbonBlack],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título + botones ───────────────────────────────────────────────
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Rutinas',
                      style: TextStyle(
                        color: AppColors.steamGray,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Gestiona y entrena con tus programas',
                      style: TextStyle(
                        color: Color(0x73E8E8E8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón + Nueva rutina
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/crear-rutina');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          color: AppColors.carbonBlack, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Nueva',
                        style: TextStyle(
                          color: AppColors.carbonBlack,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Banner explorar programas ──────────────────────────────────────
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RutinasPredeterminadasScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.electricViolet.withOpacity(0.25),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppColors.electricViolet.withOpacity(0.08),
                    AppColors.surface,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.electricViolet.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.explore_outlined,
                      color: AppColors.electricViolet,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explorar programas',
                          style: TextStyle(
                            color: AppColors.steamGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'PPL, Arnold Split, Full Body y más...',
                          style: TextStyle(
                            color: Color(0x60E8E8E8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.electricViolet,
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}