import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'mascot_assets.dart';

/// What the mascot is doing. Idle, hit, collect and celebrate are shared by
/// both games; run, lane change, jump and land belong to Signal Shift; watch
/// and wince belong to Focus Stack.
enum MascotPose {
  idle,
  run,
  laneChange,
  jump,
  land,
  hit,
  collect,
  celebrate,
  watch,
  wince,
}

/// The blob mascot: one rendered body plus whatever is equipped, animated by
/// squashing and moving the whole stack rather than by redrawing it.
class MascotCharacter extends StatefulWidget {
  const MascotCharacter({
    required this.equipped,
    this.size = 190,
    this.pose = MascotPose.idle,
    this.phase = 0,
    this.lean = 0,
    this.reducedMotion = false,
    this.highContrast = false,
    super.key,
  });

  final Map<String, String> equipped;
  final double size;
  final MascotPose pose;

  /// 0 to 1 through the current animation cycle.
  final double phase;

  /// -1 leaning left, 1 leaning right.
  final double lean;
  final bool reducedMotion;
  final bool highContrast;

  @override
  State<MascotCharacter> createState() => _MascotCharacterState();
}

class _MascotCharacterState extends State<MascotCharacter> {
  @override
  void initState() {
    super.initState();
    if (!MascotAssets.ready) {
      MascotAssets.ensureLoaded().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Your HabitWise buddy',
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _MascotPainter(
          equipped: widget.equipped,
          pose: widget.pose,
          phase: widget.phase,
          lean: widget.lean,
          reducedMotion: widget.reducedMotion,
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({
    required this.equipped,
    required this.pose,
    required this.phase,
    required this.lean,
    required this.reducedMotion,
  });

  final Map<String, String> equipped;
  final MascotPose pose;
  final double phase;
  final double lean;
  final bool reducedMotion;

  /// How much of the canvas the character fills, leaving room for a hat above
  /// and a companion to the side.
  static const _fill = 0.86;

  /// How much the body is squashed, how far it is off the ground, and how far
  /// it is tilted. Everything else follows from these three.
  ({double squash, double lift, double tilt}) get _motion {
    if (reducedMotion) return (squash: 0, lift: 0, tilt: lean * 0.05);
    final cycle = phase * math.pi * 2;
    return switch (pose) {
      MascotPose.idle || MascotPose.watch => (
        squash: math.sin(cycle) * 0.03,
        lift: 0,
        tilt: lean * 0.08,
      ),
      MascotPose.run => (
        squash: -math.sin(cycle).abs() * 0.1 + 0.05,
        lift: math.sin(cycle).abs() * 0.1,
        tilt: lean * 0.14,
      ),
      MascotPose.laneChange => (squash: 0.03, lift: 0.03, tilt: lean * 0.26),
      MascotPose.jump => (squash: -0.12, lift: 0.18, tilt: lean * 0.1),
      MascotPose.land => (squash: 0.18 * (1 - phase), lift: 0, tilt: 0),
      MascotPose.hit => (
        squash: 0.15 * (1 - phase),
        lift: 0,
        tilt: math.sin(cycle * 3) * 0.12 * (1 - phase),
      ),
      MascotPose.collect => (
        squash: -0.05,
        lift: 0.08 * math.sin(phase * math.pi),
        tilt: 0,
      ),
      MascotPose.celebrate => (
        squash: -0.07 * math.sin(cycle).abs(),
        lift: 0.12 * math.sin(phase * math.pi * 2).abs(),
        tilt: math.sin(cycle) * 0.07,
      ),
      MascotPose.wince => (
        squash: 0.1,
        lift: 0,
        tilt: math.sin(cycle * 2) * 0.04,
      ),
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final body = MascotAssets.bodyPlacement;
    final image = MascotAssets.body(equipped['baseColor'] ?? 'body_violet');
    if (body == null || image == null) return;

    // The master render's frame maps onto the widget, so every placement the
    // builder recorded lands in the right place without hand tuning.
    final unit = size.width / MascotAssets.frame;
    final motion = _motion;
    final groundY = (body.top + body.height) * unit;

    canvas.save();
    canvas.translate(size.width / 2, size.height * _fill);
    canvas.scale(_fill);
    canvas.translate(-size.width / 2, -size.height * _fill);

    _paintShadow(canvas, size, unit, body, motion.lift);

    canvas.save();
    // Squash and lift pivot on the ground so the body never sinks into it.
    canvas.translate(size.width / 2, groundY - motion.lift * size.height);
    canvas.rotate(motion.tilt);
    canvas.scale(1 + motion.squash, 1 - motion.squash);
    canvas.translate(-size.width / 2, -groundY);

    _draw(canvas, image, body, unit);
    final hidden = <String>{
      for (final entry in mascotCovers.entries)
        if (equipped.containsValue(entry.key)) ...entry.value,
    };
    for (final slot in mascotLayerOrder) {
      if (hidden.contains(slot)) continue;
      // The body has no face of its own, so something always has to go there.
      final itemId = slot == 'expression'
          ? (equipped[slot] ?? 'face_happy')
          : equipped[slot];
      if (itemId == null) continue;
      final layer = MascotAssets.layer(itemId);
      final placement = MascotAssets.placementOf(itemId);
      if (layer == null || placement == null) continue;
      _draw(canvas, layer, placement, unit);
    }
    canvas.restore();
    canvas.restore();
  }

  void _paintShadow(
    Canvas canvas,
    Size size,
    double unit,
    MascotPlacement body,
    double lift,
  ) {
    final tightness = (1 - lift * 3).clamp(0.45, 1.0);
    final centre = Offset(
      size.width / 2,
      (body.top + body.height) * unit + size.width * 0.02,
    );
    for (var ring = 0; ring < 3; ring++) {
      final spread = 1 + ring * 0.2;
      canvas.drawOval(
        Rect.fromCenter(
          center: centre,
          width: body.width * unit * 0.72 * tightness * spread,
          height: body.width * unit * 0.12 * tightness * spread,
        ),
        Paint()
          ..color = Colors.black.withValues(
            alpha: 0.13 * tightness / (ring + 1),
          ),
      );
    }
  }

  void _draw(
    Canvas canvas,
    ui.Image image,
    MascotPlacement placement,
    double unit,
  ) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(
        placement.left * unit,
        placement.top * unit,
        placement.width * unit,
        placement.height * unit,
      ),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) =>
      oldDelegate.equipped != equipped ||
      oldDelegate.pose != pose ||
      oldDelegate.phase != phase ||
      oldDelegate.lean != lean ||
      oldDelegate.reducedMotion != reducedMotion;
}
