import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/painters/grid_painter.dart';
import '../../../../core/widgets/pressable_tile.dart';
import '../../../../features/auth/data/services/auth_service.dart';
import '../../data/services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'privacy_security_screen.dart';

// ─── Profile Screen ───────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final AuthService    _authService    = AuthService();
  final ProfileService _profileService = ProfileService();

  late AnimationController _entryCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>  _fadeAnim;
  late Animation<Offset>  _slideAnim;
  late Animation<double>  _pulseAnim;

  // Preview local instantáneo mientras se sube a Cloudinary.
  // Se limpia SOLO cuando Image.network confirma que la nueva foto cargó.
  File?   _localPhotoFile;
  bool    _uploadingPhoto = false;
  // URL que acabamos de subir — la guardamos para saber cuándo Image.network
  // terminó de cargar la versión nueva y poder limpiar el preview local.
  String? _pendingPhotoUrl;

  final List<_MenuOption> _menuOptions = const [
    _MenuOption(
        icon: Icons.person_outline_rounded,
        label: 'Editar perfil',
        trailing: true),
    _MenuOption(
        icon: Icons.lock_outline_rounded,
        label: 'Privacidad y seguridad',
        trailing: true),
  ];

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _getDisplayName(Map<String, dynamic>? data) {
    // Fuente 1: Firestore — nombre guardado al registrarse (la más fiable)
    final fromFirestore = data?['displayName'] as String?;
    if (fromFirestore != null && fromFirestore.trim().isNotEmpty) {
      return fromFirestore.trim();
    }

    // Fuente 2: FirebaseAuth.displayName — puede estar vacío en el primer frame
    final user = FirebaseAuth.instance.currentUser;
    final fromAuth = user?.displayName;
    if (fromAuth != null && fromAuth.trim().isNotEmpty) {
      return fromAuth.trim();
    }

    // Fuente 3: parte del email antes del @ (siempre disponible si hay sesión)
    final fromEmail = user?.email?.split('@').first;
    if (fromEmail != null && fromEmail.trim().isNotEmpty) {
      return fromEmail.trim();
    }

    // Fallback final
    return 'Atleta';
  }

  /// Prioridad: Firestore (guardado por ProfileService) > FirebaseAuth
  String _getPhotoUrl(Map<String, dynamic>? data) {
    return data?['photoUrl'] as String? ??
        FirebaseAuth.instance.currentUser?.photoURL ??
        '';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }

  // ─── Photo picker ─────────────────────────────────────────────────────────

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PhotoOptionsSheet(
        onGallery: () async {
          Navigator.pop(context);
          final xfile = await _profileService.pickFromGallery();
          if (xfile != null && mounted) _handlePhotoSelected(xfile);
        },
        onCamera: () async {
          Navigator.pop(context);
          final xfile = await _profileService.pickFromCamera();
          if (xfile != null && mounted) _handlePhotoSelected(xfile);
        },
      ),
    );
  }

  Future<void> _handlePhotoSelected(XFile xfile) async {
    setState(() {
      _localPhotoFile  = File(xfile.path); // preview inmediato sin esperar Cloudinary
      _pendingPhotoUrl = null;
      _uploadingPhoto  = true;
    });

    try {
      final newUrl = await _profileService.saveProfilePhoto(xfile);
      if (mounted) {
        setState(() => _pendingPhotoUrl = newUrl);
        _showSnack('✅ Foto actualizada', isError: false);
      }
    } on CloudinaryUploadException catch (e) {
      if (mounted) {
        setState(() => _localPhotoFile = null); // descartamos el preview si falló
        _showSnack('Error Cloudinary: ${e.message}', isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _localPhotoFile = null);
        _showSnack('Error inesperado: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
      // NO limpiamos _localPhotoFile aquí.
      // Se limpia dentro de _buildAvatarContent cuando Image.network
      // confirma que la nueva URL terminó de cargar.
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.redAccent : AppColors.cyberLime,
        content: Text(
          msg,
          style: TextStyle(
            color: isError ? Colors.white : AppColors.carbonBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const _LogoutDialog(),
    );
    if (confirm == true && mounted) await _authService.logout();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: const GridPainter(),
          ),
          Positioned(
            top: -100, left: -100,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => _GlowOrb(
                color: AppColors.electricViolet.withOpacity(_pulseAnim.value * 0.25),
                size: 320,
              ),
            ),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => _GlowOrb(
                color: AppColors.cyberLime.withOpacity(_pulseAnim.value * 0.10),
                size: 260,
              ),
            ),
          ),

          // Contenido reactivo
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _profileService.userStream(),
                  builder: (context, snapshot) {
                    // Mientras Firestore carga, usar datos de FirebaseAuth
                    // como placeholder para que NO aparezca vacío ni 'Atleta'
                    final isLoading = snapshot.connectionState ==
                        ConnectionState.waiting;

                    final data        = snapshot.data?.data();
                    final displayName = _getDisplayName(
                      // Si aún está cargando y no hay datos de Firestore,
                      // pasamos null para que _getDisplayName use Auth/email
                      isLoading && data == null ? null : data,
                    );
                    final photoUrl = _getPhotoUrl(data);

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildHeader(
                            displayName: displayName,
                            photoUrl: photoUrl,
                            firestoreData: data,
                          ),
                        ),
                        SliverToBoxAdapter(child: _buildSectionLabel('CUENTA')),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _buildMenuTile(_menuOptions[i]),
                            childCount: _menuOptions.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        SliverToBoxAdapter(child: _buildSectionLabel('SESIÓN')),
                        SliverToBoxAdapter(child: _buildLogoutTile()),
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader({
    required String displayName,
    required String photoUrl,
    Map<String, dynamic>? firestoreData,
  }) {
    // Extraer datos físicos de Firestore
    final weightKg  = firestoreData?['weightKg'] as num?;
    final heightCm  = firestoreData?['heightCm'] as num?;
    final objetivo  = firestoreData?['objetivo'] as String?;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        children: [
          // Top bar
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERFIL',
                style: TextStyle(
                  color: AppColors.steamGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Avatar interactivo
          GestureDetector(
            onTap: _uploadingPhoto ? null : _showPhotoOptions,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: [
                  // Glow exterior
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyberLime
                              .withOpacity(_pulseAnim.value * 0.4),
                          blurRadius: 28, spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: AppColors.electricViolet
                              .withOpacity(_pulseAnim.value * 0.2),
                          blurRadius: 44, spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Arco giratorio
                  Transform.rotate(
                    angle: _pulseCtrl.value * 2 * math.pi * 0.3,
                    child: CustomPaint(
                      size: const Size(108, 108),
                      painter: _ArcRingPainter(),
                    ),
                  ),
                  // Círculo de foto
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                          color: AppColors.cyberLime.withOpacity(0.5),
                          width: 2),
                    ),
                    child: ClipOval(
                      child: _buildAvatarContent(photoUrl, displayName),
                    ),
                  ),

                  // Overlay de carga mientras sube a Cloudinary
                  if (_uploadingPhoto)
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.carbonBlack.withOpacity(0.65),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: CircularProgressIndicator(
                            color: AppColors.cyberLime,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),

                  // Badge cámara
                  if (!_uploadingPhoto)
                    Positioned(
                      bottom: 4, right: 4,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cyberLime,
                          border: Border.all(
                              color: AppColors.carbonBlack, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyberLime.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.carbonBlack,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            _uploadingPhoto ? 'Subiendo...' : 'Toca para cambiar foto',
            style: TextStyle(
              color: AppColors.cyberLime.withOpacity(0.5),
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Nombre
          Text(
            displayName.toUpperCase(),
            style: const TextStyle(
              color: AppColors.steamGray,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
            style: TextStyle(
              color: AppColors.steamGray.withOpacity(0.45),
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),

          // ── Tarjetas de datos físicos ─────────────────────────────────────
          _PhysicalStatsRow(
            weightKg: weightKg,
            heightCm: heightCm,
            objetivo: objetivo,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Avatar content ───────────────────────────────────────────────────────

  /// Prioridad:
  ///   1. Preview local (File del dispositivo, mientras sube a Cloudinary)
  ///   2. URL de Cloudinary guardada en Firestore  → Image.network
  ///   3. Iniciales como fallback
  Widget _buildAvatarContent(String photoUrl, String displayName) {
    // 1. Preview local — se mantiene visible hasta que Image.network confirme
    //    que la nueva foto terminó de cargar. Evita el flash de iniciales.
    if (_localPhotoFile != null) {
      return Image.file(_localPhotoFile!, fit: BoxFit.cover);
    }
    // 2. Foto de red
    if (photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        // frameBuilder: se ejecuta cuando el primer frame de la imagen está listo.
        // En ese momento ya podemos descartar el preview local de forma segura.
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null &&
              _pendingPhotoUrl == photoUrl &&
              _localPhotoFile != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _localPhotoFile = null);
            });
          }
          return child;
        },
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.surface,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.cyberLime,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _initialsWidget(displayName),
      );
    }
    return _initialsWidget(displayName);
  }

  Widget _initialsWidget(String displayName) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Text(
          _initials(displayName),
          style: const TextStyle(
            color: AppColors.cyberLime,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  // ─── Section label ────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: Row(
        children: [
          Container(
            width: 3, height: 12,
            decoration: BoxDecoration(
              color: AppColors.cyberLime,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                    color: AppColors.cyberLime.withOpacity(0.5), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.steamGray.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Menu tile ────────────────────────────────────────────────────────────

  Widget _buildMenuTile(_MenuOption option) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: PressableTile(
        onTap: () => _handleMenuTap(option),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.steamGray.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                      color: AppColors.steamGray.withOpacity(0.08)),
                ),
                child: Icon(option.icon,
                    color: AppColors.cyberLime, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.label,
                  style: const TextStyle(
                    color: AppColors.steamGray,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (option.trailing)
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.steamGray.withOpacity(0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuTap(_MenuOption option) {
    switch (option.label) {
      case 'Editar perfil':
        // Pasamos los datos actuales de Firestore para pre-rellenar el form
        final snapshot = _profileService.userStream().first;
        snapshot.then((doc) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(firestoreData: doc.data()),
              ),
            );
          }
        });
        break;
      case 'Privacidad y seguridad':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
        );
        break;
    }
  }

  // ─── Logout tile ──────────────────────────────────────────────────────────

  Widget _buildLogoutTile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: PressableTile(
        onTap: _handleLogout,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 18),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.redAccent.withOpacity(0.4), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Sheet opciones de foto ────────────────────────────────────────────
class _PhotoOptionsSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  const _PhotoOptionsSheet({required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.steamGray.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.steamGray.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'CAMBIAR FOTO',
            style: TextStyle(
              color: AppColors.steamGray,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 20),
          _SheetOption(
            icon: Icons.photo_library_rounded,
            label: 'Elegir de la galería',
            color: AppColors.cyberLime,
            onTap: onGallery,
          ),
          const SizedBox(height: 8),
          _SheetOption(
            icon: Icons.camera_alt_rounded,
            label: 'Tomar una foto',
            color: AppColors.electricViolet,
            onTap: onCamera,
          ),
          const SizedBox(height: 8),
          _SheetOption(
            icon: Icons.close_rounded,
            label: 'Cancelar',
            color: AppColors.steamGray.withOpacity(0.4),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableTile(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.steamGray.withOpacity(
                      color == AppColors.steamGray.withOpacity(0.4) ? 0.5 : 1),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withOpacity(0.4), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Dialog ────────────────────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.steamGray.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.1),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 26),
            ),
            const SizedBox(height: 20),
            const Text(
              '¿Cerrar sesión?',
              style: TextStyle(
                color: AppColors.steamGray,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tendrás que volver a iniciar sesión para acceder a tu cuenta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.steamGray.withOpacity(0.45),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.steamGray.withOpacity(0.1)),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                              color: AppColors.steamGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Salir',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Models y Painters ────────────────────────────────────────────────────────
class _MenuOption {
  final IconData icon;
  final String label;
  final bool trailing;
  const _MenuOption(
      {required this.icon, required this.label, this.trailing = false});
}

class _ArcRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );
    paint.color = AppColors.cyberLime.withOpacity(0.7);
    canvas.drawArc(rect, 0, math.pi * 1.2, false, paint);
    paint.color = AppColors.electricViolet.withOpacity(0.5);
    canvas.drawArc(rect, math.pi * 1.4, math.pi * 0.7, false, paint);
  }

  @override
  bool shouldRepaint(_) => true;
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

// ─── Tarjetas de datos físicos ────────────────────────────────────────────────

class _PhysicalStatsRow extends StatelessWidget {
  final num?    weightKg;
  final num?    heightCm;
  final String? objetivo;

  const _PhysicalStatsRow({
    this.weightKg,
    this.heightCm,
    this.objetivo,
  });

  // Convierte el valor del campo 'objetivo' al emoji + texto corto
  static const _objetivoMap = {
    'bajar_peso':    ('🔥', 'Bajar peso'),
    'ganar_musculo': ('💪', 'Ganar músculo'),
    'mantenerse':    ('⚖️', 'Mantenerse'),
  };

  @override
  Widget build(BuildContext context) {
    final obj = objetivo != null ? _objetivoMap[objetivo] : null;

    // Si no hay ningún dato físico todavía, mostrar un prompt sutil
    final hasAny = weightKg != null || heightCm != null || objetivo != null;
    if (!hasAny) {
      return GestureDetector(
        onTap: () {}, // el tap real lo maneja la opción "Editar perfil"
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.cyberLime.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.cyberLime.withOpacity(0.5), size: 15),
              const SizedBox(width: 8),
              Text(
                'Agrega tus datos físicos en Editar perfil',
                style: TextStyle(
                  color: AppColors.steamGray.withOpacity(0.35),
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        if (weightKg != null)
          Expanded(
            child: _StatCard(
              icon: Icons.monitor_weight_outlined,
              value: '${weightKg!.toStringAsFixed(1)}',
              unit: 'kg',
              label: 'Peso',
              color: AppColors.cyberLime,
            ),
          ),
        if (weightKg != null && heightCm != null) const SizedBox(width: 10),
        if (heightCm != null)
          Expanded(
            child: _StatCard(
              icon: Icons.height_rounded,
              value: '${heightCm!.toStringAsFixed(0)}',
              unit: 'cm',
              label: 'Altura',
              color: AppColors.electricViolet,
            ),
          ),
        if ((weightKg != null || heightCm != null) && obj != null)
          const SizedBox(width: 10),
        if (obj != null)
          Expanded(
            child: _ObjetivoCard(
              emoji: obj.$1,
              label: obj.$2,
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String   value;
  final String   unit;
  final String   label;
  final Color    color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  height: 1,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: color.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.steamGray.withOpacity(0.35),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjetivoCard extends StatelessWidget {
  final String emoji;
  final String label;

  const _ObjetivoCard({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.steamGray.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16, height: 1)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.steamGray,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'OBJETIVO',
            style: TextStyle(
              color: AppColors.steamGray.withOpacity(0.35),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}