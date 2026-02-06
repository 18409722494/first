import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';

/// API服务类
/// 封装所有与后端API的交互逻辑
/// 包括认证接口和通用HTTP请求方法
class ApiService {
  /// API基础URL
  /// 请根据实际后端API地址修改此URL
  static const String baseUrl = 'https://your-api-domain.com/api';
  
  /// 用户登录接口
  /// [username] 用户名
  /// [password] 密码
  /// 返回AuthResponse对象，包含登录结果和用户信息
  static Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? '登录失败，请检查用户名和密码',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: '网络错误: ${e.toString()}',
      );
    }
  }

  /// 用户注册接口
  /// [username] 用户名
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回AuthResponse对象，包含注册结果和用户信息
  static Future<AuthResponse> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? '注册失败，请重试',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: '网络错误: ${e.toString()}',
      );
    }
  }

  /// 带认证令牌的HTTP请求
  /// 用于需要用户认证的API接口
  /// [method] HTTP方法（GET、POST、PUT、DELETE）
  /// [endpoint] API端点路径（不包含baseUrl）
  /// [body] 请求体数据（可选）
  /// [token] 认证令牌
  /// 返回HTTP响应对象
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
