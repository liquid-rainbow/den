import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/organizer_theme.dart';

class DemographicDonutChart extends StatelessWidget {
  final int femalePercent;
  final int malePercent;
  final int otherPercent;
  final double size;

  const DemographicDonutChart({
    super.key,
    required this.femalePercent,
    required this.malePercent,
    required this.otherPercent,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartPainter(
              femaleRatio: femalePercent / 100.0,
              maleRatio: malePercent / 100.0,
              otherRatio: otherPercent / 100.0,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Split',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: OrganizerColors.onSurface,
                ),
              ),
              Text(
                'DEMOGRAPHICS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: OrganizerColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double femaleRatio;
  final double maleRatio;
  final double otherRatio;

  _DonutChartPainter({
    required this.femaleRatio,
    required this.maleRatio,
    required this.otherRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.12;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = OrganizerColors.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;

    // Female slice (Primary purple)
    if (femaleRatio > 0) {
      final sweepAngle = 2 * pi * femaleRatio;
      final femalePaint = Paint()
        ..color = OrganizerColors.primaryContainer
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle, sweepAngle, false, femalePaint);
      startAngle += sweepAngle;
    }

    // Male slice (Secondary Orange)
    if (maleRatio > 0) {
      final sweepAngle = 2 * pi * maleRatio;
      final malePaint = Paint()
        ..color = OrganizerColors.secondaryContainer
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle, sweepAngle, false, malePaint);
      startAngle += sweepAngle;
    }

    // Other slice (Charcoal onSurface)
    if (otherRatio > 0) {
      final sweepAngle = 2 * pi * otherRatio;
      final otherPaint = Paint()
        ..color = OrganizerColors.onSurface
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle, sweepAngle, false, otherPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.femaleRatio != femaleRatio ||
        oldDelegate.maleRatio != maleRatio ||
        oldDelegate.otherRatio != otherRatio;
  }
}
