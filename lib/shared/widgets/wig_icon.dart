import 'package:flutter/material.dart';

/// A hand-drawn barrister's wig icon built with [CustomPainter].
///
/// Shape: rounded dome at top + 3 rows × 4 circles (curls) below.
/// Used in the drawer menu item and the Companion screen chip.
class WigIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WigIcon({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF2D3748),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _WigPainter(color)),
    );
  }
}

class _WigPainter extends CustomPainter {
  final Color color;
  const _WigPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // ── Dome (top of the wig) ──────────────────────────────────────────────
    final domePath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.05, 0, w * 0.90, h * 0.44),
        topLeft: Radius.circular(w * 0.45),
        topRight: Radius.circular(w * 0.45),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      ));
    canvas.drawPath(domePath, paint);

    // ── Connector strip (dome → curls) ────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, h * 0.38, w * 0.90, h * 0.06),
      paint,
    );

    // ── Curl rows ─────────────────────────────────────────────────────────
    // 4 circles per row, 3 rows
    final curlR = w * 0.105;
    const cols = 4;
    final spacing = (w - 2 * curlR) / (cols - 1);
    final rowCentersY = [h * 0.55, h * 0.73, h * 0.91];

    for (final cy in rowCentersY) {
      for (int i = 0; i < cols; i++) {
        canvas.drawCircle(Offset(curlR + i * spacing, cy), curlR, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_WigPainter old) => old.color != color;
}
