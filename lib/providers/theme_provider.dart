import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  bool _isDarkMode = true;

  ThemeProvider(this._storageService) {
    final savedMode = _storageService.getThemeIsDark();
    // Default to premium dark glassmorphism
    _isDarkMode = savedMode ?? true;
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.saveThemeIsDark(_isDarkMode);
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    await _storageService.saveThemeIsDark(_isDarkMode);
  }
}
