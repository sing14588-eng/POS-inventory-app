import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Vibrant Palette
  static const Color primaryColor = Color(0xFF6C63FF); // Modern Violet
  static const Color secondaryColor = Color(0xFF00BFA6); // Vibrant Teal
  static const Color accentColor = Color(0xFFFF6584); // Soft Red/Pink
  static const Color darkSurface = Color(0xFF1E1E2C); // Dark Blue-Grey
  static const Color lightSurface = Color(0xFFF4F6F8); // Cool Grey

  static TextTheme _buildTextTheme(ThemeData base) {
    return base.textTheme.copyWith(
      displayLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      displayMedium: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      titleLarge:
          GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightSurface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        error: accentColor,
      ),
      textTheme: _buildTextTheme(base),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212), // Deep Black
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        secondary: secondaryColor,
        surface: darkSurface,
        error: accentColor,
      ),
      textTheme: _buildTextTheme(base).apply(
        bodyColor: Colors.white.withValues(alpha: 0.87),
        displayColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        color: darkSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }

  static ThemeData getBrandedTheme(Color brandColor, Brightness brightness) {
    final baseTheme = brightness == Brightness.light ? lightTheme : darkTheme;
    return baseTheme.copyWith(
      primaryColor: brandColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: brandColor,
        secondary: secondaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseTheme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.all(brandColor),
        ),
      ),
    );
  }

  static Color hexToColor(String hexString) {
    if (hexString.isEmpty) return primaryColor;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
