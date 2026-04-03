import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import '../constants/app_constants.dart';
import '../models/luggage.dart';

/// 后端行李信息 API 服务
class BaggageApiService {
  static String get _baseUrl => AppConstants.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 15);
  static const int _pageSize = 20;

  /// 分页获取行李列表
  /// [page] 从 1 开始；[pageSize] 每页条数，默认 20
  static Future<PagedResult<Luggage>> getAllBaggage({
    int page = 1,
    int pageSize = _pageSize,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/baggage/all').replace(
        queryParameters: {'page': '$page', 'pageSize': '$pageSize'},
      );
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final items = data.map((json) => _parseBaggage(json)).toList();
        final hasMore = items.length == pageSize;
        return PagedResult(items: items, hasMore: hasMore, page: page);
      } else {
        throw Exception('获取行李列表失败: ${response.statusCode}');
      }
    } catch (e) {
      // 网络失败时：用 Mock 数据模拟分页返回
      final allMock = _buildMockBaggage();
      final start = (page - 1) * pageSize;
      if (start >= allMock.length) {
        return PagedResult(items: [], hasMore: false, page: page);
      }
      final end = (start + pageSize).clamp(0, allMock.length);
      return PagedResult(
        items: allMock.sublist(start, end),
        hasMore: end < allMock.length,
        page: page,
      );
    }
  }

  /// 一次性拉取全部（用于搜索等不需分页的场景）
  static Future<List<Luggage>> getAllBaggageList() async {
    final result = await getAllBaggage(page: 1, pageSize: 9999);
    return result.items;
  }

  /// 构造 60 条 Mock 数据用于分页演示
  static List<Luggage> _buildMockBaggage() {
    return List.generate(60, (i) {
      final idx = i + 1;
      return Luggage(
        id: 'mock_$idx',
        tagNumber: 'TAG${1000 + idx}',
        flightNumber: 'CA${100 + idx}',
        passengerName: '乘客$idx',
        weight: 15.0 + (idx % 10) * 2,
        status: LuggageStatus.checkIn,
        checkInTime: DateTime.now().subtract(Duration(hours: idx)),
        lastUpdated: DateTime.now().subtract(Duration(hours: idx ~/ 2)),
        destination: '航站楼${(idx % 3) + 1}',
        notes: '',
        latitude: 39.9 + idx * 0.001,
        longitude: 116.4 + idx * 0.001,
      );
    });
  }

  /// 根据行李号查询行李
  static Future<Luggage?> getBaggageByNumber(String baggageNumber) async {
    try {
      final result = await getAllBaggageList();
      return result.firstWhereOrNull(
        (item) => item.tagNumber == baggageNumber,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 搜索行李（支持标签号、航班号、乘客名）
  static Future<List<Luggage>> searchBaggage(String keyword) async {
    final result = await getAllBaggageList();
    final lowerKeyword = keyword.toLowerCase();
    return result.where((luggage) {
      return luggage.tagNumber.toLowerCase().contains(lowerKeyword) ||
          luggage.flightNumber.toLowerCase().contains(lowerKeyword) ||
          luggage.passengerName.toLowerCase().contains(lowerKeyword) ||
          luggage.destination.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  /// 根据航班号筛选行李
  static Future<List<Luggage>> getBaggageByFlight(String flightNumber) async {
    try {
      final result = await getAllBaggageList();
      return result.where((item) => item.flightNumber == flightNumber).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 根据乘客名筛选行李
  static Future<List<Luggage>> getBaggageByPassenger(String passengerName) async {
    try {
      final result = await getAllBaggageList();
      return result.where((item) => item.passengerName == passengerName).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 解析后端返回的行李数据
  static Luggage _parseBaggage(Map<String, dynamic> json) {
    DateTime? parseTime(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return Luggage(
      id: json['id']?.toString() ?? '',
      tagNumber: json['baggageNumber']?.toString() ?? json['baggage_no']?.toString() ?? '',
      flightNumber: json['flightNumber']?.toString() ?? json['flight_no']?.toString() ?? '',
      passengerName: json['passengerName']?.toString() ?? json['passenger_name']?.toString() ?? '',
      weight: parseDouble(json['weight'] ?? json['weightKg'] ?? json['weight_kg']) ?? 0.0,
      status: _parseStatus(json['status']),
      checkInTime: parseTime(json['flightTime'] ?? json['checkInTime'] ?? json['check_in_time'] ?? DateTime.now()) ?? DateTime.now(),
      lastUpdated: parseTime(json['updatedAt'] ?? json['updated_at'] ?? DateTime.now()) ?? DateTime.now(),
      destination: json['currentLocation']?.toString() ?? json['destination']?.toString() ?? '',
      notes: json['notes']?.toString() ?? json['remark']?.toString() ?? '',
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
    );
  }

  /// 解析行李状态
  static LuggageStatus _parseStatus(dynamic v) {
    if (v == null) return LuggageStatus.checkIn;
    if (v is LuggageStatus) return v;
    final s = v.toString().toLowerCase();
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

  /// 将行李转换为后端需要的格式
  static Map<String, dynamic> toBaggageJson(Luggage luggage) {
    return {
      'baggageNumber': luggage.tagNumber,
      'flightNumber': luggage.flightNumber,
      'flightTime': luggage.checkInTime.toIso8601String(),
      'passengerName': luggage.passengerName,
      'weight': luggage.weight,
      'currentLocation': luggage.destination,
      'notes': luggage.notes,
      'latitude': luggage.latitude,
      'longitude': luggage.longitude,
    };
  }

  /// 获取今日统计
  static Future<Map<String, int>> getTodayStatistics() async {
    try {
      final result = await getAllBaggageList();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int todayCount = 0;
      int abnormalCount = 0;

      for (final luggage in result) {
        final createdDate = DateTime(
          luggage.checkInTime.year,
          luggage.checkInTime.month,
          luggage.checkInTime.day,
        );
        if (createdDate == today) {
          todayCount++;
          if (luggage.status == LuggageStatus.damaged ||
              luggage.status == LuggageStatus.lost) {
            abnormalCount++;
          }
        }
      }
      return {'todayProcessed': todayCount, 'abnormal': abnormalCount};
    } catch (e) {
      rethrow;
    }
  }

  /// 获取按航班分组的行李统计
  static Future<Map<String, List<Luggage>>> getBaggageGroupedByFlight() async {
    try {
      final result = await getAllBaggageList();
      final Map<String, List<Luggage>> grouped = {};
      for (final luggage in result) {
        final flight = luggage.flightNumber;
        grouped.putIfAbsent(flight, () => []).add(luggage);
      }
      return grouped;
    } catch (e) {
      rethrow;
    }
  }

  /// 更新行李扫码位置
  static Future<Map<String, dynamic>> updateBaggageLocation({
    required String baggageNumber,
    required String location,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/baggage/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'baggageNumber': baggageNumber,
          'location': location,
        }),
      ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('更新行李位置失败: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// 分页结果包装器
class PagedResult<T> {
  final List<T> items;
  final bool hasMore;
  final int page;

  PagedResult({
    required this.items,
    required this.hasMore,
    required this.page,
  });
}
