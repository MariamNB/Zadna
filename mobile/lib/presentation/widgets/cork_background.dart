import 'package:flutter/material.dart';
import '../../core/kitchen_theme.dart';

class CorkBackground extends StatelessWidget {
  final Widget child;
  const CorkBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KitchenTheme.background,
      child: CustomPaint(
        painter: _CorkPainter(),
        child: child,
      ),
    );
  }
}

class _CorkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KitchenTheme.corkDot.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    const double spacing = 18;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final offsetX = x + ((y / spacing).floor() % 2) * (spacing / 2);
        canvas.drawCircle(Offset(offsetX, y), 1.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CorkPainter old) => false;
}
