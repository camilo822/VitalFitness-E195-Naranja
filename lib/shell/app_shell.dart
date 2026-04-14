import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vital_fitness/core/theme/app_colors.dart';
import 'package:vital_fitness/features/auth/data/services/auth_service.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/rutinas/presentation/screens/rutinas_screen.dart';
import '../features/progreso/presentation/screens/progreso_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/admin/presentation/screens/admin_ejercicios_screen.dart';
import '../features/admin/presentation/screens/admin_rutinas_screen.dart';

// ─── App Shell ────────────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  UserRole _role = UserRole.user;
  bool _roleLoaded = false;

  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Páginas usuario normal ─────────────────────────────────────────────────
  static const List<Widget> _userPages = [
    HomeScreen(),
    RutinasScreen(),
    ProgresoScreen(),
    ProfileScreen(),
  ];

  // ── Páginas admin ──────────────────────────────────────────────────────────
  // [0] badge ADMIN  [1] Ejercicios  [2] Rutinas
  static const List<Widget> _adminPages = [
    _AdminBadgeScreen(),         // placeholder visual para el tab "ADMIN"
    AdminEjerciciosScreen(),
    AdminRutinasScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await AuthService().getCurrentUserRole();
    if (mounted) setState(() { _role = role; _roleLoaded = true; });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    HapticFeedback.selectionClick();
    if (_navIndex == index) return;
    setState(() => _navIndex = index);
  }

  bool get _isAdmin => _role == UserRole.admin;

  List<Widget> get _pages => _isAdmin ? _adminPages : _userPages;

  @override
  Widget build(BuildContext context) {
    if (!_roleLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.carbonBlack,
        body: Center(
          child: CircularProgressIndicator(
              color: AppColors.cyberLime, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: Stack(
        children: [
          _GlobalBackground(size: MediaQuery.of(context).size),
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: IndexedStack(index: _navIndex, children: _pages),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              top: false,
              child: _isAdmin
                  ? _AdminNavBar(currentIndex: _navIndex, onTap: _onTabTap)
                  : _UserNavBar(currentIndex: _navIndex, onTap: _onTabTap),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── User Nav Bar ─────────────────────────────────────────────────────────────
class _UserNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _UserNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,           label: 'Home'),
    _NavItem(icon: Icons.fitness_center_outlined,activeIcon: Icons.fitness_center_rounded, label: 'Rutinas'),
    _NavItem(icon: Icons.show_chart_rounded,     activeIcon: Icons.show_chart_rounded,     label: 'Progreso'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,         label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return _NavBarContainer(
      items: _items,
      currentIndex: currentIndex,
      onTap: onTap,
      accentColor: AppColors.cyberLime,
    );
  }
}

// ─── Admin Nav Bar ────────────────────────────────────────────────────────────
class _AdminNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AdminNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.shield_outlined,       activeIcon: Icons.shield_rounded,    label: 'Admin',      isAdmin: true),
    _NavItem(icon: Icons.fitness_center_outlined,activeIcon: Icons.fitness_center_rounded, label: 'Ejercicios', isAdmin: true),
    _NavItem(icon: Icons.list_alt_outlined,      activeIcon: Icons.list_alt_rounded,  label: 'Rutinas',    isAdmin: true),
  ];

  @override
  Widget build(BuildContext context) {
    return _NavBarContainer(
      items: _items,
      currentIndex: currentIndex,
      onTap: onTap,
      accentColor: Colors.redAccent,
    );
  }
}

// ─── NavBar Container (reutilizable) ─────────────────────────────────────────
class _NavBarContainer extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;

  const _NavBarContainer({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.steamGray.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: accentColor.withOpacity(0.06), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = i == currentIndex;
            final item = items[i];
            return GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); onTap(i); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? accentColor.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: active ? accentColor.withOpacity(0.3) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        active ? item.activeIcon : item.icon,
                        key: ValueKey(active),
                        color: active ? accentColor : AppColors.steamGray.withOpacity(0.4),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: active ? accentColor : AppColors.steamGray.withOpacity(0.35),
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Nav Item model ───────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isAdmin;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isAdmin = false,
  });
}

// ─── Admin Badge Screen (tab 0 del admin) ────────────────────────────────────
class _AdminBadgeScreen extends StatelessWidget {
  const _AdminBadgeScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withOpacity(0.1),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.redAccent, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('PANEL ADMINISTRADOR',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              )),
          const SizedBox(height: 8),
          Text('Selecciona una sección en el menú',
              style: TextStyle(
                color: AppColors.steamGray.withOpacity(0.35),
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}

// ─── Background ───────────────────────────────────────────────────────────────
class _GlobalBackground extends StatelessWidget {
  final Size size;
  const _GlobalBackground({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100, right: -80,
          child: _GlowOrb(color: AppColors.electricViolet.withOpacity(0.20), size: 300),
        ),
        Positioned(
          top: size.height * 0.45, left: -100,
          child: _GlowOrb(color: AppColors.cyberLime.withOpacity(0.07), size: 260),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
