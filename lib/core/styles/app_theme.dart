import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_style.dart';

/// Light and dark themes.
///
/// The design file only specifies the light treatment; the dark palette is
/// derived from the brand board's navy ground and is pending review.
abstract final class AppTheme {
  static ThemeData get light => _base(
    brightness: Brightness.light,
    surface: AppColors.surfaceLight,
    card: AppColors.cardLight,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    divider: AppColors.divider,
  );

  static ThemeData get dark => _base(
    brightness: Brightness.dark,
    surface: AppColors.surfaceDark,
    card: AppColors.cardDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    divider: AppColors.dividerDark,
  );

  static ThemeData _base({
    required Brightness brightness,
    required Color surface,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
    required Color divider,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brandSolid,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.brandSolid,
          surface: surface,
          error: AppColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      dividerColor: divider,
      fontFamily: AppTextStyle.fontBody,
      textTheme: TextTheme(
        displayLarge: AppTextStyle.wordmark.copyWith(color: textPrimary),
        headlineLarge: AppTextStyle.h1.copyWith(color: textPrimary),
        headlineMedium: AppTextStyle.h2.copyWith(color: textPrimary),
        headlineSmall: AppTextStyle.h3.copyWith(color: textPrimary),
        bodyLarge: AppTextStyle.bodyLarge.copyWith(color: textPrimary),
        bodyMedium: AppTextStyle.bodyMedium.copyWith(color: textPrimary),
        bodySmall: AppTextStyle.bodySmall.copyWith(color: textSecondary),
        labelMedium: AppTextStyle.label.copyWith(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyle.h3.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandSolid,
          foregroundColor: AppColors.textOnBrand,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          textStyle: AppTextStyle.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brandSolid
              : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brandSolid.withValues(alpha: 0.4)
              : null,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: AppTextStyle.bodyLarge.copyWith(color: textPrimary),
        subtitleTextStyle: AppTextStyle.bodySmall.copyWith(
          color: textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: card,
        contentTextStyle: AppTextStyle.bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}
