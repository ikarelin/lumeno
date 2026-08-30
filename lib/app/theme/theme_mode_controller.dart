import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) {
    state = mode;
  }

  void useSystem() {
    state = ThemeMode.system;
  }

  void toggleLightDark(Brightness effectiveBrightness) {
    final isDark =
        state == ThemeMode.dark ||
        (state == ThemeMode.system && effectiveBrightness == Brightness.dark);

    state = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}
