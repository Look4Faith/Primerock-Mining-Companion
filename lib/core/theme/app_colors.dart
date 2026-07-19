import 'package:flutter/material.dart';

/// Primerock brand palette — adaptive for dark and light modes.
class AppColors {
  AppColors._();

  // Brand (shared)
  static const Color black = Color(0xFF000000);
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

  // Dark surfaces
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceElevated = Color(0xFF141414);
  static const Color card = Color(0xFF1A1A1A);
  static const Color glass = Color(0xCC1C1C1C);
  static const Color divider = Color(0x33D4AF37);

  // Light surfaces
  static const Color lightScaffold = Color(0xFFF7F5F0);
  static const Color lightSurface = Color(0xFFFFFBF5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightGlass = Color(0xF2FFFFFF);
  static const Color lightInk = Color(0xFF1A1A1A);
  static const Color lightInk70 = Color(0xFF5C5346);
  static const Color lightInk38 = Color(0xFF8A8174);
  static const Color lightDivider = Color(0x66D4AF37);
  static const Color lightElevated = Color(0xFFF0EBE3);

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

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFBF5), lightScaffold, Color(0xFFF0EBE3)],
  );

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? white : lightInk;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? white70 : lightInk70;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? white38 : lightInk38;

  /// Titles / brand emphasis — readable on both themes.
  static Color accent(BuildContext context) =>
      isDark(context) ? gold : goldDark;

  static Color accentSoft(BuildContext context) =>
      isDark(context) ? goldLight : goldDark;

  static Color cardColor(BuildContext context) =>
      isDark(context) ? glass : lightGlass;

  static Color elevated(BuildContext context) =>
      isDark(context) ? surfaceElevated : lightElevated;

  static Color border(BuildContext context) =>
      isDark(context) ? divider : lightDivider;

  static Color scaffold(BuildContext context) =>
      isDark(context) ? black : lightScaffold;

  static LinearGradient pageGradient(BuildContext context) =>
      isDark(context) ? backgroundGradient : lightBackgroundGradient;

  /// Logo sits on a panel so the black-backed mark stays readable in light mode.
  static Color logoPanel(BuildContext context) =>
      isDark(context) ? surfaceElevated : black;
}
