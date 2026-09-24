import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class KT {
  // ── Exact palette from flutter-task-planner-app ──
  static const Color kLightYellow  = Color(0xFFFFF9EC);
  static const Color kLightYellow2 = Color(0xFFFFE4C7);
  static const Color kDarkYellow   = Color(0xFFF9BE7C);
  static const Color kPalePink     = Color(0xFFFED4D6);
  static const Color kRed          = Color(0xFFE46472);
  static const Color kLavender     = Color(0xFFD5E4FE);
  static const Color kBlue         = Color(0xFF6488E4);
  static const Color kLightGreen   = Color(0xFFD9E6DC);
  static const Color kGreen        = Color(0xFF309397);
  static const Color kDarkBlue     = Color(0xFF0D253F);

  // Card fill → accent pairs (pastel + vivid)
  static const List<(Color, Color)> cardPairs = [
    (kPalePink,    kRed),
    (kLavender,    kBlue),
    (kLightGreen,  kGreen),
    (kLightYellow2, kDarkYellow),
  ];

  static (Color, Color) cardPairFor(String key) {
    final idx = key.hashCode.abs() % cardPairs.length;
    return cardPairs[idx];
  }

  // Tiny rotation for cards (-0.02 to +0.02 rad)
  static double rotationFor(String id) {
    final b = id.hashCode.abs() % 5;
    return (b - 2) * 0.01;
  }

  static TextStyle poppins({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = kDarkBlue,
    double? letterSpacing,
    FontStyle style = FontStyle.normal,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontStyle: style,
      );

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kLightYellow,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kGreen,
        brightness: Brightness.light,
        surface: kLightYellow,
        onSurface: kDarkBlue,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: kDarkBlue,
        displayColor: kDarkBlue,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: kDarkBlue,
        foregroundColor: kLightYellow,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: kLightYellow,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: kLightYellow),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kRed),
        ),
        labelStyle: GoogleFonts.poppins(color: kDarkBlue, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.poppins(color: Colors.black38, fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkBlue,
          foregroundColor: kLightYellow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kDarkBlue,
          side: const BorderSide(color: kDarkBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: GoogleFonts.poppins(color: kDarkBlue, fontWeight: FontWeight.w500),
      ),
    );
  }
}
