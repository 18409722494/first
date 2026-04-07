import 'package:flutter/material.dart';
import '../services/settings_service.dart';

/// 设置状态管理（主题 / 语言 / 通知），供 MaterialApp 消费
///
/// 所有字段均在构造时同步初始化，避免首次 build 用默认值闪烁。
/// Hive.get 为同步操作，init() 已在 main.dart 中先执行。
class SettingsProvider extends ChangeNotifier {
  late ThemeMode _themeMode;
  late Locale _locale;
  late bool _notifyLuggageStatus;
  late bool _notifySystem;
  late bool _notifyAbnormal;

  SettingsProvider() {
    _themeMode = SettingsService.getThemeMode();
    _locale = SettingsService.getLocale();
    _notifyLuggageStatus = SettingsService.getNotifyLuggageStatus();
    _notifySystem = SettingsService.getNotifySystem();
    _notifyAbnormal = SettingsService.getNotifyAbnormal();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get notifyLuggageStatus => _notifyLuggageStatus;
  bool get notifySystem => _notifySystem;
  bool get notifyAbnormal => _notifyAbnormal;

  /// 供手动刷新使用（一般不需要调用）
  Future<void> load() async {
    _themeMode = SettingsService.getThemeMode();
    _locale = SettingsService.getLocale();
    _notifyLuggageStatus = SettingsService.getNotifyLuggageStatus();
    _notifySystem = SettingsService.getNotifySystem();
    _notifyAbnormal = SettingsService.getNotifyAbnormal();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await SettingsService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await SettingsService.setLocale(locale);
    notifyListeners();
  }

  Future<void> setNotifyLuggageStatus(bool value) async {
    _notifyLuggageStatus = value;
    await SettingsService.setNotifyLuggageStatus(value);
    notifyListeners();
  }

  Future<void> setNotifySystem(bool value) async {
    _notifySystem = value;
    await SettingsService.setNotifySystem(value);
    notifyListeners();
  }

  Future<void> setNotifyAbnormal(bool value) async {
    _notifyAbnormal = value;
    await SettingsService.setNotifyAbnormal(value);
    notifyListeners();
  }
}