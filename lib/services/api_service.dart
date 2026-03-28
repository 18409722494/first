import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/auth_response.dart';

/// API服务
class ApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 15);

  /// 从登录/注册响应 JSON 中解析 token（兼容多种后端字段名与嵌套结构）
  static String? _extractAuthToken(dynamic decoded) {
    if (decoded is! Map) return null;
    final root = Map<String, dynamic>.from(decoded);

    String? fromMap(Map<String, dynamic> map) {
      const keys = [
        'token',
        'accessToken',
        'access_token',
        'jwt',
        'id_token',
        'bearer',
      ];
      for (final k in keys) {
        final v = map[k];
        if (v is String && v.isNotEmpty) return v;
        if (v != null && v is! Map && v is! List && v.toString().isNotEmpty) {
          return v.toString();
        }
      }
      return null;
    }

    final direct = fromMap(root);
    if (direct != null) return direct;

    final data = root['data'];
    if (data is Map) {
      final t = fromMap(Map<String, dynamic>.from(data));
      if (t != null) return t;
    }

    final user = root['user'];
    if (user is Map) {
      final t = fromMap(Map<String, dynamic>.from(user));
      if (t != null) return t;
    }

    return null;
  }

  /// 登录
  static Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      final data = jsonDecode(response.body);
      final result = data['result']?.toString() ?? '';

      if (result == 'success') {
        // 后端约定成功可为 {"result":"success"}，无 token；若有则一并解析（兼容将来扩展）
        final token = _extractAuthToken(data);
        return AuthResponse(
          success: true,
          message: '登录成功',
          token: token,
        );
      } else if (result == 'username/passwordRequired') {
        return AuthResponse(
          success: false,
          message: '用户名或密码不能为空',
        );
      } else if (result == 'invalidCredentials') {
        return AuthResponse(
          success: false,
          message: '用户名或密码错误',
        );
      } else {
        return AuthResponse(
          success: false,
          message: '登录失败，请重试',
        );
      }
    } on TimeoutException {
      return AuthResponse(
        success: false,
        message: '请求超时，请检查网络连接',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: '网络错误: ${e.toString()}',
      );
    }
  }

  /// 注册
  static Future<AuthResponse> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      final data = jsonDecode(response.body);
      final result = data['result']?.toString() ?? '';

      if (result == 'success') {
        final token = _extractAuthToken(data);
        return AuthResponse(
          success: true,
          message: '注册成功',
          token: token,
        );
      } else if (result == 'username/passwordRequired') {
        return AuthResponse(
          success: false,
          message: '用户名或密码不能为空',
        );
      } else if (result == 'usernameExists') {
        return AuthResponse(
          success: false,
          message: '用户名已存在',
        );
      } else {
        return AuthResponse(
          success: false,
          message: '注册失败，请重试',
        );
      }
    } on TimeoutException {
      return AuthResponse(
        success: false,
        message: '请求超时，请检查网络连接',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: '网络错误: ${e.toString()}',
      );
    }
  }

  /// 带认证的请求
  static Future<http.Response> authenticatedRequest(
    String method,
    String endpoint,
    Map<String, dynamic>? body,
    String token,
  ) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http
              .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
              .timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));
        case 'POST':
          return await http
              .post(
                Uri.parse('$baseUrl$endpoint'),
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));
        case 'PUT':
          return await http
              .put(
                Uri.parse('$baseUrl$endpoint'),
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));
        case 'DELETE':
          return await http
              .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
              .timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));
        default:
          throw Exception('不支持的HTTP方法: $method');
      }
    } on TimeoutException {
      rethrow;
    }
  }
}
