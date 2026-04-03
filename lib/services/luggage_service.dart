import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';
import '../models/luggage.dart';
import '../data/mock_data.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'baggage_api_service.dart';

/// 行李服务
class LuggageService {
  /// 获取会话 Token（后端不需要认证时返回空字符串）
  static Future<String> _sessionToken() async {
    if (!await StorageService.isLoggedIn()) {
      return '';
    }
    return (await StorageService.getToken()) ?? '';
  }

  /// 获取行李列表（分页）
  /// [page] 从 1 开始；[pageSize] 每页条数
  static Future<PagedResult<Luggage>> getLuggageList({
    String? ownerId,
    int page = 1,
    int pageSize = 20,
  }) async {
    // 优先使用后端 API 分页
    try {
      final result = await BaggageApiService.getAllBaggage(
        page: page,
        pageSize: pageSize,
      );
      if (result.items.isNotEmpty) {
        return result;
      }
    } catch (_) {}

    // 原有 API 或 Mock 数据
    try {
      final token = await _sessionToken();
      final endpoint = ownerId != null
          ? '/luggage?ownerId=$ownerId&page=$page&pageSize=$pageSize'
          : '/luggage?page=$page&pageSize=$pageSize';

      final http.Response res = await ApiService.authenticatedRequest(
        'GET', endpoint, null, token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final list = (data is Map<String, dynamic> && data['data'] is List)
            ? (data['data'] as List)
            : (data is List ? data : []);

        final items = list.map((item) => Luggage.fromJson(item as Map<String, dynamic>)).toList();
        return PagedResult(items: items, hasMore: items.length == pageSize, page: page);
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '获取行李列表失败(${res.statusCode})');
    } catch (e) {
      // 最终回退到 Mock 分页
      return BaggageApiService.getAllBaggage(page: page, pageSize: pageSize);
    }
  }

  static List<Luggage> _getMockLuggageData() {
    return MockData.getLuggageList();
  }

  /// 获取行李详情
  static Future<Luggage> getLuggageById(String luggageId) async {
    try {
      final token = await _sessionToken();
      final http.Response res = await ApiService.authenticatedRequest(
        'GET', '/luggage/$luggageId', null, token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final payload = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
            ? (data['data'] as Map<String, dynamic>)
            : (data as Map<String, dynamic>);
        return Luggage.fromJson(payload);
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '查询行李失败(${res.statusCode})');
    } catch (e) {
      final mockData = _getMockLuggageData();
      final luggage = mockData.firstWhereOrNull((item) => item.id == luggageId);
      if (luggage == null) {
        throw Exception('未找到行李: $luggageId');
      }
      return luggage;
    }
  }

  /// 更新行李信息
  static Future<Luggage> updateLuggage(String luggageId, Map<String, dynamic> patch) async {
    try {
      final token = await _sessionToken();
      final http.Response res = await ApiService.authenticatedRequest(
        'PUT', '/luggage/$luggageId', patch, token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final payload = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
            ? (data['data'] as Map<String, dynamic>)
            : (data as Map<String, dynamic>);
        return Luggage.fromJson(payload);
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '更新行李失败(${res.statusCode})');
    } catch (e) {
      final mockData = _getMockLuggageData();
      final mockLuggage = mockData.firstWhereOrNull((item) => item.id == luggageId);
      if (mockLuggage == null) {
        throw Exception('未找到行李: $luggageId');
      }

      var luggage = mockLuggage;
      if (patch.containsKey('status')) {
        try {
          final statusStr = patch['status'] as String;
          final status = LuggageStatus.values.firstWhere(
            (s) => s.toString().split('.').last == statusStr,
          );
          luggage = luggage.copyWith(status: status);
        } catch (_) {}
      }
      if (patch.containsKey('destination')) luggage = luggage.copyWith(destination: patch['destination']);
      if (patch.containsKey('latitude')) luggage = luggage.copyWith(latitude: patch['latitude']);
      if (patch.containsKey('longitude')) luggage = luggage.copyWith(longitude: patch['longitude']);
      if (patch.containsKey('notes')) luggage = luggage.copyWith(notes: patch['notes']);
      return luggage.copyWith(lastUpdated: DateTime.now());
    }
  }

  /// 上传行李信息
  static Future<Luggage> uploadLuggage(Map<String, dynamic> payload) async {
    try {
      final token = await _sessionToken();
      final http.Response res = await ApiService.authenticatedRequest(
        'POST', '/luggage', payload, token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final obj = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
            ? (data['data'] as Map<String, dynamic>)
            : (data as Map<String, dynamic>);
        return Luggage.fromJson(obj);
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '上传行李失败(${res.statusCode})');
    } catch (e) {
      LuggageStatus status = LuggageStatus.checkIn;
      final statusStr = payload['status']?.toString() ?? '';
      if (statusStr.isNotEmpty) {
        final found = LuggageStatus.values.firstWhereOrNull(
          (s) => s.toString().split('.').last == statusStr,
        );
        if (found != null) status = found;
      }

      final mockLuggage = Luggage(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        tagNumber: payload['tagNumber']?.toString() ?? payload['tagNo']?.toString() ?? 'TAG${DateTime.now().millisecondsSinceEpoch}',
        flightNumber: payload['flightNumber']?.toString() ?? '',
        passengerName: payload['passengerName']?.toString() ?? '未知用户',
        weight: payload['weight'] ?? payload['weightKg'] ?? 20.0,
        status: status,
        checkInTime: DateTime.now(),
        lastUpdated: DateTime.now(),
        destination: payload['destination']?.toString() ?? payload['location']?.toString() ?? '未知位置',
        notes: payload['notes']?.toString() ?? payload['note']?.toString() ?? '',
        latitude: payload['latitude'] ?? 39.9042,
        longitude: payload['longitude'] ?? 116.4074,
      );
      return mockLuggage;
    }
  }

  /// 更新行李位置
  static Future<Luggage> updateLuggageLocation({
    required String luggageId,
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    try {
      final token = await _sessionToken();
      final payload = {
        'latitude': latitude,
        'longitude': longitude,
        if (locationName != null) 'location': locationName,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final http.Response res = await ApiService.authenticatedRequest(
        'PUT', '/luggage/$luggageId', payload, token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final obj = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
            ? (data['data'] as Map<String, dynamic>)
            : (data as Map<String, dynamic>);
        return Luggage.fromJson(obj);
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '更新行李位置失败(${res.statusCode})');
    } catch (e) {
      final mockData = _getMockLuggageData();
      var luggage = mockData.firstWhereOrNull((item) => item.id == luggageId);
      if (luggage == null) {
        throw Exception('未找到行李: $luggageId');
      }
      return luggage.copyWith(
        latitude: latitude,
        longitude: longitude,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// 添加行李
  static Future<Luggage> addLuggage(Luggage luggage) async {
    try {
      final token = await _sessionToken();
      final payload = luggage.toJson();

      final http.Response res = await ApiService.authenticatedRequest(
        'POST', '/luggage', payload, token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final obj = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
            ? (data['data'] as Map<String, dynamic>)
            : (data as Map<String, dynamic>);
        return Luggage.fromJson(obj);
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '添加行李失败(${res.statusCode})');
    } catch (e) {
      return luggage;
    }
  }

  /// 通过标签号搜索行李（调用后端 API）
  static Future<Luggage?> searchByTagNumber(String tagNumber) async {
    try {
      // 优先使用后端 API
      return await BaggageApiService.getBaggageByNumber(tagNumber);
    } catch (_) {
      // 回退到本地搜索（分页第一页即可）
      final result = await getLuggageList(page: 1, pageSize: 999);
      return result.items.firstWhereOrNull(
        (item) => item.tagNumber == tagNumber || item.tagNumber.contains(tagNumber),
      );
    }
  }

  /// 根据航班号获取行李列表
  static Future<List<Luggage>> getByFlightNumber(String flightNumber) async {
    try {
      return await BaggageApiService.getBaggageByFlight(flightNumber);
    } catch (_) {
      final result = await getLuggageList(page: 1, pageSize: 999);
      return result.items.where((item) => item.flightNumber == flightNumber).toList();
    }
  }

  /// 根据乘客名获取行李列表
  static Future<List<Luggage>> getByPassengerName(String passengerName) async {
    try {
      return await BaggageApiService.getBaggageByPassenger(passengerName);
    } catch (_) {
      final result = await getLuggageList(page: 1, pageSize: 999);
      return result.items.where((item) => item.passengerName == passengerName).toList();
    }
  }

  /// 获取今日统计数据
  static Future<Map<String, int>> getTodayStats() async {
    try {
      return await BaggageApiService.getTodayStatistics();
    } catch (_) {
      return {
        'todayProcessed': 0,
        'abnormal': 0,
      };
    }
  }

  /// 获取按航班分组的行李
  static Future<Map<String, List<Luggage>>> getGroupedByFlight() async {
    try {
      return await BaggageApiService.getBaggageGroupedByFlight();
    } catch (_) {
      final result = await getLuggageList(page: 1, pageSize: 999);
      final Map<String, List<Luggage>> grouped = {};
      for (final luggage in result.items) {
        final flight = luggage.flightNumber;
        grouped.putIfAbsent(flight, () => []).add(luggage);
      }
      return grouped;
    }
  }

  /// 更新行李扫码位置
  ///
  /// 调用后端接口: PUT /baggage/location
  /// 请求: { baggageNumber, location }
  /// 返回: { baggageNumber, location }
  static Future<Map<String, dynamic>> updateScanLocation({
    required String baggageNumber,
    required String location,
  }) async {
    try {
      return await BaggageApiService.updateBaggageLocation(
        baggageNumber: baggageNumber,
        location: location,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== GPS 位置获取辅助 ====================

  /// 检查并请求位置权限
  static Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// 获取设备当前位置
  ///
  /// [retryCount] 重试次数，默认3次
  /// [timeout] 每次获取超时时间，默认10秒
  /// 返回 Position 或 null（获取失败时）
  static Future<Position?> getCurrentDevicePosition({
    int retryCount = 3,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    for (int i = 0; i < retryCount; i++) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: timeout,
        );
        return position;
      } catch (_) {
        if (i < retryCount - 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    return null;
  }

  /// 检查 GPS 服务是否启用
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}

