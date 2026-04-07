/// 破损行李/证据模型
/// 对应接口: http://8.137.145.195:3338/abnormal-baggage/all
class AbnormalBaggage {
  final int id;
  final String baggageNumber;
  final DateTime timestamp;
  final String location;
  final String imageUrl;
  final String damageDescription;
  final String baggageHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AbnormalBaggage({
    required this.id,
    required this.baggageNumber,
    required this.timestamp,
    required this.location,
    required this.imageUrl,
    required this.damageDescription,
    required this.baggageHash,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AbnormalBaggage.fromJson(Map<String, dynamic> json) {
    DateTime? parseTime(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      // DateTime.tryParse 将 ISO 8601 UTC 时间（如 2026-04-06T11:32:00Z）当作本地时间解析，
      // 故手动先按 UTC 解析再转本地时区，保证显示时间与后端存储一致（均以本地为准）。
      final parsed = DateTime.tryParse(v.toString());
      if (parsed == null) return null;
      return parsed.toLocal();
    }

    return AbnormalBaggage(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      baggageNumber: json['baggageNumber']?.toString() ?? '',
      timestamp: parseTime(json['timestamp']) ?? DateTime.now(),
      location: json['location']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      damageDescription: json['damageDescription']?.toString() ?? json['damage_description']?.toString() ?? '',
      baggageHash: json['baggageHash']?.toString() ?? json['baggage_hash']?.toString() ?? '',
      createdAt: parseTime(json['createdAt']) ?? parseTime(json['created_at']) ?? DateTime.now(),
      updatedAt: parseTime(json['updatedAt']) ?? parseTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'baggageNumber': baggageNumber,
        'timestamp': timestamp.toIso8601String(),
        'location': location,
        'imageUrl': imageUrl,
        'damageDescription': damageDescription,
        'baggageHash': baggageHash,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 格式化时间显示
  String get formattedTime {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期显示
  String get formattedDate {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }
}
