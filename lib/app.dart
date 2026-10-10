import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/craving_flow/domain/craving_models.dart';
import 'features/craving_flow/presentation/craving_flow_screen.dart';
import 'features/gamification/domain/avatar_models.dart';
import 'features/gamification/presentation/avatar_screen.dart';
import 'features/gamification/presentation/focus_stack_game_screen.dart';
import 'features/gamification/presentation/mascot/mascot_lab_screen.dart';
import 'features/gamification/presentation/signal_shift_game_screen.dart';
import 'features/gamification/presentation/signal_style_lab_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/home/presentation/app_shell.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/insights/presentation/insights_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/profile/presentation/privacy_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'providers.dart';

class HabitWiseApp extends ConsumerStatefulWidget {
  const HabitWiseApp({super.key});

  @override
  ConsumerState<HabitWiseApp> createState() => _HabitWiseAppState();
}

class _HabitWiseAppState extends ConsumerState<HabitWiseApp> {
  late final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const _StartGate()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/craving',
        builder: (context, state) => CravingFlowScreen(
          repeat: state.extra is CravingRepeat
              ? state.extra! as CravingRepeat
              : null,
        ),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      // Temporary review screen for the new mascot. Not linked from the app.
      // Temporary review screen for the new game look. Not linked from the app.
      GoRoute(
        path: '/signal-lab',
        builder: (context, state) => const SignalStyleLabScreen(),
      ),
      GoRoute(
        path: '/mascot-lab',
        builder: (context, state) => const MascotLabScreen(),
      ),
      GoRoute(
        path: '/focus-stack',
        builder: (context, state) => FocusStackGameScreen(
          launch: state.extra is SignalShiftLaunch
              ? state.extra! as SignalShiftLaunch
              : const SignalShiftLaunch.practice(kind: GameKind.focusStack),
        ),
      ),
      GoRoute(
        path: '/signal-shift',
        builder: (context, state) => SignalShiftGameScreen(
          launch: state.extra is SignalShiftLaunch
              ? state.extra! as SignalShiftLaunch
              : const SignalShiftLaunch.practice(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/history',
                builder: (_, _) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: '/avatar', builder: (_, _) => const AvatarScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/insights',
                builder: (_, _) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final themeMode = switch (profile?.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return MaterialApp.router(
      title: 'HabitWise',
      debugShowCheckedModeBanner: false,
      theme: buildHabitTheme(Brightness.light),
      darkTheme: buildHabitTheme(Brightness.dark),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}

class _StartGate extends ConsumerStatefulWidget {
  const _StartGate();

  @override
  ConsumerState<_StartGate> createState() => _StartGateState();
}

class _StartGateState extends ConsumerState<_StartGate> {
  bool _routed = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    profile.whenData((value) {
      if (_routed) return;
      _routed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(value.onboardingComplete ? '/home' : '/onboarding');
      });
    });
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'Opening HabitWise',
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
