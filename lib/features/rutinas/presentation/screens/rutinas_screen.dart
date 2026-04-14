import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'rutinas_creadas_screen.dart';
import 'rutinas_predeterminadas_screen.dart';

// ─── Rutinas Screen (Tab container) ──────────────────────────────────────────
class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> {
  int _tabIndex = 0; // 0 = Mis Rutinas, 1 = Predeterminadas

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RutinasHeader(
          tabIndex: _tabIndex,
          onTabChanged: (i) {
            HapticFeedback.selectionClick();
            setState(() => _tabIndex = i);
          },
        ),
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: const [
              RutinasCreatedasScreen(),
              RutinasPredeterminadasScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Header con toggle tab ────────────────────────────────────────────────────
class _RutinasHeader extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  const _RutinasHeader({
    required this.tabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mis Rutinas',
                    style: TextStyle(
                      color: AppColors.steamGray,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gestiona y entrena con tus programas',
                    style: TextStyle(
                      color: AppColors.steamGray.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              // Botón + Nueva (solo visible en tab "Mis Rutinas")
              AnimatedOpacity(
                opacity: tabIndex == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: tabIndex == 0
                      ? () => Navigator.pushNamed(context, '/crear-rutina')
                      : null,
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
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Tab toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.steamGray.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                _TabButton(
                  label: 'Creadas por mí',
                  active: tabIndex == 0,
                  onTap: () => onTabChanged(0),
                ),
                _TabButton(
                  label: 'Predeterminadas',
                  active: tabIndex == 1,
                  onTap: () => onTabChanged(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.cyberLime : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.cyberLime.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active
                    ? AppColors.carbonBlack
                    : AppColors.steamGray.withOpacity(0.45),
                fontSize: 13,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
