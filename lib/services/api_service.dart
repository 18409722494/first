import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';

/// API服务类
/// 封装所有与后端API的交互逻辑
/// 包括认证接口和通用HTTP请求方法
class ApiService {
  /// API基础URL
  /// 使用提供的API地址
  static const String baseUrl = 'http://8.137.145.195:3338';
  
  /// 用户登录接口
  /// [username] 用户名
  /// [password] 密码
  /// 返回AuthResponse对象，包含登录结果和用户信息
  /// Future<AuthResponse>：异步方法，返回AuthResponse对象
  static Future<AuthResponse> login(String username, String password) async {
    try {
      // 打印调试信息
      print('登录请求开始: $username');
      print('API地址: $baseUrl/auth/login');
      
      // 发送HTTP POST请求
      // Uri.parse：将字符串转换为URI对象
      // headers：设置请求头，Content-Type表示请求体格式
      // body：请求体数据，使用jsonEncode转换为JSON字符串
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

      // 打印响应信息
      print('登录请求完成，状态码: ${response.statusCode}');
      print('响应体: ${response.body}');
      
      try {
        // 解析JSON响应体
        final data = jsonDecode(response.body);
        
        // 检查HTTP状态码
        if (response.statusCode == 200) {
          print('登录成功');
          // 使用fromJson工厂方法创建AuthResponse对象
          return AuthResponse.fromJson(data);
        } else {
          print('登录失败: ${data['message'] ?? '未知错误'}');
          // 创建失败的AuthResponse对象
          return AuthResponse(
            success: false,
            message: data['message'] ?? '登录失败，请检查用户名和密码',
          );
        }
      } catch (jsonError) {
        // 处理JSON解析错误
        print('JSON解析错误: $jsonError');
        // 处理非JSON响应
        final responseBody = response.body.trim();
        if (responseBody == '登录成功') {
          print('登录成功（非JSON响应）');
          // 创建成功的AuthResponse对象
          return AuthResponse(
            success: true,
            message: '登录成功',
            token: 'token_${DateTime.now().millisecondsSinceEpoch}',
          );
        } else {
          print('登录失败（非JSON响应）: $responseBody');
          // 创建失败的AuthResponse对象
          return AuthResponse(
            success: false,
            message: responseBody,
          );
        }
      }
    } catch (e) {
      // 处理网络错误
      print('网络错误: $e');
      return AuthResponse(
        success: false,
        message: '网络错误: ${e.toString()}',
      );
    }
  }

  /// 用户注册接口
  /// [username] 用户名
  /// [password] 密码
  /// 返回AuthResponse对象，包含注册结果和用户信息
  static Future<AuthResponse> register(
    String username,
    String password,
  ) async {
    try {
      print('注册请求开始: $username');
      print('API地址: $baseUrl/auth/register');
      
      // 发送HTTP POST请求
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('注册请求完成，状态码: ${response.statusCode}');
      print('响应体: ${response.body}');
      
      try {
        // 解析JSON响应体
        final data = jsonDecode(response.body);
        
        // 检查HTTP状态码
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('注册成功');
          return AuthResponse.fromJson(data);
        } else {
          print('注册失败: ${data['message'] ?? '未知错误'}');
          return AuthResponse(
            success: false,
            message: data['message'] ?? '注册失败，请重试',
          );
        }
      } catch (jsonError) {
        // 处理JSON解析错误
        print('JSON解析错误: $jsonError');
        // 处理非JSON响应
        final responseBody = response.body.trim();
        if (responseBody == '注册成功') {
          print('注册成功（非JSON响应）');
          return AuthResponse(
            success: true,
            message: '注册成功',
            token: 'token_${DateTime.now().millisecondsSinceEpoch}',
          );
        } else {
          print('注册失败（非JSON响应）: $responseBody');
          return AuthResponse(
            success: false,
            message: responseBody,
          );
        }
      }
    } catch (e) {
      // 处理网络错误
      print('网络错误: $e');
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
    // 设置请求头
    // Authorization: Bearer token 是标准的认证头格式
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 根据HTTP方法执行不同的请求
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
        // 抛出异常，处理不支持的HTTP方法
        throw Exception('不支持的HTTP方法: $method');
    }
  }
}
