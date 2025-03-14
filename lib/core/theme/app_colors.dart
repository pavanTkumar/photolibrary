import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();
  
  // Light theme color scheme - improved contrast and vibrancy
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF21005E),
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1E192B),
    tertiary: Color(0xFF7E5260),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD9E3),
    onTertiaryContainer: Color(0xFF31101D),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    background: Color(0xFFFFFBFF),
    onBackground: Color(0xFF1C1B1F),
    surface: Color(0xFFFFFBFF),
    onSurface: Color(0xFF1C1B1F),
    outline: Color(0xFF79747E),
    surfaceVariant: Color(0xFFE7E0EB),
    onSurfaceVariant: Color(0xFF49454E),
  );
  
  // Dark theme color scheme - Enhanced for better dark mode visibility
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF371E73),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFEADDFF),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF8),
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
    tertiaryContainer: Color(0xFF633B48),
    onTertiaryContainer: Color(0xFFFFD9E3),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    background: Color(0xFF1C1B1F),
    onBackground: Color(0xFFE6E1E5),
    surface: Color(0xFF1C1B1F),
    onSurface: Color(0xFFE6E1E5),
    outline: Color(0xFF938F99),
    surfaceVariant: Color(0xFF49454E),
    onSurfaceVariant: Color(0xFFCAC4CF),
  );
  
  // Brand colors
  static const Color brandPrimary = Color(0xFF6750A4);
  static const Color brandSecondary = Color(0xFF625B71);
  static const Color brandAccent = Color(0xFF7E5260);
  
  // Additional colors for different components in dark mode
  static const Color darkCardBackground = Color(0xFF2D2D2D);
  static const Color darkElevatedSurface = Color(0xFF353535);
  
  // Gradient colors - Enhanced for more vibrant look in both modes
  static const List<Color> primaryGradient = [
    Color(0xFF9C27B0),
    Color(0xFF6750A4),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF7E5260),
    Color(0xFF625B71),
  ];
  
  // Dark mode gradients
  static const List<Color> darkPrimaryGradient = [
    Color(0xFFD0BCFF),
    Color(0xFF9C27B0),
  ];
  
  static const List<Color> darkSecondaryGradient = [
    Color(0xFFCCC2DC),
    Color(0xFF4A4458),
  ];
}