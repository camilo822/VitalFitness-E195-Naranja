import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vital_fitness/core/theme/app_colors.dart';
import '../../../../core/painters/hex_painter.dart';
import '../../../../core/widgets/pulse_ring.dart';
import '../../../../features/rutinas/presentation/screens/rutinas_predeterminadas_screen.dart';
import '../../../../features/rutinas/presentation/screens/crear_rutina_screen.dart';
import '../../../../features/ejercicios/presentation/screens/guia_ejercicios_screen.dart';

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _HomeHeader(),
        Expanded(child: _HomeBody()),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _HomeHeader extends StatefulWidget {
  const _HomeHeader();

  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  final _uid     = FirebaseAuth.instance.currentUser?.uid;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    if (_uid != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .snapshots();
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  String _resolveName(Map<String, dynamic>? data) {
    final fromFirestore = data?['displayName'] as String?;
    if (fromFirestore != null && fromFirestore.trim().isNotEmpty) {
      return fromFirestore.trim();
    }
    final user = FirebaseAuth.instance.currentUser;
    final fromAuth = user?.displayName;
    if (fromAuth != null && fromAuth.trim().isNotEmpty) return fromAuth.trim();
    final email = user?.email ?? '';
    return email.split('@').first;
  }

  String _resolvePhotoUrl(Map<String, dynamic>? data) =>
      data?['photoUrl'] as String? ?? '';

  String _initials(String name) {
    return name.trim().split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        final data     = snapshot.data?.data();
        final name     = _resolveName(data);
        final photoUrl = _resolvePhotoUrl(data);
        final initials = _initials(name);

        return AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) => Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.surfaceLight, AppColors.carbonBlack],
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    PulseRing(size: 62, color: AppColors.cyberLime),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cyberLime
                              .withOpacity(_glowAnim.value * 0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyberLime
                                .withOpacity(_glowAnim.value * 0.4),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatarContent(photoUrl, initials),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hola, ',
                            style: TextStyle(
                              color: AppColors.steamGray.withOpacity(0.6),
                              fontSize: 15,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.steamGray,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('💪', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Listo para el entrenamiento de hoy',
                        style: TextStyle(
                          color: AppColors.cyberLime,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarContent(String photoUrl, String initials) {
    if (photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        width: 52, height: 52, fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _initialsWidget(initials),
        errorBuilder: (_, __, ___) => _initialsWidget(initials),
      );
    }
    return _initialsWidget(initials);
  }

  Widget _initialsWidget(String initials) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.electricViolet.withOpacity(0.8),
          AppColors.electricViolet.withOpacity(0.4),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: AppColors.steamGray,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        const _SectionTitle('¿QUÉ HAREMOS HOY?'),
        ...List.generate(
          _cards.length,
          (i) => _FeatureCard(data: _cards[i], index: i),
        ),
        const SizedBox(height: 110),
      ],
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 4),
      child: Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
              color: AppColors.cyberLime,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                    color: AppColors.cyberLime.withOpacity(0.6),
                    blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                color: AppColors.steamGray,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              )),
        ],
      ),
    );
  }
}

// ─── Card Data ────────────────────────────────────────────────────────────────
class _CardData {
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final Color accentColor;
  final List<Color> gradientColors;

  const _CardData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    required this.accentColor,
    required this.gradientColors,
  });
}

const _cards = [
  _CardData(
    title: 'Rutinas\nPredeterminadas',
    subtitle: '24 programas listos para ti',
    tag: 'POPULAR',
    icon: Icons.fitness_center_rounded,
    iconColor: AppColors.cyberLime,
    glowColor: AppColors.cyberLime,
    accentColor: AppColors.cyberLime,
    gradientColors: [Color(0xFF232325), Color(0xFF1E2410)],
  ),
  _CardData(
    title: 'Crea tu\nPropia Rutina',
    subtitle: 'Diseña entrenamientos a medida',
    tag: 'CREAR',
    icon: Icons.add_circle_outline_rounded,
    iconColor: AppColors.electricViolet,
    glowColor: AppColors.electricViolet,
    accentColor: AppColors.electricViolet,
    gradientColors: [Color(0xFF232325), Color(0xFF1A1428)],
  ),
  _CardData(
    title: 'Guía de\nEjercicios',
    subtitle: '200+ ejercicios con instrucciones',
    tag: 'GUÍA',
    icon: Icons.menu_book_rounded,
    iconColor: Color(0xFF00D4FF),
    glowColor: Color(0xFF00D4FF),
    accentColor: Color(0xFF00D4FF),
    gradientColors: [Color(0xFF232325), Color(0xFF0F1E22)],
  ),
];

// ─── Feature Card ─────────────────────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final _CardData data;
  final int index;
  const _FeatureCard({required this.data, required this.index});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ─── Navegación correcta por tarjeta ──────────────────────────────────────
  void _onTap(BuildContext context) {
    HapticFeedback.mediumImpact();
    switch (widget.index) {
      case 0: // Rutinas Predeterminadas
        Navigator.push(
          context,
          MaterialPageRoute(
            // standaloneMode: true → la pantalla usa su propio Scaffold oscuro
            builder: (_) => const RutinasPredeterminadasScreen(standaloneMode: true),
          ),
        );
        break;
      case 1: // Crear Rutina
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CrearRutinaScreen()),
        );
        break;
      case 2: // Guía de Ejercicios
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GuiaEjerciciosScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _ctrl.reverse();
        _onTap(context);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _ctrl.reverse();
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: d.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _pressed
                  ? d.accentColor.withOpacity(0.7)
                  : d.accentColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: d.glowColor.withOpacity(_pressed ? 0.28 : 0.1),
                blurRadius: _pressed ? 28 : 16,
                spreadRadius: _pressed ? 2 : 0,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Color(0xFF000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                      painter: HexPainter(color: d.accentColor)),
                ),
                Positioned(
                  top: -30, right: -30,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        d.glowColor.withOpacity(0.15),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 16, 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _Pseudo3DIcon(
                        icon: d.icon,
                        primaryColor: d.iconColor,
                        glowColor: d.glowColor,
                        size: 46,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: d.accentColor.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: d.accentColor.withOpacity(0.35),
                                    width: 1),
                              ),
                              child: Text(d.tag,
                                  style: TextStyle(
                                    color: d.accentColor,
                                    fontSize: 9,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                            const SizedBox(height: 8),
                            Text(d.title,
                                style: const TextStyle(
                                  color: AppColors.steamGray,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  letterSpacing: 0.3,
                                )),
                            const SizedBox(height: 6),
                            Text(d.subtitle,
                                style: TextStyle(
                                  color: AppColors.steamGray.withOpacity(0.45),
                                  fontSize: 12,
                                  letterSpacing: 0.2,
                                )),
                          ],
                        ),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: d.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: d.accentColor.withOpacity(0.25),
                              width: 1),
                        ),
                        child: Icon(Icons.arrow_forward_ios_rounded,
                            color: d.accentColor, size: 15),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        d.accentColor.withOpacity(0.6),
                        Colors.transparent,
                      ]),
                    ),
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

// ─── Icono 3D ─────────────────────────────────────────────────────────────────
class _Pseudo3DIcon extends StatelessWidget {
  final IconData icon;
  final Color primaryColor;
  final Color glowColor;
  final double size;

  const _Pseudo3DIcon({
    required this.icon,
    required this.primaryColor,
    required this.glowColor,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 16, height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 6, left: 6,
            child: Icon(icon, size: size, color: glowColor.withOpacity(0.25)),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: glowColor.withOpacity(0.45),
                    blurRadius: 20,
                    spreadRadius: 2),
              ],
            ),
            child: Icon(icon, size: size, color: primaryColor),
          ),
        ],
      ),
    );
  }
}
