import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/profile_service.dart';

// ─── Privacy & Security Screen ────────────────────────────────────────────────
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // ── Cambiar contraseña ─────────────────────────────
                      _SectionHeader(
                        icon: Icons.lock_outline_rounded,
                        label: 'CONTRASEÑA',
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon: Icons.key_rounded,
                        iconColor: AppColors.cyberLime,
                        title: 'Cambiar contraseña',
                        subtitle: 'Actualiza tu contraseña de acceso',
                        onTap: () => _showChangePasswordSheet(context),
                      ),
                      const SizedBox(height: 28),

                      // ── Zona de peligro ────────────────────────────────
                      _SectionHeader(
                        icon: Icons.warning_amber_rounded,
                        label: 'ZONA DE PELIGRO',
                        danger: true,
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon: Icons.delete_forever_rounded,
                        iconColor: Colors.redAccent,
                        title: 'Eliminar cuenta',
                        subtitle: 'Esta acción es permanente e irreversible',
                        danger: true,
                        onTap: () => _showDeleteAccountSheet(context),
                      ),
                      const SizedBox(height: 32),

                      // ── Nota informativa ───────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.steamGray.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.steamGray.withOpacity(0.35),
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Por seguridad, algunas acciones requieren que ingreses tu contraseña actual para confirmar tu identidad.',
                                style: TextStyle(
                                  color: AppColors.steamGray.withOpacity(0.35),
                                  fontSize: 12,
                                  height: 1.5,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.steamGray.withOpacity(0.08),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.steamGray,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'PRIVACIDAD Y SEGURIDAD',
            style: TextStyle(
              color: AppColors.steamGray,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sheets ───────────────────────────────────────────────────────────────

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _showDeleteAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DeleteAccountSheet(),
    );
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     danger;

  const _SectionHeader({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : AppColors.cyberLime;
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.steamGray.withOpacity(0.45),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData     icon;
  final Color        iconColor;
  final String       title;
  final String       subtitle;
  final bool         danger;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: danger
              ? Colors.redAccent.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: danger
                ? Colors.redAccent.withOpacity(0.2)
                : AppColors.steamGray.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withOpacity(0.2)),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: danger ? Colors.redAccent : AppColors.steamGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.steamGray.withOpacity(0.35),
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: (danger ? Colors.redAccent : AppColors.steamGray)
                  .withOpacity(0.35),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet: Cambiar contraseña ────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey     = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _service     = ProfileService();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _loading     = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await _service.changePassword(
        currentPassword: _currentCtrl.text,
        newPassword:     _newCtrl.text,
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.cyberLime,
            content: const Text(
              '✅ Contraseña actualizada',
              style: TextStyle(
                  color: AppColors.carbonBlack, fontWeight: FontWeight.w700),
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Error al cambiar la contraseña';
        final err = e.toString();
        if (err.contains('wrong-password') || err.contains('invalid-credential')) {
          msg = 'La contraseña actual es incorrecta';
        } else if (err.contains('weak-password')) {
          msg = 'La nueva contraseña es muy débil';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(msg,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border:
              Border.all(color: AppColors.steamGray.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 4),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.steamGray.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Título
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.cyberLime.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.cyberLime.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.key_rounded,
                          color: AppColors.cyberLime, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Cambiar contraseña',
                      style: TextStyle(
                        color: AppColors.steamGray,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Campo contraseña actual
                _PasswordField(
                  controller:   _currentCtrl,
                  label:        'Contraseña actual',
                  showPassword: _showCurrent,
                  onToggle: () =>
                      setState(() => _showCurrent = !_showCurrent),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerida' : null,
                ),
                const SizedBox(height: 14),

                // Campo nueva contraseña
                _PasswordField(
                  controller:   _newCtrl,
                  label:        'Nueva contraseña',
                  showPassword: _showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerida';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    if (v == _currentCtrl.text) {
                      return 'Debe ser diferente a la actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Confirmar nueva contraseña
                _PasswordField(
                  controller:   _confirmCtrl,
                  label:        'Confirmar nueva contraseña',
                  showPassword: _showConfirm,
                  onToggle: () =>
                      setState(() => _showConfirm = !_showConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerida';
                    if (v != _newCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botón
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: _loading ? null : _submit,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cyberLime,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyberLime.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.carbonBlack,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'ACTUALIZAR CONTRASEÑA',
                                style: TextStyle(
                                  color: AppColors.carbonBlack,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
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

// ─── Sheet: Eliminar cuenta ───────────────────────────────────────────────────

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _formKey      = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _service      = ProfileService();

  bool _showPassword = false;
  bool _loading      = false;
  bool _confirmed    = false; // el usuario marcó el checkbox de confirmación

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await _service.deleteAccount(password: _passwordCtrl.text);
      // deleteAccount hace signOut automáticamente → StreamBuilder de main.dart
      // redirige a LoginScreen sin necesidad de Navigator.pop
    } catch (e) {
      if (mounted) {
        String msg = 'Error al eliminar la cuenta';
        final err = e.toString();
        if (err.contains('wrong-password') || err.contains('invalid-credential')) {
          msg = 'Contraseña incorrecta';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(msg,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 4),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.steamGray.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Título con ícono de advertencia
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.delete_forever_rounded,
                          color: Colors.redAccent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Eliminar cuenta',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Esta acción no se puede deshacer',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Aviso
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.redAccent.withOpacity(0.15)),
                  ),
                  child: Text(
                    'Se eliminarán permanentemente tu cuenta, todos tus datos y tu historial de entrenamiento. Esta acción es irreversible.',
                    style: TextStyle(
                      color: Colors.redAccent.withOpacity(0.75),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contraseña
                _PasswordField(
                  controller:   _passwordCtrl,
                  label:        'Ingresa tu contraseña para confirmar',
                  showPassword: _showPassword,
                  onToggle: () =>
                      setState(() => _showPassword = !_showPassword),
                  danger: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerida' : null,
                ),
                const SizedBox(height: 16),

                // Checkbox de confirmación
                GestureDetector(
                  onTap: () => setState(() => _confirmed = !_confirmed),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: _confirmed
                              ? Colors.redAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _confirmed
                                ? Colors.redAccent
                                : AppColors.steamGray.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: _confirmed
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 13)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Entiendo que esta acción es permanente e irreversible',
                          style: TextStyle(
                            color: AppColors.steamGray.withOpacity(0.55),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón eliminar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: (_confirmed && !_loading) ? _deleteAccount : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: _confirmed
                            ? Colors.redAccent
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _confirmed
                            ? [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'ELIMINAR CUENTA',
                                style: TextStyle(
                                  color: _confirmed
                                      ? Colors.white
                                      : AppColors.steamGray.withOpacity(0.25),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
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

// ─── Campo de contraseña reutilizable ─────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController      controller;
  final String                     label;
  final bool                       showPassword;
  final VoidCallback               onToggle;
  final String? Function(String?)? validator;
  final bool                       danger;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.showPassword,
    required this.onToggle,
    this.validator,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = danger ? Colors.redAccent : AppColors.cyberLime;
    return TextFormField(
      controller:      controller,
      obscureText:     !showPassword,
      validator:       validator,
      style: const TextStyle(
        color: AppColors.steamGray,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.steamGray.withOpacity(0.4),
          fontSize: 13,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: accentColor.withOpacity(0.6),
          size: 18,
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            showPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.steamGray.withOpacity(0.3),
            size: 18,
          ),
        ),
        filled: true,
        fillColor: AppColors.carbonBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.steamGray.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}