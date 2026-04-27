import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/abnormal_baggage.dart';
import '../models/baggage_operation_log.dart';
import '../models/luggage.dart';
import '../utils/api_cache.dart';

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
    // 第1页且请求全部数据时使用缓存
    if (page == 1 && pageSize >= 100) {
      final cacheKey = 'allBaggage_$pageSize';
      final cached = baggageListCache.get(cacheKey);
      if (cached != null) {
        final items = cached.map((json) => _parseBaggage(json)).toList();
        return PagedResult(items: items, hasMore: items.length >= pageSize, page: page);
      }
    }

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

        // 缓存第1页大量数据
        if (page == 1 && pageSize >= 100) {
          final cacheKey = 'allBaggage_$pageSize';
          baggageListCache.set(cacheKey, data.cast<Map<String, dynamic>>());
        }

        final hasMore = items.length == pageSize;
        return PagedResult(items: items, hasMore: hasMore, page: page);
      } else {
        throw Exception('获取行李列表失败: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 一次性拉取全部（用于搜索等不需分页的场景）
  static Future<List<Luggage>> getAllBaggageList() async {
    final result = await getAllBaggage(page: 1, pageSize: 9999);
    return result.items;
  }

  /// 行李操作历史（POST /baggage/history）
  ///
  /// Query参数：baggageNumber（行李号）
  /// 接口不存在或失败时返回空列表（不阻塞详情页），但会记录错误日志
  static Future<List<BaggageOperationLog>> getOperationLogs({
    String? baggageNumber,
    String? baggageId,
  }) async {
    final key = baggageNumber?.trim() ?? baggageId?.trim() ?? '';
    if (key.isEmpty) return [];

    try {
      final body = <String, dynamic>{
        'baggageNumber': key,
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/baggage/history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[BaggageApiService] getOperationLogs HTTP错误: ${response.statusCode}');
        return [];
      }

      final decoded = jsonDecode(response.body);
      List<dynamic> rawList;
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final d = decoded['data'] ?? decoded['records'] ?? decoded['logs'];
        if (d is List) {
          rawList = d;
        } else {
          debugPrint('[BaggageApiService] getOperationLogs 响应格式异常');
          return [];
        }
      } else {
        debugPrint('[BaggageApiService] getOperationLogs 响应类型异常');
        return [];
      }

      return rawList
          .whereType<Map>()
          .map((m) => BaggageOperationLog.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      debugPrint('[BaggageApiService] getOperationLogs 异常: $e');
      return [];
    }
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

  /// 根据行李号获取破损记录（GET /abnormal-baggage/all 再过滤）
  /// 接口失败时返回空列表（不阻塞详情页），但会记录错误日志
  static Future<List<AbnormalBaggage>> getAbnormalRecords(String baggageNumber) async {
    try {
      final all = await getAllAbnormalBaggageRaw();
      return all
          .where((r) => r.baggageNumber.trim().toLowerCase() == baggageNumber.trim().toLowerCase())
          .toList();
    } catch (e) {
      debugPrint('[BaggageApiService] getAbnormalRecords 异常: $e');
      return [];
    }
  }

  /// 一次性拉取全部破损记录（内部用，与 GET /abnormal-baggage/all 对齐）
  static Future<List<AbnormalBaggage>> getAllAbnormalBaggageRaw() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/abnormal-baggage/all'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => AbnormalBaggage.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        debugPrint('[BaggageApiService] getAllAbnormalBaggageRaw 响应不是数组');
        return [];
      }
      debugPrint('[BaggageApiService] getAllAbnormalBaggageRaw HTTP错误: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('[BaggageApiService] getAllAbnormalBaggageRaw 异常: $e');
      return [];
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
      id: (json['id']?.toString().isNotEmpty ?? false)
          ? json['id'].toString()
          : (json['baggageNumber']?.toString().isNotEmpty ?? false)
              ? json['baggageNumber'].toString()
              : (json['_id']?.toString().isNotEmpty ?? false)
                  ? json['_id'].toString()
                  : '',
      tagNumber: json['baggageNumber']?.toString() ?? json['baggage_no']?.toString() ?? '',
      flightNumber: json['flightNumber']?.toString() ?? json['flight_no']?.toString() ?? '',
      passengerName: json['passengerName']?.toString() ?? json['passenger_name']?.toString() ?? '',
      weight: parseDouble(json['weight'] ?? json['weightKg'] ?? json['weight_kg']) ?? 0.0,
      // 后端表字段为 baggageStatus；旧字段名 status 作回退
      status: _parseStatus(json['baggageStatus'] ?? json['status']),
      checkInTime: parseTime(json['flightTime'] ?? json['checkInTime'] ?? json['check_in_time'] ?? DateTime.now()) ?? DateTime.now(),
      lastUpdated: parseTime(json['updatedAt'] ?? json['updated_at'] ?? DateTime.now()) ?? DateTime.now(),
      destination: json['currentLocation']?.toString() ?? json['destination']?.toString() ?? '',
      notes: json['notes']?.toString() ??
          json['remark']?.toString() ??
          json['baggageRemark']?.toString() ??
          '',
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      contact: json['contact']?.toString(),
    );
  }

  /// 解析行李状态（与 [Luggage.fromJson] 一致，支持中文）
  static LuggageStatus _parseStatus(dynamic v) => BaggageStatusMapper.parseFromApi(v);

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
      'contact': luggage.contact,
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

  /// 更新行李位置与状态（POST /baggage/location）
  /// 请求: { baggageNumber, location, status?, employeeId }
  /// 添加重试机制和详细错误信息
  static Future<Map<String, dynamic>> updateBaggageLocation({
    required String baggageNumber,
    required String location,
    String? status,
    String? employeeId,
  }) async {
    const maxRetries = 2;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final body = <String, dynamic>{
          'baggageNumber': baggageNumber,
          'location': location,
          if (status != null && status.isNotEmpty) 'status': status,
          if (employeeId != null && employeeId.isNotEmpty) 'employeeId': employeeId,
        };

        debugPrint('[BaggageApiService] POST /baggage/location (第$attempt次): $body');

        final response = await http.post(
          Uri.parse('$_baseUrl/baggage/location'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

        debugPrint('[BaggageApiService] 响应状态码: ${response.statusCode}');
        debugPrint('[BaggageApiService] 响应内容: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final map = jsonDecode(response.body) as Map<String, dynamic>;
          final ok = map['result']?.toString().toLowerCase() == 'success' ||
              map['success'] == true ||
              map['code']?.toString() == '0';
          if (ok || !map.containsKey('result')) {
            return map;
          }
          throw Exception(map['message']?.toString() ?? '更新行李失败');
        } else {
          // 尝试解析错误信息
          String errorDetail = '更新行李位置失败: ${response.statusCode}';
          try {
            final errorMap = jsonDecode(response.body) as Map<String, dynamic>;
            errorDetail = errorMap['message']?.toString() ??
                errorMap['error']?.toString() ??
                errorDetail;
          } catch (_) {}
          throw Exception(errorDetail);
        }
      } catch (e) {
        debugPrint('[BaggageApiService] 位置更新第$attempt次失败: $e');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          rethrow;
        }
      }
    }
    throw Exception('更新行李位置失败');
  }

  /// 写入操作日志（POST /baggage/history）
  /// 必填：baggageNumber、phone（来自行李的 contact 字段）
  /// 选填：action、location、employeeId、details
  /// 注意：写入失败时会记录日志但返回 false（不影响主流程）
  static Future<bool> addOperationLog({
    required String baggageNumber,
    required String phone,
    String? action,
    String? location,
    String? employeeId,
    String? details,
  }) async {
    try {
      final body = <String, dynamic>{
        'baggageNumber': baggageNumber,
        'phone': phone,
        if (action != null && action.isNotEmpty) 'action': action,
        if (location != null && location.isNotEmpty) 'location': location,
        if (employeeId != null && employeeId.isNotEmpty) 'employeeId': employeeId,
        if (details != null && details.isNotEmpty) 'details': details,
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/baggage/history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final success = map['result']?.toString().toLowerCase() == 'success';
        if (!success) {
          debugPrint('[BaggageApiService] addOperationLog 业务失败: ${map['message']}');
        }
        return success;
      }
      debugPrint('[BaggageApiService] addOperationLog HTTP错误: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[BaggageApiService] addOperationLog 异常: $e');
      return false;
    }
  }

  /// 读取操作日志（POST /baggage/history）
  /// 必填：baggageNumber、phone（来自行李的 contact 字段）
  /// 注意：失败时返回空列表，但会记录错误日志
  static Future<List<BaggageOperationLog>> getOperationHistory({
    required String baggageNumber,
    required String phone,
  }) async {
    try {
      final body = <String, dynamic>{
        'baggageNumber': baggageNumber,
        'phone': phone,
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/baggage/history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final result = map['result']?.toString().toLowerCase();
        if (result != 'success') {
          debugPrint('[BaggageApiService] getOperationHistory 业务失败');
          return [];
        }

        final data = map['data'];
        if (data == null) {
          debugPrint('[BaggageApiService] getOperationHistory 无数据');
          return [];
        }
        if (data is List) {
          return data
              .whereType<Map>()
              .map((m) => BaggageOperationLog.fromJson(Map<String, dynamic>.from(m)))
              .toList();
        }
      }
      debugPrint('[BaggageApiService] getOperationHistory HTTP错误: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('[BaggageApiService] getOperationHistory 异常: $e');
      return [];
    }
  }

  /// 通过行李号读取操作历史（POST /baggage/history/by-number）
  /// 返回行李位置变更的历史记录
  /// 注意：失败时返回空列表，但会记录错误日志
  static Future<List<BaggageOperationLog>> getOperationHistoryByNumber(
    String baggageNumber,
  ) async {
    try {
      final body = <String, dynamic>{
        'baggageNumber': baggageNumber,
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/baggage/history/by-number'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final result = map['result']?.toString().toLowerCase();
        if (result != 'success') {
          debugPrint('[BaggageApiService] getOperationHistoryByNumber 业务失败');
          return [];
        }

        final data = map['data'];
        if (data == null) return [];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((m) => BaggageOperationLog.fromHistoryByNumber(Map<String, dynamic>.from(m)))
              .toList();
        }
      }
      debugPrint('[BaggageApiService] getOperationHistoryByNumber HTTP错误: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('[BaggageApiService] getOperationHistoryByNumber 异常: $e');
      return [];
    }
  }

  /// 获取未处理行李列表（该航班中 baggageStatus 为 null 的行李）
  /// 请求: { flightNumber: "TJ123", employeeId: "88790126" }
  /// 响应: { result: "success", data: [{ id, baggageNumber, flightNumber, ... }, ...] }
  static Future<List<Luggage>> getUnprocessedBaggage({
    required String flightNumber,
    required String employeeId,
  }) async {
    try {
      final body = <String, dynamic>{
        'flightNumber': flightNumber.trim(),
        'employeeId': employeeId.trim(),
      };

      debugPrint('[BaggageApiService] POST /baggage/unprocessed: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/baggage/unprocessed'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      debugPrint('[BaggageApiService] 响应: ${response.body}');

      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final result = map['result']?.toString().toLowerCase();
        if (result == 'success') {
          final data = map['data'];
          if (data is List) {
            return data
                .whereType<Map>()
                .map((m) => _parseBaggage(Map<String, dynamic>.from(m)))
                .toList();
          }
          debugPrint('[BaggageApiService] getUnprocessedBaggage data不是数组');
        } else {
          debugPrint('[BaggageApiService] getUnprocessedBaggage 业务失败: $result');
        }
      } else {
        debugPrint('[BaggageApiService] getUnprocessedBaggage HTTP错误: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('[BaggageApiService] getUnprocessedBaggage 异常: $e');
      return [];
    }
  }

  /// 标记行李为丢失状态
  /// 请求: { baggageNumber: "1099", location: "...", status: "已丢失", employeeId: "..." }
  /// 响应: { result: "success", data: { flightNumber: "TJ123" } }
  static Future<Map<String, dynamic>> markBaggageAsLost({
    required String baggageNumber,
    required String location,
    required String employeeId,
  }) async {
    try {
      final body = <String, dynamic>{
        'baggageNumber': baggageNumber.trim(),
        'location': location.trim(),
        'status': '已丢失',
        'employeeId': employeeId.trim(),
      };

      debugPrint('[BaggageApiService] POST /baggage/location (标记丢失): $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/baggage/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      debugPrint('[BaggageApiService] 响应: ${response.body}');

      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final result = map['result']?.toString().toLowerCase();
        if (result == 'success') {
          return map;
        } else {
          throw Exception(map['message']?.toString() ?? '标记失败');
        }
      } else {
        throw Exception('请求失败: ${response.statusCode}');
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
