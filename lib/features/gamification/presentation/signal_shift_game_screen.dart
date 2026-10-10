import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../data/local/app_database.dart';
import '../../../providers.dart';
import '../domain/avatar_models.dart';
import 'mascot/mascot_character.dart';

class SignalShiftGameScreen extends ConsumerStatefulWidget {
  const SignalShiftGameScreen({required this.launch, super.key});

  final SignalShiftLaunch launch;

  @override
  ConsumerState<SignalShiftGameScreen> createState() =>
      _SignalShiftGameScreenState();
}

class _SignalShiftGameScreenState extends ConsumerState<SignalShiftGameScreen>
    with SingleTickerProviderStateMixin {
  final _random = math.Random();
  final List<_TrackObject> _objects = <_TrackObject>[];
  // The loop used to run on a 50ms timer, which is 20 frames a second on a
  // phone that draws 60 or 120. Everything now moves by real elapsed time on
  // the frame ticker instead.
  Ticker? _ticker;
  Duration _lastFrame = Duration.zero;
  late int _durationMinutes = widget.launch.durationMinutes;
  late GameMode _mode = widget.launch.mode;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  int _lane = 1;
  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  double _sinceSpawn = 0;
  double _runTime = 0;
  // Rows waiting to be dropped. A wave is a short designed sequence of rows,
  // which is what makes the track read as patterns instead of noise.
  final List<List<_Cell>> _pendingRows = <List<_Cell>>[];

  /// How far the combo is allowed to multiply the track speed. Raise it if
  /// triple speed stops feeling like enough.
  static const _comboSpeedCap = 3;
  double _lean = 0;

  /// Counts down after collecting a spark so the mascot can react to it.
  double _collect = 0;
  double _scroll = 0;
  bool _started = false;
  bool _paused = false;
  bool _jumping = false;
  String? _flash;
  Offset? _dragStart;
  final _focusNode = FocusNode();
  Timer? _flashTimer;
  double _shake = 0;
  bool _saving = false;

  /// Whether the urge slider has actually been moved. It opens on the number
  /// from before the game, which made it look answered and saved a reading
  /// nobody gave. This is the single number that says whether the game does
  /// anything, so it has to be a real answer.
  bool _rated = false;
  String? _saveError;
  bool _finished = false;
  int _intensityAfter = 5;
  GameHelpfulness? _helpfulness;
  SignalShiftResult? _result;

  @override
  void dispose() {
    _ticker?.dispose();
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
    _lastFrame = Duration.zero;
    _ticker = createTicker(_onFrame)..start();
    // The Play button still holds focus at this point, so the key listener
    // never sees an arrow press until something hands focus back to it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onFrame(Duration elapsed) {
    final frame = elapsed - _lastFrame;
    _lastFrame = elapsed;
    if (!mounted || _paused || _finished) return;
    // A frame after the app was backgrounded can be arbitrarily long, so the
    // step is capped at a tenth of a second rather than teleporting everything.
    final seconds = math.min(frame.inMicroseconds / 1000000, 0.1);
    if (seconds <= 0) return;
    _step(seconds);
  }

  /// A smoothed frame rate, used to decide how much of the look this device
  /// can afford. The aura is the one expensive part: four wide strokes down
  /// the whole screen per stream. On a machine that cannot keep up, drawing
  /// fewer of them beats dropping frames.
  double _fps = 60;

  void _step(double seconds) {
    final target = Duration(minutes: _durationMinutes);
    setState(() {
      _fps = _fps * 0.9 + (1 / seconds) * 0.1;
      _elapsed += Duration(microseconds: (seconds * 1000000).round());
      _runTime += seconds;
      // Everything scales with how far through the session you are, so the
      // last minute is not the same as the first.
      final progress = (_elapsed.inMilliseconds / target.inMilliseconds).clamp(
        0.0,
        1.0,
      );
      // Seconds between rows, closing up as the session goes on.
      final baseGap = _mode == GameMode.calm ? 1.1 : 0.85;
      final rowGap = baseGap - (_mode == GameMode.calm ? 0.25 : 0.4) * progress;
      _sinceSpawn += seconds;
      if (_sinceSpawn >= rowGap) {
        _sinceSpawn = 0;
        _spawnRow(progress);
      }
      // Track heights per second. The old numbers were per 50ms tick and felt
      // sluggish, so what used to be double speed is now the starting speed.
      final baseSpeed = _mode == GameMode.calm
          ? 0.24
          : _mode == GameMode.reducedMotion
          ? 0.32
          : 0.40;
      // Speed is the combo. A run of two is double speed, three is triple.
      // It stops at triple on purpose: at the base speed an object takes about
      // 3.6 seconds to arrive, so triple leaves 1.2 seconds to see it, decide
      // and swipe, and anything faster than that stops being readable rather
      // than becoming harder. Calm mode stops at double.
      final comboCap = _mode == GameMode.calm ? 2 : _comboSpeedCap;
      final speed =
          baseSpeed * math.max(1, math.min(_combo, comboCap)) * seconds;
      for (final object in _objects) {
        object.y += speed;
        // The player is drawn near the bottom of the track, and with the
        // new perspective that is about 0.88 down rather than 0.73.
        if (!object.resolved && object.y >= 0.88) {
          object.resolved = true;
          if (object.covers(_lane)) {
            if (object.spark) {
              _combo++;
              _bestCombo = math.max(_bestCombo, _combo);
              // Each spark in a row is worth 10 more, up to 50, and a block
              // sends it back to the start.
              final points = math.min(_combo * 10, 50);
              _score += points;
              object.collected = true;
              _collect = 1;
              _showFlash('+$points');
            } else if (!_jumping || !object.kind.hoppable) {
              // Losing a long run should feel like losing something, not like
              // a flat ten point fee.
              final lostRun = _combo >= 4 ? _combo : 0;
              _combo = 0;
              _score = math.max(0, _score - 10);
              _shake = 1;
              _ripple(object.lane, _TrackPainter.interference);
              _showFlash(lostRun > 0 ? 'combo x$lostRun lost' : '-10');
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
        _shake = math.max(0, _shake - 2.4 * seconds);
      }
      if (_collect > 0) {
        _collect = math.max(0, _collect - 2.6 * seconds);
      }
      if (_lean != 0) {
        final decay = 2.8 * seconds;
        _lean = _lean > 0
            ? math.max(0, _lean - decay)
            : math.min(0, _lean + decay);
      }
      // The lane markers move at the same speed as the objects, which is what
      // makes the character look like it is running rather than standing.
      _scroll = (_scroll + speed * 2.2) % 1.0;
      // A collected spark disappears straight away; a cleared block fades on.
      _objects.removeWhere((object) => object.y > 1.08 || object.collected);
    });
    if (_elapsed >= target) _complete(completed: true);
  }

  /// The best score from every session before this one. The app has always
  /// stored these and never shown them, and a number to beat is the cheapest
  /// reason to come back.
  int get _previousBest {
    final sessions =
        ref.read(gameSessionsProvider).value ?? const <GameSession>[];
    var best = 0;
    for (final session in sessions) {
      if (session.id == _result?.sessionId) continue;
      if (session.score > best) best = session.score;
    }
    return best;
  }

  /// Drops the next row of a wave, building a new wave when the current one
  /// runs out. Rows can be empty, which is the breathing space between waves.
  void _spawnRow(double progress) {
    if (_pendingRows.isEmpty) _pendingRows.addAll(_buildWave(progress));
    final row = _pendingRows.removeAt(0);
    for (final cell in row) {
      _objects.add(_TrackObject(lane: cell.lane, y: -0.08, kind: cell.kind));
    }
  }

  List<List<_Cell>> _buildWave(double progress) {
    const gap = <_Cell>[];
    List<_Cell> sparks(List<int> lanes) =>
        lanes.map((lane) => _Cell(lane, _ObjectKind.spark)).toList();
    List<_Cell> blocks(List<int> lanes) =>
        lanes.map((lane) => _Cell(lane, _ObjectKind.clump)).toList();
    List<_Cell> shards(List<int> lanes) =>
        lanes.map((lane) => _Cell(lane, _ObjectKind.shards)).toList();
    List<_Cell> rings(List<int> lanes) =>
        lanes.map((lane) => _Cell(lane, _ObjectKind.ring)).toList();
    List<_Cell> surge(int lane) => <_Cell>[_Cell(lane, _ObjectKind.surge)];
    final lane = _random.nextInt(3);
    final other = (lane + 1 + _random.nextInt(2)) % 3;

    // A run of sparks in one lane: the simple reward, and what the combo is
    // built on.
    final run = <List<_Cell>>[
      sparks(<int>[lane]),
      sparks(<int>[lane]),
      sparks(<int>[lane]),
    ];
    // Sparks walking across the lanes, so you are moving the whole time.
    final zigzag = <List<_Cell>>[
      sparks(<int>[0]),
      sparks(<int>[1]),
      sparks(<int>[2]),
      sparks(<int>[1]),
    ];
    // Two blocks with one way through, then a spark waiting in that gap.
    final gateLane = _random.nextInt(3);
    final gate = <List<_Cell>>[
      blocks(<int>[0, 1, 2]..remove(gateLane)),
      gap,
      sparks(<int>[gateLane]),
    ];
    // Two sparks at once: you can only have one, so you have to choose.
    final choice = <List<_Cell>>[
      sparks(<int>[lane, other]),
      gap,
      sparks(<int>[other]),
    ];
    // Every lane blocked. The only answer is to jump, which is the whole
    // reason the jump exists.
    final wall = <List<_Cell>>[
      sparks(<int>[lane]),
      blocks(<int>[0, 1, 2]),
      gap,
      sparks(<int>[lane]),
    ];
    // A block beside a spark: take the point or play it safe.
    final pressure = <List<_Cell>>[
      <_Cell>[_Cell(lane, _ObjectKind.spark), _Cell(other, _ObjectKind.clump)],
      gap,
      sparks(<int>[lane]),
    ];

    // Blocks every other lane, with a spark in the one way through.
    final slalom = <List<_Cell>>[
      blocks(<int>[0, 2]),
      sparks(<int>[1]),
      blocks(<int>[1]),
      sparks(<int>[lane == 1 ? 0 : lane]),
    ];

    // A surge takes two streams, so the third is the answer and the move is
    // forced rather than optional.
    final surgeLane = _random.nextInt(3);
    final sweep = <List<_Cell>>[
      sparks(<int>[(surgeLane + 2) % 3]),
      surge(surgeLane),
      gap,
      sparks(<int>[(surgeLane + 2) % 3]),
    ];
    // Shards cannot be hopped, so this one is about reading which lane is
    // closed rather than reacting with the jump.
    final stand = <List<_Cell>>[
      shards(<int>[lane]),
      sparks(<int>[other]),
      gap,
    ];
    // A ring can be hopped or gone around, which makes it the only object
    // with two right answers.
    final pulse = <List<_Cell>>[
      rings(<int>[lane]),
      gap,
      sparks(<int>[lane]),
    ];

    final calm = _mode == GameMode.calm;
    final harder = progress > 0.12 && !calm;
    // Listing a wave more than once makes it more likely. Roughly two in three
    // waves should contain something to dodge, otherwise the jump, the combo
    // risk and the whole point of the blocks never come up.
    final waves = <List<List<_Cell>>>[
      run,
      zigzag,
      choice,
      if (!calm) ...<List<List<_Cell>>>[gate, gate, pressure, pressure, pulse],
      if (calm) ...<List<List<_Cell>>>[gate, pulse],
      if (harder) ...<List<List<_Cell>>>[wall, slalom, slalom, sweep, stand],
    ];
    return <List<_Cell>>[
      ...waves[_random.nextInt(waves.length)],
      gap,
      if (calm || progress < 0.3) gap,
    ];
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
    setState(() {
      final next = (_lane + direction).clamp(0, 2);
      if (next != _lane) {
        _lean = direction.toDouble();
        // Every shift disturbs the field, in the colour of the stream moved
        // into. This is the game's signature, not decoration.
        _ripple(next, _TrackPainter.streamColour(next));
      }
      _lane = next;
    });
  }

  void _jump() {
    if (!_started || _paused || _finished || _jumping) return;
    setState(() => _jumping = true);
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _jumping = false);
    });
  }

  /// What the mascot is doing, in priority order: in the air, recovering from
  /// a hit, celebrating a spark, leaning into a lane change, otherwise running.
  MascotPose get _mascotPose {
    if (_jumping) return MascotPose.jump;
    if (_shake > 0.05) return MascotPose.hit;
    if (_collect > 0) return MascotPose.collect;
    if (_lean.abs() > 0.15) return MascotPose.laneChange;
    return MascotPose.run;
  }

  /// The hit and collect reactions play once, so their phase runs from 0 to 1
  /// as the reaction decays rather than looping.
  double get _mascotPhase => switch (_mascotPose) {
    MascotPose.hit => (1 - _shake).clamp(0.0, 1.0),
    MascotPose.collect => (1 - _collect).clamp(0.0, 1.0),
    _ => (_runTime * 1.1) % 1,
  };

  Future<void> _complete({required bool completed}) async {
    if (_finished || _saving) return;
    _ticker?.stop();
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
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final SignalShiftResult result;
    try {
      result = await ref
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
    } on Exception catch (error) {
      // Without this the screen sat on a spinner with a dead Return button
      // and no way out but killing the app, and the run was lost anyway.
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = 'Could not save this session: $error';
      });
      return;
    }
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
              'assets/images/signal_shift_hero.webp',
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
                'Shift between three streams of signal, gather sparks, and '
                    'get past the interference. Missing something never ends the '
                    'run.',
          ),
          const SizedBox(height: 18),
          HabitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'How it works',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (_previousBest > 0)
                      Text(
                        'Best $_previousBest',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const _RuleRow(
                  icon: Icons.auto_awesome_rounded,
                  text: 'Gather a spark',
                  value: '+10',
                ),
                const _RuleRow(
                  icon: Icons.bolt_rounded,
                  text: 'Each spark in a row is worth more',
                  value: 'up to +50',
                ),
                const _RuleRow(
                  icon: Icons.speed_rounded,
                  text: 'Your run sets the speed',
                  value: 'up to 3x',
                ),
                const _RuleRow(
                  icon: Icons.arrow_upward_rounded,
                  text: 'Hop a clump of interference, or a pulse ring',
                  value: '+5',
                ),
                const _RuleRow(
                  icon: Icons.change_circle_outlined,
                  text: 'Shards and surges cannot be hopped. Shift instead',
                  value: 'move',
                ),
                const _RuleRow(
                  icon: Icons.close_rounded,
                  text: 'Take a hit',
                  value: '-10',
                ),
                const SizedBox(height: 6),
                const Text(
                  'Finishing a session pays coins, and stopping after '
                  'halfway pays half. Practice pays 1 to 3, a craving '
                  'session 3 to 12. Each game pays once per check-in, so '
                  'switching to the other one pays again and replaying this '
                  'one does not.\n'
                  'A run of sparks pays 10, then 20, 30, 40, 50, and a hit '
                  'sends it back to 10. Shards stand upright and a surge '
                  'covers two streams, so the way past those is the third '
                  'stream, never the hop. Your score sets how many coins the '
                  'session earns, and finishing always earns some.',
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

  /// Rings left behind by shifts and hits, trimmed as they fade.
  final List<_Ripple> _ripples = <_Ripple>[];

  void _ripple(int lane, Color colour) {
    _ripples
      ..removeWhere((ripple) => _runTime - ripple.born > 1.1)
      ..add(_Ripple(lane, _runTime, colour));
  }

  Widget _buildGame(BuildContext context, AvatarProfileData avatar) {
    final totalSeconds = _durationMinutes * 60;
    final remaining = math.max(0, totalSeconds - _elapsed.inSeconds);
    return Column(
      children: <Widget>[
        // One ring that empties, one meter that fills, and a combo that only
        // appears while it is worth something. Three floating counters are the
        // clearest sign of a runner, so they are gone.
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 34,
                width: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: totalSeconds == 0 ? 0 : remaining / totalSeconds,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFB9ACDF),
                      ),
                    ),
                    Text(
                      _clock(remaining),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_combo / 8).clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD86B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_combo > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'x$_combo',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5FE0C0),
                    ),
                  ),
                ),
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
                _focusNode.requestFocus();
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
                  final playerLeft = laneWidth * _lane + laneWidth / 2 - 48;
                  final shakeAllowed =
                      _mode != GameMode.calm && _mode != GameMode.reducedMotion;
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Transform.translate(
                          offset: shakeAllowed
                              ? Offset(math.sin(_runTime * 34) * _shake * 9, 0)
                              : Offset.zero,
                          child: CustomPaint(
                            painter: _TrackPainter(
                              rich: _fps > 42 && _mode == GameMode.standard,
                              clock: _runTime,
                              ripples: _ripples,
                              objects: _objects,
                              calm: _mode == GameMode.calm,
                              highContrast: avatar.preferences.highContrast,
                              scroll: _mode == GameMode.reducedMotion
                                  ? 0
                                  : _scroll,
                              playerLane: _lane,
                              jumping: _jumping,
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
                        child: MascotCharacter(
                          equipped: avatar.equipped,
                          size: 96,
                          pose: _mascotPose,
                          phase: _mascotPhase,
                          lean: _mode == GameMode.reducedMotion ? 0 : _lean,
                          reducedMotion: _mode == GameMode.reducedMotion,
                          highContrast: avatar.preferences.highContrast,
                        ),
                      ),
                      if (_paused)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black54,
                            child: Center(
                              child: FilledButton.icon(
                                onPressed: () {
                                  setState(() => _paused = false);
                                  // Resume takes focus with it, so hand the
                                  // keys back to the game.
                                  _focusNode.requestFocus();
                                },
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
              child: MascotCharacter(
                equipped: <String, String>{
                  ...avatar.equipped,
                  'expression': 'face_happy',
                },
                size: 145,
                pose: MascotPose.watch,
              ),
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
            Text(
              _rated
                  ? 'Urge now: $_intensityAfter / 10'
                  : 'Urge now: move the slider',
            ),
            Slider(
              value: _intensityAfter.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_intensityAfter',
              onChanged: (value) => setState(() {
                _intensityAfter = value.round();
                _rated = true;
              }),
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
                onPressed: _helpfulness == null || !_rated
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
            MascotCharacter(
              equipped: <String, String>{
                ...avatar.equipped,
                'expression': _result?.completed == true
                    ? 'face_excited'
                    : 'face_happy',
              },
              size: 155,
              pose: _result?.completed == true
                  ? MascotPose.celebrate
                  : MascotPose.watch,
            ),
            const SizedBox(height: 14),
            Text(
              _result?.completed == true ? 'Shift complete' : 'Session ended',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text('Score $_score  •  Best combo x$_bestCombo'),
            const SizedBox(height: 6),
            Builder(
              builder: (context) {
                final best = _previousBest;
                if (best == 0) {
                  return const Text(
                    'This is your first run. That is the score to beat.',
                  );
                }
                if (_score > best) {
                  return Text('New best. Your last best was $best.');
                }
                return Text('Your best so far is $best.');
              },
            ),
            const SizedBox(height: 8),
            if (_saving)
              const CircularProgressIndicator()
            else if (_saveError != null)
              Text(
                _saveError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if ((_result?.coinsEarned ?? 0) > 0)
              Text(
                '+${_result!.coinsEarned} coins',
                style: Theme.of(context).textTheme.titleLarge,
              )
            else
              // Saying nothing was added, with no reason, reads as a judgement
              // on how you played. The result knows which of the two reasons
              // applies, so it is the one that says.
              Text(_result?.noCoinsReason ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const Text(
              'The game was one strategy. Return to your plan and decide what support fits next.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving
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
          'Stopping is always okay. Past the halfway mark a stopped session '
          'still pays half; before that it is recorded without a reward.',
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

/// What can come down a stream.
///
/// Three kinds of interference rather than one, because each asks for a
/// different move: a clump can be hopped, a stand of shards has to be gone
/// around, and a surge takes two streams at once so the only answer is the
/// third one.
enum _ObjectKind {
  spark,
  clump,
  shards,
  surge,
  ring;

  bool get isSpark => this == _ObjectKind.spark;

  /// Low enough to hop. Shards stand upright and a surge is a wall of light,
  /// so jumping into either is still a hit.
  bool get hoppable => this == _ObjectKind.clump || this == _ObjectKind.ring;

  /// A surge covers this stream and the next one round.
  bool get spans => this == _ObjectKind.surge;
}

/// One item in one lane of a spawned row.
class _Cell {
  const _Cell(this.lane, this.kind);
  final int lane;
  final _ObjectKind kind;
}

class _TrackObject {
  _TrackObject({required this.lane, required this.y, required this.kind});
  final int lane;
  bool collected = false;
  bool cleared = false;
  double y;
  final _ObjectKind kind;
  bool resolved = false;

  bool get spark => kind.isSpark;

  bool covers(int playerLane) =>
      lane == playerLane || (kind.spans && (lane + 1) % 3 == playerLane);
}

/// A ring thrown out when the signal shifts. The game's signature: every
/// change disturbs the field it leaves behind.
class _Ripple {
  _Ripple(this.lane, this.born, this.colour);

  final int lane;
  final double born;
  final Color colour;
}

/// The world: three streams of signal, not a road.
///
/// There is no horizon and no perspective. Each stream is a ribbon that
/// wanders as it travels, and the wander fades to nothing at the bottom of
/// the screen so that objects, collisions and the character all still line up
/// on the same three lane centres the rest of the game counts in.
///
/// Nothing here uses a blur filter and no shader is built per frame. Those two
/// are what made the old perspective track crawl on a software renderer; the
/// soft edges are stacked translucent strokes instead.
class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.rich,
    required this.objects,
    required this.calm,
    required this.highContrast,
    required this.scroll,
    required this.playerLane,
    required this.jumping,
    required this.clock,
    required this.ripples,
  });

  /// Whether this device can afford the aura.
  final bool rich;
  final List<_TrackObject> objects;
  final bool calm;
  final bool highContrast;

  /// How far the field has travelled, 0 to 1 of one spacing.
  final double scroll;
  final int playerLane;
  final bool jumping;
  final double clock;
  final List<_Ripple> ripples;

  static const _spark = Color(0xFFFFD86B);
  static const _interference = Color(0xFFF2708A);
  static const _shard = Color(0xFFC9A8FF);
  static const _ringColour = Color(0xFF5FD0E8);
  static const _surgeColour = Color(0xFFFF9D6E);

  /// Each stream carries its own colour, so a shift is a change of light and
  /// not just a sideways step.
  static const _streams = <Color>[
    Color(0xFF7FB4F5),
    Color(0xFFA78BFA),
    Color(0xFF5FE0C0),
  ];

  static Color streamColour(int lane) => _streams[lane % _streams.length];

  /// The colour a hit leaves behind.
  static const interference = _interference;

  static Size? _cachedSize;
  static bool? _cachedCalm;
  static Shader? _skyShader;

  double _laneCentre(int lane, double y, Size size) {
    final laneWidth = size.width / 3;
    final base = laneWidth * lane + laneWidth / 2;
    if (calm) return base;
    // The wander dies away at the bottom, where the character stands.
    final left = 1 - y.clamp(0.0, 1.0);
    final settle = left * left;
    final wander =
        math.sin(y * 2.4 + clock * 0.75 + lane * 2.1) * size.width * 0.05;
    return base + wander * settle;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_cachedSize != size || _cachedCalm != calm) {
      _cachedSize = size;
      _cachedCalm = calm;
      _skyShader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        calm
            ? const <Color>[
                Color(0xFFF6EFFA),
                Color(0xFFEFE6F6),
                Color(0xFFF8F1E9),
              ]
            : const <Color>[
                Color(0xFF140D26),
                Color(0xFF241A42),
                Color(0xFF140D26),
              ],
        const <double>[0, 0.62, 1],
      );
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = _skyShader);

    for (var lane = 0; lane < 3; lane++) {
      _paintStream(canvas, size, lane);
    }
    for (final ripple in ripples) {
      _paintRipple(canvas, size, ripple);
    }
    for (final object in objects) {
      _paintObject(canvas, size, object);
    }
  }

  void _paintStream(Canvas canvas, Size size, int lane) {
    final colour = calm
        ? Color.lerp(_streams[lane], Colors.white, 0.35)!
        : _streams[lane];
    final lit = lane == playerLane;
    final width = size.width * (lit ? 0.2 : 0.17);

    final core = Path();
    const steps = 20;
    for (var i = 0; i <= steps; i++) {
      final y = i / steps;
      final x = _laneCentre(lane, y, size);
      if (i == 0) {
        core.moveTo(x, y * size.height);
      } else {
        core.lineTo(x, y * size.height);
      }
    }

    // The aura: one stroke per halo ring, widest and faintest first. This is
    // what a blur would give for free on a GPU and what it costs the earth to
    // ask for here. Calm mode does without it.
    // Only the stream being played gets an aura, and only when the frame rate
    // can pay for it. Each ring is a stroke half the screen wide down the full
    // height, so three lanes of them was most of a frame's work.
    if (rich && lit) {
      const rings = <double>[1.9, 1.4];
      for (var i = 0; i < rings.length; i++) {
        canvas.drawPath(
          core,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = width * rings[i]
            ..color = colour.withValues(alpha: 0.05 * (i + 1)),
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
          highContrast ? Colors.white : Colors.white,
          lit ? 0.5 : 0.25,
        )!.withValues(alpha: lit ? 0.95 : 0.5),
    );

    // Light travelling down the stream carries the movement the vanishing
    // point used to provide.
    const gap = 0.16;
    final drift = (scroll * gap) % gap;
    for (var n = 0; n < 8; n++) {
      final y = n * gap + drift;
      if (y > 1) continue;
      final x = _laneCentre(lane, y, size);
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
        Paint()
          ..color = (calm ? colour : Colors.white).withValues(
            alpha: lit ? 0.5 : 0.2,
          ),
      );
    }
  }

  void _paintRipple(Canvas canvas, Size size, _Ripple ripple) {
    final age = ((clock - ripple.born) / 1.1).clamp(0.0, 1.0);
    if (age >= 1) return;
    final fade = (1 - age) * (1 - age);
    final at = Offset(_laneCentre(ripple.lane, 0.86, size), size.height * 0.86);
    for (var ring = 0; ring < 2; ring++) {
      final reach = size.width * (0.1 + age * (0.55 + ring * 0.12));
      canvas.drawOval(
        Rect.fromCenter(center: at, width: reach * 2, height: reach * 0.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (2.6 - ring).clamp(1.0, 3.0)
          ..color = ripple.colour.withValues(alpha: fade * (0.55 - ring * 0.2)),
      );
    }
  }

  void _paintObject(Canvas canvas, Size size, _TrackObject object) {
    final at = Offset(
      _laneCentre(object.lane, object.y, size),
      object.y * size.height,
    );
    if (object.spark) {
      if (object.collected) {
        // A collected spark opens out rather than vanishing.
        final age = ((object.y - 0.88).abs() / 0.2).clamp(0.0, 1.0);
        canvas.drawCircle(
          at,
          18 + age * 32,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = _spark.withValues(alpha: (1 - age) * 0.85),
        );
        return;
      }
      _paintSpark(canvas, at);
      return;
    }
    if (object.cleared) return;
    switch (object.kind) {
      case _ObjectKind.spark:
        break;
      case _ObjectKind.clump:
        _paintInterference(canvas, at, object.lane);
      case _ObjectKind.shards:
        _paintShards(canvas, at);
      case _ObjectKind.ring:
        _paintRing(canvas, at, object.lane);
      case _ObjectKind.surge:
        _paintSurge(canvas, size, object);
    }
  }

  /// Shards: angular, upright, the one thing a hop will not clear, so they
  /// are drawn tall and hard-edged where everything else is soft.
  void _paintShards(Canvas canvas, Offset at) {
    const heights = <double>[30, 46, 24];
    const offsets = <double>[-22, 0, 20];
    final colour = highContrast
        ? Color.lerp(_shard, Colors.white, 0.3)!
        : _shard;
    for (var i = 0; i < 3; i++) {
      final base = at.translate(offsets[i], 16);
      final tall = heights[i] * (calm ? 1 : 1 + math.sin(clock * 2 + i) * 0.04);
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..lineTo(base.dx - 11, base.dy - tall * 0.42)
        ..lineTo(base.dx, base.dy - tall)
        ..lineTo(base.dx + 11, base.dy - tall * 0.42)
        ..close();
      canvas.drawPath(path, Paint()..color = colour);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  /// A pulse ring, opening outward where it sits. It can be hopped or gone
  /// around, so it is the one object with two right answers.
  void _paintRing(Canvas canvas, Offset at, int lane) {
    final beat = calm ? 0.0 : (clock * 1.3 + lane) % 1;
    for (var i = 0; i < 3; i++) {
      final phase = (beat + i / 3) % 1;
      canvas.drawOval(
        Rect.fromCenter(
          center: at,
          width: 36 + phase * 92,
          height: 14 + phase * 32,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 - phase * 2
          ..color = _ringColour.withValues(alpha: (1 - phase) * 0.85),
      );
    }
  }

  /// A surge sweeps two of the three streams, so there is always one way
  /// through and the answer is always to move, never to stop.
  void _paintSurge(Canvas canvas, Size size, _TrackObject object) {
    final from = object.lane;
    final to = (object.lane + 1) % 3;
    final left = math.min(
      _laneCentre(from, object.y, size),
      _laneCentre(to, object.y, size),
    );
    final right = math.max(
      _laneCentre(from, object.y, size),
      _laneCentre(to, object.y, size),
    );
    final mid = Offset((left + right) / 2, object.y * size.height);
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
          ..color = _surgeColour.withValues(alpha: 0.9 - arc * 0.22),
      );
    }
  }

  /// A four point star with a halo, breathing in time with the field.
  void _paintSpark(Canvas canvas, Offset at) {
    final beat = calm ? 1.0 : 1 + math.sin(clock * 3.4 + at.dy * 0.02) * 0.09;
    final radius = 18.0 * beat;
    for (var halo = 3; halo >= 1; halo--) {
      canvas.drawCircle(
        at,
        radius * (0.9 + halo * 0.3),
        Paint()..color = _spark.withValues(alpha: 0.05 * (4 - halo)),
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
    canvas.drawPath(path, Paint()..color = _spark);
    canvas.drawCircle(at, radius * 0.28, Paint()..color = Colors.white);
  }

  /// Interference: a clump that will not hold still. Overlapping discs rather
  /// than a blur, which is what a soft edge costs on a device with no GPU to
  /// spare.
  void _paintInterference(Canvas canvas, Offset at, int lane) {
    final colour = highContrast
        ? Color.lerp(_interference, Colors.white, 0.25)!
        : _interference;
    for (var halo = 3; halo >= 1; halo--) {
      canvas.drawCircle(
        at,
        14.0 + halo * 8,
        Paint()..color = colour.withValues(alpha: 0.075 * (4 - halo)),
      );
    }
    final jitter = calm ? 0.0 : clock * 1.9;
    for (var i = 0; i < 8; i++) {
      final angle = (lane * 31 + i * 47) % 360 * math.pi / 180 + jitter;
      final reach = 9 + (i % 3) * 6.0;
      canvas.drawCircle(
        Offset(
          at.dx + math.cos(angle) * reach,
          at.dy + math.sin(angle) * reach,
        ),
        7.5 - (i % 3) * 1.2,
        Paint()..color = colour.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) => true;
}
