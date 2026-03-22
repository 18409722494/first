import 'dart:convert';

/// 二维码载荷解析
/// 支持JSON和QueryString两种格式
class QrPayload {
  final String? userId;
  final String? luggageId;
  final String? role;
  final Map<String, dynamic> extra;

  const QrPayload({
    required this.userId,
    required this.luggageId,
    required this.role,
    required this.extra,
  });

  factory QrPayload.fromRaw(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const QrPayload(userId: null, luggageId: null, role: null, extra: {});
    }

    // JSON
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final obj = jsonDecode(trimmed);
        if (obj is Map<String, dynamic>) return QrPayload.fromJson(obj);
      } catch (_) {
        // fallthrough
      }
    }

    // QueryString / URL
    try {
      final uri = Uri.tryParse(trimmed);
      final Map<String, String> params = uri?.queryParameters.isNotEmpty == true
          ? uri!.queryParameters
          : Uri(query: trimmed).queryParameters;

      return QrPayload(
        userId: params['userId'] ?? params['uid'] ?? params['user_id'],
        luggageId: params['luggageId'] ??
            params['luggage_id'] ??
            params['bagId'] ??
            params['bag_id'],
        role: params['role'],
        extra: Map<String, dynamic>.from(params),
      );
    } catch (_) {
      return QrPayload(userId: null, luggageId: null, role: null, extra: {'raw': trimmed});
    }
  }

  factory QrPayload.fromJson(Map<String, dynamic> json) {
    return QrPayload(
      userId: json['userId']?.toString() ?? json['uid']?.toString(),
      luggageId: json['luggageId']?.toString() ?? json['bagId']?.toString(),
      role: json['role']?.toString(),
      extra: json['extra'] is Map<String, dynamic>
          ? (json['extra'] as Map<String, dynamic>)
          : Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'luggageId': luggageId,
        'role': role,
        'extra': extra,
      };
}

