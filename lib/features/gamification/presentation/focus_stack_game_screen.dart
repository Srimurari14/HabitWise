import 'dart:async';
import 'dart:math' as math;

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

/// Focus Stack: fit falling shapes into a wall and clear full rows.
///
/// The mechanic is deliberate rather than decorative. Craving runs on vivid
/// mental imagery, mostly visual, and fitting and rotating shapes occupies the
/// same part of working memory, which is why visuospatial tasks reduce craving
/// strength where word and audio tasks do not.
///
/// The piece set, the grid and the look are our own. The idea of falling
/// blocks is not ownable, but a particular game's shapes, proportions and
/// colours are, so nothing here is copied from one.
class FocusStackGameScreen extends ConsumerStatefulWidget {
  const FocusStackGameScreen({required this.launch, super.key});

  final SignalShiftLaunch launch;

  @override
  ConsumerState<FocusStackGameScreen> createState() =>
      _FocusStackGameScreenState();
}

const _columns = 7;
const _rows = 13;

/// Our own set: three, four and five cell shapes, so it is not the classic
/// four-cell seven.
const _shapes = <List<List<int>>>[
  // Corner
  <List<int>>[
    <int>[1, 0],
    <int>[1, 1],
  ],
  // Short bar
  <List<int>>[
    <int>[1, 1, 1],
  ],
  // Square
  <List<int>>[
    <int>[1, 1],
    <int>[1, 1],
  ],
  // Step
  <List<int>>[
    <int>[0, 1, 1],
    <int>[1, 1, 0],
  ],
  // Long bar
  <List<int>>[
    <int>[1, 1, 1, 1],
  ],
  // Tee
  <List<int>>[
    <int>[1, 1, 1],
    <int>[0, 1, 0],
  ],
  // Plus
  <List<int>>[
    <int>[0, 1, 0],
    <int>[1, 1, 1],
    <int>[0, 1, 0],
  ],
  // Hook
  <List<int>>[
    <int>[1, 0, 0],
    <int>[1, 1, 1],
  ],
];

/// Which shapes come up. Even odds across the eight, kept as a list so a shape
/// can be made rarer later by listing it fewer times.
const _shapeBag = <int>[0, 1, 2, 3, 4, 5, 6, 7];

class _Piece {
  _Piece({required this.cells, required this.colour, required this.column});
  List<List<int>> cells;
  final int colour;
  int column;
  double row = 0;

  int get width => cells.first.length;
  int get height => cells.length;

  void rotate() {
    final rotated = List<List<int>>.generate(
      width,
      (y) => List<int>.generate(height, (x) => cells[height - 1 - x][y]),
    );
    cells = rotated;
  }
}

class _FocusStackGameScreenState extends ConsumerState<FocusStackGameScreen>
    with SingleTickerProviderStateMixin {
  final _random = math.Random();
  final List<List<int>> _well = List<List<int>>.generate(
    _rows,
    (_) => List<int>.filled(_columns, 0),
  );
  Ticker? _ticker;
  Duration _lastFrame = Duration.zero;
  Duration _elapsed = Duration.zero;
  late final int _durationMinutes = widget.launch.durationMinutes;
  late final GameMode _mode = widget.launch.mode;
  DateTime? _startedAt;
  _Piece? _piece;
  int _nextShape = 0;
  // The controls hint rides along with the very first piece and leaves as soon
  // as the shape is turned once.
  int _pieces = 0;
  bool _rotatedOnce = false;
  double _fall = 0;

  /// Seconds since the run started, used for timing the clear flash.
  double _runTime = 0;
  int _score = 0;
  int _rowsCleared = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _started = false;
  bool _paused = false;
  bool _finished = false;
  bool _saving = false;
  String? _flash;
  Timer? _flashTimer;
  final _focusNode = FocusNode();

  /// Rows that have just been cleared, and when. The board is redrawn every
  /// frame anyway, so a fading band costs nothing and gives the clear the
  /// moment of payoff it was missing.
  final List<int> _justCleared = <int>[];
  double _clearedAt = -10;
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

  int get _previousBest {
    final sessions =
        ref.read(gameSessionsProvider).value ?? const <GameSession>[];
    var best = 0;
    for (final session in sessions) {
      if (session.game != GameKind.focusStack.key) continue;
      if (session.id == _result?.sessionId) continue;
      if (session.score > best) best = session.score;
    }
    return best;
  }

  void _showFlash(String message) {
    _flashTimer?.cancel();
    setState(() => _flash = message);
    _flashTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _flash = null);
    });
  }

  void _start() {
    if (_started) return;
    setState(() {
      _started = true;
      _startedAt = DateTime.now();
      _intensityAfter = widget.launch.intensityBefore ?? 5;
      _nextShape = _shapeBag[_random.nextInt(_shapeBag.length)];
      _spawn();
    });
    _lastFrame = Duration.zero;
    _ticker = createTicker(_onFrame)..start();
  }

  void _spawn() {
    _pieces += 1;
    final shapeIndex = _nextShape;
    _nextShape = _shapeBag[_random.nextInt(_shapeBag.length)];
    final cells = _shapes[shapeIndex]
        .map((row) => List<int>.from(row))
        .toList();
    final piece = _Piece(
      cells: cells,
      colour: shapeIndex % _blockColours.length,
      column: ((_columns - cells.first.length) / 2).floor(),
    );
    _piece = piece;
    _fall = 0;
    // Nothing ends the run. If the new piece cannot fit, the bottom two rows
    // are taken away instead, because being thrown out mid-craving is the
    // opposite of what this is for.
    if (!_fits(piece, piece.column, 0)) {
      final lost = _score - (_score / 2).round();
      _dropFloor();
      _showFlash(lost > 0 ? 'space cleared  -$lost' : 'space cleared');
    }
  }

  /// Running out of room costs half the score. Nothing ends the run, but
  /// letting the well fill up has to be worth avoiding or the whole puzzle is
  /// pointless.
  void _dropFloor() {
    for (var row = _rows - 1; row >= 2; row--) {
      _well[row] = List<int>.from(_well[row - 2]);
    }
    _well[0] = List<int>.filled(_columns, 0);
    _well[1] = List<int>.filled(_columns, 0);
    _score = (_score / 2).round();
    _streak = 0;
  }

  bool _fits(_Piece piece, int column, int row) {
    for (var y = 0; y < piece.height; y++) {
      for (var x = 0; x < piece.width; x++) {
        if (piece.cells[y][x] == 0) continue;
        final boardX = column + x;
        final boardY = row + y;
        if (boardX < 0 || boardX >= _columns || boardY >= _rows) return false;
        if (boardY >= 0 && _well[boardY][boardX] != 0) return false;
      }
    }
    return true;
  }

  void _onFrame(Duration elapsed) {
    final frame = elapsed - _lastFrame;
    _lastFrame = elapsed;
    if (!mounted || _paused || _finished) return;
    final seconds = math.min(frame.inMicroseconds / 1000000, 0.1);
    if (seconds <= 0) return;
    _step(seconds);
  }

  void _step(double seconds) {
    final target = Duration(minutes: _durationMinutes);
    setState(() {
      _runTime += seconds;
      _elapsed += Duration(microseconds: (seconds * 1000000).round());
      final progress = (_elapsed.inMilliseconds / target.inMilliseconds).clamp(
        0.0,
        1.0,
      );
      // Rows per second. Slow enough to think at the start, about twice that
      // by the end. Calm mode stays gentle throughout.
      final base = _mode == GameMode.calm ? 1.1 : 1.8;
      final speed =
          base * (1 + (_mode == GameMode.calm ? 0.4 : 1.0) * progress);
      final piece = _piece;
      if (piece != null) {
        _fall += speed * seconds;
        while (_fall >= 1) {
          _fall -= 1;
          if (_fits(piece, piece.column, piece.row.toInt() + 1)) {
            piece.row += 1;
          } else {
            _land(piece);
            break;
          }
        }
      }
    });
    if (_elapsed >= target) _complete(completed: true);
  }

  void _land(_Piece piece) {
    final row = piece.row.toInt();
    for (var y = 0; y < piece.height; y++) {
      for (var x = 0; x < piece.width; x++) {
        if (piece.cells[y][x] == 0) continue;
        final boardY = row + y;
        if (boardY < 0 || boardY >= _rows) continue;
        _well[boardY][piece.column + x] = piece.colour + 1;
      }
    }
    _piece = null;
    _resolveRows();
    _spawn();
  }

  void _resolveRows() {
    final full = <int>[];
    for (var row = 0; row < _rows; row++) {
      if (_well[row].every((cell) => cell != 0)) full.add(row);
    }
    if (full.isEmpty) {
      // Points come from cleared rows only. Placing a shape is not an
      // achievement.
      _streak = 0;
      return;
    }
    _justCleared
      ..clear()
      ..addAll(full);
    _clearedAt = _runTime;
    for (final row in full.reversed) {
      _well.removeAt(row);
      _well.insert(0, List<int>.filled(_columns, 0));
    }
    _streak += 1;
    _bestStreak = math.max(_bestStreak, _streak);
    // One row is 50. Clearing more at once, or clearing again without a gap,
    // is worth progressively more.
    final multiple = <int, int>{1: 50, 2: 130, 3: 240, 4: 400};
    final base = multiple[full.length] ?? 400;
    final bonus = math.min((_streak - 1) * 25, 100);
    _rowsCleared += full.length;
    _score += base + bonus;
    _showFlash(
      full.length > 1
          ? '${full.length} rows  +${base + bonus}'
          : '+${base + bonus}',
    );
    if (_mode != GameMode.calm && _mode != GameMode.reducedMotion) {
      unawaited(HapticFeedback.selectionClick());
    }
  }

  void _move(int direction) {
    final piece = _piece;
    if (piece == null || !_started || _paused || _finished) return;
    if (_fits(piece, piece.column + direction, piece.row.toInt())) {
      setState(() => piece.column += direction);
    }
  }

  void _rotate() {
    final piece = _piece;
    if (piece == null || !_started || _paused || _finished) return;
    _rotatedOnce = true;
    final before = piece.cells;
    piece.rotate();
    // A rotation beside a wall is nudged in rather than refused.
    for (final shift in <int>[0, -1, 1, -2, 2]) {
      if (_fits(piece, piece.column + shift, piece.row.toInt())) {
        setState(() => piece.column += shift);
        return;
      }
    }
    piece.cells = before;
  }

  void _drop() {
    final piece = _piece;
    if (piece == null || !_started || _paused || _finished) return;
    setState(() {
      while (_fits(piece, piece.column, piece.row.toInt() + 1)) {
        piece.row += 1;
      }
      _land(piece);
    });
  }

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
    setState(() => _saving = true);
    final result = await ref
        .read(gamificationRepositoryProvider)
        .recordGame(
          launch: SignalShiftLaunch(
            kind: GameKind.focusStack,
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

  Future<void> _showExitDialog() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End this session?'),
        content: const Text(
          'Your score so far is kept. You can start another one any time.',
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End it'),
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
          title: const Text('Focus Stack'),
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
              ? _buildIntro(context)
              : _finished
              ? _buildResults(context, avatar)
              : _buildGame(context, avatar),
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/focus_stack_hero.png',
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
              // The art may not be in place yet, and a missing picture should
              // not put a red error box on a screen someone opens mid-craving.
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
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
          const Text(
            'Fit the falling shapes together and fill a row to clear it. '
            'Nothing here can end your run early.',
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
                const _StackRule(
                  icon: Icons.swipe_rounded,
                  text: 'Tap left or right of the well to move',
                ),
                const _StackRule(
                  icon: Icons.rotate_right_rounded,
                  text: 'Tap the middle, or swipe up, to turn the shape',
                ),
                const _StackRule(
                  icon: Icons.south_rounded,
                  text: 'Swipe down to drop it straight away',
                ),
                const _StackRule(
                  icon: Icons.view_week_rounded,
                  text: 'Fill a row to clear it',
                  value: '+50',
                ),
                const _StackRule(
                  icon: Icons.layers_rounded,
                  text: 'Clear two, three or four at once',
                  value: 'up to +400',
                ),
                const _StackRule(
                  icon: Icons.block_rounded,
                  text: 'If the shapes reach the top, the bottom rows go',
                  value: 'no game over',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Shape fitting is the point, not decoration. Cravings run on vivid '
            'mental pictures, and turning shapes occupies the same part of '
            'working memory, which is why visual puzzles lower craving '
            'strength where word games do not.',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _start,
              child: Text('Start $_durationMinutes minutes'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Not now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame(BuildContext context, AvatarProfileData avatar) {
    final totalSeconds = _durationMinutes * 60;
    final remaining = math.max(0, totalSeconds - _elapsed.inSeconds);
    final oneHanded = avatar.preferences.oneHanded;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(
            children: <Widget>[
              _StackMetric(label: 'SCORE', value: '$_score'),
              const SizedBox(width: 16),
              _StackMetric(label: 'ROWS', value: '$_rowsCleared'),
              const SizedBox(width: 16),
              _StackMetric(label: 'TIME', value: _clock(remaining)),
              const Spacer(),
              _NextShape(
                shape: _shapes[_nextShape],
                colour: _blockColours[_nextShape % _blockColours.length],
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
              switch (event.logicalKey.keyLabel) {
                case 'Arrow Left':
                case 'A':
                  _move(-1);
                case 'Arrow Right':
                case 'D':
                  _move(1);
                case 'Arrow Up':
                case 'W':
                  _rotate();
                case 'Arrow Down':
                case 'S':
                case ' ':
                  _drop();
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final width = context.size?.width ?? 0;
                if (width == 0) return;
                final third = width / 3;
                if (details.localPosition.dx < third) {
                  _move(-1);
                } else if (details.localPosition.dx > width - third) {
                  _move(1);
                } else {
                  _rotate();
                }
              },
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity > 0) {
                  _drop();
                } else if (velocity < 0) {
                  _rotate();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _WellPainter(
                          flashRows: _justCleared,
                          flashAge: _runTime - _clearedAt,
                          well: _well,
                          piece: _piece,
                          highContrast: avatar.preferences.highContrast,
                          calm: _mode == GameMode.calm,
                        ),
                      ),
                    ),
                    if (_pieces <= 1 && !_rotatedOnce)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 28,
                        child: IgnorePointer(
                          child: Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface
                                    .withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text(
                                  'Sides to move  •  middle to turn  •  swipe down to drop',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onInverseSurface,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_flash != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 24,
                        child: IgnorePointer(
                          child: Center(
                            child: Text(
                              _flash!,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFFFD86B),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    // A pause is a breath, not a menu. The mascot sits down
                    // with you and the way back in is the obvious button.
                    if (_paused)
                      Positioned.fill(
                        child: ColoredBox(
                          color: const Color(
                            0xFF140D26,
                          ).withValues(alpha: 0.82),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Paused',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Take a breath. Nothing is lost.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  MascotCharacter(
                                    equipped: <String, String>{
                                      ...avatar.equipped,
                                      'expression': 'face_happy',
                                    },
                                    size: 120,
                                    pose: MascotPose.watch,
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: () {
                                      setState(() => _paused = false);
                                      _focusNode.requestFocus();
                                    },
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: const Text('Resume'),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(Icons.home_rounded),
                                    label: const Text('Exit to home'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (oneHanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _move(-1),
                    child: const Icon(Icons.chevron_left_rounded),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _rotate,
                    child: const Icon(Icons.rotate_right_rounded),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _drop,
                    child: const Icon(Icons.south_rounded),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _move(1),
                    child: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showExitDialog,
              child: const Text('End early'),
            ),
          ),
        ),
      ],
    );
  }

  static String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  /// The mascot wearing a face for the moment rather than its saved one.
  /// Clearing rows earns the bright face; a run with none gets the steady one,
  /// never a disappointed one, because the point was the few minutes away from
  /// the urge and not the score.
  Map<String, String> _faced(AvatarProfileData avatar) => <String, String>{
    ...avatar.equipped,
    'expression': _rowsCleared > 0 ? 'face_excited' : 'face_happy',
  };

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
                equipped: _faced(avatar),
                size: 145,
                pose: _rowsCleared > 0
                    ? MascotPose.celebrate
                    : MascotPose.watch,
              ),
            ),
            Text(
              'Notice what changed',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'There is no right result. This helps HabitWise learn whether '
              'this fits this kind of moment.',
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
            const Text('Did it take your attention?'),
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
            MascotCharacter(
              equipped: _faced(avatar),
              size: 155,
              pose: _rowsCleared > 0 ? MascotPose.celebrate : MascotPose.watch,
            ),
            const SizedBox(height: 14),
            Text(
              _result?.completed == true ? 'Session complete' : 'Session ended',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Score $_score  •  $_rowsCleared rows  •  best run $_bestStreak',
            ),
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
            else if ((_result?.coinsEarned ?? 0) > 0)
              Text(
                '+${_result!.coinsEarned} coins',
                style: Theme.of(context).textTheme.titleLarge,
              )
            else
              const Text('No coins were added for this session.'),
            const SizedBox(height: 20),
            const Text(
              'That was one strategy. Go back to your plan and decide what '
              'fits next.',
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
}

class _StackRule extends StatelessWidget {
  const _StackRule({required this.icon, required this.text, this.value});
  final IconData icon;
  final String text;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          if (value != null)
            Text(value!, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _StackMetric extends StatelessWidget {
  const _StackMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _NextShape extends StatelessWidget {
  const _NextShape({required this.shape, required this.colour});
  final List<List<int>> shape;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'NEXT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 46,
            height: 32,
            child: CustomPaint(
              painter: _ShapePainter(shape: shape, colour: colour),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lavender, mint, coral, butter, sky and a warm orange. Pastels on a dark
/// panel, so a filling board reads as something pleasant rather than something
/// closing in.
const _blockColours = <Color>[
  Color(0xFFB69CF5),
  Color(0xFF6FD3B8),
  Color(0xFFF2708A),
  Color(0xFFF7D774),
  Color(0xFF7FB4F5),
  Color(0xFFFF9F7A),
];

class _ShapePainter extends CustomPainter {
  const _ShapePainter({required this.shape, this.colour});
  final List<List<int>> shape;
  final Color? colour;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = math.min(
      size.width / shape.first.length,
      size.height / shape.length,
    );
    // The preview wears the colour the piece will actually be, so the eye can
    // start planning before it lands.
    final tint = colour ?? const Color(0xFF8E85A0);
    for (var y = 0; y < shape.length; y++) {
      for (var x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 0) continue;
        final rect = Rect.fromLTWH(
          x * cell + 1.5,
          y * cell + 1.5,
          cell - 3,
          cell - 3,
        );
        final radius = Radius.circular(cell * 0.26);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.translate(0, 1.5), radius),
          Paint()
            ..color = Color.lerp(
              tint,
              Colors.black,
              0.45,
            )!.withValues(alpha: 0.5),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, radius),
          Paint()..color = tint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              rect.left + rect.width * 0.14,
              rect.top + rect.height * 0.12,
              rect.width * 0.72,
              rect.height * 0.32,
            ),
            Radius.circular(cell * 0.18),
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.28),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.colour != colour;
}

class _WellPainter extends CustomPainter {
  const _WellPainter({
    required this.flashRows,
    required this.flashAge,
    required this.well,
    required this.piece,
    required this.highContrast,
    required this.calm,
  });

  /// Rows cleared a moment ago, and how long ago in seconds.
  final List<int> flashRows;
  final double flashAge;
  final List<List<int>> well;
  final _Piece? piece;
  final bool highContrast;
  final bool calm;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = math.min(size.width / _columns, size.height / _rows);
    final boardWidth = cell * _columns;
    final boardHeight = cell * _rows;
    final left = (size.width - boardWidth) / 2;
    final top = (size.height - boardHeight) / 2;
    final board = Rect.fromLTWH(left, top, boardWidth, boardHeight);
    final panel = RRect.fromRectAndRadius(board, const Radius.circular(20));

    canvas.drawRRect(
      panel,
      Paint()..color = calm ? const Color(0xFFF0EAF6) : const Color(0xFF1E1536),
    );
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = (calm ? const Color(0xFF7557A8) : Colors.white).withValues(
          alpha: 0.12,
        ),
    );

    final grid = Paint()
      ..color = (calm ? const Color(0xFF7557A8) : Colors.white).withValues(
        alpha: highContrast ? 0.22 : 0.07,
      )
      ..strokeWidth = 1;
    for (var column = 1; column < _columns; column++) {
      final x = left + column * cell;
      canvas.drawLine(
        Offset(x, top + 6),
        Offset(x, top + boardHeight - 6),
        grid,
      );
    }
    for (var row = 1; row < _rows; row++) {
      final y = top + row * cell;
      canvas.drawLine(
        Offset(left + 6, y),
        Offset(left + boardWidth - 6, y),
        grid,
      );
    }

    /// A block: a rounded pastel tile with a lit top face and a shaded foot,
    /// which is what makes it read as a solid object rather than a flat
    /// square. No blur anywhere, the same rule the other game runs under.
    void drawCell(int column, int row, Color colour) {
      if (row < 0) return;
      final rect = Rect.fromLTWH(
        left + column * cell + 2.5,
        top + row * cell + 2.5,
        cell - 5,
        cell - 5,
      );
      final radius = Radius.circular(cell * 0.26);
      final shape = RRect.fromRectAndRadius(rect, radius);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.translate(0, 2), radius),
        Paint()
          ..color = Color.lerp(
            colour,
            Colors.black,
            0.45,
          )!.withValues(alpha: 0.5),
      );
      canvas.drawRRect(shape, Paint()..color = colour);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + rect.width * 0.14,
            rect.top + rect.height * 0.12,
            rect.width * 0.72,
            rect.height * 0.34,
          ),
          Radius.circular(cell * 0.18),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
      if (highContrast) {
        canvas.drawRRect(
          shape,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.white.withValues(alpha: 0.6),
        );
      }
    }

    if (flashAge < 0.45) {
      final fade = 1 - flashAge / 0.45;
      for (final row in flashRows) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left + 4, top + row * cell, boardWidth - 8, cell),
            Radius.circular(cell * 0.3),
          ),
          Paint()..color = Colors.white.withValues(alpha: fade * 0.55),
        );
      }
    }

    for (var row = 0; row < _rows; row++) {
      for (var column = 0; column < _columns; column++) {
        final value = well[row][column];
        if (value == 0) continue;
        drawCell(
          column,
          row,
          _blockColours[(value - 1) % _blockColours.length],
        );
      }
    }

    final current = piece;
    if (current == null) return;

    // Where the piece would land, drawn as an outline rather than a ghost
    // block, so the landing spot never looks like something already placed.
    var ghostRow = current.row.toInt();
    while (_wouldFit(current, current.column, ghostRow + 1)) {
      ghostRow += 1;
    }
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _blockColours[current.colour % _blockColours.length].withValues(
        alpha: 0.55,
      );
    for (var y = 0; y < current.height; y++) {
      for (var x = 0; x < current.width; x++) {
        if (current.cells[y][x] == 0) continue;
        if (ghostRow + y < 0) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left + (current.column + x) * cell + 3.5,
              top + (ghostRow + y) * cell + 3.5,
              cell - 7,
              cell - 7,
            ),
            Radius.circular(cell * 0.24),
          ),
          outline,
        );
      }
    }
    for (var y = 0; y < current.height; y++) {
      for (var x = 0; x < current.width; x++) {
        if (current.cells[y][x] == 0) continue;
        drawCell(
          current.column + x,
          current.row.toInt() + y,
          _blockColours[current.colour % _blockColours.length],
        );
      }
    }
  }

  bool _wouldFit(_Piece piece, int column, int row) {
    for (var y = 0; y < piece.height; y++) {
      for (var x = 0; x < piece.width; x++) {
        if (piece.cells[y][x] == 0) continue;
        final boardX = column + x;
        final boardY = row + y;
        if (boardX < 0 || boardX >= _columns || boardY >= _rows) return false;
        if (boardY >= 0 && well[boardY][boardX] != 0) return false;
      }
    }
    return true;
  }

  @override
  bool shouldRepaint(covariant _WellPainter oldDelegate) => true;
}
