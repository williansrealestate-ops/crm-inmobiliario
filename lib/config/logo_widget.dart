import 'package:flutter/material.dart';
import 'theme.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  const LogoWidget({super.key, this.size = 48, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícono de techo/montaña
        CustomPaint(
          size: Size(size, size * 0.75),
          painter: _LogoPainter(color: AppTheme.accent),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          const Text(
            'REAL ESTATE',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Forma de techo: triángulo con corte en la base
    path.moveTo(size.width / 2, 0); // Punta superior
    path.lineTo(size.width, size.height * 0.75); // Esquina derecha
    path.lineTo(size.width * 0.65, size.height * 0.75); // Base derecha interna
    path.lineTo(size.width / 2, size.height * 0.45); // Centro (corte)
    path.lineTo(
        size.width * 0.35, size.height * 0.75); // Base izquierda interna
    path.lineTo(0, size.height * 0.75); // Esquina izquierda
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
