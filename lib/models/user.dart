/// 用户模型
/// 注意：token 不序列化到 JSON，仅由 StorageService 单独管理
class User {
  final String id;
  final String username;
  final String email;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      // token 字段不从此处读取，统一由 StorageService 管理
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      // token 不写入 JSON，避免持久化泄露
    };
  }
}
