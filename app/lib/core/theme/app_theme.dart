import 'package:flutter/material.dart';
import 'app_typography.dart';

/// Semantic palette. Resolve with [AppColors.of] so it follows light/dark.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.sidebar,
    required this.surfaceHover,
    required this.border,
    required this.borderLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.icon,
    required this.iconHover,
    required this.accentSoft,
    required this.warningSoft,
    required this.errorSoft,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color sidebar;
  final Color surfaceHover;
  final Color border;
  final Color borderLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  /// Default icon color (grey).
  final Color icon;
  /// Icon color on hover — black in light, white in dark.
  final Color iconHover;
  final Color accentSoft;
  final Color warningSoft;
  final Color errorSoft;

  // Shared across themes
  static const Color accent = Color(0xFF239B98);
  static const Color accentDim = Color(0xFF1B7A78);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFB26A00);
  static const Color error = Color(0xFFD92D20);
  static const Color sentimentPositive = Color(0xFF12805C);
  static const Color sentimentNegative = Color(0xFFD92D20);
  static const Color sentimentNeutral = Color(0xFFB26A00);
  static const Color terminalGreen = Color(0xFF12805C);
  static const Color terminalRed = Color(0xFFD92D20);
  static const Color terminalAmber = Color(0xFFB26A00);

  static const AppColors light = AppColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF7F7F8),
    sidebar: Color(0xFFECECEE),
    surfaceHover: Color(0xFFEFEFF0),
    border: Color(0xFFE6E6E8),
    borderLight: Color(0xFFF0F0F1),
    textPrimary: Color(0xFF0D0D0D),
    textSecondary: Color(0xFF6B6B76),
    textTertiary: Color(0xFF9A9AA5),
    icon: Color(0xFF6B6B76),
    iconHover: Color(0xFF0D0D0D),
    accentSoft: Color(0xFFE9F5F4),
    warningSoft: Color(0xFFFCF3E6),
    errorSoft: Color(0xFFFDECEA),
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF0F0F10),
    surface: Color(0xFF161618),
    surfaceVariant: Color(0xFF1C1C1F),
    sidebar: Color(0xFF080809),
    surfaceHover: Color(0xFF242428),
    border: Color(0xFF2A2A2E),
    borderLight: Color(0xFF333338),
    textPrimary: Color(0xFFF2F2F3),
    textSecondary: Color(0xFFA0A0AB),
    textTertiary: Color(0xFF6E6E78),
    icon: Color(0xFFA0A0AB),
    iconHover: Color(0xFFFFFFFF),
    accentSoft: Color(0xFF163534),
    warningSoft: Color(0xFF332A00),
    errorSoft: Color(0xFF3A1515),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? sidebar,
    Color? surfaceHover,
    Color? border,
    Color? borderLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? icon,
    Color? iconHover,
    Color? accentSoft,
    Color? warningSoft,
    Color? errorSoft,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      sidebar: sidebar ?? this.sidebar,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      icon: icon ?? this.icon,
      iconHover: iconHover ?? this.iconHover,
      accentSoft: accentSoft ?? this.accentSoft,
      warningSoft: warningSoft ?? this.warningSoft,
      errorSoft: errorSoft ?? this.errorSoft,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      iconHover: Color.lerp(iconHover, other.iconHover, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme => _build(AppColors.light, Brightness.light);
  static ThemeData get darkTheme => _build(AppColors.dark, Brightness.dark);

  /// Legacy alias — prefer [lightTheme].
  @Deprecated('Use lightTheme')
  static ThemeData get theme => lightTheme;

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    TextStyle colored(TextStyle base, Color color) => base.copyWith(color: color);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.primaryFontFamily,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.accentDim,
        onSecondary: AppColors.onAccent,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: colors.border,
      ),
      textTheme: TextTheme(
        displayLarge: colored(AppTypography.displayLarge, colors.textPrimary),
        headlineLarge: colored(AppTypography.headlineLarge, colors.textPrimary),
        headlineMedium: colored(AppTypography.headlineMedium, colors.textPrimary),
        titleLarge: colored(AppTypography.titleLarge, colors.textPrimary),
        titleMedium: colored(AppTypography.titleMedium, colors.textPrimary),
        titleSmall: colored(AppTypography.titleSmall, colors.textPrimary),
        bodyLarge: colored(AppTypography.bodyLarge, colors.textPrimary),
        bodyMedium: colored(AppTypography.bodyMedium, colors.textSecondary),
        bodySmall: colored(AppTypography.bodySmall, colors.textTertiary),
        labelLarge: colored(AppTypography.labelLarge, colors.textPrimary),
        labelMedium: colored(AppTypography.labelMedium, colors.textSecondary),
        labelSmall: colored(AppTypography.labelSmall, colors.textTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colors.icon),
        titleTextStyle: colored(AppTypography.headlineMedium, colors.textPrimary),
      ),
      iconTheme: IconThemeData(color: colors.icon, size: 20),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: colored(AppTypography.bodyMedium, colors.textTertiary),
        labelStyle: colored(AppTypography.bodyMedium, colors.textSecondary),
        prefixIconColor: colors.icon,
        suffixIconColor: colors.icon,
      ),
      // Important actions use the accent.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: colors.surfaceHover,
          disabledForegroundColor: colors.textTertiary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTypography.titleMedium.copyWith(color: AppColors.onAccent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.textSecondary),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accent;
          return null;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onAccent),
        side: BorderSide(color: colors.border, width: 1.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        thumbColor: AppColors.accent,
        inactiveTrackColor: colors.border,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surfaceHover : colors.textPrimary,
        contentTextStyle: colored(AppTypography.bodyMedium, isDark ? colors.textPrimary : Colors.white),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.accentSoft,
        side: BorderSide.none,
        labelStyle: colored(AppTypography.labelMedium, colors.textPrimary),
        secondaryLabelStyle: colored(AppTypography.labelMedium, colors.textPrimary),
      ),
    );
  }
}
