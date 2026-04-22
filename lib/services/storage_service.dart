import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
/// 缓存 SharedPreferences 实例，避免每次操作都重新 getInstance
class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _employeeIdKey = 'employee_id';

  static SharedPreferences? _prefs;

  /// 初始化并缓存实例（main() 中调用）
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError('StorageService 未初始化，请先调用 init()');
    }
    return _prefs!;
  }

  static Future<void> saveToken(String token) async {
    await _p.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    return _p.getString(_tokenKey);
  }

  static Future<String?> getEmployeeId() async {
    return _p.getString(_employeeIdKey);
  }

  static Future<void> saveUserInfo({
    required String userId,
    required String username,
    required String email,
    String? employeeId,
  }) async {
    await _p.setString(_userIdKey, userId);
    await _p.setString(_usernameKey, username);
    await _p.setString(_emailKey, email);
    if (employeeId != null && employeeId.isNotEmpty) {
      await _p.setString(_employeeIdKey, employeeId);
    } else {
      await _p.remove(_employeeIdKey);
    }
  }

  /// 批量读取认证信息（AuthProvider.init() 专用，减少异步调用次数）
  static Future<Map<String, String?>> readAuthData() async {
    return {
      'token': _p.getString(_tokenKey),
      'userId': _p.getString(_userIdKey),
      'username': _p.getString(_usernameKey),
      'email': _p.getString(_emailKey),
      'employeeId': _p.getString(_employeeIdKey),
    };
  }

  static Future<void> clearToken() async {
    await _p.remove(_tokenKey);
  }

  static Future<void> clearAll() async {
    await _p.remove(_tokenKey);
    await _p.remove(_userIdKey);
    await _p.remove(_usernameKey);
    await _p.remove(_emailKey);
    await _p.remove(_employeeIdKey);
  }

  static Future<bool> isLoggedIn() async {
    final userId = _p.getString(_userIdKey);
    if (userId != null && userId.isNotEmpty) return true;
    final token = _p.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }
}
