import 'user.dart';

/// 认证响应数据模型
/// 用于封装登录和注册接口的响应数据
class AuthResponse {
  /// 操作是否成功
  final bool success;
  
  /// 响应消息
  final String message;
  
  /// 用户信息（可选）
  final User? user;
  
  /// 认证令牌（可选）
  final String? token;

  /// 构造函数
  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  /// 从JSON数据创建AuthResponse对象
  /// 兼容不同的响应格式（token可能在data字段中）
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'] ?? json['data']?['token'],
    );
  }
}
