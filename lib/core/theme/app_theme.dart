import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFFF6D00);

  // Dark Theme: Warm dark charcoal (NOT pure black)
  static const Color darkBackground = Color(0xFF1E1A18);

  // Light Theme: Warm cream (NOT pure white)
  static const Color lightBackground = Color(0xFFF9F6F0);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        surface: lightBackground,
        onSurface: Colors.black,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        surface: darkBackground,
        onSurface: Colors.white,
      ),
    );
  }
}
