import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/auth_response.dart';

/// API服务
class ApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 15);

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
        final token = data['token']?.toString();
        if (token == null || token.isEmpty) {
          throw Exception('Server error: Login successful but no token received');
        }
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
        final token = data['token']?.toString();
        if (token == null || token.isEmpty) {
          throw Exception('Server error: Register successful but no token received');
        }
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
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

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
