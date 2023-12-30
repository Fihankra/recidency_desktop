import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../theme/theme.dart';

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeData>((ref) {
  var box = Hive.box('myBox');
  var isDarkMode = box.get('isDarkMode', defaultValue: false);
  return ThemeProvider(isDarkMode);
});

class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider(this.isDarkMode) : super(isDarkMode ? darkMode : lightMode);
  final bool isDarkMode ;

  void toggleTheme() {
    state = state == darkMode ? lightMode : darkMode;
    var box = Hive.box('myBox');
    box.put('isDarkMode', state == darkMode);
  }
}