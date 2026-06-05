import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/services/auth_service.dart';

// ─── Modelo ───────────────────────────────────────────────────────────────────
class _EjercicioAdmin {
  final String id;
  final String nombre;
  final String grupo;
  final List<String> etiquetas;
  final Color grupoColor;

  const _EjercicioAdmin({
    required this.id,
    required this.nombre,
    required this.grupo,
    required this.etiquetas,
    required this.grupoColor,
  });
}

const _grupoColores = {
  'Pecho':    AppColors.cyberLime,
  'Espalda':  AppColors.electricViolet,
  'Piernas':  Color(0xFF00D4FF),
  'Brazos':   Color(0xFFFF9500),
  'Abdomen':  Color(0xFF00E676),
  'Cardio':   Colors.redAccent,
};

final _ejerciciosData = [
  const _EjercicioAdmin(id: '1', nombre: 'Press Banca Plano',         grupo: 'Pecho',   etiquetas: ['Compuesto', 'Barra'],        grupoColor: AppColors.cyberLime),
  const _EjercicioAdmin(id: '2', nombre: 'Press Inclinado Mancuernas',grupo: 'Pecho',   etiquetas: ['Compuesto', 'Mancuernas'],   grupoColor: AppColors.cyberLime),
  const _EjercicioAdmin(id: '3', nombre: 'Fondos en Paralelas',       grupo: 'Pecho',   etiquetas: ['Compuesto', 'Peso corporal'],grupoColor: AppColors.cyberLime),
  const _EjercicioAdmin(id: '4', nombre: 'Peso Muerto Convencional',  grupo: 'Espalda', etiquetas: ['Compuesto', 'Barra'],        grupoColor: AppColors.electricViolet),
  const _EjercicioAdmin(id: '5', nombre: 'Jalón al Pecho',            grupo: 'Espalda', etiquetas: ['Compuesto', 'Máquina'],      grupoColor: AppColors.electricViolet),
  const _EjercicioAdmin(id: '6', nombre: 'Dominadas',                 grupo: 'Espalda', etiquetas: ['Compuesto', 'Peso corporal'],grupoColor: AppColors.electricViolet),
  const _EjercicioAdmin(id: '7', nombre: 'Sentadilla con Barra',      grupo: 'Piernas', etiquetas: ['Compuesto', 'Barra'],        grupoColor: Color(0xFF00D4FF)),
  const _EjercicioAdmin(id: '8', nombre: 'Prensa de Piernas',         grupo: 'Piernas', etiquetas: ['Compuesto', 'Máquina'],      grupoColor: Color(0xFF00D4FF)),
  const _EjercicioAdmin(id: '9', nombre: 'Curl de Bíceps',            grupo: 'Brazos',  etiquetas: ['Aislamiento', 'Mancuernas'], grupoColor: Color(0xFFFF9500)),
  const _EjercicioAdmin(id:'10', nombre: 'Extensión Tríceps Polea',   grupo: 'Brazos',  etiquetas: ['Aislamiento', 'Polea'],      grupoColor: Color(0xFFFF9500)),
  const _EjercicioAdmin(id:'11', nombre: 'Crunch Abdominal',          grupo: 'Abdomen', etiquetas: ['Aislamiento', 'Peso corporal'],grupoColor: Color(0xFF00E676)),
  const _EjercicioAdmin(id:'12', nombre: 'Plancha',                   grupo: 'Abdomen', etiquetas: ['Isométrico', 'Peso corporal'],grupoColor: Color(0xFF00E676)),
  const _EjercicioAdmin(id:'13', nombre: 'Carrera en Cinta',          grupo: 'Cardio',  etiquetas: ['Cardio', 'Máquina'],          grupoColor: Colors.redAccent),
];

const _filtros = ['Todos', 'Pecho', 'Espalda', 'Pierna', 'Brazos', 'Abdomen', 'Cardio'];

// ─── Admin Ejercicios Screen ──────────────────────────────────────────────────
class AdminEjerciciosScreen extends StatefulWidget {
  const AdminEjerciciosScreen({super.key});

  @override
  State<AdminEjerciciosScreen> createState() => _AdminEjerciciosScreenState();
}

class _AdminEjerciciosScreenState extends State<AdminEjerciciosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;

  int _filtroIndex = 0;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_EjercicioAdmin> get _filtrados {
    var lista = _ejerciciosData;
    if (_filtroIndex != 0) {
      final filtro = _filtros[_filtroIndex].toLowerCase();
      lista = lista
          .where((e) => e.grupo.toLowerCase().contains(filtro))
          .toList();
    }
    if (_search.isNotEmpty) {
      lista = lista
          .where((e) =>
              e.nombre.toLowerCase().contains(_search.toLowerCase()) ||
              e.grupo.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    return lista;
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            SizedBox(width: 10),
            Text('Cerrar sesión',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await AuthService().logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
  }

  void _showAddDialog() {
    _showEjercicioDialog(context, null);
  }

  void _showEditDialog(_EjercicioAdmin e) {
    _showEjercicioDialog(context, e);
  }

  void _confirmDelete(_EjercicioAdmin e) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => _DeleteDialog(nombre: e.nombre),
    ).then((confirm) {
      if (confirm == true) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('🗑️ "${e.nombre}" eliminado',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });
  }

  void _showEjercicioDialog(BuildContext context, _EjercicioAdmin? ejercicio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EjercicioFormSheet(ejercicio: ejercicio),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;

    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────
              _AdminTopBar(
                title: 'Gestión de Ejercicios',
                subtitle: '${lista.length} EJERCICIOS EN TOTAL',
                onAdd: _showAddDialog,
                onLogout: _cerrarSesion,
              ),
              // ── Search ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: _SearchField(controller: _searchCtrl),
              ),
              // ── Filtros ────────────────────────────────────────────────
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filtros.length,
                  itemBuilder: (context, i) {
                    final active = _filtroIndex == i;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _filtroIndex = i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: active ? AppColors.cyberLime : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active
                                  ? AppColors.cyberLime
                                  : AppColors.steamGray.withOpacity(0.12)),
                        ),
                        child: Center(
                          child: Text(_filtros[i],
                              style: TextStyle(
                                color: active
                                    ? AppColors.carbonBlack
                                    : AppColors.steamGray.withOpacity(0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              )),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // ── Resultado count ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${lista.length} resultado${lista.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppColors.steamGray.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // ── Lista ──────────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  physics: const BouncingScrollPhysics(),
                  itemCount: lista.length,
                  itemBuilder: (context, i) => _EjercicioAdminCard(
                    ejercicio: lista[i],
                    onEdit: () => _showEditDialog(lista[i]),
                    onDelete: () => _confirmDelete(lista[i]),
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

// ─── Ejercicio Admin Card ─────────────────────────────────────────────────────
class _EjercicioAdminCard extends StatelessWidget {
  final _EjercicioAdmin ejercicio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EjercicioAdminCard({
    required this.ejercicio,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final e = ejercicio;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: e.grupoColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Barra lateral de color
          Container(
            width: 4, height: 44,
            decoration: BoxDecoration(
              color: e.grupoColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: e.grupoColor.withOpacity(0.5), blurRadius: 6)
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.nombre,
                    style: const TextStyle(
                      color: AppColors.steamGray,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    // Grupo (con color)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: e.grupoColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: e.grupoColor.withOpacity(0.3)),
                      ),
                      child: Text(e.grupo,
                          style: TextStyle(
                            color: e.grupoColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    // Etiquetas
                    ...e.etiquetas.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.steamGray.withOpacity(0.1)),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                color: AppColors.steamGray.withOpacity(0.5),
                                fontSize: 10,
                              )),
                        )),
                  ],
                ),
              ],
            ),
          ),
          // Botones editar / eliminar
          Row(
            children: [
              _IconBtn(
                icon: Icons.edit_rounded,
                color: AppColors.electricViolet,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon: Icons.delete_outline_rounded,
                color: Colors.redAccent,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Widgets compartidos ──────────────────────────────────────────────────────
class _AdminTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  final VoidCallback? onLogout;

  const _AdminTopBar({
    required this.title,
    required this.subtitle,
    required this.onAdd,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Badge ADMIN
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
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: AppColors.steamGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    )),
                Text(subtitle,
                    style: TextStyle(
                      color: AppColors.cyberLime.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    )),
              ],
            ),
          ),
          // Botón añadir
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.cyberLime.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cyberLime.withOpacity(0.3)),
              ),
              child: const Icon(Icons.fitness_center_rounded,
                  color: AppColors.cyberLime, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // Botón cerrar sesión
          GestureDetector(
            onTap: onLogout,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.steamGray, fontSize: 14),
      cursorColor: AppColors.cyberLime,
      decoration: InputDecoration(
        hintText: 'Buscar ejercicio...',
        hintStyle: TextStyle(color: AppColors.steamGray.withOpacity(0.3)),
        prefixIcon: Icon(Icons.search_rounded,
            color: AppColors.steamGray.withOpacity(0.35), size: 20),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: AppColors.steamGray.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.cyberLime, width: 1.5)),
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

// ─── Dialog eliminar ──────────────────────────────────────────────────────────
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
              child: const Icon(Icons.delete_forever_rounded,
                  color: Colors.redAccent, size: 24),
            ),
            const SizedBox(height: 16),
            Text('¿Eliminar "$nombre"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.steamGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Esta acción no se puede deshacer.',
                style: TextStyle(
                    color: AppColors.steamGray.withOpacity(0.4), fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Cancelar',
                            style: TextStyle(
                                color: AppColors.steamGray,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Eliminar',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
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

// ─── Form Sheet (agregar / editar) ────────────────────────────────────────────
class _EjercicioFormSheet extends StatefulWidget {
  final _EjercicioAdmin? ejercicio;
  const _EjercicioFormSheet({this.ejercicio});

  @override
  State<_EjercicioFormSheet> createState() => _EjercicioFormSheetState();
}

class _EjercicioFormSheetState extends State<_EjercicioFormSheet> {
  late TextEditingController _nombreCtrl;
  String _grupoSel = 'Pecho';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.ejercicio?.nombre ?? '');
    _grupoSel = widget.ejercicio?.grupo ?? 'Pecho';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_nombreCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.cyberLime,
          content: Text(
            widget.ejercicio == null
                ? '✅ Ejercicio creado'
                : '✅ Ejercicio actualizado',
            style: const TextStyle(
                color: AppColors.carbonBlack, fontWeight: FontWeight.bold),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.ejercicio != null;
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
            Text(isEdit ? 'Editar ejercicio' : 'Nuevo ejercicio',
                style: const TextStyle(
                    color: AppColors.steamGray,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            // Nombre
            TextField(
              controller: _nombreCtrl,
              style: const TextStyle(color: AppColors.steamGray),
              cursorColor: AppColors.cyberLime,
              decoration: InputDecoration(
                hintText: 'Nombre del ejercicio',
                hintStyle: TextStyle(color: AppColors.steamGray.withOpacity(0.3)),
                filled: true,
                fillColor: AppColors.carbonBlack,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cyberLime, width: 1.5)),
              ),
            ),
            const SizedBox(height: 14),
            // Grupo selector
            Text('Grupo muscular',
                style: TextStyle(
                    color: AppColors.steamGray.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _grupoColores.keys.map((g) {
                final sel = _grupoSel == g;
                final color = _grupoColores[g]!;
                return GestureDetector(
                  onTap: () => setState(() => _grupoSel = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? color.withOpacity(0.2) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel ? color : AppColors.steamGray.withOpacity(0.1)),
                    ),
                    child: Text(g,
                        style: TextStyle(
                          color: sel ? color : AppColors.steamGray.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loading ? null : _guardar,
              child: Container(
                width: double.infinity, height: 50,
                decoration: BoxDecoration(
                  color: AppColors.cyberLime,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.cyberLime.withOpacity(0.35),
                        blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: AppColors.carbonBlack, strokeWidth: 2.5))
                      : Text(isEdit ? 'GUARDAR CAMBIOS' : 'CREAR EJERCICIO',
                          style: const TextStyle(
                              color: AppColors.carbonBlack,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}