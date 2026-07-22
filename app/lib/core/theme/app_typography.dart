import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Centralized typography design system for Newsletter Portal.
/// Strictly enforces 2 font families (Inter & JetBrains Mono) across a 4-tier font size scale (24px, 16px, 13px, 11px).
abstract class AppTypography {
  // --- Font Family Definitions (Strictly 2 Fonts) ---
  static String get primaryFontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';
  static String get monoFontFamily => GoogleFonts.jetBrainsMono().fontFamily ?? 'JetBrains Mono';

  // --- Primary UI TextStyles (Inter) ---

  /// Tier 1: Hero / Headline (24px, Bold)
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Tier 1: Hero / Headline (24px, Bold)
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// Tier 2: Title / Subhead (16px, SemiBold)
  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Tier 2: Title / Subhead (16px, SemiBold)
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Tier 2: Title / Subhead (16px, SemiBold)
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Tier 3: Body / Standard (13px, Medium)
  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Tier 2: Title / Subhead (16px, Regular)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Tier 3: Body / Standard (13px, Regular)
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Tier 4: Small / Micro (11px, Regular)
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  /// Tier 3: Body / Standard (13px, Medium)
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Tier 4: Small / Micro (11px, Medium)
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Tier 4: Small / Micro (11px, Medium)
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );


  // --- Monospace TextStyles (JetBrains Mono) ---

  /// Mono Title (16px, Regular)
  static TextStyle monoLarge = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Mono Standard (13px, Regular)
  static TextStyle monoMedium = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Mono Standard (13px, Regular)
  static TextStyle monoStandard = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Mono Small (11px, Regular)
  static TextStyle monoSmall = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Mono Small (11px, Regular)
  static TextStyle monoExtraSmall = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Mono Micro (11px, Medium)
  static TextStyle monoTiny = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );


  // --- Editorial / Document Preview TextStyles (Inter Clean Modern) ---

  /// Tier 1: Hero Document Title (24px, Bold)
  static TextStyle serifTitle = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  /// Tier 2: Section Heading (16px, SemiBold)
  static TextStyle serifHeading = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  /// Tier 2: Article Subheading (16px, SemiBold)
  static TextStyle serifSubheading = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  /// Tier 3: Article Body (13px, Regular)
  static TextStyle serifBody = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    height: 1.6,
  );

  /// Tier 4: Metadata Caption (11px, Regular)
  static TextStyle serifCaption = GoogleFonts.inter(
    fontSize: 11,
    fontStyle: FontStyle.italic,
    color: Colors.black54,
  );
}
