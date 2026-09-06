import 'dart:math';
import 'package:flutter/material.dart';
import 'den_logo.dart';

/// A custom branded QR Code widget that draws a clean QR matrix with
/// the 'den' badge in the center.
class DenQrCode extends StatelessWidget {
  final String data;
  final double size;

  const DenQrCode({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // QR Matrix Custom Painter
          CustomPaint(
            size: Size(size, size),
            painter: _DenQrPainter(data: data),
          ),

          // Center 'den' badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DenLogo(size: size * 0.1),
                const SizedBox(width: 4),
                const Text(
                  'den',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DenQrPainter extends CustomPainter {
  final String data;

  _DenQrPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    const moduleCount = 25;
    final moduleSize = size.width / moduleCount;

    // Deterministic pseudo-random matrix derived from data hash
    final seed = data.hashCode.abs();
    final random = Random(seed);

    // Draw finder patterns (top-left, top-right, bottom-left)
    _drawFinderPattern(canvas, paint, 0, 0, moduleSize);
    _drawFinderPattern(canvas, paint, (moduleCount - 7) * moduleSize, 0, moduleSize);
    _drawFinderPattern(canvas, paint, 0, (moduleCount - 7) * moduleSize, moduleSize);

    // Reserved center box for 'den' logo: 9x9 modules in center
    const centerStart = 8;
    const centerEnd = 16;

    for (int r = 0; r < moduleCount; r++) {
      for (int c = 0; c < moduleCount; c++) {
        // Skip finder patterns
        if ((r < 8 && c < 8) || (r < 8 && c >= moduleCount - 8) || (r >= moduleCount - 8 && c < 8)) {
          continue;
        }

        // Skip center logo
        if (r >= centerStart && r <= centerEnd && c >= centerStart && c <= centerEnd) {
          continue;
        }

        // Module bits
        final isFilled = random.nextBool();
        if (isFilled) {
          final rect = Rect.fromLTWH(
            c * moduleSize + 0.5,
            r * moduleSize + 0.5,
            moduleSize - 1,
            moduleSize - 1,
          );
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(1.5)), paint);
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, double x, double y, double moduleSize) {
    // 7x7 outer square
    final outerRect = Rect.fromLTWH(x, y, 7 * moduleSize, 7 * moduleSize);
    canvas.drawRRect(RRect.fromRectAndRadius(outerRect, const Radius.circular(4)), paint);

    // 5x5 white inner
    final whitePaint = Paint()..color = Colors.white;
    final innerWhite = Rect.fromLTWH(x + moduleSize, y + moduleSize, 5 * moduleSize, 5 * moduleSize);
    canvas.drawRect(innerWhite, whitePaint);

    // 3x3 solid core
    final coreRect = Rect.fromLTWH(x + 2 * moduleSize, y + 2 * moduleSize, 3 * moduleSize, 3 * moduleSize);
    canvas.drawRRect(RRect.fromRectAndRadius(coreRect, const Radius.circular(2)), paint);
  }

  @override
  bool shouldRepaint(covariant _DenQrPainter oldDelegate) => oldDelegate.data != data;
}
