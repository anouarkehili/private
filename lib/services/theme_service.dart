import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  Future<void> loadTheme() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (savedTheme != null) {
        _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    } catch (e) {
      // استخدام الوضع المظلم كافتراضي في حالة الخطأ
      _themeMode = ThemeMode.dark;
    }
  }
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _storage.write(key: _themeKey, value: _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
  
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.write(key: _themeKey, value: mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}