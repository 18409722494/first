import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/auth_response.dart';

/// 员工详细信息
class EmployeeDetails {
  final String? employeeId;
  final String? username;
  final String? gender;
  final String? hometown;
  final String? birthDate;
  final String? contact;
  final String? hireDate;
  final String? airport;
  final String? natureOfService;
  final String? status;

  EmployeeDetails({
    this.employeeId,
    this.username,
    this.gender,
    this.hometown,
    this.birthDate,
    this.contact,
    this.hireDate,
    this.airport,
    this.natureOfService,
    this.status,
  });

  factory EmployeeDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeDetails(
      employeeId: json['employeeId']?.toString(),
      username: json['username']?.toString(),
      gender: json['gender']?.toString(),
      hometown: json['hometown']?.toString(),
      birthDate: json['birthDate']?.toString(),
      contact: json['contact']?.toString(),
      hireDate: json['hireDate']?.toString(),
      airport: json['airport']?.toString(),
      natureOfService: json['NatureofService']?.toString() ?? json['natureOfService']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

/// API服务
class ApiService {
  static String get baseUrl => AppConstants.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 15);

  static String? _pickServerMessage(Map<String, dynamic> data) {
    for (final k in ['message', 'msg', 'error', 'detail']) {
      final v = data[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }
    return null;
  }

  static String _messageForNonOkResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final tip = _pickServerMessage(Map<String, dynamic>.from(decoded));
        if (tip != null) return tip;
      }
    } catch (_) {}
    return '请求失败（HTTP ${response.statusCode}）';
  }

  /// 登录（使用工号+用户名+密码）
  static Future<AuthResponse> login({
    required String username,
    required String password,
    required String employeeId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employee/login-with-employee-id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
          'employeeId': employeeId.trim(),
        }),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResponse(
          success: false,
          message: _messageForNonOkResponse(response),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return AuthResponse(
          success: false,
          message: '登录失败，请重试',
        );
      }
      final data = Map<String, dynamic>.from(decoded);
      final result = data['result']?.toString() ?? '';

      if (result == 'success') {
        return AuthResponse(
          success: true,
          message: '登录成功',
        );
      } else if (result == 'invalidCredentials') {
        return AuthResponse(
          success: false,
          message: '用户名或密码错误',
        );
      } else if (result == 'employeeIdNotFound') {
        return AuthResponse(
          success: false,
          message: '工号不存在',
        );
      } else {
        return AuthResponse(
          success: false,
          message: _pickServerMessage(data) ?? '登录失败，请重试',
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

  /// 注册（航司员工：工号须已在后台预置且尚未激活）
  /// [airport] 所属机场完整名称，如 "北京首都国际机场"
  /// [natureOfService] 服务性质，如 "行李中转员"
  static Future<AuthResponse> register(
    String employeeId,
    String username,
    String password,
    String airport,
    String natureOfService,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employee/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': employeeId.trim(),
          'username': username.trim(),
          'password': password,
          'airport': airport,
          'NatureofService': natureOfService,
        }),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResponse(
          success: false,
          message: _messageForNonOkResponse(response),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return AuthResponse(
          success: false,
          message: '注册失败，请重试',
        );
      }
      final data = Map<String, dynamic>.from(decoded);
      final result = data['result']?.toString() ?? '';

      if (result == 'success') {
        return AuthResponse(
          success: true,
          message: '注册成功',
        );
      } else if (result == 'username/passwordRequired') {
        return AuthResponse(
          success: false,
          message: '用户名或密码不能为空',
        );
      } else if (result == 'employeeIdNotFound') {
        return AuthResponse(
          success: false,
          message: '工号不存在或未在系统中登记',
        );
      } else if (result == 'employeeIdAlreadyRegistered') {
        return AuthResponse(
          success: false,
          message: '该工号已注册',
        );
      } else if (result == 'usernameExists') {
        return AuthResponse(
          success: false,
          message: '用户名已被占用',
        );
      } else {
        return AuthResponse(
          success: false,
          message: _pickServerMessage(data) ?? '注册失败，请重试',
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

  /// 注销（需传员工工号）
  static Future<AuthResponse> logout(String employeeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employee/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': employeeId.trim(),
        }),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResponse(
          success: false,
          message: _messageForNonOkResponse(response),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return AuthResponse(
          success: false,
          message: '注销失败，请重试',
        );
      }
      final data = Map<String, dynamic>.from(decoded);
      final result = data['result']?.toString() ?? '';

      if (result == 'success') {
        return AuthResponse(success: true, message: '已注销');
      }
      if (result == 'employeeIdNotFound') {
        return AuthResponse(
          success: false,
          message: '工号不存在，无法完成服务端注销',
        );
      }
      return AuthResponse(
        success: false,
        message: _pickServerMessage(data) ?? '注销失败，请重试',
      );
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

  /// 修改密码
  static Future<AuthResponse> updatePassword({
    required String employeeId,
    required String username,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employee/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': employeeId.trim(),
          'username': username.trim(),
          'newPassword': newPassword,
        }),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResponse(
          success: false,
          message: _messageForNonOkResponse(response),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return AuthResponse(
          success: false,
          message: '修改密码失败，请重试',
        );
      }
      final data = Map<String, dynamic>.from(decoded);
      final result = data['result']?.toString() ?? '';

      if (result == 'success') {
        return AuthResponse(
          success: true,
          message: '密码修改成功',
        );
      }
      return AuthResponse(
        success: false,
        message: _pickServerMessage(data) ?? '修改密码失败，请重试',
      );
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

  /// 修改个人信息
  static Future<AuthResponse> updateDetails({
    required String employeeId,
    String? gender,
    String? hometown,
    String? birthDate,
    String? contact,
    String? hireDate,
  }) async {
    try {
      final body = <String, dynamic>{
        'employeeId': employeeId.trim(),
      };
      if (gender != null && gender.isNotEmpty) body['gender'] = gender;
      if (hometown != null && hometown.isNotEmpty) body['hometown'] = hometown;
      if (birthDate != null && birthDate.isNotEmpty) body['birthDate'] = birthDate;
      if (contact != null && contact.isNotEmpty) body['contact'] = contact;
      if (hireDate != null && hireDate.isNotEmpty) body['hireDate'] = hireDate;

      final response = await http.post(
        Uri.parse('$baseUrl/employee/update-details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResponse(
          success: false,
          message: _messageForNonOkResponse(response),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return AuthResponse(
          success: false,
          message: '修改个人信息失败，请重试',
        );
      }
      final data = Map<String, dynamic>.from(decoded);
      final result = data['result']?.toString() ?? '';

      if (result == 'success') {
        return AuthResponse(
          success: true,
          message: '个人信息修改成功',
        );
      }
      return AuthResponse(
        success: false,
        message: _pickServerMessage(data) ?? '修改个人信息失败，请重试',
      );
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

  /// 修改在职状态
  /// [status] 状态值：null 表示在职，'离职办理' 表示离职申请
  static Future<AuthResponse> updateStatus({
    required String employeeId,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employee/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': employeeId.trim(),
          'status': status,
        }),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResponse(
          success: false,
          message: _messageForNonOkResponse(response),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return AuthResponse(
          success: false,
          message: '修改状态失败，请重试',
        );
      }
      final data = Map<String, dynamic>.from(decoded);
      final result = data['result']?.toString() ?? '';

      if (result == 'success') {
        return AuthResponse(
          success: true,
          message: '离职申请已提交',
        );
      }
      return AuthResponse(
        success: false,
        message: _pickServerMessage(data) ?? '修改状态失败，请重试',
      );
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

  /// 获取员工详细信息
  static Future<EmployeeDetails?> getDetails(String employeeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employee/details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': employeeId.trim(),
        }),
      ).timeout(_timeout, onTimeout: () => throw TimeoutException('请求超时，请检查网络连接'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return null;
      }
      final data = Map<String, dynamic>.from(decoded);
      final result = data['result']?.toString() ?? '';

      if (result == 'success' && data['data'] is Map) {
        return EmployeeDetails.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
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
