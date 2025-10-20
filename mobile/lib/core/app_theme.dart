import 'package:flutter/material.dart';

ThemeData buildLightTheme(Color seed) {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: seed, brightness: Brightness.light);
  final cs = base.colorScheme;
  return base.copyWith(
    listTileTheme: ListTileThemeData(
      iconColor: cs.onSurfaceVariant,
      textColor: cs.onSurface,
      titleTextStyle: base.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
      subtitleTextStyle: base.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: cs.surfaceContainerHigh,
      labelStyle: base.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) => cs.onSurface),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(contentTextStyle: TextStyle(color: cs.onInverseSurface)),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
    ),
  );
}

ThemeData buildDarkTheme(Color seed) {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: seed, brightness: Brightness.dark);
  final cs = base.colorScheme;
  return base.copyWith(
    scaffoldBackgroundColor: cs.background,
    listTileTheme: ListTileThemeData(
      iconColor: cs.onSurfaceVariant,
      textColor: cs.onSurface,
      titleTextStyle: base.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
      subtitleTextStyle: base.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: cs.surfaceContainerHigh,
      labelStyle: base.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) => cs.onSurface),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(contentTextStyle: TextStyle(color: cs.onInverseSurface)),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
    ),
  );
}
