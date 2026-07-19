import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData(brightness: Brightness.dark).textTheme
        : ThemeData(brightness: Brightness.light).textTheme;
    final color =
        brightness == Brightness.dark ? AppColors.white : AppColors.lightInk;
    return base.apply(
      fontFamily: 'Montserrat',
      bodyColor: color,
      displayColor: color,
    );
  }

  static ThemeData get dark {
    final textTheme = _textTheme(Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      fontFamily: 'Montserrat',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.gold,
        textColor: AppColors.white,
        subtitleTextStyle: TextStyle(color: AppColors.white70),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.gold;
          return AppColors.white70;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold.withValues(alpha: 0.45);
          }
          return AppColors.surfaceElevated;
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        labelStyle: const TextStyle(color: AppColors.white70),
        hintStyle: const TextStyle(color: AppColors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.black,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.goldLight),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.black,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.gold),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.white),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.gold.withValues(alpha: 0.25),
        labelStyle: const TextStyle(color: AppColors.white),
        secondaryLabelStyle: const TextStyle(color: AppColors.white),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get light {
    final textTheme = _textTheme(Brightness.light);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightScaffold,
      fontFamily: 'Montserrat',
      colorScheme: const ColorScheme.light(
        primary: AppColors.goldDark,
        secondary: AppColors.gold,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
        onSurface: AppColors.lightInk,
        onError: AppColors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.goldDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.goldDark,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.goldDark),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.goldDark,
        textColor: AppColors.lightInk,
        subtitleTextStyle: TextStyle(color: AppColors.lightInk70),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.goldDark;
          return AppColors.lightInk38;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold.withValues(alpha: 0.45);
          }
          return AppColors.lightElevated;
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightDivider),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightElevated,
        labelStyle: const TextStyle(color: AppColors.lightInk70),
        hintStyle: const TextStyle(color: AppColors.lightInk38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.goldDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldDark,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldDark,
          side: const BorderSide(color: AppColors.goldDark),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.goldDark),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.goldDark,
        foregroundColor: AppColors.white,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightDivider),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightInk,
        contentTextStyle: const TextStyle(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(color: AppColors.goldDark),
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.lightInk),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightElevated,
        selectedColor: AppColors.gold.withValues(alpha: 0.28),
        labelStyle: const TextStyle(color: AppColors.lightInk),
        secondaryLabelStyle: const TextStyle(color: AppColors.lightInk),
        side: const BorderSide(color: AppColors.lightDivider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
