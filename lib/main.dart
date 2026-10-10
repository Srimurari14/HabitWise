import 'dart:async';

import 'package:flutter/material.dart';

import 'startup.dart';

void main() {
  // Anything the framework catches during build, layout or paint. Without
  // this it goes to the console in debug and nowhere at all in release.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    reportAppError(
      'the interface',
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  // A widget that throws while building shows this instead of the framework's
  // bare grey rectangle, which tells the person nothing and looks like the app
  // has died.
  ErrorWidget.builder = (details) => const Directionality(
    // The error widget can be asked for above MaterialApp, where there is no
    // Directionality and a bare Text would throw. An error widget that throws
    // loops forever.
    textDirection: TextDirection.ltr,
    child: _SomethingBroke(),
  );

  // Errors thrown out of a callback with nobody waiting on them land here
  // rather than taking the app down.
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const HabitWiseStartup());
  }, (error, stack) => reportAppError('a background task', error, stack));
}

/// Shown in place of one piece of the screen that failed to build.
///
/// It names no error and offers no detail. Someone reaching for this app is
/// not in a position to debug it, and a wall of red text in the middle of a
/// craving is worse than a quiet gap.
class _SomethingBroke extends StatelessWidget {
  const _SomethingBroke();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'This part did not load. Going back and returning usually fixes it.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
