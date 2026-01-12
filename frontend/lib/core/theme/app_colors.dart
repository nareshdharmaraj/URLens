import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Vibrant Light Palette
  static const Color primary = Color(0xFF6C63FF); // Vibrant Purple
  static const Color secondary = Color(0xFF00BFA6); // Teal
  static const Color accent = Color(0xFFFF6584); // Pinkish Red
  
  // Light Backgrounds
  static const Color background = Color(0xFFF0F2F5); // Soft Light Cloud Blue/Grey
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  
  // Glassy Effects
  static const Color glassySurface = Color(0xCCFFFFFF); // Semi-transparent White (80%)
  static const Color glassyBorder = Color(0x33FFFFFF); // White Border (20%)
  
  static const Color textPrimary = Color(0xFF2D3436); // Dark Slate Grey
  static const Color textSecondary = Color(0xFF636E72); // Slate Grey
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFFF4C29);
  static const Color success = Color(0xFF00C897);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // Platform Colors
  static const Color youtube = Color(0xFFFF0000);
  static const Color instagram = Color(0xFFE1306C);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color facebook = Color(0xFF1877F2);
  static const Color tiktok = Color(0xFF000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF4834D4),
  ]; 
  
  static const List<Color> backgroundGradient = [
    Color(0xFFF0F2F5), 
    Color(0xFFE6E9F0)
  ];
}
