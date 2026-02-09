import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color accent = Color(0xFFEC4899);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double captureButtonSize = 80.0;
  static const double iconButtonSize = 48.0;
}

enum CameraMode {
  split,
  overlay,
}

enum LayoutType {
  grid2x2(2, 2, '2x2'),
  grid3x3(3, 3, '3x3'),
  grid3x2(3, 2, '3x2'),
  grid4x2(4, 2, '4x2');

  final int columns;
  final int rows;
  final String label;

  const LayoutType(this.columns, this.rows, this.label);

  int get totalCells => columns * rows;
}
