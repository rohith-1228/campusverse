import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/providers/theme_provider.dart';
import 'package:campusverse/services/local_storage_service.dart';

void main() {
  group('Theme Provider State & Toggle', () {
    late LocalStorageService storageService;
    late ThemeProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = LocalStorageService(prefs);
      provider = ThemeProvider(storageService);
    });

    test('should default to dark theme mode for premium glassmorphism', () {
      expect(provider.isDarkMode, true);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should toggle theme and update themeMode', () async {
      await provider.toggleTheme();
      expect(provider.isDarkMode, false);
      expect(provider.themeMode, ThemeMode.light);

      await provider.toggleTheme();
      expect(provider.isDarkMode, true);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should persist theme mode to storage', () async {
      await provider.setDarkMode(false);

      final reloaded = ThemeProvider(storageService);
      expect(reloaded.isDarkMode, false);
      expect(reloaded.themeMode, ThemeMode.light);
    });
  });
}
