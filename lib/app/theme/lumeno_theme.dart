import 'package:flutter/material.dart';

class LumenoColors {
  static const backgroundLight = Color(0xFFFAFAF8);
  static const surfaceLight = Color(0xFFFFFFFF);

  static const backgroundDark = Color(0xFF111315);
  static const surfaceDark = Color(0xFF1B2024);

  static const textPrimary = Color(0xFF171A1F);

  static const brand = Color(0xFF1FA89A);
  static const brandDark = Color(0xFF55D6C2);
}


class LumenoTheme {
  static ThemeData get light {

    return ThemeData(
      brightness: Brightness.light,

      scaffoldBackgroundColor:
      LumenoColors.backgroundLight,

      colorScheme: ColorScheme.fromSeed(
        seedColor: LumenoColors.brand,
        brightness: Brightness.light,
      ),

      useMaterial3: true,
    );
  }


  static ThemeData get dark {

    return ThemeData(
      brightness: Brightness.dark,

      scaffoldBackgroundColor:
      LumenoColors.backgroundDark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: LumenoColors.brandDark,
        brightness: Brightness.dark,
      ),

      useMaterial3: true,
    );
  }
}