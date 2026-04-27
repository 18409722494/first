/// 用户模型
/// 注意：token 不序列化到 JSON，仅由 StorageService 单独管理
class User {
  final String id;
  final String username;
  final String email;
  final String? token;
  /// 航司员工工号（注册时写入；登录页录入以便调用注销接口）
  final String? employeeId;
  /// 性别
  final String? gender;
  /// 籍贯
  final String? hometown;
  /// 出生日期
  final String? birthDate;
  /// 联系方式
  final String? contact;
  /// 入职日期
  final String? hireDate;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.token,
    this.employeeId,
    this.gender,
    this.hometown,
    this.birthDate,
    this.contact,
    this.hireDate,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? token,
    String? employeeId,
    String? gender,
    String? hometown,
    String? birthDate,
    String? contact,
    String? hireDate,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      token: token ?? this.token,
      employeeId: employeeId ?? this.employeeId,
      gender: gender ?? this.gender,
      hometown: hometown ?? this.hometown,
      birthDate: birthDate ?? this.birthDate,
      contact: contact ?? this.contact,
      hireDate: hireDate ?? this.hireDate,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      employeeId: json['employeeId']?.toString(),
      gender: json['gender']?.toString(),
      hometown: json['hometown']?.toString(),
      birthDate: json['birthDate']?.toString(),
      contact: json['contact']?.toString(),
      hireDate: json['hireDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (employeeId != null) 'employeeId': employeeId,
      if (gender != null) 'gender': gender,
      if (hometown != null) 'hometown': hometown,
      if (birthDate != null) 'birthDate': birthDate,
      if (contact != null) 'contact': contact,
      if (hireDate != null) 'hireDate': hireDate,
    };
  }
}
