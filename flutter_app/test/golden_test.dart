import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/core/theme/app_theme.dart';
import 'package:habitwise/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('welcome screen phone layout', (tester) async {
    await (FontLoader(
      'DM Sans',
    )..addFont(rootBundle.load('assets/fonts/DMSans.ttf'))).load();
    await (FontLoader(
      'Playfair Display',
    )..addFont(rootBundle.load('assets/fonts/PlayfairDisplay.ttf'))).load();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildHabitTheme(Brightness.light),
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_welcome.png'),
    );
  }, tags: <String>['golden']);
}
