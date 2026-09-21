import 'package:flutter/material.dart';

abstract final class HabitColors {
  static const forest = Color(0xFF04342C);
  static const mint = Color(0xFF5DCAA5);
  static const cream = Color(0xFFF8F4EC);
  static const ink = Color(0xFF17211F);
  static const darkSurface = Color(0xFF102521);
  static const warning = Color(0xFFB24A2F);
}

ThemeData buildHabitTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: HabitColors.mint,
    brightness: brightness,
    primary: isDark ? const Color(0xFF8DE3C2) : HabitColors.forest,
    secondary: HabitColors.mint,
    surface: isDark ? HabitColors.darkSurface : const Color(0xFFFFFCF7),
    error: isDark ? const Color(0xFFFFB4A5) : HabitColors.warning,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF081A17)
        : HabitColors.cream,
    fontFamily: 'DM Sans',
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w700,
        height: 1.08,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w700,
        height: 1.08,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.4),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: scheme.surface,
      indicatorColor: HabitColors.mint.withValues(alpha: 0.28),
      labelTextStyle: WidgetStatePropertyAll(
        base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
