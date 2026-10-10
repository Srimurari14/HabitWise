import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/app_database.dart';
import 'data/local/database_key.dart';
import 'providers.dart';

/// How far the app got before it could show anything.
enum _Stage { working, ready, noKey, unreadable }

/// Everything that has to work before the first screen can be drawn.
///
/// This used to happen in `main` ahead of `runApp`, which meant anything that
/// threw left the app with no interface at all: a black window, on every
/// launch, with nothing to tap and nothing to report. For an app whose whole
/// job is being available during a craving, that is the worst way to fail.
/// Doing it inside a widget means a failure has somewhere to be shown and
/// something to offer.
class HabitWiseStartup extends StatefulWidget {
  const HabitWiseStartup({super.key});

  @override
  State<HabitWiseStartup> createState() => _HabitWiseStartupState();
}

class _HabitWiseStartupState extends State<HabitWiseStartup> {
  static const _storage = FlutterSecureStorage();
  static const _store = DatabaseKeyStore(_storage);

  _Stage _stage = _Stage.working;
  DatabaseKey? _key;
  AppDatabase? _database;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _stage = _Stage.working);

    // Reminders are a convenience. The app has to open without them, so a
    // platform that refuses to set them up costs notifications and nothing
    // else.
    try {
      await NotificationService.instance.initialize();
    } on Object catch (error, stack) {
      reportAppError('notifications', error, stack);
    }

    DatabaseKey? key;
    try {
      key = await _store.getOrCreate();
    } on Object catch (error, stack) {
      reportAppError('database key', error, stack);
    }
    if (!mounted) return;
    if (key == null) {
      setState(() => _stage = _Stage.noKey);
      return;
    }

    await _closeDatabase();
    final database = AppDatabase.open(key);
    final readable = await _canRead(database);
    if (!mounted) return;
    setState(() {
      _key = key;
      _database = readable ? database : null;
      _stage = readable ? _Stage.ready : _Stage.unreadable;
    });
  }

  /// Whether the file actually opens with this key.
  ///
  /// SQLCipher does not report a wrong key when the connection is made. It
  /// reports it on the first statement, so the only way to know is to run
  /// one.
  Future<bool> _canRead(AppDatabase database) async {
    try {
      await database.customSelect('SELECT 1').get();
      return true;
    } on Object catch (error, stack) {
      reportAppError('database open', error, stack);
      return false;
    }
  }

  Future<void> _closeDatabase() async {
    final open = _database;
    if (open == null) return;
    _database = null;
    try {
      await open.close();
    } on Object {
      // Already gone, which is the state we wanted.
    }
  }

  /// Start a new, empty database, leaving the unreadable one where it is.
  Future<void> _startFresh() async {
    final current = _key;
    if (current == null) return;
    setState(() => _stage = _Stage.working);
    try {
      await _store.nextGeneration(current);
    } on Object catch (error, stack) {
      reportAppError('new database key', error, stack);
      if (!mounted) return;
      setState(() => _stage = _Stage.noKey);
      return;
    }
    await _start();
  }

  @override
  Widget build(BuildContext context) {
    final database = _database;
    if (_stage == _Stage.ready && database != null) {
      return ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const HabitWiseApp(),
      );
    }
    return MaterialApp(
      title: 'HabitWise',
      debugShowCheckedModeBanner: false,
      theme: buildHabitTheme(Brightness.light),
      darkTheme: buildHabitTheme(Brightness.dark),
      home: switch (_stage) {
        _Stage.working || _Stage.ready => const _Working(),
        _Stage.noKey => _Trouble(
          heading: 'HabitWise could not start',
          body:
              'This device would not let the app reach its private key, so '
              'there is no way to open your data safely. Nothing has been '
              'deleted.',
          actionLabel: 'Try again',
          onAction: _start,
        ),
        _Stage.unreadable => _Trouble(
          heading: 'Your data cannot be opened',
          body:
              'The key that unlocks your check-ins is no longer on this '
              'device. This usually follows a system update or a restored '
              'backup. Without it the existing data cannot be read by anyone, '
              'including HabitWise.\n\nStarting fresh gives you a working app '
              'again with an empty history. The old data is left alone and '
              'stays locked.',
          actionLabel: 'Start fresh',
          onAction: _startFresh,
          secondaryLabel: 'Try again',
          onSecondary: _start,
        ),
      },
    );
  }
}

class _Working extends StatelessWidget {
  const _Working();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _Trouble extends StatelessWidget {
  const _Trouble({
    required this.heading,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String heading;
  final String body;
  final String actionLabel;
  final Future<void> Function() onAction;
  final String? secondaryLabel;
  final Future<void> Function()? onSecondary;

  @override
  Widget build(BuildContext context) {
    final secondary = secondaryLabel;
    final onPressSecondary = onSecondary;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    heading,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 14),
                  Text(body),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: onAction, child: Text(actionLabel)),
                  if (secondary != null &&
                      onPressSecondary != null) ...<Widget>[
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: onPressSecondary,
                      child: Text(secondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Where a swallowed failure goes.
///
/// There is no crash reporter here and no server to send anything to, which is
/// deliberate for an app that keeps everything on the device. So this prints.
/// That is not much, but it is the difference between a failure somebody can
/// see while running the app and one that leaves no trace at all.
void reportAppError(String during, Object error, StackTrace stack) {
  debugPrint('HabitWise startup failed during $during: $error');
  debugPrintStack(stackTrace: stack);
}
