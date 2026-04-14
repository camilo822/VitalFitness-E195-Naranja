import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/profile_service.dart';

// ─── Edit Profile Screen ──────────────────────────────────────────────────────
/// Modal de pantalla completa para editar nombre de usuario y datos físicos.
/// Se abre desde ProfileScreen con Navigator.push / showModalBottomSheet.
class EditProfileScreen extends StatefulWidget {
  /// Datos actuales del usuario para pre-rellenar el formulario.
  final Map<String, dynamic>? firestoreData;

  const EditProfileScreen({super.key, this.firestoreData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _profileService = ProfileService();
  final _formKey        = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;

  String? _selectedObjetivo;
  bool    _loading = false;
  bool    _dirty   = false; // hay cambios sin guardar

  // Animación de entrada
  late AnimationController _entryCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  static const _objetivos = [
    _ObjetivoItem('bajar_peso',     '🔥 Bajar de peso',   'Déficit calórico y cardio'),
    _ObjetivoItem('ganar_musculo',  '💪 Ganar músculo',   'Hipertrofia y fuerza'),
    _ObjetivoItem('mantenerse',     '⚖️ Mantenerse',       'Equilibrio y salud general'),
  ];

  @override
  void initState() {
    super.initState();

    final data = widget.firestoreData;

    _nameCtrl   = TextEditingController(text: data?['displayName'] as String? ?? '');
    _weightCtrl = TextEditingController(
      text: data?['weightKg'] != null
          ? (data!['weightKg'] as num).toStringAsFixed(1)
          : '',
    );
    _heightCtrl = TextEditingController(
      text: data?['heightCm'] != null
          ? (data!['heightCm'] as num).toStringAsFixed(0)
          : '',
    );
    _selectedObjetivo = data?['objetivo'] as String?;

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    // Detectar cambios para mostrar botón activo
    for (final c in [_nameCtrl, _weightCtrl, _heightCtrl]) {
      c.addListener(_onChanged);
    }
  }

  void _onChanged() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final name   = _nameCtrl.text.trim();
      final weight = double.tryParse(_weightCtrl.text.trim());
      final height = double.tryParse(_heightCtrl.text.trim());

      // Guardar nombre (si cambió)
      final currentName = widget.firestoreData?['displayName'] as String? ?? '';
      if (name != currentName && name.isNotEmpty) {
        await _profileService.updateDisplayName(name);
      }

      // Guardar datos físicos
      await _profileService.updatePhysicalData(
        weightKg: weight,
        heightCm: height,
        objetivo: _selectedObjetivo,
      );

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context, true); // true = hubo cambios
      }
    } catch (e) {
      if (mounted) _showSnack('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(msg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

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
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // ── Sección: Información personal ──────────────────
                        _SectionHeader(
                          icon: Icons.person_outline_rounded,
                          label: 'INFORMACIÓN PERSONAL',
                        ),
                        const SizedBox(height: 12),
                        _VFTextField(
                          controller: _nameCtrl,
                          label: 'Nombre de usuario',
                          hint: 'Tu nombre visible',
                          icon: Icons.badge_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'El nombre no puede estar vacío';
                            }
                            if (v.trim().length < 2) {
                              return 'Mínimo 2 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // ── Sección: Datos físicos ─────────────────────────
                        _SectionHeader(
                          icon: Icons.monitor_weight_outlined,
                          label: 'DATOS FÍSICOS',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _VFTextField(
                                controller: _weightCtrl,
                                label: 'Peso',
                                hint: '70',
                                suffix: 'kg',
                                icon: Icons.monitor_weight_outlined,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
                                ],
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return null;
                                  final n = double.tryParse(v.trim());
                                  if (n == null || n <= 0 || n > 400) {
                                    return 'Peso inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _VFTextField(
                                controller: _heightCtrl,
                                label: 'Altura',
                                hint: '175',
                                suffix: 'cm',
                                icon: Icons.height_rounded,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return null;
                                  final n = int.tryParse(v.trim());
                                  if (n == null || n < 50 || n > 300) {
                                    return 'Altura inválida';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── Sección: Objetivo ──────────────────────────────
                        _SectionHeader(
                          icon: Icons.track_changes_rounded,
                          label: 'OBJETIVO',
                        ),
                        const SizedBox(height: 12),
                        ..._objetivos.map((item) => _ObjetivoCard(
                          item: item,
                          selected: _selectedObjetivo == item.value,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedObjetivo = item.value;
                              _dirty = true;
                            });
                          },
                        )),
                        const SizedBox(height: 32),

                        // ── Botón guardar ──────────────────────────────────
                        _SaveButton(
                          loading: _loading,
                          enabled: _dirty || _selectedObjetivo != widget.firestoreData?['objetivo'],
                          onTap: _save,
                        ),
                      ],
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

  // ─── Top Bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Botón volver
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
            'EDITAR PERFIL',
            style: TextStyle(
              color: AppColors.steamGray,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets reutilizables ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: AppColors.cyberLime,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyberLime.withOpacity(0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: AppColors.cyberLime, size: 15),
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

// ─── Campo de texto ───────────────────────────────────────────────────────────

class _VFTextField extends StatelessWidget {
  final TextEditingController      controller;
  final String                     label;
  final String                     hint;
  final String?                    suffix;
  final IconData                   icon;
  final TextInputType?             keyboardType;
  final List<TextInputFormatter>?  inputFormatters;
  final String? Function(String?)? validator;

  const _VFTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.steamGray.withOpacity(0.55),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller:      controller,
          keyboardType:    keyboardType,
          inputFormatters: inputFormatters,
          validator:       validator,
          style: const TextStyle(
            color: AppColors.steamGray,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.steamGray.withOpacity(0.25),
              fontSize: 15,
            ),
            prefixIcon: Icon(icon,
                color: AppColors.cyberLime.withOpacity(0.7), size: 18),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: AppColors.steamGray.withOpacity(0.4),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.steamGray.withOpacity(0.08),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.cyberLime,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

// ─── Tarjeta de objetivo ──────────────────────────────────────────────────────

class _ObjetivoItem {
  final String value;
  final String label;
  final String subtitle;
  const _ObjetivoItem(this.value, this.label, this.subtitle);
}

class _ObjetivoCard extends StatelessWidget {
  final _ObjetivoItem item;
  final bool          selected;
  final VoidCallback  onTap;

  const _ObjetivoCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.cyberLime.withOpacity(0.07)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.cyberLime.withOpacity(0.5)
                : AppColors.steamGray.withOpacity(0.08),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.cyberLime.withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji
            Text(
              item.label.split(' ').first,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label.split(' ').skip(1).join(' '),
                    style: TextStyle(
                      color: selected
                          ? AppColors.cyberLime
                          : AppColors.steamGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: AppColors.steamGray.withOpacity(0.4),
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de selección
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.cyberLime : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.cyberLime
                      : AppColors.steamGray.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.carbonBlack, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Botón guardar ────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool         loading;
  final bool         enabled;
  final VoidCallback onTap;

  const _SaveButton({
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (enabled && !loading) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: enabled && !loading
              ? AppColors.cyberLime
              : AppColors.surface,
          border: Border.all(
            color: enabled && !loading
                ? Colors.transparent
                : AppColors.steamGray.withOpacity(0.08),
          ),
          boxShadow: enabled && !loading
              ? [
                  BoxShadow(
                    color: AppColors.cyberLime.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.carbonBlack,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'GUARDAR CAMBIOS',
                  style: TextStyle(
                    color: enabled
                        ? AppColors.carbonBlack
                        : AppColors.steamGray.withOpacity(0.25),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }
}