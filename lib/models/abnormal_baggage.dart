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
      return DateTime.tryParse(v.toString());
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
