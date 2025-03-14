import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'theme_extensions.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  // Constructor to initialize theme
  ThemeProvider() {
    loadThemePreference();
  }
  
  // Custom light theme
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.lightColorScheme,
      brightness: Brightness.light,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.lightColorScheme.primary,
        unselectedItemColor: AppColors.lightColorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.lightColorScheme.primary,
        unselectedLabelColor: AppColors.lightColorScheme.onSurfaceVariant,
        indicatorColor: AppColors.lightColorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.lightColorScheme.primary,
          foregroundColor: AppColors.lightColorScheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: AppColors.lightColorScheme.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          foregroundColor: AppColors.lightColorScheme.primary,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightColorScheme.onSurface,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightColorScheme.surfaceVariant,
        labelStyle: TextStyle(color: AppColors.lightColorScheme.onSurfaceVariant),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      extensions: [
        CustomThemeExtension.light,
      ],
    );
  }
  
  // Custom dark theme
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.darkColorScheme,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: CustomThemeExtension.dark.statusBarColor,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.darkColorScheme.primary,
        unselectedItemColor: AppColors.darkColorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        backgroundColor: AppColors.darkCardBackground,
      ),
      scaffoldBackgroundColor: AppColors.darkColorScheme.background,
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.darkCardBackground,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.darkColorScheme.primary,
        unselectedLabelColor: AppColors.darkColorScheme.onSurfaceVariant,
        indicatorColor: AppColors.darkColorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.darkColorScheme.primary,
          foregroundColor: AppColors.darkColorScheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: AppColors.darkColorScheme.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          foregroundColor: AppColors.darkColorScheme.primary,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkColorScheme.onSurface,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkColorScheme.surfaceVariant,
        labelStyle: TextStyle(color: AppColors.darkColorScheme.onSurfaceVariant),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      extensions: [
        CustomThemeExtension.dark,
      ],
    );
  }
  
  // Toggle theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }
  
  // Load theme preference
  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Default to light mode if there's an error
      _themeMode = ThemeMode.light;
    }
  }
  
  // Save theme preference
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    } catch (e) {
      // Silently fail if we can't save preferences
    }
  }
}