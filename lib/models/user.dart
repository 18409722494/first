/// 用户数据模型
/// 用于表示应用中的用户信息
class User {
  /// 用户唯一标识符
  final String id;
  
  /// 用户名
  final String username;
  
  /// 用户邮箱
  final String email;
  
  /// 用户认证令牌（可选）
  final String? token;

  /// 构造函数
  User({
    required this.id,
    required this.username,
    required this.email,
    this.token,
  });

  /// 从JSON数据创建User对象
  /// 兼容不同的JSON格式（id或_id字段）
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
    );
  }

  /// 将User对象转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
    };
  }
}
