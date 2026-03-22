/// 行李状态枚举
enum LuggageStatus {
  checkIn,
  inTransit,
  arrived,
  delivered,
  damaged,
  lost;

  String get displayName {
    switch (this) {
      case LuggageStatus.checkIn:
        return '已办理托运';
      case LuggageStatus.inTransit:
        return '运输中';
      case LuggageStatus.arrived:
        return '已到达';
      case LuggageStatus.delivered:
        return '已交付';
      case LuggageStatus.damaged:
        return '已损坏';
      case LuggageStatus.lost:
        return '已丢失';
      default:
        return '未知状态';
    }
  }

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

