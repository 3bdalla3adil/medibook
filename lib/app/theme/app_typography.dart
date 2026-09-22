import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const _family = 'Cairo';

  static TextTheme textTheme(ColorScheme scheme) => const TextTheme(
        displayLarge: TextStyle(fontFamily: _family, fontSize: 57, height: 1.2),
        displayMedium: TextStyle(fontFamily: _family, fontSize: 45, height: 1.2),
        displaySmall: TextStyle(fontFamily: _family, fontSize: 36, height: 1.2),
        headlineLarge: TextStyle(fontFamily: _family, fontSize: 32, height: 1.3),
        headlineMedium: TextStyle(fontFamily: _family, fontSize: 28, height: 1.3),
        headlineSmall: TextStyle(fontFamily: _family, fontSize: 24, height: 1.3),
        titleLarge: TextStyle(
          fontFamily: _family,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontFamily: _family,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontFamily: _family,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(fontFamily: _family, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(fontFamily: _family, fontSize: 14, height: 1.5),
        bodySmall: TextStyle(fontFamily: _family, fontSize: 12, height: 1.5),
        labelLarge: TextStyle(
          fontFamily: _family,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelMedium: TextStyle(fontFamily: _family, fontSize: 12, height: 1.4),
        labelSmall: TextStyle(fontFamily: _family, fontSize: 11, height: 1.4),
      ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
}
