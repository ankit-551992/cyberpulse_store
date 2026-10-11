import 'package:flutter/material.dart';

class CyberColors {
  // Brand Gradients & Accents
  static const Color cyanPrimary = Color(0xFF00F2FE);
  static const Color blueElectric = Color(0xFF4FACFE);
  static const Color purpleNeon = Color(0xFF8B5CF6);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color pinkAccent = Color(0xFFFF2E93);
  
  // Status Colors
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color roseDanger = Color(0xFFEF4444);
  static const Color skyInfo = Color(0xFF0EA5E9);

  // Dark Palette (Default Cyberpunk / Futuristic)
  static const Color darkBg = Color(0xFF0A0E17);
  static const Color darkSurface = Color(0xFF121826);
  static const Color darkSurfaceLight = Color(0xFF1A2338);
  static const Color darkBorder = Color(0xFF23304B);
  static const Color darkBorderGlow = Color(0xFF00F2FE);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Palette
  static const Color lightBg = Color(0xFFF4F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEDF2F7);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyanPrimary, blueElectric],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonPurpleGradient = LinearGradient(
    colors: [purpleNeon, pinkAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x3300F2FE), Color(0x118B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF161F33), Color(0xFF101726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
