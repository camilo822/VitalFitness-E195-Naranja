import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vital_fitness/features/auth/data/services/auth_service.dart';
// Importa los colores compartidos (ajusta la ruta según tu estructura de proyecto)
import 'package:vital_fitness/core/theme/app_colors.dart';

// ─── Compact Animated Logo ────────────────────────────────────────────────────
class FitnessLogoCompact extends StatefulWidget {
  const FitnessLogoCompact({super.key});

  @override
  State<FitnessLogoCompact> createState() => _FitnessLogoCompactState();
}

class _FitnessLogoCompactState extends State<FitnessLogoCompact>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotateAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _rotateAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(_ctrl);
    _glowAnim   = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyberLime.withOpacity(_glowAnim.value * 0.45),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: AppColors.electricViolet.withOpacity(_glowAnim.value * 0.25),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Transform.rotate(
                  angle: _rotateAnim.value,
                  child: CustomPaint(
                    size: const Size(60, 60),
                    painter: _ArcPainter(),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: AppColors.cyberLime.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.cyberLime,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'VITAL',
                        style: TextStyle(
                          color: AppColors.cyberLime,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      TextSpan(
                        text: 'FITNESS',
                        style: TextStyle(
                          color: AppColors.steamGray,
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'PUSH YOUR LIMITS',
                  style: TextStyle(
                    color: AppColors.electricViolet,
                    fontSize: 9,
                    letterSpacing: 3.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );

    paint.color = AppColors.cyberLime;
    canvas.drawArc(rect, 0, math.pi * 1.4, false, paint);

    paint.color = AppColors.electricViolet;
    canvas.drawArc(rect, math.pi * 1.5, math.pi * 0.8, false, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Progress Step Indicator ──────────────────────────────────────────────────
class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int filledSteps;

  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.filledSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final filled = i < filledSteps;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: filled
                  ? AppColors.cyberLime
                  : AppColors.electricViolet.withOpacity(0.25),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: AppColors.cyberLime.withOpacity(0.5),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Glow Text Field ──────────────────────────────────────────────────────────
class GlowTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const GlowTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  State<GlowTextField> createState() => _GlowTextFieldState();
}

class _GlowTextFieldState extends State<GlowTextField> {
  bool _obscure  = true;
  bool _focused  = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (f) => setState(() => _focused = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: (_error != null
                                ? Colors.redAccent
                                : AppColors.cyberLime)
                            .withOpacity(0.22),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.isPassword && _obscure,
              keyboardType: widget.keyboardType,
              style: const TextStyle(
                color: AppColors.steamGray,
                fontSize: 15,
                letterSpacing: 0.8,
              ),
              cursorColor: AppColors.cyberLime,
              validator: (v) {
                final err = widget.validator?.call(v);
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => mounted ? setState(() => _error = err) : null);
                return err;
              },
              onChanged: widget.onChanged,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: AppColors.steamGray.withOpacity(0.3),
                  fontSize: 14,
                ),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                prefixIcon: Icon(
                  widget.prefixIcon,
                  color: _focused
                      ? (_error != null
                          ? Colors.redAccent
                          : AppColors.cyberLime)
                      : AppColors.steamGray.withOpacity(0.35),
                  size: 20,
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _focused
                              ? AppColors.cyberLime
                              : AppColors.steamGray.withOpacity(0.35),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLight,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _error != null
                        ? Colors.redAccent.withOpacity(0.5)
                        : AppColors.steamGray.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _error != null
                        ? Colors.redAccent
                        : AppColors.cyberLime,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.redAccent.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 13),
              const SizedBox(width: 5),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 11.5,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Password Strength Meter ──────────────────────────────────────────────────
class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8)  score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$&*~._\-]'))) score++;
    return score;
  }

  Color get _color {
    switch (_strength) {
      case 1: return Colors.redAccent;
      case 2: return Colors.orangeAccent;
      case 3: return AppColors.cyberLime.withOpacity(0.7);
      case 4: return AppColors.cyberLime;
      default: return Colors.transparent;
    }
  }

  String get _label {
    switch (_strength) {
      case 1: return 'Débil';
      case 2: return 'Regular';
      case 3: return 'Buena';
      case 4: return 'Fuerte';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(4, (i) {
              final filled = i < _strength;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: filled
                        ? _color
                        : AppColors.steamGray.withOpacity(0.12),
                    boxShadow: filled
                        ? [
                            BoxShadow(
                              color: _color.withOpacity(0.4),
                              blurRadius: 4,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }),
            const SizedBox(width: 10),
            Text(
              _label,
              style: TextStyle(
                color: _color,
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Register Button ──────────────────────────────────────────────────────────
class _RegisterButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _RegisterButton({required this.loading, required this.onPressed});

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.loading) widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFCCFF00),
                Color(0xFFAAD900),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyberLime.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.carbonBlack),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.rocket_launch_rounded,
                          color: AppColors.carbonBlack, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'REGISTRARSE',
                        style: TextStyle(
                          color: AppColors.carbonBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.5,
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

// ─── Background Painters ──────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCFF00).withOpacity(0.035)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Register Screen ──────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  bool  _loading        = false;
  String _password      = '';

  int get _filledSteps {
    int count = 0;
    if (_nameCtrl.text.trim().isNotEmpty)   count++;
    if (_emailCtrl.text.trim().isNotEmpty)  count++;
    if (_passCtrl.text.isNotEmpty)          count++;
    if (_confirmCtrl.text.isNotEmpty)       count++;
    return count;
  }

  late AnimationController _entryCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    for (final c in [_nameCtrl, _emailCtrl, _passCtrl, _confirmCtrl]) {
      c.addListener(() => setState(() {}));
    }
    _passCtrl.addListener(() => setState(() => _password = _passCtrl.text));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      await _authService.register(
        email:       _emailCtrl.text.trim(),
        password:    _passCtrl.text.trim(),
        displayName: _nameCtrl.text.trim(),   // ← nombre → Firestore + Auth
      );

      // ✅ Firebase registró al usuario correctamente.
      // El StreamBuilder en main.dart detectará authStateChanges()
      // y navegará automáticamente a HomeScreen. No se necesita Navigator aquí.

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.cyberLime,
            content: const Text(
              '¡Cuenta creada con éxito! 🚀',
              style: TextStyle(
                color: AppColors.carbonBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              e.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _GridPainter(),
          ),
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.electricViolet.withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyberLime.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color:
                                      AppColors.steamGray.withOpacity(0.12),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.steamGray,
                                size: 18,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.electricViolet.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.electricViolet.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$_filledSteps/4 completado',
                              style: const TextStyle(
                                color: AppColors.electricViolet,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              const FitnessLogoCompact(),
                              const SizedBox(height: 24),
                              StepProgressBar(
                                totalSteps: 4,
                                filledSteps: _filledSteps,
                              ),
                              const SizedBox(height: 24),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Crea tu cuenta',
                                      style: TextStyle(
                                        color: AppColors.steamGray,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Únete y comienza tu transformación',
                                      style: TextStyle(
                                        color: AppColors.steamGray
                                            .withOpacity(0.45),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              GlowTextField(
                                controller: _nameCtrl,
                                hint: 'Nombre de usuario',
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'El nombre es requerido';
                                  }
                                  if (v.trim().length < 3) {
                                    return 'Mínimo 3 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              GlowTextField(
                                controller: _emailCtrl,
                                hint: 'Correo electrónico',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'El correo es requerido';
                                  }
                                  final emailRx = RegExp(
                                      r'^[\w\-\.]+@([\w\-]+\.)+[\w]{2,4}$');
                                  if (!emailRx.hasMatch(v.trim())) {
                                    return 'Correo no válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              GlowTextField(
                                controller: _passCtrl,
                                hint: 'Contraseña',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'La contraseña es requerida';
                                  }
                                  if (v.length < 8) {
                                    return 'Mínimo 8 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              PasswordStrengthMeter(password: _password),
                              const SizedBox(height: 14),
                              GlowTextField(
                                controller: _confirmCtrl,
                                hint: 'Confirmar contraseña',
                                prefixIcon: Icons.lock_reset_rounded,
                                isPassword: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Confirma tu contraseña';
                                  }
                                  if (v != _passCtrl.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    color: AppColors.electricViolet
                                        .withOpacity(0.7),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Al registrarte aceptas nuestros ',
                                            style: TextStyle(
                                              color: AppColors.steamGray
                                                  .withOpacity(0.4),
                                              fontSize: 11.5,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: 'Términos de uso',
                                            style: TextStyle(
                                              color: AppColors.electricViolet,
                                              fontSize: 11.5,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' y ',
                                            style: TextStyle(
                                              color: AppColors.steamGray
                                                  .withOpacity(0.4),
                                              fontSize: 11.5,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: 'Política de Privacidad',
                                            style: TextStyle(
                                              color: AppColors.electricViolet,
                                              fontSize: 11.5,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _RegisterButton(
                                loading: _loading,
                                onPressed: _handleRegister,
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            AppColors.steamGray
                                                .withOpacity(0.18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'ó',
                                      style: TextStyle(
                                        color: AppColors.steamGray
                                            .withOpacity(0.28),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.steamGray
                                                .withOpacity(0.18),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: () => Navigator.of(context).maybePop(),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '¿Ya tienes una cuenta? ',
                                        style: TextStyle(
                                          color: AppColors.steamGray
                                              .withOpacity(0.45),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'Inicia sesión',
                                        style: TextStyle(
                                          color: AppColors.cyberLime,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}