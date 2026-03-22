import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/auth_response.dart';

/// API服务
class ApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;

  /// 登录
  static Future<AuthResponse> login(String username, String password) async {
    try {
      print('登录请求: $username, API: $baseUrl/auth/login');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('登录响应: ${response.statusCode}, ${response.body}');

      try {
        final data = jsonDecode(response.body);
        final result = data['result']?.toString() ?? '';

        if (result == 'success') {
          return AuthResponse(
            success: true,
            message: '登录成功',
            token: 'token_${DateTime.now().millisecondsSinceEpoch}',
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
      } catch (jsonError) {
        print('JSON解析错误: $jsonError');
        final responseBody = response.body.trim();
        print('非JSON响应: $responseBody');
        return AuthResponse(
          success: false,
          message: '登录失败，请重试',
        );
      }
    } catch (e) {
      print('网络错误: $e');
      return AuthResponse(
        success: false,
        message: '网络错误: ${e.toString()}',
      );
    }
  }

  /// 注册
  static Future<AuthResponse> register(String username, String password) async {
    try {
      print('注册请求: $username, API: $baseUrl/auth/register');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('注册响应: ${response.statusCode}, ${response.body}');

      try {
        final data = jsonDecode(response.body);
        final result = data['result']?.toString() ?? '';

        if (result == 'success') {
          return AuthResponse(
            success: true,
            message: '注册成功',
            token: 'token_${DateTime.now().millisecondsSinceEpoch}',
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
      } catch (jsonError) {
        print('JSON解析错误: $jsonError');
        final responseBody = response.body.trim();
        print('非JSON响应: $responseBody');
        return AuthResponse(
          success: false,
          message: '注册失败，请重试',
        );
      }
    } catch (e) {
      print('网络错误: $e');
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

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
      case 'POST':
        return await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
        );
      default:
        throw Exception('不支持的HTTP方法: $method');
    }
  }
}
