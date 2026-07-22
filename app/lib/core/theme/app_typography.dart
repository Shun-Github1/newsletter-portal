import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography: Open Sans for headers, IBM Plex Sans for body / UI chrome.
/// Colors are applied by [AppTheme] / call sites via [AppColors.of].
abstract class AppTypography {
  static String get headerFontFamily => GoogleFonts.openSans().fontFamily ?? 'Open Sans';
  static String get bodyFontFamily => GoogleFonts.ibmPlexSans().fontFamily ?? 'IBM Plex Sans';
  static String get primaryFontFamily => bodyFontFamily;

  // --- Headers (Open Sans) ---

  static TextStyle displayLarge = GoogleFonts.openSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  static TextStyle headlineLarge = GoogleFonts.openSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static TextStyle headlineMedium = GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleLarge = GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleMedium = GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleSmall = GoogleFonts.openSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // --- Body / UI (IBM Plex Sans) ---

  static TextStyle bodyLarge = GoogleFonts.ibmPlexSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static TextStyle labelLarge = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelMedium = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelSmall = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle monoLarge = GoogleFonts.ibmPlexSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle monoMedium = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle monoStandard = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle monoSmall = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle monoExtraSmall = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle monoTiny = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle serifTitle = GoogleFonts.openSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle serifHeading = GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle serifSubheading = GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle serifBody = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle serifCaption = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    fontStyle: FontStyle.italic,
  );
}
