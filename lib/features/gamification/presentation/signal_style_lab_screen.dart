import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'mascot/mascot_character.dart';

/// A scratch screen for the new look of Signal Shift. Not wired to scoring,
/// coins or the craving flow. It exists so the world, the objects and the
/// readouts can be judged on a real device, at the frame rate the device can
/// actually manage, before any of it replaces the running game.
///
/// The rule it is built to: no blur filters and no shaders built per frame.
/// Those two are what made the old track crawl. Everything soft here is built
/// from stacked translucent shapes instead, which the software renderer can
/// afford.
class SignalStyleLabScreen extends StatefulWidget {
  const SignalStyleLabScreen({super.key});

  @override
  State<SignalStyleLabScreen> createState() => _SignalStyleLabScreenState();
}

class _Ink {
  static const deep = Color(0xFF140D26);
  static const field = Color(0xFF241A42);
  static const spark = Color(0xFFFFD86B);
  static const cloud = Color(0xFFF2708A);
  static const wave = Color(0xFFFF9D6E);
  static const shard = Color(0xFFC9A8FF);
  static const drifter = Color(0xFF8E7BD8);
  static const ring = Color(0xFF5FD0E8);
  static const quiet = Color(0xFFB9ACDF);

  /// Each stream carries its own colour, so a shift is a change of light and
  /// not just a sideways step.
  static const streams = <Color>[
    Color(0xFF7FB4F5),
    Color(0xFFA78BFA),
    Color(0xFF5FE0C0),
  ];
}

enum _Kind {
  spark,
  focusSpark,
  cloud,
  doubleCloud,
  wave,
  shards,
  drifter,
  ring;

  bool get collectible => this == _Kind.spark || this == _Kind.focusSpark;

  /// Low things can be hopped. A wave and a stand of shards cannot.
  bool get hoppable =>
      this == _Kind.cloud ||
      this == _Kind.doubleCloud ||
      this == _Kind.drifter ||
      this == _Kind.ring;
}

class _Thing {
  _Thing(this.kind, this.lane, this.y, {this.seed = 0});

  final _Kind kind;
  final int lane;
  final int seed;
  double y;
  bool taken = false;

  /// Only the drifter uses this: it slides sideways as it travels.
  double get wobble => kind == _Kind.drifter ? seed.toDouble() : 0;
}

/// A ring thrown out when the signal shifts. This is the game's signature:
/// every change disturbs the field.
class _Ripple {
  _Ripple(this.at, this.born, this.colour);

  final Offset at;
  final double born;
  final Color colour;
}

class _SignalStyleLabScreenState extends State<SignalStyleLabScreen>
    with SingleTickerProviderStateMixin {
  static const _lanes = 3;
  static const _jumpFor = 0.62;

  late final Ticker _ticker;
  final _things = <_Thing>[];
  final _ripples = <_Ripple>[];
  final _random = math.Random(7);
  final _keys = FocusNode();

  double _clock = 0;
  double _last = 0;
  double _spawn = 0;
  double _fps = 0;

  int _lane = 1;
  double _slide = 1;
  double _lean = 0;
  double _signal = 0.35;
  double _hop = 0;
  double _hopFrom = -1;
  int _combo = 1;
  double _comboShown = 0;
  MascotPose _pose = MascotPose.run;
  double _poseUntil = 0;

  double _speed = 0.55;
  bool _calm = false;
  bool _aura = true;
  Size _field = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_frame)..start();
  }

  @override
  void dispose() {
    _keys.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _frame(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1000000;
    var step = now - _last;
    _last = now;
    if (step <= 0) return;
    if (step > 0.1) step = 0.1; // after a stall, never leap the world forward
    setState(() {
      _clock += step;
      _fps = _fps < 1 ? 1 / step : _fps * 0.92 + (1 / step) * 0.08;

      final target = _lane.toDouble();
      _slide += (target - _slide).clamp(-step * 7, step * 7);
      _lean = (target - _slide) * -1.6;

      if (_hopFrom >= 0) {
        final age = (_clock - _hopFrom) / _jumpFor;
        if (age >= 1) {
          _hopFrom = -1;
          _hop = 0;
          _hold(MascotPose.land, 0.18);
        } else {
          _hop = math.sin(age * math.pi);
        }
      }

      final pace = _speed * (_calm ? 0.7 : 1) * math.min(_combo, 3);
      _spawn += step;
      if (_spawn > (_calm ? 0.9 : 0.6)) {
        _spawn = 0;
        _add();
      }
      for (final thing in _things) {
        thing.y += step * pace;
      }
      _collide();
      _things.removeWhere((thing) => thing.y > 1.2);
      _ripples.removeWhere((ripple) => _clock - ripple.born > 1.1);

      if (_poseUntil > 0 && _clock > _poseUntil) {
        _poseUntil = 0;
        _pose = _hopFrom >= 0 ? MascotPose.jump : MascotPose.run;
      }
      _comboShown += ((_combo > 1 ? 1.0 : 0.0) - _comboShown).clamp(
        -step * 4,
        step * 4,
      );
    });
  }

  void _add() {
    final lane = _random.nextInt(_lanes);
    final roll = _random.nextDouble();
    if (roll < 0.06) {
      _things.add(_Thing(_Kind.focusSpark, lane, -0.12));
      return;
    }
    if (roll < 0.14) {
      _things.add(_Thing(_Kind.wave, lane, -0.12));
      return;
    }
    if (roll < 0.21) {
      _things.add(_Thing(_Kind.shards, lane, -0.12));
      return;
    }
    if (roll < 0.28) {
      _things.add(_Thing(_Kind.ring, lane, -0.12));
      return;
    }
    if (roll < 0.35) {
      _things.add(
        _Thing(_Kind.drifter, lane, -0.12, seed: _random.nextInt(6) + 1),
      );
      return;
    }
    if (roll < 0.42) {
      _things.add(_Thing(_Kind.doubleCloud, lane, -0.12));
      return;
    }
    if (roll < 0.55) {
      _things.add(_Thing(_Kind.cloud, lane, -0.12, seed: _random.nextInt(9)));
      return;
    }
    // A trail: short runs are what make a streak feel like one thing rather
    // than three separate pickups.
    for (var i = 0; i < 3; i++) {
      _things.add(_Thing(_Kind.spark, lane, -0.1 - i * 0.07));
    }
  }

  void _collide() {
    for (final thing in _things) {
      if (thing.taken || thing.y < 0.74 || thing.y > 0.92) continue;
      final here = thing.kind == _Kind.wave
          ? (thing.lane == _lane || (thing.lane + 1) % _lanes == _lane)
          : thing.lane == _lane;
      if (!here) continue;
      // A hop clears the low interference but never a spark, so jumping costs
      // the run you were collecting and is never the safe default.
      if (!thing.kind.collectible && thing.kind.hoppable && _hop > 0.35) {
        continue;
      }
      thing.taken = true;
      if (thing.kind.collectible) {
        _signal = math.min(
          1,
          _signal + (thing.kind == _Kind.focusSpark ? 0.2 : 0.06),
        );
        _combo = math.min(9, _combo + 1);
        _hold(MascotPose.collect, 0.25);
        if (thing.kind == _Kind.focusSpark) {
          _ripples.add(_Ripple(_blobAt(), _clock, _Ink.spark));
        }
      } else {
        _signal = math.max(0, _signal - 0.12);
        _combo = 1;
        _hold(MascotPose.hit, 0.35);
        _ripples.add(_Ripple(_blobAt(), _clock, _Ink.cloud));
      }
    }
  }

  Offset _blobAt() {
    if (_field == Size.zero) return Offset.zero;
    return Offset(
      _field.width / 2 + (_slide - 1) * _field.width * 0.31,
      _field.height * 0.78,
    );
  }

  void _hold(MascotPose pose, double seconds) {
    _pose = pose;
    _poseUntil = _clock + seconds;
  }

  void _move(int by) {
    final next = (_lane + by).clamp(0, _lanes - 1);
    if (next == _lane) return;
    setState(() {
      _lane = next;
      _ripples.add(_Ripple(_blobAt(), _clock, _Ink.streams[next]));
      _hold(MascotPose.laneChange, 0.22);
    });
  }

  void _jump() {
    if (_hopFrom >= 0) return;
    setState(() {
      _hopFrom = _clock;
      _hold(MascotPose.jump, _jumpFor);
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _move(-1);
      case LogicalKeyboardKey.arrowRight:
        _move(1);
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.space:
        _jump();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Ink.deep,
      appBar: AppBar(
        title: const Text('Signal Shift look'),
        backgroundColor: _Ink.deep,
        foregroundColor: Colors.white,
      ),
      body: Focus(
        focusNode: _keys,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Column(
          children: <Widget>[
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _field = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      _keys.requestFocus();
                      _move(
                        details.localPosition.dx < constraints.maxWidth / 2
                            ? -1
                            : 1,
                      );
                    },
                    onHorizontalDragEnd: (details) =>
                        _move((details.primaryVelocity ?? 0) < 0 ? -1 : 1),
                    onVerticalDragEnd: (details) {
                      if ((details.primaryVelocity ?? 0) < -200) _jump();
                    },
                    child: ClipRect(
                      child: CustomPaint(
                        painter: _FieldPainter(
                          clock: _clock,
                          slide: _slide,
                          things: _things,
                          ripples: _ripples,
                          calm: _calm,
                          aura: _aura,
                        ),
                        foregroundPainter: _ReadoutPainter(
                          signal: _signal,
                          combo: _combo,
                          comboShown: _comboShown,
                          seconds: 48 - _clock % 48,
                        ),
                        child: Align(
                          alignment: Alignment(
                            (_slide - 1) * 0.62,
                            0.56 - _hop * 0.3,
                          ),
                          child: MascotCharacter(
                            equipped: const <String, String>{
                              'baseColor': 'body_violet',
                              'expression': 'face_happy',
                            },
                            size: 104,
                            pose: _pose,
                            phase: (_clock * 1.6) % 1,
                            lean: _lean.clamp(-1, 1),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: _Ink.field,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${_fps.round()} fps   arrow keys or swipe, up to hop',
                    style: const TextStyle(color: _Ink.quiet, fontSize: 12),
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Pace', style: TextStyle(color: _Ink.quiet)),
                      Expanded(
                        child: Slider(
                          value: _speed,
                          min: 0.25,
                          max: 1.2,
                          onChanged: (value) => setState(() => _speed = value),
                        ),
                      ),
                      const Text('Aura', style: TextStyle(color: _Ink.quiet)),
                      Switch(
                        value: _aura,
                        onChanged: (value) => setState(() => _aura = value),
                      ),
                      const Text('Calm', style: TextStyle(color: _Ink.quiet)),
                      Switch(
                        value: _calm,
                        onChanged: (value) => setState(() => _calm = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The world: three streams of signal rather than a road. No horizon and no
/// perspective, so the maths is a fraction of the old track's.
class _FieldPainter extends CustomPainter {
  _FieldPainter({
    required this.clock,
    required this.slide,
    required this.things,
    required this.ripples,
    required this.calm,
    required this.aura,
  });

  final double clock;
  final double slide;
  final List<_Thing> things;
  final List<_Ripple> ripples;
  final bool calm;
  final bool aura;

  static ui.Shader? _sky;
  static Size? _skyFor;

  double _centre(Size size, int lane, double y) {
    final base = size.width / 2 + (lane - 1) * size.width * 0.31;
    final wander =
        math.sin(y * 2.4 + clock * 0.75 + lane * 2.1) *
        size.width *
        (calm ? 0.022 : 0.042);
    return base + wander;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_sky == null || _skyFor != size) {
      _sky = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        <Color>[_Ink.deep, _Ink.field, _Ink.deep],
        <double>[0, 0.62, 1],
      );
      _skyFor = size;
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = _sky);

    for (var lane = 0; lane < 3; lane++) {
      _paintStream(canvas, size, lane);
    }
    for (final ripple in ripples) {
      _paintRipple(canvas, size, ripple);
    }
    for (final thing in things) {
      _paintThing(canvas, size, thing);
    }
  }

  void _paintStream(Canvas canvas, Size size, int lane) {
    final colour = _Ink.streams[lane];
    final lit = (slide - lane).abs() < 0.5;
    final width = size.width * (lit ? 0.2 : 0.17);

    final core = Path();
    const steps = 22;
    for (var i = 0; i <= steps; i++) {
      final y = i / steps;
      final py = y * size.height;
      final x = _centre(size, lane, y);
      if (i == 0) {
        core.moveTo(x, py);
      } else {
        core.lineTo(x, py);
      }
    }

    // The aura: one stroke per halo ring, widest and faintest first. This is
    // what a blur would give for free on a GPU and what it costs the earth to
    // ask for here.
    if (aura) {
      const rings = <double>[2.6, 2.0, 1.5, 1.1];
      for (var i = 0; i < rings.length; i++) {
        canvas.drawPath(
          core,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = width * rings[i]
            ..color = colour.withValues(
              alpha: (lit ? 0.055 : 0.03) * (i + 1) / rings.length,
            ),
        );
      }
    }

    canvas.drawPath(
      core,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width
        ..color = colour.withValues(alpha: lit ? 0.3 : 0.15),
    );
    canvas.drawPath(
      core,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width * 0.42
        ..color = colour.withValues(alpha: lit ? 0.5 : 0.24),
    );
    canvas.drawPath(
      core,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = lit ? 4 : 2
        ..color = Color.lerp(
          colour,
          Colors.white,
          lit ? 0.5 : 0.25,
        )!.withValues(alpha: lit ? 0.95 : 0.5),
    );

    // Light travelling down the stream carries the movement the vanishing
    // point used to provide.
    const gap = 0.16;
    final drift = (clock * (calm ? 0.1 : 0.24)) % gap;
    for (var n = 0; n < 8; n++) {
      final y = n * gap + drift;
      if (y > 1) continue;
      final x = _centre(size, lane, y);
      final glide = 1 - (y - 0.5).abs() * 0.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y * size.height),
            width: width * 0.44 * glide,
            height: 7,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.white.withValues(alpha: lit ? 0.5 : 0.2),
      );
    }
  }

  /// The signature: every shift disturbs the field it leaves behind.
  void _paintRipple(Canvas canvas, Size size, _Ripple ripple) {
    final age = ((clock - ripple.born) / 1.1).clamp(0.0, 1.0);
    final fade = (1 - age) * (1 - age);
    for (var ring = 0; ring < 2; ring++) {
      final reach = size.width * (0.1 + age * (0.55 + ring * 0.12));
      canvas.drawOval(
        Rect.fromCenter(
          center: ripple.at,
          width: reach * 2,
          height: reach * 0.75,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (2.6 - ring).clamp(1.0, 3.0)
          ..color = ripple.colour.withValues(alpha: fade * (0.55 - ring * 0.2)),
      );
    }
  }

  void _paintThing(Canvas canvas, Size size, _Thing thing) {
    final wobble = thing.kind == _Kind.drifter
        ? math.sin(clock * 1.3 + thing.wobble) * size.width * 0.09
        : 0.0;
    final at = Offset(
      _centre(size, thing.lane, thing.y) + wobble,
      thing.y * size.height,
    );
    switch (thing.kind) {
      case _Kind.spark:
      case _Kind.focusSpark:
        final big = thing.kind == _Kind.focusSpark;
        if (thing.taken) {
          final age = (thing.y - 0.84).clamp(0.0, 0.22) / 0.22;
          canvas.drawCircle(
            at,
            (big ? 30 : 18) + age * 34,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = _Ink.spark.withValues(alpha: (1 - age) * 0.85),
          );
          return;
        }
        _spark(canvas, at, big);
      case _Kind.cloud:
        if (!thing.taken) _cloud(canvas, at, thing.seed, 1);
      case _Kind.doubleCloud:
        if (!thing.taken) {
          _cloud(canvas, at.translate(-size.width * 0.045, -6), 3, 0.85);
          _cloud(canvas, at.translate(size.width * 0.045, 6), 7, 0.95);
        }
      case _Kind.drifter:
        if (!thing.taken) _drifter(canvas, at);
      case _Kind.shards:
        if (!thing.taken) _shards(canvas, at);
      case _Kind.ring:
        if (!thing.taken) _ring(canvas, at, thing);
      case _Kind.wave:
        if (!thing.taken) _wave(canvas, size, thing);
    }
  }

  /// A four point star with a halo, breathing in time with the field.
  void _spark(Canvas canvas, Offset at, bool big) {
    final beat = 1 + math.sin(clock * 3.4 + at.dy * 0.02) * 0.09;
    final radius = (big ? 26.0 : 18.0) * beat;
    if (big) {
      // The rare one wears a ring so it reads as worth crossing for.
      canvas.drawCircle(
        at,
        radius * 1.75,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _Ink.spark.withValues(alpha: 0.75),
      );
    }
    for (var halo = 3; halo >= 1; halo--) {
      canvas.drawCircle(
        at,
        radius * (0.9 + halo * 0.3),
        Paint()..color = _Ink.spark.withValues(alpha: 0.05 * (4 - halo)),
      );
    }
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final tip = Offset(
        at.dx + math.cos(angle) * radius,
        at.dy + math.sin(angle) * radius,
      );
      final left = Offset(
        at.dx + math.cos(angle - math.pi / 4) * radius * 0.3,
        at.dy + math.sin(angle - math.pi / 4) * radius * 0.3,
      );
      final right = Offset(
        at.dx + math.cos(angle + math.pi / 4) * radius * 0.3,
        at.dy + math.sin(angle + math.pi / 4) * radius * 0.3,
      );
      path
        ..moveTo(at.dx, at.dy)
        ..quadraticBezierTo(left.dx, left.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(right.dx, right.dy, at.dx, at.dy);
    }
    canvas.drawPath(path, Paint()..color = _Ink.spark);
    canvas.drawCircle(at, radius * 0.28, Paint()..color = Colors.white);
  }

  /// Interference: a clump that will not hold still.
  void _cloud(Canvas canvas, Offset at, int seed, double scale) {
    for (var halo = 3; halo >= 1; halo--) {
      canvas.drawCircle(
        at,
        (14.0 + halo * 8) * scale,
        Paint()..color = _Ink.cloud.withValues(alpha: 0.075 * (4 - halo)),
      );
    }
    for (var i = 0; i < 8; i++) {
      final angle = (seed * 31 + i * 47) % 360 * math.pi / 180 + clock * 1.9;
      final reach = (9 + (i % 3) * 6.0) * scale;
      canvas.drawCircle(
        Offset(
          at.dx + math.cos(angle) * reach,
          at.dy + math.sin(angle) * reach,
        ),
        (7.5 - (i % 3) * 1.2) * scale,
        Paint()..color = _Ink.cloud.withValues(alpha: 0.9),
      );
    }
  }

  /// A slow blob that wanders across the streams. Soft, round and unhurried,
  /// so it reads as something to go around rather than something to fear.
  void _drifter(Canvas canvas, Offset at) {
    for (var halo = 2; halo >= 1; halo--) {
      canvas.drawCircle(
        at,
        20.0 + halo * 9,
        Paint()..color = _Ink.drifter.withValues(alpha: 0.09 * (3 - halo)),
      );
    }
    canvas.drawCircle(at, 20, Paint()..color = _Ink.drifter);
    canvas.drawCircle(
      at.translate(-13, -10),
      9,
      Paint()..color = _Ink.drifter.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      at.translate(14, 7),
      7,
      Paint()..color = _Ink.drifter.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      at.translate(-6, -7),
      5,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  /// Shards: angular, upright, the one thing a hop will not clear.
  void _shards(Canvas canvas, Offset at) {
    const heights = <double>[30, 46, 24];
    const offsets = <double>[-22, 0, 20];
    for (var i = 0; i < 3; i++) {
      final base = at.translate(offsets[i], 14);
      final tall = heights[i] * (1 + math.sin(clock * 2 + i) * 0.04);
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..lineTo(base.dx - 11, base.dy - tall * 0.42)
        ..lineTo(base.dx, base.dy - tall)
        ..lineTo(base.dx + 11, base.dy - tall * 0.42)
        ..close();
      canvas.drawPath(path, Paint()..color = _Ink.shard.withValues(alpha: 0.9));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  /// A pulse ring, opening outward where it sits. Wait for it or move.
  void _ring(Canvas canvas, Offset at, _Thing thing) {
    final beat = (clock * 1.3 + thing.lane) % 1;
    for (var i = 0; i < 3; i++) {
      final phase = (beat + i / 3) % 1;
      canvas.drawOval(
        Rect.fromCenter(
          center: at,
          width: 36 + phase * 96,
          height: 14 + phase * 34,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 - phase * 2
          ..color = _Ink.ring.withValues(alpha: (1 - phase) * 0.8),
      );
    }
  }

  /// A wave sweeps two of the three streams, so there is always one way
  /// through and the answer is always to move, never to stop.
  void _wave(Canvas canvas, Size size, _Thing thing) {
    final from = thing.lane;
    final to = (thing.lane + 1) % 3;
    final left = math.min(
      _centre(size, from, thing.y),
      _centre(size, to, thing.y),
    );
    final right = math.max(
      _centre(size, from, thing.y),
      _centre(size, to, thing.y),
    );
    final mid = Offset((left + right) / 2, thing.y * size.height);
    final reach = (right - left) / 2 + size.width * 0.1;
    for (var arc = 0; arc < 3; arc++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(mid.dx, mid.dy + arc * 10),
          width: reach * 2 - arc * 14,
          height: 46 - arc * 7.0,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 6.0 - arc * 1.2
          ..color = _Ink.wave.withValues(alpha: 0.9 - arc * 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FieldPainter old) => true;
}

/// The readouts. One meter that fills, one ring that empties, and a combo that
/// only exists while it is worth something.
class _ReadoutPainter extends CustomPainter {
  _ReadoutPainter({
    required this.signal,
    required this.combo,
    required this.comboShown,
    required this.seconds,
  });

  final double signal;
  final int combo;
  final double comboShown;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    const margin = 18.0;
    final ringAt = Offset(margin + 17, margin + 17);
    canvas.drawCircle(
      ringAt,
      17,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.16),
    );
    canvas.drawArc(
      Rect.fromCircle(center: ringAt, radius: 17),
      -math.pi / 2,
      math.pi * 2 * (seconds / 48),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3
        ..color = _Ink.quiet,
    );

    final bar = Rect.fromLTRB(
      margin + 46,
      margin + 10,
      size.width - margin - (comboShown > 0.05 ? 56 : 0),
      margin + 24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(7)),
      Paint()..color = Colors.white.withValues(alpha: 0.1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bar.left, bar.top, bar.width * signal, bar.height),
        const Radius.circular(7),
      ),
      Paint()..color = _Ink.spark.withValues(alpha: 0.9),
    );

    if (comboShown > 0.05) {
      final text = TextPainter(
        text: TextSpan(
          text: 'x$combo',
          style: TextStyle(
            color: _Ink.streams[2].withValues(alpha: comboShown),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(size.width - margin - text.width, margin + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _ReadoutPainter old) => true;
}
