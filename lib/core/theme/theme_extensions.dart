import 'package:flutter/material.dart';
import 'app_colors.dart';

// Custom theme extension for additional app-specific styling
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color cardBackground;
  final Color photoCardBorder;
  final Color eventCardBackground;
  final List<Color> featuredGradient;
  final EdgeInsets defaultPadding;
  final BorderRadius defaultBorderRadius;
  
  // Additional dark mode specific colors
  final Color? statusBarColor;
  final Color? buttonShadowColor;
  final Color? activeIconColor;
  final Color? inactiveIconColor;

  CustomThemeExtension({
    required this.cardBackground,
    required this.photoCardBorder,
    required this.eventCardBackground,
    required this.featuredGradient,
    required this.defaultPadding,
    required this.defaultBorderRadius,
    this.statusBarColor,
    this.buttonShadowColor,
    this.activeIconColor,
    this.inactiveIconColor,
  });

  // Light theme extension
  static final light = CustomThemeExtension(
    cardBackground: Colors.white,
    photoCardBorder: const Color(0xFFE0E0E0),
    eventCardBackground: const Color(0xFFF5F5F5),
    featuredGradient: AppColors.primaryGradient,
    defaultPadding: const EdgeInsets.all(16.0),
    defaultBorderRadius: BorderRadius.circular(16.0),
    statusBarColor: Colors.transparent,
    buttonShadowColor: Colors.black.withOpacity(0.1),
    activeIconColor: AppColors.brandPrimary,
    inactiveIconColor: Colors.grey.shade600,
  );

  // Dark theme extension
  static final dark = CustomThemeExtension(
    cardBackground: AppColors.darkCardBackground,
    photoCardBorder: const Color(0xFF3D3D3D),
    eventCardBackground: AppColors.darkElevatedSurface,
    featuredGradient: AppColors.darkPrimaryGradient,
    defaultPadding: const EdgeInsets.all(16.0),
    defaultBorderRadius: BorderRadius.circular(16.0),
    statusBarColor: Colors.black26,
    buttonShadowColor: Colors.black.withOpacity(0.3),
    activeIconColor: AppColors.darkColorScheme.primary,
    inactiveIconColor: Colors.grey.shade400,
  );

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? cardBackground,
    Color? photoCardBorder,
    Color? eventCardBackground,
    List<Color>? featuredGradient,
    EdgeInsets? defaultPadding,
    BorderRadius? defaultBorderRadius,
    Color? statusBarColor,
    Color? buttonShadowColor,
    Color? activeIconColor,
    Color? inactiveIconColor,
  }) {
    return CustomThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      photoCardBorder: photoCardBorder ?? this.photoCardBorder,
      eventCardBackground: eventCardBackground ?? this.eventCardBackground,
      featuredGradient: featuredGradient ?? this.featuredGradient,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      defaultBorderRadius: defaultBorderRadius ?? this.defaultBorderRadius,
      statusBarColor: statusBarColor ?? this.statusBarColor,
      buttonShadowColor: buttonShadowColor ?? this.buttonShadowColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) {
      return this;
    }

    return CustomThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      photoCardBorder: Color.lerp(photoCardBorder, other.photoCardBorder, t)!,
      eventCardBackground:
          Color.lerp(eventCardBackground, other.eventCardBackground, t)!,
      featuredGradient: [
        Color.lerp(featuredGradient[0], other.featuredGradient[0], t)!,
        Color.lerp(featuredGradient[1], other.featuredGradient[1], t)!,
      ],
      defaultPadding: EdgeInsets.lerp(defaultPadding, other.defaultPadding, t)!,
      defaultBorderRadius:
          BorderRadius.lerp(defaultBorderRadius, other.defaultBorderRadius, t)!,
      statusBarColor: Color.lerp(statusBarColor, other.statusBarColor, t),
      buttonShadowColor: Color.lerp(buttonShadowColor, other.buttonShadowColor, t),
      activeIconColor: Color.lerp(activeIconColor, other.activeIconColor, t),
      inactiveIconColor: Color.lerp(inactiveIconColor, other.inactiveIconColor, t),
    );
  }
}