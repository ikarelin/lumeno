import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const bodyLarge = TextStyle(fontSize: 16, height: 1.5);

  static const bodyMedium = TextStyle(fontSize: 14, height: 1.5);

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
