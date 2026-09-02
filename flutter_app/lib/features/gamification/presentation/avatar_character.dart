import 'dart:math' as math;

import 'package:flutter/material.dart';

class AvatarCharacter extends StatelessWidget {
  const AvatarCharacter({
    required this.equipped,
    this.size = 190,
    this.running = false,
    this.phase = 0,
    super.key,
  });

  final Map<String, String> equipped;
  final double size;
  final bool running;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Your customized HabitWise character',
      child: CustomPaint(
        size: Size(size, size),
        painter: _AvatarPainter(
          equipped: equipped,
          running: running,
          phase: phase,
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter({
    required this.equipped,
    required this.running,
    required this.phase,
  });

  final Map<String, String> equipped;
  final bool running;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 190;
    canvas.save();
    canvas.scale(scale);
    final bob = running ? math.sin(phase * math.pi * 2) * 3 : 0.0;
    canvas.translate(0, bob);
    final bodyColor = switch (equipped['baseColor']) {
      'base_coral' => const Color(0xFFFF806D),
      'base_cyan' => const Color(0xFF4EC5CF),
      _ => const Color(0xFF7557A8),
    };
    final outline = Paint()
      ..color = const Color(0xFF32233D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    if (equipped['trail'] == 'trail_comet') {
      final trail = Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0x00FF806D), Color(0xFFFF806D)],
        ).createShader(const Rect.fromLTWH(5, 110, 70, 22));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(10, 116, 70, 18),
          const Radius.circular(20),
        ),
        trail,
      );
    }
    if (equipped['back'] == 'back_wings') {
      final wing = Paint()..color = const Color(0xFFBCEFF1);
      canvas.drawOval(const Rect.fromLTWH(45, 81, 34, 55), wing);
      canvas.drawOval(const Rect.fromLTWH(111, 81, 34, 55), wing);
      canvas.drawOval(const Rect.fromLTWH(45, 81, 34, 55), outline);
      canvas.drawOval(const Rect.fromLTWH(111, 81, 34, 55), outline);
    }

    final stride = running ? math.sin(phase * math.pi * 2) * 7 : 0.0;
    final legPaint = Paint()
      ..color = equipped['bottom'] == 'bottom_night'
          ? const Color(0xFF453B60)
          : bodyColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(72 + stride, 130, 18, 39),
        const Radius.circular(9),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(101 - stride, 130, 18, 39),
        const Radius.circular(9),
      ),
      legPaint,
    );
    final shoes = Paint()
      ..color = equipped['shoes'] == 'shoes_spark'
          ? const Color(0xFFFF806D)
          : const Color(0xFFF7F0E8);
    canvas.drawOval(Rect.fromLTWH(64 + stride, 159, 31, 17), shoes);
    canvas.drawOval(Rect.fromLTWH(96 - stride, 159, 31, 17), shoes);

    final topColor = equipped['top'] == 'top_coral'
        ? const Color(0xFFFF806D)
        : const Color(0xFFF7F0E8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(57, 85, 76, 65),
        const Radius.circular(25),
      ),
      Paint()..color = topColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(57, 85, 76, 65),
        const Radius.circular(25),
      ),
      outline,
    );

    canvas.drawCircle(const Offset(95, 58), 45, Paint()..color = bodyColor);
    canvas.drawCircle(const Offset(95, 58), 45, outline);
    if (equipped['hat'] == 'hat_beanie') {
      canvas.drawArc(
        const Rect.fromLTWH(54, 13, 82, 67),
        math.pi,
        math.pi,
        true,
        Paint()..color = const Color(0xFF4EC5CF),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(52, 34, 86, 15),
          const Radius.circular(7),
        ),
        Paint()..color = const Color(0xFF4EC5CF),
      );
    }

    final eyePaint = Paint()..color = const Color(0xFF22172B);
    if (equipped['eyes'] == 'eyes_star') {
      _drawStar(canvas, const Offset(79, 57), 7, eyePaint);
      _drawStar(canvas, const Offset(111, 57), 7, eyePaint);
    } else {
      canvas.drawOval(const Rect.fromLTWH(73, 51, 12, 16), eyePaint);
      canvas.drawOval(const Rect.fromLTWH(105, 51, 12, 16), eyePaint);
    }
    if (equipped['glasses'] == 'glasses_round') {
      final glasses = Paint()
        ..color = const Color(0xFF32233D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(const Offset(79, 59), 13, glasses);
      canvas.drawCircle(const Offset(111, 59), 13, glasses);
      canvas.drawLine(const Offset(92, 59), const Offset(98, 59), glasses);
    }
    final mouth = Path()..moveTo(84, 77);
    if (equipped['expression'] == 'expression_focus') {
      mouth.lineTo(106, 77);
    } else {
      mouth.quadraticBezierTo(95, 88, 106, 77);
    }
    canvas.drawPath(mouth, outline);

    if (equipped['scarf'] == 'scarf_lavender') {
      final scarf = Paint()..color = const Color(0xFFBDA7E5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(56, 88, 78, 13),
          const Radius.circular(7),
        ),
        scarf,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(113, 94, 17, 38),
          const Radius.circular(7),
        ),
        scarf,
      );
    }
    canvas.restore();
  }

  static void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    for (var index = 0; index < 10; index++) {
      final angle = -math.pi / 2 + index * math.pi / 5;
      final r = index.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      oldDelegate.equipped != equipped ||
      oldDelegate.running != running ||
      oldDelegate.phase != phase;
}
