import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
/// 使用SharedPreferences进行数据的持久化存储
/// SharedPreferences：Flutter官方推荐的轻量级本地存储方案
/// 适合存储小量数据，如用户认证信息、设置等
class StorageService {
  // 存储键名常量
  // 使用const定义常量，避免拼写错误和重复定义
  static const String _tokenKey = 'auth_token';     // 认证令牌的存储键
  static const String _userIdKey = 'user_id';       // 用户ID的存储键
  static const String _usernameKey = 'username';     // 用户名的存储键
  static const String _emailKey = 'email';           // 邮箱的存储键

  /// 保存认证令牌
  /// [token] 要保存的认证令牌
  /// Future<void>：异步方法，不返回值
  static Future<void> saveToken(String token) async {
    // 获取SharedPreferences实例
    // await：等待异步操作完成
    final prefs = await SharedPreferences.getInstance();
    // 存储字符串类型的数据
    await prefs.setString(_tokenKey, token);
  }

  /// 获取保存的认证令牌
  /// 返回保存的token，如果不存在则返回null
  /// Future<String?>：异步方法，返回String或null
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // 获取字符串，如果不存在返回null
    return prefs.getString(_tokenKey);
  }

  /// 保存用户信息
  /// [userId] 用户ID
  /// [username] 用户名
  /// [email] 用户邮箱
  /// 使用命名参数（required表示必填参数）
  static Future<void> saveUserInfo({
    required String userId,
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // 分别存储用户信息的各个字段
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey, email);
  }

  /// 获取保存的用户信息
  /// 返回包含userId、username、email的Map
  /// Map<String, String?>：键为String，值为String或null
  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    // 构建并返回用户信息Map
    return {
      'userId': prefs.getString(_userIdKey),
      'username': prefs.getString(_usernameKey),
      'email': prefs.getString(_emailKey),
    };
  }

  /// 清除本地保存的 token（无 JWT 的会话模式会用到）
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// 清除所有存储的数据
  /// 在用户登出时调用，清除所有本地保存的认证和用户信息
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // 逐个移除存储的数据
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
  }

  /// 检查用户是否已登录
  /// 有 JWT 时用 token；后端仅返回 `{"result":"success"}` 时无 token，以已保存的 userId 为准
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    if (userId != null && userId.isNotEmpty) return true;
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }
}
