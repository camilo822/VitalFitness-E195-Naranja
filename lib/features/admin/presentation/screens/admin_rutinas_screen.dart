import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

// ─── Modelo ───────────────────────────────────────────────────────────────────
class _RutinaAdmin {
  final String nombre;
  final String tag;
  final String nivel;
  final int diasSemana;
  final int minutos;
  final int ejercicios;
  final Color color;

  const _RutinaAdmin({
    required this.nombre,
    required this.tag,
    required this.nivel,
    required this.diasSemana,
    required this.minutos,
    required this.ejercicios,
    required this.color,
  });
}

final _rutinasAdmin = [
  const _RutinaAdmin(nombre: 'PPL — Push Pull Legs', tag: 'POPULAR',    nivel: 'Intermedio',   diasSemana: 6, minutos: 75, ejercicios: 18, color: AppColors.cyberLime),
  const _RutinaAdmin(nombre: 'Arnold Split',          tag: 'CLÁSICO',    nivel: 'Avanzado',     diasSemana: 6, minutos: 90, ejercicios: 20, color: AppColors.electricViolet),
  const _RutinaAdmin(nombre: 'Upper / Lower Split',   tag: 'EQUILIBRADO',nivel: 'Principiante+',diasSemana: 4, minutos: 60, ejercicios: 12, color: Color(0xFF00D4FF)),
  const _RutinaAdmin(nombre: 'StrongLifts 5×5',       tag: 'FUERZA',     nivel: 'Principiante', diasSemana: 3, minutos: 45, ejercicios: 5,  color: Color(0xFFFF9500)),
  const _RutinaAdmin(nombre: 'PHUL — Power Hypertrophy', tag: 'AVANZADO', nivel: 'Avanzado',    diasSemana: 4, minutos: 80, ejercicios: 16, color: Colors.redAccent),
];

// ─── Admin Rutinas Screen ─────────────────────────────────────────────────────
class AdminRutinasScreen extends StatefulWidget {
  const AdminRutinasScreen({super.key});

  @override
  State<AdminRutinasScreen> createState() => _AdminRutinasScreenState();
}

class _AdminRutinasScreenState extends State<AdminRutinasScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;

  int get _totalEjercicios =>
      _rutinasAdmin.fold(0, (s, r) => s + r.ejercicios);

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    _showRutinaForm(context, null);
  }

  void _showEditDialog(_RutinaAdmin r) {
    _showRutinaForm(context, r);
  }

  void _showRutinaForm(BuildContext ctx, _RutinaAdmin? rutina) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RutinaFormSheet(rutina: rutina),
    );
  }

  void _confirmDelete(_RutinaAdmin r) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => _DeleteDialog(nombre: r.nombre),
    ).then((confirm) {
      if (confirm == true) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('🗑️ "${r.nombre}" eliminada',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────
              _AdminTopBar(
                title: 'Rutinas Predeterminadas',
                subtitle: '${_rutinasAdmin.length} PROGRAMAS',
                onAdd: _showAddDialog,
                addIcon: Icons.post_add_rounded,
              ),
              const SizedBox(height: 4),
              // ── Stats ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    _StatCard(value: '${_rutinasAdmin.length}', label: 'Total rutinas',   color: AppColors.electricViolet),
                    const SizedBox(width: 10),
                    _StatCard(value: '$_totalEjercicios',        label: 'Ejercicios totales', color: AppColors.cyberLime),
                    const SizedBox(width: 10),
                    _StatCard(value: '142',                      label: 'Usuarios activos',   color: Color(0xFF00D4FF)),
                  ],
                ),
              ),
              // ── Sección ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Container(
                      width: 4, height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.electricViolet,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [BoxShadow(
                            color: AppColors.electricViolet.withOpacity(0.5),
                            blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('PROGRAMAS DISPONIBLES',
                        style: TextStyle(
                          color: AppColors.steamGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        )),
                  ],
                ),
              ),
              // ── Lista ──────────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _rutinasAdmin.length,
                  itemBuilder: (_, i) => _RutinaAdminCard(
                    rutina: _rutinasAdmin[i],
                    onEdit: () => _showEditDialog(_rutinasAdmin[i]),
                    onDelete: () => _confirmDelete(_rutinasAdmin[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Rutina Admin Card ────────────────────────────────────────────────────────
class _RutinaAdminCard extends StatelessWidget {
  final _RutinaAdmin rutina;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RutinaAdminCard({
    required this.rutina,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final r = rutina;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: r.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: r.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: r.color.withOpacity(0.3)),
                ),
                child: Text(r.tag,
                    style: TextStyle(
                      color: r.color, fontSize: 9,
                      fontWeight: FontWeight.w800, letterSpacing: 1.5,
                    )),
              ),
              const Spacer(),
              _IconBtn(icon: Icons.edit_rounded,          color: AppColors.electricViolet, onTap: onEdit),
              const SizedBox(width: 8),
              _IconBtn(icon: Icons.delete_outline_rounded, color: Colors.redAccent,        onTap: onDelete),
            ],
          ),
          const SizedBox(height: 8),
          Text(r.nombre,
              style: const TextStyle(
                  color: AppColors.steamGray, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          // Chips de info
          Wrap(
            spacing: 8, runSpacing: 6,
            children: [
              _InfoChip(label: r.nivel,              color: r.color),
              _InfoChip(label: '${r.diasSemana} días/sem', color: AppColors.steamGray.withOpacity(0.5)),
              _InfoChip(label: '~${r.minutos} min',        color: AppColors.steamGray.withOpacity(0.5)),
              _InfoChip(label: '${r.ejercicios} ejercicios', color: AppColors.steamGray.withOpacity(0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.steamGray.withOpacity(0.08)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Widgets compartidos ──────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, height: 1)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: AppColors.steamGray.withOpacity(0.35), fontSize: 9, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  final IconData addIcon;

  const _AdminTopBar({
    required this.title,
    required this.subtitle,
    required this.onAdd,
    this.addIcon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: Colors.redAccent, size: 12),
                SizedBox(width: 5),
                Text('ADMIN',
                    style: TextStyle(color: Colors.redAccent, fontSize: 10,
                        fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: AppColors.steamGray, fontSize: 16, fontWeight: FontWeight.w800)),
              Text(subtitle, style: TextStyle(color: AppColors.electricViolet.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ]),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.electricViolet.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.electricViolet.withOpacity(0.3)),
              ),
              child: Icon(addIcon, color: AppColors.electricViolet, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  final String nombre;
  const _DeleteDialog({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.1),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 24),
            ),
            const SizedBox(height: 16),
            Text('¿Eliminar "$nombre"?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.steamGray, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('Cancelar', style: TextStyle(color: AppColors.steamGray, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
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

class _RutinaFormSheet extends StatefulWidget {
  final _RutinaAdmin? rutina;
  const _RutinaFormSheet({this.rutina});

  @override
  State<_RutinaFormSheet> createState() => _RutinaFormSheetState();
}

class _RutinaFormSheetState extends State<_RutinaFormSheet> {
  late TextEditingController _nombreCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.rutina?.nombre ?? '');
  }

  @override
  void dispose() { _nombreCtrl.dispose(); super.dispose(); }

  void _guardar() {
    if (_nombreCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.cyberLime,
          content: Text(widget.rutina == null ? '✅ Rutina creada' : '✅ Rutina actualizada',
              style: const TextStyle(color: AppColors.carbonBlack, fontWeight: FontWeight.bold)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.rutina != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.steamGray.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.steamGray.withOpacity(0.2), borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 20),
            Text(isEdit ? 'Editar rutina' : 'Nueva rutina predeterminada',
                style: const TextStyle(color: AppColors.steamGray, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreCtrl,
              style: const TextStyle(color: AppColors.steamGray),
              cursorColor: AppColors.electricViolet,
              decoration: InputDecoration(
                hintText: 'Nombre del programa',
                hintStyle: TextStyle(color: AppColors.steamGray.withOpacity(0.3)),
                filled: true, fillColor: AppColors.carbonBlack,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.electricViolet, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loading ? null : _guardar,
              child: Container(
                width: double.infinity, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.electricViolet, Color(0xFF6A1FB5)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.electricViolet.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(isEdit ? 'GUARDAR CAMBIOS' : 'CREAR RUTINA',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
