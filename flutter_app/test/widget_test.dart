import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/core/theme/app_theme.dart';
import 'package:habitwise/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phone onboarding advances through the privacy introduction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildHabitTheme(Brightness.light),
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Understand the urge.\nChoose what helps.'),
      findsOneWidget,
    );
    expect(find.textContaining('Eating the food is always'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Built around your needs'), findsOneWidget);
    expect(find.text('Hunger comes first'), findsOneWidget);
    expect(find.text('Local and private'), findsOneWidget);
  });
}
