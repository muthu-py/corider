import 'package:flutter/material.dart';

/// A simple controller to manage the app's theme mode.
/// It uses ValueNotifier to allow listeners to react to changes.
class ThemeController extends ValueNotifier<ThemeMode> {
  // Singleton instance for easy access if needed (though passing via InheritedWidget is cleaner)
  static final ThemeController _instance = ThemeController._internal();
  
  factory ThemeController() {
    return _instance;
  }

  ThemeController._internal() : super(ThemeMode.system);

  void toggleTheme() {
    if (value == ThemeMode.light) {
      value = ThemeMode.dark;
    } else if (value == ThemeMode.dark) {
      value = ThemeMode.light;
    } else {
      // If system, switch to the opposite of current platform brightness, or valid default
      // For simplicity in this requirement "Toggle must Switch theme instantly", we can cycle or flip.
      // Let's assume we toggle between Light and Dark explicitly once user interacts.
      // If currently system, we force a mode.
      // To determine "current", we need context, but here we just set to dark as default toggle from system?
      // Or better check SchedulerBinding, but sticking to explicit:
      value = ThemeMode.dark; 
    }
  }

  void setTheme(ThemeMode mode) {
    value = mode;
  }
}
