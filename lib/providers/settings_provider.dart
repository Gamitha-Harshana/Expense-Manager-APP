import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';

class SettingsProvider extends ChangeNotifier {
  final _settingsBox = Hive.box(AppConstants.settingsBox);

  // Theme logic
  ThemeMode get themeMode {
    final mode = _settingsBox.get('themeMode', defaultValue: 'system');
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    
    await _settingsBox.put('themeMode', modeString);
    notifyListeners();
  }

  // Currency logic
  String get currencySymbol {
    return _settingsBox.get('currencySymbol', defaultValue: '\$');
  }

  Future<void> setCurrencySymbol(String symbol) async {
    await _settingsBox.put('currencySymbol', symbol);
    notifyListeners();
  }
}
