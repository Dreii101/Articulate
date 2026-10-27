import 'package:flutter/material.dart';

ThemeData articulateTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF285344),
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFFB9D8C5) : const Color(0xFF285344),
        onPrimary: dark ? const Color(0xFF18382C) : Colors.white,
        surface: dark ? const Color(0xFF171D1A) : const Color(0xFFF7F7F2),
        onSurface: dark ? const Color(0xFFE7ECE5) : const Color(0xFF202F27),
        onSurfaceVariant: dark
            ? const Color(0xFFB8C5BB)
            : const Color(0xFF56655B),
        surfaceContainerLow: dark ? const Color(0xFF202924) : Colors.white,
        surfaceContainerHighest: dark
            ? const Color(0xFF2E3C33)
            : const Color(0xFFE9EEE4),
        outlineVariant: dark
            ? const Color(0xFF48564B)
            : const Color(0xFFD9E0D5),
      );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: scheme.surface,
  );
  return base.copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final entry in const PageTransitionsTheme().builders.entries)
          entry.key: _MotionAwareTransitions(entry.value),
      },
    ),
    textTheme: base.textTheme.copyWith(
      headlineLarge: TextStyle(
        fontFamily: 'Lora',
        fontSize: 38,
        height: 1.2,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Lora',
        fontSize: 28,
        height: 1.25,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 16,
        height: 1.6,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        height: 1.6,
        color: scheme.onSurfaceVariant,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    chipTheme: base.chipTheme.copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.surfaceContainerHighest,
    ),
    focusColor: scheme.primary.withValues(alpha: .18),
  );
}

class _MotionAwareTransitions extends PageTransitionsBuilder {
  const _MotionAwareTransitions(this.normal);
  final PageTransitionsBuilder normal;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => MediaQuery.disableAnimationsOf(context)
      ? child
      : normal.buildTransitions(
          route,
          context,
          animation,
          secondaryAnimation,
          child,
        );
}
