import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'informacion_ejercicio_screen.dart';

// ─── Modelo ───────────────────────────────────────────────────────────────────
class EjercicioData {
  final String nombre;
  final String musculo;
  final String nivel;
  final List<String> etiquetas;
  final Color color;
  final String? imageUrl;

  const EjercicioData({
    required this.nombre,
    required this.musculo,
    required this.nivel,
    required this.etiquetas,
    required this.color,
    this.imageUrl,
  });
}

// Mock data por grupo muscular
final _ejerciciosPorGrupo = <String, List<EjercicioData>>{
  'pecho': [
    EjercicioData(
      nombre: 'Press de Banca Plano',
      musculo: 'Pectoral Mayor',
      nivel: 'INTERMEDIO',
      etiquetas: ['Barra', 'Banco'],
      color: AppColors.cyberLime,
    ),
    EjercicioData(
      nombre: 'Aperturas con Mancuernas',
      musculo: 'Pectoral Mayor',
      nivel: 'PRINCIPIANTE',
      etiquetas: ['Mancuernas', 'Aislamiento'],
      color: const Color(0xFF00D4FF),
    ),
    EjercicioData(
      nombre: 'Fondos en Paralelas',
      musculo: 'Pectoral Inferior',
      nivel: 'INTERMEDIO',
      etiquetas: ['Peso Corporal', 'Compuesto'],
      color: AppColors.electricViolet,
    ),
    EjercicioData(
      nombre: 'Press Inclinado con Barra',
      musculo: 'Pectoral Clavicular',
      nivel: 'INTERMEDIO',
      etiquetas: ['Barra', 'Banco Inclinado'],
      color: AppColors.cyberLime,
    ),
    EjercicioData(
      nombre: 'Crossover en Polea',
      musculo: 'Pectoral Mayor',
      nivel: 'PRINCIPIANTE',
      etiquetas: ['Polea', 'Aislamiento'],
      color: const Color(0xFFFF9500),
    ),
    EjercicioData(
      nombre: 'Push-Up',
      musculo: 'Pectoral Mayor',
      nivel: 'PRINCIPIANTE',
      etiquetas: ['Peso Corporal', 'Compuesto'],
      color: const Color(0xFF00E676),
    ),
  ],
  'espalda': [
    EjercicioData(
      nombre: 'Dominadas',
      musculo: 'Dorsal Ancho',
      nivel: 'INTERMEDIO',
      etiquetas: ['Peso Corporal', 'Compuesto'],
      color: const Color(0xFF00D4FF),
    ),
    EjercicioData(
      nombre: 'Remo con Barra',
      musculo: 'Trapecio Medio',
      nivel: 'AVANZADO',
      etiquetas: ['Barra', 'Compuesto'],
      color: AppColors.electricViolet,
    ),
    EjercicioData(
      nombre: 'Jalón al Pecho',
      musculo: 'Dorsal Ancho',
      nivel: 'PRINCIPIANTE',
      etiquetas: ['Polea', 'Compuesto'],
      color: AppColors.cyberLime,
    ),
  ],
  'piernas': [
    EjercicioData(
      nombre: 'Sentadilla con Barra',
      musculo: 'Cuádriceps',
      nivel: 'INTERMEDIO',
      etiquetas: ['Barra', 'Compuesto'],
      color: AppColors.electricViolet,
    ),
    EjercicioData(
      nombre: 'Peso Muerto Rumano',
      musculo: 'Isquiotibiales',
      nivel: 'AVANZADO',
      etiquetas: ['Barra', 'Compuesto'],
      color: AppColors.cyberLime,
    ),
    EjercicioData(
      nombre: 'Prensa de Piernas',
      musculo: 'Cuádriceps',
      nivel: 'PRINCIPIANTE',
      etiquetas: ['Máquina', 'Compuesto'],
      color: const Color(0xFF00D4FF),
    ),
  ],
};

// ─── Screen ───────────────────────────────────────────────────────────────────
class ListaEjerciciosScreen extends StatefulWidget {
  final String grupoId;
  final String grupoNombre;
  final Color color;
  final int cantidad;

  const ListaEjerciciosScreen({
    super.key,
    required this.grupoId,
    required this.grupoNombre,
    required this.color,
    required this.cantidad,
  });

  @override
  State<ListaEjerciciosScreen> createState() =>
      _ListaEjerciciosScreenState();
}

class _ListaEjerciciosScreenState extends State<ListaEjerciciosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;

  List<EjercicioData> get _ejercicios =>
      _ejerciciosPorGrupo[widget.grupoId] ?? [];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
    _fadeAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                              color: widget.color.withOpacity(0.5),
                              blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'EJERCICIOS DISPONIBLES',
                      style: TextStyle(
                        color: AppColors.steamGray.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _ejercicios.length,
                  itemBuilder: (context, i) =>
                      _EjercicioCard(
                    ejercicio: _ejercicios[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InformacionEjercicioScreen(
                          ejercicio: _ejercicios[i],
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
    );
  }

  Widget _buildHeader() {
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: widget.color.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(Icons.fitness_center_rounded,
                color: widget.color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ejercicios de ${widget.grupoNombre}',
                style: const TextStyle(
                  color: AppColors.steamGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${_ejercicios.length} ejercicios · Músculo ${widget.grupoNombre}al',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Ejercicio Card ───────────────────────────────────────────────────────────
class _EjercicioCard extends StatefulWidget {
  final EjercicioData ejercicio;
  final VoidCallback onTap;

  const _EjercicioCard({
    required this.ejercicio,
    required this.onTap,
  });

  @override
  State<_EjercicioCard> createState() => _EjercicioCardState();
}

class _EjercicioCardState extends State<_EjercicioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _nivelColor {
    switch (widget.ejercicio.nivel) {
      case 'PRINCIPIANTE':
        return const Color(0xFF00D4FF);
      case 'AVANZADO':
        return Colors.redAccent;
      default:
        return AppColors.electricViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.ejercicio;

    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); HapticFeedback.lightImpact(); },
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: e.color.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Imagen de fondo si existe
                if (e.imageUrl != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 120,
                    child: Image.network(
                      e.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: e.color.withOpacity(0.05),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: e.color.withOpacity(0.2),
                          size: 40,
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surface,
                            e.color.withOpacity(0.08),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: e.color.withOpacity(0.15),
                        size: 48,
                      ),
                    ),
                  ),
                // Gradiente para legibilidad
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withOpacity(0.9),
                          AppColors.surface.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.5, 0.75, 1],
                      ),
                    ),
                  ),
                ),
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nivel badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _nivelColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _nivelColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          e.nivel,
                          style: TextStyle(
                            color: _nivelColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        e.nombre,
                        style: const TextStyle(
                          color: AppColors.steamGray,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: e.color, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            e.musculo,
                            style: TextStyle(
                              color: AppColors.steamGray.withOpacity(0.55),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: e.etiquetas.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.steamGray.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: AppColors.steamGray.withOpacity(0.55),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // Botón flecha
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: e.color.withOpacity(0.15),
                      border:
                          Border.all(color: e.color.withOpacity(0.35)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: e.color,
                      size: 12,
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
