import 'package:flutter/material.dart';

/// 行李状态枚举（自带展示属性：颜色、背景色）
///
/// [displayNameKey] 用于国际化 lookup。
enum LuggageStatus {
  checkIn('已办理托运'),
  inTransit('运输中'),
  arrived('已到达'),
  delivered('已交付'),
  damaged('已损坏'),
  lost('已丢失');

  /// 中文默认显示名
  final String displayName;

  /// 状态文字颜色
  Color get color {
    switch (this) {
      case LuggageStatus.checkIn:
        return const Color(0xFF2196F3); // 蓝色
      case LuggageStatus.inTransit:
        return const Color(0xFF050D22); // 深蓝
      case LuggageStatus.arrived:
        return const Color(0xFF4CAF50); // 绿色
      case LuggageStatus.delivered:
        return const Color(0xFF75210E); // 深红
      case LuggageStatus.damaged:
        return const Color(0xFFBDBB41); // 黄色
      case LuggageStatus.lost:
        return const Color(0xFF9E9E9E); // 灰色
    }
  }

  /// 状态背景浅色（适合 Chip/Container 背景）
  Color get bgColor {
    switch (this) {
      case LuggageStatus.checkIn:
        return const Color(0xFFE3F2FD);
      case LuggageStatus.inTransit:
        return const Color(0xFFE8EAF6);
      case LuggageStatus.arrived:
        return const Color(0xFFE8F5E9);
      case LuggageStatus.delivered:
        return const Color(0xFFFBE9E7);
      case LuggageStatus.damaged:
        return const Color(0xFFFFFDE7);
      case LuggageStatus.lost:
        return const Color(0xFFF5F5F5);
    }
  }

  const LuggageStatus(this.displayName);

  @override
  String toString() => displayName;
}

/// 行李模型
class Luggage {
  final String id;
  final String tagNumber;
  final String flightNumber;
  final String passengerName;
  final double weight;
  final LuggageStatus status;
  final DateTime checkInTime;
  final DateTime lastUpdated;
  final String destination;
  final String notes;
  final double? latitude;
  final double? longitude;
  final String? contact;

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
    this.contact,
  });

  factory Luggage.fromJson(Map<String, dynamic> json) {
    DateTime? parseTime(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    LuggageStatus parseStatus(dynamic v) {
      // 使用统一映射（支持后端中文如「已达」）
      return BaggageStatusMapper.parseFromApi(v);
    }

    return Luggage(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      tagNumber: json['tagNumber']?.toString() ?? json['tag_no']?.toString() ?? json['tagNo']?.toString() ?? '',
      flightNumber: json['flightNumber']?.toString() ?? json['flight_no']?.toString() ?? '',
      passengerName: json['passengerName']?.toString() ?? json['passenger_name']?.toString() ?? json['ownerName']?.toString() ?? '',
      weight: parseDouble(json['weight'] ?? json['weightKg'] ?? json['weight_kg']) ?? 0.0,
      status: parseStatus(json['baggageStatus'] ?? json['status']),
      checkInTime: parseTime(json['checkInTime'] ?? json['check_in_time'] ?? DateTime.now()) ?? DateTime.now(),
      lastUpdated: parseTime(json['lastUpdated'] ?? json['last_updated'] ?? json['updatedAt'] ?? json['updated_at'] ?? DateTime.now()) ?? DateTime.now(),
      destination: json['destination']?.toString() ?? '',
      notes: json['notes']?.toString() ??
          json['note']?.toString() ??
          json['remark']?.toString() ??
          json['baggageRemark']?.toString() ??
          '',
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      contact: json['contact']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tagNumber': tagNumber,
        'flightNumber': flightNumber,
        'passengerName': passengerName,
        'weight': weight,
        'status': status.name,
        'checkInTime': checkInTime.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'destination': destination,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
        'contact': contact,
      };

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
    String? contact,
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
      contact: contact ?? this.contact,
    );
  }
}

/// 后端行李状态（中文）与本地 [LuggageStatus] 互转。
/// `PUT /baggage/location` 的 `status` 使用中文（如「已达」）。
class BaggageStatusMapper {
  BaggageStatusMapper._();

  /// 解析列表/详情接口返回的状态（中文或英文）
  static LuggageStatus parseFromApi(dynamic v) {
    if (v == null) return LuggageStatus.checkIn;
    if (v is LuggageStatus) return v;
    final raw = v.toString().trim();
    if (raw.isEmpty) return LuggageStatus.checkIn;

    switch (raw) {
      case '正常':
        // 后端业务用语：无异常，按托运在途前默认可视为已办托运
        return LuggageStatus.checkIn;
      case '已办理托运':
      case '办理托运':
      case '托运':
        return LuggageStatus.checkIn;
      case '运输中':
      case '在途':
        return LuggageStatus.inTransit;
      case '已达':
      case '已到达':
      case '到达':
        return LuggageStatus.arrived;
      case '已交付':
      case '交付':
        return LuggageStatus.delivered;
      case '已损坏':
      case '损坏':
        return LuggageStatus.damaged;
      case '已丢失':
      case '丢失':
        return LuggageStatus.lost;
    }

    final s = raw.toLowerCase();
    switch (s) {
      case 'in_transit':
      case 'intransit':
      case 'transporting':
        return LuggageStatus.inTransit;
      case 'arrived':
      case 'arrival':
        return LuggageStatus.arrived;
      case 'delivered':
      case 'claimed':
        return LuggageStatus.delivered;
      case 'damaged':
      case 'broken':
        return LuggageStatus.damaged;
      case 'lost':
      case 'missing':
        return LuggageStatus.lost;
      case 'checkin':
      case 'check_in':
      case 'checked':
        return LuggageStatus.checkIn;
      default:
        return LuggageStatus.checkIn;
    }
  }

  /// 写入 `PUT /baggage/location` 的 `status` 字段
  static String toBackendLocationStatus(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.checkIn:
        return '已办理托运';
      case LuggageStatus.inTransit:
        return '运输中';
      case LuggageStatus.arrived:
        return '已达';
      case LuggageStatus.delivered:
        return '已交付';
      case LuggageStatus.damaged:
        return '已损坏';
      case LuggageStatus.lost:
        return '已丢失';
    }
  }

  /// 从详情页文本框解析状态（英文名、中文显示名或后端用语）
  static LuggageStatus parseFromUserInput(String text, LuggageStatus fallback) {
    final t = text.trim();
    if (t.isEmpty) return fallback;
    for (final s in LuggageStatus.values) {
      if (s.name == t || s.displayName == t) return s;
    }
    return parseFromApi(t);
  }
}
