import 'package:flutter/material.dart';

/// All design tokens for Fit-Log.
///
/// Source of truth: design/tokens.js. Keep this file in sync with the design
/// canvas — values here are the only colors/typography/spacing the app should
/// use; do not hard-code them at the call site.

// ─── Colors ──────────────────────────────────────────────────────────────────

@immutable
class FLColors {
  // surfaces (warm neutral)
  final Color bgCanvas;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgMuted;
  final Color bgInset;
  final Color bgScrim;
  final Color glassFill;
  final Color glassStroke;
  // text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color textOnAccent;
  final Color textOnBlack;
  // accent (warm terracotta)
  final Color accentBrand;
  final Color accentBrandHi;
  final Color accentBrandLo;
  final Color accentBrandFill;
  // semantic
  final Color danger;
  final Color success;
  // strokes
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  // camera UI is always on dark
  final Color cameraFg;
  final Color cameraGlass;
  final Color cameraGlassStrong;
  final Color cameraStroke;
  final Color cameraGuide;

  const FLColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgMuted,
    required this.bgInset,
    required this.bgScrim,
    required this.glassFill,
    required this.glassStroke,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textOnAccent,
    required this.textOnBlack,
    required this.accentBrand,
    required this.accentBrandHi,
    required this.accentBrandLo,
    required this.accentBrandFill,
    required this.danger,
    required this.success,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.cameraFg,
    required this.cameraGlass,
    required this.cameraGlassStrong,
    required this.cameraStroke,
    required this.cameraGuide,
  });

  static const FLColors light = FLColors(
    bgCanvas: Color(0xFFF4EFE8),
    bgSurface: Color(0xFFFAF8F5),
    bgElevated: Color(0xFFFFFFFF),
    bgMuted: Color(0xFFEBE5DC),
    bgInset: Color(0xFFE2DBD0),
    bgScrim: Color(0x6B1A1816),
    glassFill: Color(0xB8FFFDFA),
    glassStroke: Color(0x8CFFFFFF),
    textPrimary: Color(0xFF1A1816),
    textSecondary: Color(0xFF5C5650),
    textMuted: Color(0xFF8A8278),
    textDisabled: Color(0xFFB5AEA4),
    textOnAccent: Color(0xFFFFFFFF),
    textOnBlack: Color(0xFFFAF8F5),
    accentBrand: Color(0xFFC2614A),
    accentBrandHi: Color(0xFFD67459),
    accentBrandLo: Color(0xFFA2503D),
    accentBrandFill: Color(0x1FC2614A),
    danger: Color(0xFFB0432E),
    success: Color(0xFF5C7A4A),
    borderSubtle: Color(0x0F1A1816),
    borderDefault: Color(0x1A1A1816),
    borderStrong: Color(0x2E1A1816),
    cameraFg: Color(0xFFFAF8F5),
    cameraGlass: Color(0x8C141210),
    cameraGlassStrong: Color(0xC7141210),
    cameraStroke: Color(0x29FFFFFF),
    cameraGuide: Color(0xD9FFFFFF),
  );

  static const FLColors dark = FLColors(
    bgCanvas: Color(0xFF0F0E0D),
    bgSurface: Color(0xFF16140F),
    bgElevated: Color(0xFF201D17),
    bgMuted: Color(0xFF2A2620),
    bgInset: Color(0xFF35302A),
    bgScrim: Color(0x8C000000),
    glassFill: Color(0x8C282420),
    glassStroke: Color(0x14FFFFFF),
    textPrimary: Color(0xFFF4EFE8),
    textSecondary: Color(0xFFB6AEA3),
    textMuted: Color(0xFF7E7770),
    textDisabled: Color(0xFF4D4842),
    textOnAccent: Color(0xFF1A1816),
    textOnBlack: Color(0xFFFAF8F5),
    accentBrand: Color(0xFFD67459),
    accentBrandHi: Color(0xFFE68C6E),
    accentBrandLo: Color(0xFFB25940),
    accentBrandFill: Color(0x26D67459),
    danger: Color(0xFFE07A66),
    success: Color(0xFFA4C087),
    borderSubtle: Color(0x0DFFFFFF),
    borderDefault: Color(0x17FFFFFF),
    borderStrong: Color(0x29FFFFFF),
    cameraFg: Color(0xFFFAF8F5),
    cameraGlass: Color(0x8C141210),
    cameraGlassStrong: Color(0xC7141210),
    cameraStroke: Color(0x29FFFFFF),
    cameraGuide: Color(0xD9FFFFFF),
  );
}

// ─── Typography ──────────────────────────────────────────────────────────────

class FLFonts {
  static const String sans = 'Pretendard';
  static const String mono = 'JetBrainsMono';
}

class FLType {
  static const TextStyle displayLg = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.08,
    letterSpacing: -0.72,
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.56,
  );
  static const TextStyle titleLg = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.20,
    letterSpacing: -0.33,
  );
  static const TextStyle titleMd = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.18,
  );
  static const TextStyle titleSm = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: -0.08,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.40,
  );
  static const TextStyle label = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: 0.24,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: FLFonts.sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.30,
    letterSpacing: 0.22,
  );
  static const TextStyle monoMd = TextStyle(
    fontFamily: FLFonts.mono,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.30,
  );
  static const TextStyle monoSm = TextStyle(
    fontFamily: FLFonts.mono,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.30,
  );
}

// ─── Spacing ─────────────────────────────────────────────────────────────────

class FLSpace {
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 40;
  static const double s9 = 48;
  static const double s10 = 64;
}

// ─── Radii ───────────────────────────────────────────────────────────────────

class FLRadii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;
}

// ─── Shadows ─────────────────────────────────────────────────────────────────

class FLShadows {
  static const List<BoxShadow> lightSm = [
    BoxShadow(color: Color(0x0F1A1816), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0A1A1816), offset: Offset(0, 1), blurRadius: 1),
  ];
  static const List<BoxShadow> lightMd = [
    BoxShadow(color: Color(0x141A1816), offset: Offset(0, 4), blurRadius: 12),
    BoxShadow(color: Color(0x0D1A1816), offset: Offset(0, 1), blurRadius: 3),
  ];
  static const List<BoxShadow> lightLg = [
    BoxShadow(
      color: Color(0x291A1816),
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: -8,
    ),
    BoxShadow(color: Color(0x0F1A1816), offset: Offset(0, 4), blurRadius: 8),
  ];
  static const List<BoxShadow> darkSm = [
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  static const List<BoxShadow> darkMd = [
    BoxShadow(color: Color(0x73000000), offset: Offset(0, 4), blurRadius: 14),
  ];
  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: Color(0x8C000000),
      offset: Offset(0, 18),
      blurRadius: 40,
      spreadRadius: -8,
    ),
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 10),
  ];
}

// ─── Blur ────────────────────────────────────────────────────────────────────

class FLBlur {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 28;
}
