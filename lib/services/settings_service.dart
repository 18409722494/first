import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 设置服务：主题、语言、通知等偏好的持久化
class SettingsService {
  static const String _boxName = 'settings';
  static const String _themeModeKey = 'theme_mode'; // 'light'|'dark'|'system'
  static const String _localeKey = 'locale';         // 'zh_CN'|'en_US'
  static const String _notifyLuggageStatusKey = 'notify_luggage_status';
  static const String _notifySystemKey = 'notify_system';
  static const String _notifyAbnormalKey = 'notify_abnormal';

  static late Box _box;

  /// 初始化
  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // ==================== 主题 ====================

  static ThemeMode getThemeMode() {
    final value = _box.get(_themeModeKey, defaultValue: 'system') as String;
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    if (mode == ThemeMode.light) {
      value = 'light';
    } else if (mode == ThemeMode.dark) {
      value = 'dark';
    } else {
      value = 'system';
    }
    await _box.put(_themeModeKey, value);
  }

  static String getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  // ==================== 语言 ====================

  static Locale getLocale() {
    final value = _box.get(_localeKey, defaultValue: 'zh_CN') as String;
    switch (value) {
      case 'zh_CN':
        return const Locale('zh', 'CN');
      case 'en_US':
        return const Locale('en', 'US');
      default:
        return const Locale('zh', 'CN');
    }
  }

  static Future<void> setLocale(Locale locale) async {
    final value = '${locale.languageCode}_${locale.countryCode ?? ''}';
    await _box.put(_localeKey, value);
  }

  static String getLocaleLabel(String localeCode) {
    switch (localeCode) {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      default:
        return '简体中文';
    }
  }

  static List<Map<String, dynamic>> getSupportedLocales() {
    return [
      {'code': 'zh_CN', 'label': '简体中文', 'locale': const Locale('zh', 'CN')},
      {'code': 'en_US', 'label': 'English', 'locale': const Locale('en', 'US')},
    ];
  }

  // ==================== 通知 ====================

  static bool getNotifyLuggageStatus() =>
      _box.get(_notifyLuggageStatusKey, defaultValue: true) as bool;

  static Future<void> setNotifyLuggageStatus(bool value) async {
    await _box.put(_notifyLuggageStatusKey, value);
  }

  static bool getNotifySystem() =>
      _box.get(_notifySystemKey, defaultValue: true) as bool;

  static Future<void> setNotifySystem(bool value) async {
    await _box.put(_notifySystemKey, value);
  }

  static bool getNotifyAbnormal() =>
      _box.get(_notifyAbnormalKey, defaultValue: true) as bool;

  static Future<void> setNotifyAbnormal(bool value) async {
    await _box.put(_notifyAbnormalKey, value);
  }
}