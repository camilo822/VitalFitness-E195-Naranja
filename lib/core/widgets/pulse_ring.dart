import 'package:flutter/material.dart';

/// Anillo animado que pulsa — se usa en el avatar del header.
class PulseRing extends StatefulWidget {
  final double size;
  final Color color;
  const PulseRing({super.key, required this.size, required this.color});

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _scale   = Tween<double>(begin: 0.7, end: 1.4).animate(_ctrl);
    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(_ctrl);
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
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(_opacity.value),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
