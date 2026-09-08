import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HostEventInsightsScreen extends StatelessWidget {
  final String eventId;

  const HostEventInsightsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final primaryPurple = const Color(0xFF5614D0);
    final textDark = const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB), // Very light gray/purple background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: primaryPurple, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Edit',
              style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // 1. Header Card (Event Details)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    'Neon Nights Festival',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: primaryPurple,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: primaryPurple),
                      const SizedBox(width: 6),
                      Text(
                        "24 Aug '25",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "10 PM - 2 AM",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryPurple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16, color: primaryPurple),
                      const SizedBox(width: 6),
                      Text(
                        "Cyber Pier 9",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Ticket Inventory Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TICKET INVENTORY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '428',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: primaryPurple, letterSpacing: -1),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ 500 Sold',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.confirmation_num_outlined, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('85% Capacity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                      Text('72 Rem.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Custom gradient progress bar
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.85,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5614D0), Color(0xFFF5A623)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Financials Row
            Row(
              children: [
                Expanded(
                  child: _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GROSS VALUE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('₹', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textDark)),
                            const SizedBox(width: 2),
                            Text('2,04,500', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCard(
                    backgroundColor: const Color(0xFFF3FAF5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NET EARNINGS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('₹', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0C8259))),
                            const SizedBox(width: 2),
                            const Text('1,82,400', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0C8259), letterSpacing: -0.5)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('After 10.0% platform fees', style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Audience Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audience',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 24),
                  
                  // Donut Chart Placeholder - would ideally use CustomPaint, creating a basic visual structure for now
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(180, 180),
                            painter: DonutChartPainter(
                              segments: [
                                ChartSegment(value: 60, color: primaryPurple),
                                ChartSegment(value: 35, color: const Color(0xFFF5A623)),
                                ChartSegment(value: 5, color: Colors.grey.shade300),
                              ],
                              strokeWidth: 20,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                              const SizedBox(height: 4),
                              Text('DEMOGRAPHICS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Demographics breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('60%', 'FEMALE', primaryPurple),
                      _buildStatColumn('35%', 'MALE', const Color(0xFFF5A623)),
                      _buildStatColumn('5%', 'OTHER', textDark),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Guest Loyalty',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 12),
                  
                  // Loyalty progress bar
                  Row(
                    children: [
                      Expanded(
                        flex: 58,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: primaryPurple,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 42,
                        child: Container(
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5A623),
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLegendDot('First Timers (58%)', primaryPurple),
                      _buildLegendDot('Returning (42%)', const Color(0xFFF5A623)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Attendees Summary Card
            _buildCard(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ATTENDEES',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '382',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: primaryPurple, letterSpacing: -1),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Attended',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, Color backgroundColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1),
        ),
      ],
    );
  }
  
  Widget _buildLegendDot(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class ChartSegment {
  final double value;
  final Color color;
  ChartSegment({required this.value, required this.color});
}

class DonutChartPainter extends CustomPainter {
  final List<ChartSegment> segments;
  final double strokeWidth;

  DonutChartPainter({required this.segments, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double total = 0;
    for (var seg in segments) {
      total += seg.value;
    }

    double startAngle = -pi / 2; // Start from top

    for (var seg in segments) {
      final sweepAngle = (seg.value / total) * 2 * pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
