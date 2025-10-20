import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _key = 'theme_mode';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    try {
      final v = await _storage.read(key: _key);
      switch (v) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        default:
          _mode = ThemeMode.system;
      }
    } catch (_) {
      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode m) async {
    if (_mode == m) return;
    _mode = m;
    try {
      final v = switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      // Persist preference (ignore result)
      _storage.write(key: _key, value: v);
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }
}
