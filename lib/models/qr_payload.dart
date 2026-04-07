import 'dart:convert';

/// 二维码载荷解析
/// 支持 JSON、URL/QueryString、以及 PC 端打印的纯文本行李标签（多行「键:值」）
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

    // 纯文本行李标签，例如：
    // 行李标签
    // 旅客:王五
    // 行李号:7SMPDX
    // 行李编号:ZK1VQI
    final plain = _parsePlainTextLuggageLabel(trimmed);
    if (plain != null) {
      return plain;
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
            params['bag_id'] ??
            params['baggageNumber'] ??
            params['baggage_no'],
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
      luggageId: json['luggageId']?.toString() ??
          json['luggage_id']?.toString() ??
          json['bagId']?.toString() ??
          json['baggageNumber']?.toString() ??
          json['baggage_no']?.toString() ??
          json['id']?.toString(),
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

  /// 解析多行「键:值」或「键：值」（支持中英文冒号）
  static QrPayload? _parsePlainTextLuggageLabel(String text) {
    final map = <String, String>{};
    for (final line in text.split(RegExp(r'\r?\n'))) {
      final l = line.trim();
      if (l.isEmpty) continue;
      final m = RegExp(r'^(.+?)[:：]\s*(.+)$').firstMatch(l);
      if (m == null) continue;
      map[m.group(1)!.trim()] = m.group(2)!.trim();
    }
    if (map.isEmpty) return null;

    String? baggageNo = map['行李号'];
    if (baggageNo == null || baggageNo.isEmpty) baggageNo = map['行李编号'];
    if (baggageNo == null || baggageNo.isEmpty) baggageNo = map['行李标签号'];

    if (baggageNo == null || baggageNo.isEmpty) return null;

    final extra = <String, dynamic>{
      ...map.map((k, v) => MapEntry(k, v)),
      'tagNo': baggageNo,
      if (map['旅客'] != null) 'passenger_hint': map['旅客'],
      if (map['航班'] != null) 'flight_hint': map['航班'],
    };

    return QrPayload(
      userId: null,
      luggageId: baggageNo,
      role: 'scanned_plain',
      extra: extra,
    );
  }
}

