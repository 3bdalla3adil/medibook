import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const _family = 'Cairo';

  static TextTheme textTheme(ColorScheme scheme) => const TextTheme(
        displayLarge: const TextStyle(fontFamily: _family, fontSize: 57, height: 1.2),
        displayMedium: const TextStyle(fontFamily: _family, fontSize: 45, height: 1.2),
        displaySmall: const TextStyle(fontFamily: _family, fontSize: 36, height: 1.2),
        headlineLarge: const TextStyle(fontFamily: _family, fontSize: 32, height: 1.3),
        headlineMedium: const TextStyle(fontFamily: _family, fontSize: 28, height: 1.3),
        headlineSmall: const TextStyle(fontFamily: _family, fontSize: 24, height: 1.3),
        titleLarge: const TextStyle(
          fontFamily: _family,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleMedium: const TextStyle(
          fontFamily: _family,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleSmall: const TextStyle(
          fontFamily: _family,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: const TextStyle(fontFamily: _family, fontSize: 16, height: 1.5),
        bodyMedium: const TextStyle(fontFamily: _family, fontSize: 14, height: 1.5),
        bodySmall: const TextStyle(fontFamily: _family, fontSize: 12, height: 1.5),
        labelLarge: const TextStyle(
          fontFamily: _family,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelMedium: const TextStyle(fontFamily: _family, fontSize: 12, height: 1.4),
        labelSmall: const TextStyle(fontFamily: _family, fontSize: 11, height: 1.4),
      ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
}
