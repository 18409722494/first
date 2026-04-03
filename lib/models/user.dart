/// 用户模型
/// 注意：token 不序列化到 JSON，仅由 StorageService 单独管理
class User {
  final String id;
  final String username;
  final String email;
  final String? token;
  /// 航司员工工号（注册时写入；登录页录入以便调用注销接口）
  final String? employeeId;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.token,
    this.employeeId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      employeeId: json['employeeId']?.toString(),
      // token 字段不从此处读取，统一由 StorageService 管理
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (employeeId != null) 'employeeId': employeeId,
      // token 不写入 JSON，避免持久化泄露
    };
  }
}
