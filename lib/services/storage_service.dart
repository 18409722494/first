import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
/// 使用SharedPreferences进行数据的持久化存储
/// 主要用于存储用户认证信息和用户基本信息
class StorageService {
  // 存储键名常量
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';

  /// 保存认证令牌
  /// [token] 要保存的认证令牌
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// 获取保存的认证令牌
  /// 返回保存的token，如果不存在则返回null
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// 保存用户信息
  /// [userId] 用户ID
  /// [username] 用户名
  /// [email] 用户邮箱
  static Future<void> saveUserInfo({
    required String userId,
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey, email);
  }

  /// 获取保存的用户信息
  /// 返回包含userId、username、email的Map
  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'username': prefs.getString(_usernameKey),
      'email': prefs.getString(_emailKey),
    };
  }

  /// 清除所有存储的数据
  /// 在用户登出时调用，清除所有本地保存的认证和用户信息
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
  }

  /// 检查用户是否已登录
  /// 通过检查是否存在有效的token来判断
  /// 返回true表示已登录，false表示未登录
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
