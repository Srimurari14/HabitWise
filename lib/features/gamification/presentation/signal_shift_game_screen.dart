import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../providers.dart';
import '../domain/avatar_models.dart';
import 'avatar_character.dart';

class SignalShiftGameScreen extends ConsumerStatefulWidget {
  const SignalShiftGameScreen({required this.launch, super.key});

  final SignalShiftLaunch launch;

  @override
  ConsumerState<SignalShiftGameScreen> createState() =>
      _SignalShiftGameScreenState();
}

class _SignalShiftGameScreenState extends ConsumerState<SignalShiftGameScreen> {
  final _random = math.Random();
  final List<_TrackObject> _objects = <_TrackObject>[];
  Timer? _timer;
  late int _durationMinutes = widget.launch.durationMinutes;
  late GameMode _mode = widget.launch.mode;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  int _lane = 1;
  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _lastSpawnTick = 0;
  int _tick = 0;
  bool _started = false;
  bool _paused = false;
  bool _jumping = false;
  String? _flash;
  Offset? _dragStart;
  final _focusNode = FocusNode();
  Timer? _flashTimer;
  double _shake = 0;
  bool _saving = false;
  bool _finished = false;
  int _intensityAfter = 5;
  GameHelpfulness? _helpfulness;
  SignalShiftResult? _result;

  @override
  void dispose() {
    _timer?.cancel();
    _flashTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _showFlash(String message) {
    _flashTimer?.cancel();
    setState(() => _flash = message);
    _flashTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _flash = null);
    });
  }

  void _start() {
    if (_started) return;
    setState(() {
      _started = true;
      _startedAt = DateTime.now();
      _intensityAfter = widget.launch.intensityBefore ?? 5;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _step());
  }

  void _step() {
    if (!mounted || _paused || _finished) return;
    const delta = Duration(milliseconds: 50);
    final target = Duration(minutes: _durationMinutes);
    setState(() {
      _elapsed += delta;
      _tick++;
      final spawnEvery = _mode == GameMode.calm ? 21 : 15;
      if (_tick - _lastSpawnTick >= spawnEvery) {
        _lastSpawnTick = _tick;
        _objects.add(
          _TrackObject(
            lane: _random.nextInt(3),
            y: -0.08,
            spark: _random.nextDouble() > 0.27,
          ),
        );
      }
      final speed = _mode == GameMode.calm
          ? 0.006
          : _mode == GameMode.reducedMotion
          ? 0.008
          : 0.011;
      for (final object in _objects) {
        object.y += speed;
        if (!object.resolved && object.y >= 0.73) {
          object.resolved = true;
          if (object.lane == _lane) {
            if (object.spark) {
              _combo++;
              _bestCombo = math.max(_bestCombo, _combo);
              // Each spark in a row is worth 10 more, up to 50, and a block
              // sends it back to the start.
              final points = math.min(_combo * 10, 50);
              _score += points;
              object.collected = true;
              _showFlash('+$points');
            } else if (!_jumping) {
              _combo = 0;
              _score = math.max(0, _score - 10);
              _shake = 1;
              _showFlash('-10');
              if (_mode != GameMode.calm && _mode != GameMode.reducedMotion) {
                unawaited(HapticFeedback.mediumImpact());
              }
            } else {
              _score += 5;
              object.cleared = true;
              _showFlash('+5');
            }
          }
        }
      }
      if (_shake > 0) {
        _shake = math.max(0, _shake - 0.12);
      }
      // A collected spark disappears straight away; a cleared block fades on.
      _objects.removeWhere((object) => object.y > 1.08 || object.collected);
    });
    if (_elapsed >= target) _complete(completed: true);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final start = _dragStart;
    if (start == null) return;
    final dx = details.localPosition.dx - start.dx;
    final dy = details.localPosition.dy - start.dy;
    const threshold = 32.0;
    if (dy < -threshold && dy.abs() > dx.abs()) {
      _dragStart = null;
      _jump();
      return;
    }
    if (dx.abs() > threshold) {
      _dragStart = null;
      _move(dx < 0 ? -1 : 1);
    }
  }

  void _move(int direction) {
    if (!_started || _paused || _finished) return;
    setState(() => _lane = (_lane + direction).clamp(0, 2));
  }

  void _jump() {
    if (!_started || _paused || _finished || _jumping) return;
    setState(() => _jumping = true);
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _jumping = false);
    });
  }

  Future<void> _complete({required bool completed}) async {
    if (_finished || _saving) return;
    _timer?.cancel();
    setState(() {
      _finished = true;
      _paused = false;
    });
    if (widget.launch.source == GameSource.practice || !completed) {
      await _save(completed: completed);
    }
  }

  Future<void> _save({required bool completed}) async {
    if (_saving || _result != null) return;
    setState(() => _saving = true);
    final result = await ref
        .read(gamificationRepositoryProvider)
        .recordGame(
          launch: SignalShiftLaunch(
            source: widget.launch.source,
            durationMinutes: _durationMinutes,
            mode: _mode,
            cravingSessionId: widget.launch.cravingSessionId,
            category: widget.launch.category,
            subtriggerId: widget.launch.subtriggerId,
            intensityBefore: widget.launch.intensityBefore,
            reason: widget.launch.reason,
          ),
          startedAt: _startedAt ?? DateTime.now(),
          durationSeconds: _elapsed.inSeconds,
          score: _score,
          completed: completed,
          intensityAfter: widget.launch.source == GameSource.recommended
              ? _intensityAfter
              : null,
          helpfulness: widget.launch.source == GameSource.recommended
              ? _helpfulness
              : null,
        );
    if (!mounted) return;
    setState(() {
      _result = result;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(avatarProvider).value ?? const AvatarProfileData();
    return PopScope(
      canPop: !_started || _finished,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _started && !_finished) _showExitDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Signal Shift'),
          actions: <Widget>[
            if (_started && !_finished)
              IconButton(
                tooltip: _paused ? 'Resume' : 'Pause',
                onPressed: () => setState(() => _paused = !_paused),
                icon: Icon(
                  _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: !_started
              ? _buildIntro(context, avatar)
              : _finished
              ? _buildResults(context, avatar)
              : _buildGame(context, avatar),
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context, AvatarProfileData avatar) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/signal_shift_hero.png',
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.launch.source == GameSource.recommended
                ? 'An optional attention shift'
                : 'Practice at your own pace',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.launch.reason ??
                'Move your character between three lanes, collect Focus Sparks, and jump over Signal Blocks. Missing an item never ends the game.',
          ),
          const SizedBox(height: 18),
          HabitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'How it works',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const _RuleRow(
                  icon: Icons.auto_awesome_rounded,
                  text: 'Collect a Focus Spark',
                  value: '+10',
                ),
                const _RuleRow(
                  icon: Icons.bolt_rounded,
                  text: 'Each spark in a row is worth more',
                  value: 'up to +50',
                ),
                const _RuleRow(
                  icon: Icons.arrow_upward_rounded,
                  text: 'Jump over a Signal Block',
                  value: '+5',
                ),
                const _RuleRow(
                  icon: Icons.close_rounded,
                  text: 'Run into a Signal Block',
                  value: '-10',
                ),
                const SizedBox(height: 6),
                const Text(
                  'A run of sparks pays 10, then 20, 30, 40, 50. Running into '
                  'a block sends it back to 10. Your score sets how many coins '
                  'the session earns, and finishing always earns some.',
                ),
                const Divider(height: 26),
                Text(
                  'Controls',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                const _RuleRow(
                  icon: Icons.swipe_rounded,
                  text: 'Swipe left or right, or tap that side',
                  value: 'Move',
                ),
                const _RuleRow(
                  icon: Icons.swipe_up_rounded,
                  text: 'Swipe up, or tap the middle',
                  value: 'Jump',
                ),
                const _RuleRow(
                  icon: Icons.keyboard_rounded,
                  text: 'Arrow keys also work',
                  value: 'Move and jump',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Missing something never ends the session. This is a short coping option, not treatment and not a measure of self-control.',
          ),
          if (widget.launch.source == GameSource.practice) ...<Widget>[
            const SizedBox(height: 22),
            Text('Length', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment(value: 3, label: Text('3 min')),
                ButtonSegment(value: 5, label: Text('5 min')),
                ButtonSegment(value: 7, label: Text('7 min')),
              ],
              selected: <int>{_durationMinutes},
              onSelectionChanged: (values) =>
                  setState(() => _durationMinutes = values.first),
            ),
          ],
          const SizedBox(height: 22),
          Text('Mode', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: GameMode.values
                .map(
                  (mode) => ChoiceChip(
                    label: Text(switch (mode) {
                      GameMode.standard => 'Standard',
                      GameMode.calm => 'Calm',
                      GameMode.reducedMotion => 'Reduced motion',
                    }),
                    selected: _mode == mode,
                    onSelected: widget.launch.source == GameSource.recommended
                        ? null
                        : (_) => setState(() => _mode = mode),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Start $_durationMinutes-minute shift'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Stop if the game increases distress, dizziness, pain, fatigue, or agitation. If you are hungry or managing glucose symptoms, respond to that need instead.',
          ),
        ],
      ),
    );
  }

  Widget _buildGame(BuildContext context, AvatarProfileData avatar) {
    final totalSeconds = _durationMinutes * 60;
    final remaining = math.max(0, totalSeconds - _elapsed.inSeconds);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Row(
            children: <Widget>[
              _GameMetric(label: 'TIME', value: _clock(remaining)),
              const Spacer(),
              _GameMetric(label: 'SPARKS', value: '$_score'),
              const Spacer(),
              _GameMetric(label: 'COMBO', value: 'x$_combo'),
            ],
          ),
        ),
        Expanded(
          child: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (event) {
              if (event is! KeyDownEvent) return;
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.arrowLeft ||
                  key == LogicalKeyboardKey.keyA) {
                _move(-1);
              } else if (key == LogicalKeyboardKey.arrowRight ||
                  key == LogicalKeyboardKey.keyD) {
                _move(1);
              } else if (key == LogicalKeyboardKey.arrowUp ||
                  key == LogicalKeyboardKey.space ||
                  key == LogicalKeyboardKey.keyW) {
                _jump();
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Decided by how far the finger or pointer moved, not how fast, so
              // a slow drag on a trackpad works as well as a flick on a phone.
              onPanStart: (details) => _dragStart = details.localPosition,
              onPanUpdate: _onDragUpdate,
              onPanEnd: (_) => _dragStart = null,
              onTapUp: (details) {
                if (!_started || _paused || _finished) return;
                final width = context.size?.width ?? 0;
                if (width == 0) return;
                final third = width / 3;
                if (details.localPosition.dx < third) {
                  _move(-1);
                } else if (details.localPosition.dx > width - third) {
                  _move(1);
                } else {
                  _jump();
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final laneWidth = constraints.maxWidth / 3;
                  final playerLeft = laneWidth * _lane + laneWidth / 2 - 42;
                  final shakeAllowed =
                      _mode != GameMode.calm && _mode != GameMode.reducedMotion;
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Transform.translate(
                          offset: shakeAllowed
                              ? Offset(math.sin(_tick * 1.7) * _shake * 9, 0)
                              : Offset.zero,
                          child: CustomPaint(
                            painter: _TrackPainter(
                              objects: _objects,
                              calm: _mode == GameMode.calm,
                              highContrast: avatar.preferences.highContrast,
                            ),
                          ),
                        ),
                      ),
                      if (_flash != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 150,
                          child: IgnorePointer(
                            child: Center(
                              child: Text(
                                _flash!,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: _flash!.startsWith('-')
                                          ? const Color(0xFFFF806D)
                                          : const Color(0xFFFFD86B),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      AnimatedPositioned(
                        duration: _mode == GameMode.reducedMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 140),
                        curve: Curves.easeOut,
                        left: playerLeft,
                        bottom: _jumping ? 100 : 24,
                        child: AvatarCharacter(
                          equipped: avatar.equipped,
                          size: 84,
                          running: _mode != GameMode.reducedMotion,
                          phase: (_tick % 20) / 20,
                        ),
                      ),
                      if (_paused)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black54,
                            child: Center(
                              child: FilledButton.icon(
                                onPressed: () =>
                                    setState(() => _paused = false),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Resume'),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        if (avatar.preferences.oneHanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _move(-1),
                    icon: const Icon(Icons.arrow_left_rounded),
                    label: const Text('Left'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _jump,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    label: const Text('Jump'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _move(1),
                    icon: const Icon(Icons.arrow_right_rounded),
                    label: const Text('Right'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, AvatarProfileData avatar) {
    if (_result == null &&
        widget.launch.source == GameSource.recommended &&
        !_saving) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: AvatarCharacter(equipped: avatar.equipped, size: 145),
            ),
            Text(
              'Notice what changed',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'There is no right result. This helps HabitWise learn whether the game fits this kind of moment.',
            ),
            const SizedBox(height: 22),
            Text('Urge now: $_intensityAfter / 10'),
            Slider(
              value: _intensityAfter.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_intensityAfter',
              onChanged: (value) =>
                  setState(() => _intensityAfter = value.round()),
            ),
            const SizedBox(height: 14),
            const Text('Did the attention shift help?'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GameHelpfulness.values
                  .map(
                    (value) => ChoiceChip(
                      label: Text(switch (value) {
                        GameHelpfulness.helpful => 'Yes',
                        GameHelpfulness.somewhat => 'Somewhat',
                        GameHelpfulness.notHelpful => 'Not this time',
                      }),
                      selected: _helpfulness == value,
                      onSelected: (_) => setState(() => _helpfulness = value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _helpfulness == null
                    ? null
                    : () => _save(completed: true),
                child: const Text('Save game check-in'),
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            AvatarCharacter(equipped: avatar.equipped, size: 155),
            const SizedBox(height: 14),
            Text(
              _result?.completed == true ? 'Shift complete' : 'Session ended',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text('Score $_score  •  Best combo x$_bestCombo'),
            const SizedBox(height: 8),
            if (_saving)
              const CircularProgressIndicator()
            else if ((_result?.coinsEarned ?? 0) > 0)
              Text(
                '+${_result!.coinsEarned} coins',
                style: Theme.of(context).textTheme.titleLarge,
              )
            else
              const Text('No coins were added for this session.'),
            const SizedBox(height: 20),
            const Text(
              'The game was one strategy. Return to your plan and decide what support fits next.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _result == null
                  ? null
                  : () => context.pop<SignalShiftResult>(_result),
              child: const Text('Return'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExitDialog() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End this session?'),
        content: const Text(
          'Stopping is always okay. An incomplete session will be recorded without a coin reward.',
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End session'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep playing'),
          ),
        ],
      ),
    );
    if (exit == true) await _complete(completed: false);
  }

  static String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.text, required this.value});

  final IconData icon;
  final String text;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          const SizedBox(width: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _GameMetric extends StatelessWidget {
  const _GameMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _TrackObject {
  _TrackObject({required this.lane, required this.y, required this.spark});
  final int lane;
  bool collected = false;
  bool cleared = false;
  double y;
  final bool spark;
  bool resolved = false;
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.objects,
    required this.calm,
    required this.highContrast,
  });
  final List<_TrackObject> objects;
  final bool calm;
  final bool highContrast;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: calm
            ? const <Color>[Color(0xFFE8E3F4), Color(0xFFF8F1E9)]
            : const <Color>[Color(0xFF31204B), Color(0xFF7658A7)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);
    final line = Paint()
      ..color = (calm ? const Color(0xFF7557A8) : Colors.white).withValues(
        alpha: highContrast ? 0.8 : 0.35,
      )
      ..strokeWidth = highContrast ? 4 : 2;
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      line,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      line,
    );
    final laneWidth = size.width / 3;
    for (final object in objects) {
      final center = Offset(
        laneWidth * object.lane + laneWidth / 2,
        object.y * size.height,
      );
      if (object.spark) {
        final glow = Paint()
          ..color = const Color(0xFFFFD86B).withValues(alpha: 0.25);
        canvas.drawCircle(center, 21, glow);
        _drawSpark(canvas, center, const Color(0xFFFFD86B));
      } else {
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 46, height: 34),
          const Radius.circular(9),
        );
        canvas.drawRRect(rect, Paint()..color = const Color(0xFFFF806D));
        canvas.drawRRect(
          rect,
          Paint()
            ..color = const Color(0xFF32233D)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  static void _drawSpark(Canvas canvas, Offset center, Color color) {
    final path = Path();
    for (var index = 0; index < 8; index++) {
      final angle = -math.pi / 2 + index * math.pi / 4;
      final radius = index.isEven ? 16.0 : 7.0;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
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
  bool shouldRepaint(covariant _TrackPainter oldDelegate) => true;
}
