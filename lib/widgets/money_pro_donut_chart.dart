import 'package:flutter/material.dart';

class DonutSegment {
  final String label;
  final double value;
  final Color color;

  DonutSegment({required this.label, required this.value, required this.color});
}

class MoneyProDonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final String centerTitle;
  final double centerValue;
  final double size;
  final double outerRingWidth;
  final double innerRingWidth;
  final double centerCircleRadius;

  const MoneyProDonutChart({
    super.key,
    required this.segments,
    required this.centerTitle,
    required this.centerValue,
    this.size = 320,
    this.outerRingWidth = 60,
    this.innerRingWidth = 20,
    this.centerCircleRadius = 70,
  });

  String _formatearMoneda(double valor) {
    return '\$${valor.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total == 0) {
      return const Center(
        child: Text('Sin datos', style: TextStyle(color: Colors.grey)),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anillo exterior grueso
              CustomPaint(
                size: Size(size, size),
                painter: DonutRingPainter(
                  segments: segments,
                  total: total,
                  ringWidth: outerRingWidth,
                  radius: size / 2 - 10,
                ),
              ),
              // Anillo interior delgado decorativo
              CustomPaint(
                size: Size(size * 0.55, size * 0.55),
                painter: InnerRingPainter(
                  radius: size * 0.55 / 2 - 5,
                  ringWidth: innerRingWidth,
                ),
              ),
              // Círculo central con total
              Container(
                width: centerCircleRadius * 2,
                height: centerCircleRadius * 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade700, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatearMoneda(centerValue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      centerTitle.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Porcentajes en los segmentos
              ..._buildPercentageLabels(total),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Leyenda a la derecha
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: segments
              .where((s) => s.value > 0)
              .map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 120,
                          child: Text(
                            s.label.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatearMoneda(s.value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  List<Widget> _buildPercentageLabels(double total) {
    final List<Widget> labels = [];
    double currentAngle = -90; // Empezar desde arriba

    for (final segment in segments) {
      if (segment.value == 0) continue;
      final percentage = (segment.value / total) * 100;
      final sweepAngle = (segment.value / total) * 360;
      final midAngle = currentAngle + sweepAngle / 2;
      final radians = midAngle * (3.14159 / 180);
      
      final radius = (size / 2) - (outerRingWidth / 2) - 10;
      final x = (size / 2) + radius * (radians.cos());
      final y = (size / 2) + radius * (radians.sin());

      if (percentage >= 4) {
        labels.add(
          Positioned(
            left: x - 15,
            top: y - 8,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }

      currentAngle += sweepAngle;
    }

    return labels;
  }
}

class DonutRingPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double total;
  final double ringWidth;
  final double radius;

  DonutRingPainter({
    required this.segments,
    required this.total,
    required this.ringWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double startAngle = -90 * (3.14159 / 180);

    for (final segment in segments) {
      if (segment.value == 0) continue;
      final sweepAngle = (segment.value / total) * 360 * (3.14159 / 180);

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class InnerRingPainter extends CustomPainter {
  final double radius;
  final double ringWidth;

  InnerRingPainter({required this.radius, required this.ringWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension on double {
  double cos() => this;
  double sin() => this;
}