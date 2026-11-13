import 'package:flutter/material.dart';

class AppTheme {
  // Design Tokens from Spec
  static const Color bg = Color(0xFF0B0B10);
  static const Color surface1 = Color(0xFF14141C);
  static const Color surface2 = Color(0xFF1D1D28);
  static const Color outline = Color(0xFF2A2A38);
  static const Color textHigh = Color(0xFFF4F4F8);
  static const Color textMedium = Color(0xFFA5A5B8);
  static const Color danger = Color(0xFFFF5C7A);
  static const Color success = Color(0xFF3DDC97);
  static const Color warning = Color(0xFFFFB547);

  // Dynamic Primary Accent Color & Gradient
  static Color primary = const Color(0xFF7C5CFF);
  static Color primaryEnd = const Color(0xFF5B3FE0);

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF7C5CFF), Color(0xFF5B3FE0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static void setPrimaryColor(Color color) {
    primary = color;
    final hsl = HSLColor.fromColor(color);
    primaryEnd = hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .withHue((hsl.hue + 8) % 360)
        .toColor();
    primaryGradient = LinearGradient(
      colors: [primary, primaryEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static ThemeData getDarkTheme(Color primaryColor) {
    setPrimaryColor(primaryColor);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primaryEnd,
        error: danger,
        surface: surface1,
        onSurface: textHigh,
        surfaceContainerHighest: surface2,
        outline: outline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textHigh,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textHigh,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outline, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: textMedium),
        labelStyle: const TextStyle(color: textMedium),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface1,
        elevation: 0,
        height: 64,
        indicatorColor: primary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary);
          }
          return const IconThemeData(color: textMedium);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textHigh,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textMedium,
          );
        }),
      ),
    );
  }

  static ThemeData getLightTheme(Color primaryColor) {
    setPrimaryColor(primaryColor);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F6FA),
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryEnd,
        error: danger,
        surface: Colors.white,
        onSurface: const Color(0xFF14141C),
        surfaceContainerHighest: const Color(0xFFECECF4),
        outline: const Color(0xFFDEDEEA),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F6FA),
        foregroundColor: Color(0xFF14141C),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF14141C),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E5F0), width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 64,
        indicatorColor: primary.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary);
          }
          return const IconThemeData(color: Color(0xFF7E7E94));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7E7E94),
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme => getDarkTheme(primary);
  static ThemeData get lightTheme => getLightTheme(primary);
}
