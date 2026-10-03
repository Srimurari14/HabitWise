import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The HabitWise character: an original, stylised human figure drawn with
/// Flutter's canvas, so every garment layers cleanly and animates in the game.
///
/// Everything is laid out on a 190 by 190 square and scaled to [size].
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
      label: 'Your HabitWise character',
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

  static const _ink = Color(0xFF2A2430);
  static const _hair = Color(0xFF2B2320);

  Color get _skin => switch (equipped['baseColor']) {
    'skin_porcelain' => const Color(0xFFF3D3BC),
    'skin_sand' => const Color(0xFFE3B591),
    'skin_bronze' => const Color(0xFFA9683F),
    'skin_espresso' => const Color(0xFF6E3F26),
    _ => const Color(0xFFC98D62),
  };

  Color get _shirt => switch (equipped['top']) {
    'top_cream' => const Color(0xFFF3ECDE),
    'top_coral' => const Color(0xFFE8654F),
    _ => const Color(0xFF1E1E24),
  };

  Color get _trousers => switch (equipped['bottom']) {
    'bottom_night' => const Color(0xFF2E3552),
    _ => const Color(0xFF1B1B22),
  };

  Color get _shoeColor => switch (equipped['shoes']) {
    'shoes_cloud' => const Color(0xFFF2EFE8),
    'shoes_spark' => const Color(0xFFE8654F),
    _ => const Color(0xFF2A2A32),
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 190);

    final stride = running ? math.sin(phase * math.pi * 2) * 8 : 0.0;
    final bob = running ? math.sin(phase * math.pi * 4).abs() * 2.5 : 0.0;
    canvas.translate(0, -bob);

    final outline = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _paintBehind(canvas, outline);
    _paintLegs(canvas, outline, stride);
    _paintTorso(canvas, outline);
    _paintArms(canvas, outline, stride);
    _paintHead(canvas, outline);

    canvas.restore();
  }

  void _paintBehind(Canvas canvas, Paint outline) {
    if (equipped['trail'] == 'trail_comet') {
      final trail = Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0x00E8654F), Color(0xCCE8654F)],
        ).createShader(const Rect.fromLTWH(8, 150, 78, 20));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 152, 78, 16),
          const Radius.circular(18),
        ),
        trail,
      );
    }
    if (equipped['back'] == 'back_wings') {
      final wing = Paint()..color = const Color(0xFFBCEFF1);
      final left = Path()
        ..moveTo(78, 74)
        ..quadraticBezierTo(38, 68, 44, 118)
        ..quadraticBezierTo(62, 104, 78, 108)
        ..close();
      final right = Path()
        ..moveTo(112, 74)
        ..quadraticBezierTo(152, 68, 146, 118)
        ..quadraticBezierTo(128, 104, 112, 108)
        ..close();
      canvas
        ..drawPath(left, wing)
        ..drawPath(right, wing)
        ..drawPath(left, outline)
        ..drawPath(right, outline);
    }
  }

  void _paintLegs(Canvas canvas, Paint outline, double stride) {
    final trousers = Paint()..color = _trousers;
    final shoes = Paint()..color = _shoeColor;

    for (final side in <int>[-1, 1]) {
      final swing = stride * side;
      final hipX = 95 + side * 11.0;
      final leg = RRect.fromRectAndRadius(
        Rect.fromLTWH(hipX - 8 + swing * 0.4, 108, 16, 48),
        const Radius.circular(7),
      );
      canvas
        ..drawRRect(leg, trousers)
        ..drawRRect(leg, outline);

      final shoe = RRect.fromRectAndCorners(
        Rect.fromLTWH(hipX - 11 + swing * 0.8, 154, 23, 13),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(9),
      );
      canvas
        ..drawRRect(shoe, shoes)
        ..drawRRect(shoe, outline);
    }
  }

  void _paintTorso(Canvas canvas, Paint outline) {
    final shirt = Paint()..color = _shirt;
    const shoulder = 22.0;
    const waist = 21.0;
    final body = Path()
      ..moveTo(95 - shoulder, 72)
      ..lineTo(95 + shoulder, 72)
      ..quadraticBezierTo(95 + shoulder + 3, 92, 95 + waist, 112)
      ..lineTo(95 - waist, 112)
      ..quadraticBezierTo(95 - shoulder - 3, 92, 95 - shoulder, 72)
      ..close();
    canvas
      ..drawPath(body, shirt)
      ..drawPath(body, outline);

    // A collar so the shirt reads as clothing rather than a block of colour.
    final collar = Path()
      ..moveTo(86, 72)
      ..quadraticBezierTo(95, 80, 104, 72);
    canvas.drawPath(collar, outline);
  }

  void _paintArms(Canvas canvas, Paint outline, double stride) {
    final sleeve = Paint()..color = _shirt;
    final skin = Paint()..color = _skin;

    for (final side in <int>[-1, 1]) {
      final swing = -stride * side;
      final shoulderX = 95 + side * 23.0;
      final upper = RRect.fromRectAndRadius(
        Rect.fromLTWH(shoulderX - 6, 74, 12, 22),
        const Radius.circular(6),
      );
      canvas
        ..drawRRect(upper, sleeve)
        ..drawRRect(upper, outline);

      final forearm = RRect.fromRectAndRadius(
        Rect.fromLTWH(shoulderX - 5.5 + swing * 0.35, 94, 11, 22),
        const Radius.circular(6),
      );
      canvas
        ..drawRRect(forearm, skin)
        ..drawRRect(forearm, outline);
    }
  }

  void _paintHead(Canvas canvas, Paint outline) {
    final skin = Paint()..color = _skin;

    // Neck
    final neck = RRect.fromRectAndRadius(
      const Rect.fromLTWH(89, 58, 12, 16),
      const Radius.circular(5),
    );
    canvas
      ..drawRRect(neck, skin)
      ..drawRRect(neck, outline);

    if (equipped['scarf'] == 'scarf_lavender') {
      final scarf = Paint()..color = const Color(0xFFB9A3E3);
      final band = RRect.fromRectAndRadius(
        const Rect.fromLTWH(79, 64, 32, 12),
        const Radius.circular(6),
      );
      final tail = RRect.fromRectAndRadius(
        const Rect.fromLTWH(102, 70, 10, 24),
        const Radius.circular(5),
      );
      canvas
        ..drawRRect(band, scarf)
        ..drawRRect(tail, scarf)
        ..drawRRect(band, outline)
        ..drawRRect(tail, outline);
    }

    // Head
    final head = RRect.fromRectAndRadius(
      const Rect.fromLTWH(73, 16, 44, 48),
      const Radius.circular(20),
    );
    canvas
      ..drawRRect(head, skin)
      ..drawRRect(head, outline);

    // Ears
    for (final side in <int>[-1, 1]) {
      final ear = Rect.fromCircle(
        center: Offset(95 + side * 23.0, 42),
        radius: 5,
      );
      canvas
        ..drawOval(ear, skin)
        ..drawOval(ear, outline);
    }

    // Hair, unless a beanie covers it
    if (equipped['hat'] != 'hat_beanie') {
      final hair = Paint()..color = _hair;
      final top = Path()
        ..moveTo(71, 40)
        ..quadraticBezierTo(70, 12, 95, 12)
        ..quadraticBezierTo(120, 12, 119, 40)
        ..quadraticBezierTo(112, 26, 95, 26)
        ..quadraticBezierTo(78, 26, 71, 40)
        ..close();
      canvas
        ..drawPath(top, hair)
        ..drawPath(top, outline);
    }

    _paintFace(canvas, outline);

    if (equipped['hat'] == 'hat_beanie') {
      final beanie = Paint()..color = const Color(0xFF3C6E63);
      final cap = Path()
        ..moveTo(70, 34)
        ..quadraticBezierTo(70, 8, 95, 8)
        ..quadraticBezierTo(120, 8, 120, 34)
        ..close();
      final brim = RRect.fromRectAndRadius(
        const Rect.fromLTWH(68, 30, 54, 11),
        const Radius.circular(5),
      );
      canvas
        ..drawPath(cap, beanie)
        ..drawPath(cap, outline)
        ..drawRRect(brim, beanie)
        ..drawRRect(brim, outline);
    }
  }

  void _paintFace(Canvas canvas, Paint outline) {
    final ink = Paint()..color = _ink;

    if (equipped['eyes'] == 'eyes_star') {
      for (final side in <int>[-1, 1]) {
        _star(
          canvas,
          Offset(95 + side * 9.0, 42),
          5.4,
          const Color(0xFFFFC857),
        );
      }
    } else {
      for (final side in <int>[-1, 1]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(95 + side * 9.0, 42),
            width: 5.5,
            height: 7,
          ),
          ink,
        );
      }
    }

    // Brows give the face most of its expression.
    final brows = Paint()
      ..color = _hair
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final focused = equipped['expression'] == 'expression_focus';
    for (final side in <int>[-1, 1]) {
      final centerX = 95 + side * 9.0;
      canvas.drawLine(
        Offset(centerX - 4.5, focused ? 34 : 33),
        Offset(centerX + 4.5, focused ? 32.5 : 33),
        brows,
      );
    }

    final mouth = Path();
    if (focused) {
      mouth
        ..moveTo(89, 53)
        ..lineTo(101, 53);
    } else {
      mouth
        ..moveTo(88, 51)
        ..quadraticBezierTo(95, 58, 102, 51);
    }
    canvas.drawPath(mouth, outline);

    if (equipped['glasses'] == 'glasses_round') {
      final frame = Paint()
        ..color = const Color(0xFF32233D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;
      for (final side in <int>[-1, 1]) {
        canvas.drawCircle(Offset(95 + side * 9.5, 42), 8, frame);
      }
      canvas.drawLine(const Offset(89.5, 42), const Offset(100.5, 42), frame);
    }
  }

  static void _star(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var index = 0; index < 8; index++) {
      final angle = -math.pi / 2 + index * math.pi / 4;
      final length = index.isEven ? radius : radius * 0.42;
      final point = Offset(
        center.dx + math.cos(angle) * length,
        center.dy + math.sin(angle) * length,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      oldDelegate.equipped != equipped ||
      oldDelegate.running != running ||
      oldDelegate.phase != phase;
}
