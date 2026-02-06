/// 行李状态枚举
enum LuggageStatus {
  checkIn('已办理托运'),
  inTransit('运输中'),
  arrived('已到达'),
  delivered('已交付'),
  damaged('已损坏'),
  lost('已丢失');

  final String displayName;
  const LuggageStatus(this.displayName);

  @override
  String toString() => displayName;
}

/// 行李数据模型
/// 用于表示行李的完整信息
class Luggage {
  /// 行李唯一标识符
  final String id;
  
  /// 行李标签号
  final String tagNumber;
  
  /// 航班号
  final String flightNumber;
  
  /// 乘客姓名
  final String passengerName;
  
  /// 行李重量（单位：千克）
  final double weight;
  
  /// 行李状态
  final LuggageStatus status;
  
  /// 办理托运时间
  final DateTime checkInTime;
  
  /// 最后更新时间
  final DateTime lastUpdated;
  
  /// 目的地
  final String destination;
  
  /// 备注信息
  final String notes;
  
  /// 行李位置纬度
  final double? latitude;
  
  /// 行李位置经度
  final double? longitude;

  /// 构造函数
  const Luggage({
    required this.id,
    required this.tagNumber,
    required this.flightNumber,
    required this.passengerName,
    required this.weight,
    required this.status,
    required this.checkInTime,
    required this.lastUpdated,
    required this.destination,
    required this.notes,
    this.latitude,
    this.longitude,
  });

  /// 从JSON数据创建Luggage对象
  /// 兼容不同的字段命名格式（驼峰和下划线）
  factory Luggage.fromJson(Map<String, dynamic> json) {
    /// 解析时间字段的辅助函数
    /// 支持DateTime对象或字符串格式
    DateTime? parseTime(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    /// 解析数字字段的辅助函数
    /// 支持各种数字类型
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    /// 解析状态字段
    LuggageStatus parseStatus(dynamic v) {
      if (v == null) return LuggageStatus.checkIn;
      if (v is LuggageStatus) return v;
      final s = v.toString().toLowerCase();
      switch (s) {
        case 'in_transit':
        case 'intransit':
          return LuggageStatus.inTransit;
        case 'arrived':
          return LuggageStatus.arrived;
        case 'delivered':
          return LuggageStatus.delivered;
        case 'damaged':
          return LuggageStatus.damaged;
        case 'lost':
          return LuggageStatus.lost;
        default:
          return LuggageStatus.checkIn;
      }
    }

    return Luggage(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      tagNumber: json['tagNumber']?.toString() ?? json['tag_no']?.toString() ?? json['tagNo']?.toString() ?? '',
      flightNumber: json['flightNumber']?.toString() ?? json['flight_no']?.toString() ?? '',
      passengerName: json['passengerName']?.toString() ?? json['passenger_name']?.toString() ?? json['ownerName']?.toString() ?? '',
      weight: parseDouble(json['weight'] ?? json['weightKg'] ?? json['weight_kg']) ?? 0.0,
      status: parseStatus(json['status']),
      checkInTime: parseTime(json['checkInTime'] ?? json['check_in_time'] ?? DateTime.now()) ?? DateTime.now(),
      lastUpdated: parseTime(json['lastUpdated'] ?? json['last_updated'] ?? json['updatedAt'] ?? json['updated_at'] ?? DateTime.now()) ?? DateTime.now(),
      destination: json['destination']?.toString() ?? '',
      notes: json['notes']?.toString() ?? json['note']?.toString() ?? json['remark']?.toString() ?? '',
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
    );
  }

  /// 将Luggage对象转换为JSON格式
  Map<String, dynamic> toJson() => {
        'id': id,
        'tagNumber': tagNumber,
        'flightNumber': flightNumber,
        'passengerName': passengerName,
        'weight': weight,
        'status': status.toString().split('.').last,
        'checkInTime': checkInTime.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'destination': destination,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
      };

  /// 创建一个新的Luggage对象，只更新指定的字段
  /// 用于不可变对象的更新操作
  Luggage copyWith({
    String? id,
    String? tagNumber,
    String? flightNumber,
    String? passengerName,
    double? weight,
    LuggageStatus? status,
    DateTime? checkInTime,
    DateTime? lastUpdated,
    String? destination,
    String? notes,
    double? latitude,
    double? longitude,
  }) {
    return Luggage(
      id: id ?? this.id,
      tagNumber: tagNumber ?? this.tagNumber,
      flightNumber: flightNumber ?? this.flightNumber,
      passengerName: passengerName ?? this.passengerName,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      destination: destination ?? this.destination,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

