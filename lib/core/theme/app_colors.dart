import 'package:flutter/material.dart';

/// Primerock brand palette — black primary, metallic gold accents, white text.
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceElevated = Color(0xFF141414);
  static const Color card = Color(0xFF1A1A1A);
  static const Color glass = Color(0xCC1C1C1C);

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF1D279);
  static const Color goldDark = Color(0xFF916B25);
  static const Color goldMuted = Color(0xFFB8962E);

  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white38 = Color(0x61FFFFFF);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color divider = Color(0x33D4AF37);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0D0D), black, Color(0xFF050505)],
  );
}
