import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Patrón de hexágonos de fondo usado en las tarjetas de home.
class HexPainter extends CustomPainter {
  final Color color;
  const HexPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const r = 18.0;
    const w = r * 2;
    final h = r * math.sqrt(3);

    for (double row = -1; row < size.height / h + 2; row++) {
      for (double col = -1; col < size.width / w + 2; col++) {
        final cx = col * w * 0.75 + (row.toInt().isOdd ? w * 0.375 : 0);
        final cy = row * h;
        _drawHex(canvas, paint, Offset(cx, cy), r);
      }
    }
  }

  void _drawHex(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
