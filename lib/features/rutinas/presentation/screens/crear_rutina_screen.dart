import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/rutina_service.dart';

// ─── Modelos ──────────────────────────────────────────────────────────────────
class _Objetivo {
  final String id;
  final String emoji;
  final String nombre;
  final String desc;
  final Color color;

  const _Objetivo({
    required this.id,
    required this.emoji,
    required this.nombre,
    required this.desc,
    required this.color,
  });
}

const _objetivos = [
  _Objetivo(
    id: 'fuerza',
    emoji: '🏋️',
    nombre: 'Fuerza',
    desc: 'Cargas pesadas y\nbaja repetición',
    color: AppColors.electricViolet,
  ),
  _Objetivo(
    id: 'hipertrofia',
    emoji: '💪',
    nombre: 'Hipertrofia',
    desc: 'Volumen y máximo\ncrecimiento muscular',
    color: AppColors.cyberLime,
  ),
  _Objetivo(
    id: 'resistencia',
    emoji: '⚡',
    nombre: 'Resistencia',
    desc: 'Alta repetición y\ncardio integrado',
    color: Color(0xFFFF9500),
  ),
];

//const _diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

// ─── Crear Rutina Screen ──────────────────────────────────────────────────────
class CrearRutinaScreen extends StatefulWidget {
  const CrearRutinaScreen({super.key});

  @override
  State<CrearRutinaScreen> createState() => _CrearRutinaScreenState();
}

class _CrearRutinaScreenState extends State<CrearRutinaScreen>
    with SingleTickerProviderStateMixin {
  final _nombreCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final List<bool> _diasSeleccionados =
      List.generate(7, (_) => false);
  String _objetivoSeleccionado = 'fuerza';
  final List<String> _ejerciciosAgregados = [];

  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int get _diasCount => _diasSeleccionados.where((d) => d).length;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _fadeAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _nombreCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _toggleDia(int i) {
    HapticFeedback.selectionClick();
    setState(() => _diasSeleccionados[i] = !_diasSeleccionados[i]);
  }

  Future<void> _guardarRutina() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: const Text('Ingresa un nombre para la rutina'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    // Calcular minutos estimados según días y objetivo
    final diasCount = _diasSeleccionados.where((d) => d).length;
    final minutos = _objetivoSeleccionado == 'fuerza'
        ? 70
        : _objetivoSeleccionado == 'resistencia'
            ? 50
            : 60;

    try {
      await RutinaService.crearRutina(
        nombre: nombre,
        categoria: _objetivoSeleccionado,
        diasActivos: List<bool>.from(_diasSeleccionados),
        ejercicios: List<String>.from(_ejerciciosAgregados),
        minutos: diasCount > 0 ? minutos : 45,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cyberLime,
          content: Text(
            '✅ Rutina "$nombre" guardada',
            style: const TextStyle(
                color: AppColors.carbonBlack, fontWeight: FontWeight.bold),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Error al guardar: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // ── Nombre ──────────────────────────────────────
                      _SectionLabel(label: 'NOMBRE DE LA RUTINA'),
                      const SizedBox(height: 10),
                      _NombreField(
                        controller: _nombreCtrl,
                        focusNode: _nameFocus,
                      ),
                      const SizedBox(height: 24),
                      // ── Días ─────────────────────────────────────────
                      _SectionLabel(label: 'DÍAS DE ENTRENAMIENTO'),
                      const SizedBox(height: 10),
                      _DiasSelector(
                        diasSeleccionados: _diasSeleccionados,
                        onToggle: _toggleDia,
                        diasCount: _diasCount,
                      ),
                      const SizedBox(height: 24),
                      // ── Objetivo ──────────────────────────────────────
                      _SectionLabel(label: 'OBJETIVO PRINCIPAL'),
                      const SizedBox(height: 10),
                      _ObjetivoSelector(
                        seleccionado: _objetivoSeleccionado,
                        onSelect: (id) =>
                            setState(() => _objetivoSeleccionado = id),
                      ),
                      const SizedBox(height: 24),
                      // ── Ejercicios ────────────────────────────────────
                      _SectionLabel(label: 'EJERCICIOS'),
                      const SizedBox(height: 10),
                      _AgregarEjercicioButton(
                        onTap: () {
                          // Navegar a guía de ejercicios
                          Navigator.pushNamed(
                              context, '/guia-ejercicios');
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_ejerciciosAgregados.isEmpty)
                        _EmptyEjercicios()
                      else
                        ..._ejerciciosAgregados.map(
                          (e) => Text(e,
                              style: const TextStyle(
                                  color: AppColors.steamGray)),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // ── Botón guardar flotante ─────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.carbonBlack,
          border: Border(
            top: BorderSide(
              color: AppColors.steamGray.withOpacity(0.06),
            ),
          ),
        ),
        child: GestureDetector(
          onTap: _guardarRutina,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  AppColors.electricViolet,
                  Color(0xFF6A1FB5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricViolet.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'GUARDAR RUTINA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                    color: AppColors.steamGray.withOpacity(0.08)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.steamGray, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear Rutina',
                style: TextStyle(
                  color: AppColors.steamGray,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'PERSONALIZA TU ENTRENAMIENTO',
                style: TextStyle(
                  color: AppColors.electricViolet,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.electricViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.electricViolet.withOpacity(0.25)),
            ),
            child: const Icon(Icons.add_rounded,
                color: AppColors.electricViolet, size: 22),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.electricViolet,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                  color: AppColors.electricViolet.withOpacity(0.5),
                  blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: AppColors.steamGray.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _NombreField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _NombreField(
      {required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(
        color: AppColors.steamGray,
        fontSize: 15,
      ),
      cursorColor: AppColors.electricViolet,
      decoration: InputDecoration(
        hintText: 'Ej. Mi rutina de fuerza...',
        hintStyle: TextStyle(
          color: AppColors.steamGray.withOpacity(0.3),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.edit_outlined,
          color: AppColors.steamGray.withOpacity(0.35),
          size: 18,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: AppColors.steamGray.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColors.electricViolet, width: 1.5),
        ),
      ),
    );
  }
}

class _DiasSelector extends StatelessWidget {
  final List<bool> diasSeleccionados;
  final ValueChanged<int> onToggle;
  final int diasCount;

  const _DiasSelector({
    required this.diasSeleccionados,
    required this.onToggle,
    required this.diasCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steamGray.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final sel = diasSeleccionados[i];
              return GestureDetector(
                onTap: () => onToggle(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel
                        ? AppColors.electricViolet
                        : AppColors.surfaceLight,
                    border: Border.all(
                      color: sel
                          ? AppColors.electricViolet
                          : AppColors.steamGray.withOpacity(0.12),
                    ),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.electricViolet.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      const ['L','M','X','J','V','S','D'][i],
                      style: TextStyle(
                        color: sel
                            ? Colors.white
                            : AppColors.steamGray.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (diasCount > 0) ...[
            const SizedBox(height: 12),
            Text(
              '$diasCount ${diasCount == 1 ? 'día seleccionado' : 'días seleccionados'}',
              style: const TextStyle(
                color: AppColors.electricViolet,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ObjetivoSelector extends StatelessWidget {
  final String seleccionado;
  final ValueChanged<String> onSelect;

  const _ObjetivoSelector({
    required this.seleccionado,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _objetivos.map((o) {
        final sel = seleccionado == o.id;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(o.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: sel ? o.color.withOpacity(0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel
                      ? o.color.withOpacity(0.5)
                      : AppColors.steamGray.withOpacity(0.08),
                  width: sel ? 1.5 : 1,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: o.color.withOpacity(0.2),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Text(o.emoji,
                      style: const TextStyle(fontSize: 24, height: 1)),
                  const SizedBox(height: 8),
                  Text(
                    o.nombre,
                    style: TextStyle(
                      color: sel ? o.color : AppColors.steamGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    o.desc,
                    style: TextStyle(
                      color: AppColors.steamGray.withOpacity(0.4),
                      fontSize: 10,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AgregarEjercicioButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AgregarEjercicioButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cyberLime.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyberLime.withOpacity(0.15),
                border:
                    Border.all(color: AppColors.cyberLime.withOpacity(0.4)),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.cyberLime, size: 16),
            ),
            const SizedBox(width: 12),
            const Text(
              'Agregar ejercicio',
              style: TextStyle(
                color: AppColors.cyberLime,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              ' → Guía de ejercicios',
              style: TextStyle(
                color: AppColors.steamGray.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEjercicios extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_outlined,
            color: AppColors.steamGray.withOpacity(0.2),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Aún no has agregado ejercicios',
            style: TextStyle(
              color: AppColors.steamGray.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca el botón de arriba para explorar\nla guía y elegir los ejercicios',
            style: TextStyle(
              color: AppColors.steamGray.withOpacity(0.25),
              fontSize: 11,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}