import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';
import '../constants/app_constants.dart';
import '../models/abnormal_baggage.dart';
import '../models/baggage_operation_log.dart';
import '../models/luggage.dart';
import '../models/luggage_detail_info.dart';
import '../models/qr_payload.dart';
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
      rethrow;
    }
  }

  /// 行李操作历史（后端 `/baggage/operationLogs`；无数据或接口未实现时返回空列表）
  static Future<List<BaggageOperationLog>> getBaggageOperationLogs({
    String? baggageNumber,
    String? baggageId,
  }) =>
      BaggageApiService.getOperationLogs(
        baggageNumber: baggageNumber,
        baggageId: baggageId,
      );

  /// 获取指定行李的破损记录（按行李号过滤）
  static Future<List<AbnormalBaggage>> getAbnormalRecords(String baggageNumber) =>
      BaggageApiService.getAbnormalRecords(baggageNumber);

  /// 根据行李 ID 优先查接口；无数据时基于扫码 [qrPayload] 构造基础信息。
  /// 同时并发拉取操作日志和破损记录，三者聚合成 [LuggageDetailInfo]。
  /// 破损记录和操作日志拉取失败时不阻塞，只返回空列表。
  static Future<LuggageDetailInfo> getBaggageDetail({
    required QrPayload qrPayload,
    required String rawQr,
  }) async {
    final luggageId = qrPayload.luggageId?.trim() ?? '';

    // 1. 行李基础信息
    Luggage luggage;
    if (luggageId.isNotEmpty) {
      try {
        luggage = await getLuggageById(luggageId);
        luggage = _mergeApiAndQr(luggage, qrPayload);
      } catch (e) {
        luggage = _buildFromQrOnly(qrPayload, rawQr);
      }
    } else {
      luggage = _buildFromQrOnly(qrPayload, rawQr);
    }

    // 2. 并发拉取操作日志和破损记录
    final tagNo = luggage.tagNumber.trim().isNotEmpty
        ? luggage.tagNumber.trim()
        : (qrPayload.extra['tagNo']?.toString() ?? qrPayload.luggageId ?? '');
    final logFuture = getBaggageOperationLogs(
      baggageNumber: tagNo.isNotEmpty ? tagNo : null,
      baggageId: luggage.id.trim().isNotEmpty ? luggage.id.trim() : luggageId,
    );
    final abnormalFuture = tagNo.isNotEmpty
        ? getAbnormalRecords(tagNo)
        : Future.value(<AbnormalBaggage>[]);

    final results = await Future.wait(
      [logFuture, abnormalFuture],
    );
    final logs = (results[0] as List<BaggageOperationLog>)
      ..sort((a, b) => b.time.compareTo(a.time));
    final abnormalRecords = (results[1] as List<AbnormalBaggage>)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return LuggageDetailInfo(
      luggage: luggage,
      abnormalRecords: abnormalRecords,
      operationLogs: logs,
    );
  }

  static Luggage _mergeApiAndQr(Luggage api, QrPayload p) {
    final tagQr = '${p.extra['tagNo'] ?? p.extra['tag_no'] ?? p.luggageId ?? ''}';
    final passHint = '${p.extra['passenger_hint'] ?? p.extra['旅客'] ?? p.extra['passengerName'] ?? ''}';
    final flightHint = '${p.extra['flight_hint'] ?? p.extra['航班'] ?? p.extra['flightNumber'] ?? ''}';
    return api.copyWith(
      tagNumber: api.tagNumber.trim().isNotEmpty ? api.tagNumber : tagQr,
      passengerName: api.passengerName.trim().isNotEmpty ? api.passengerName : passHint,
      flightNumber: api.flightNumber.trim().isNotEmpty ? api.flightNumber : flightHint,
    );
  }

  static Luggage _buildFromQrOnly(QrPayload p, String rawQr) {
    final id = (p.luggageId != null && p.luggageId!.trim().isNotEmpty)
        ? p.luggageId!.trim()
        : (rawQr.trim().isNotEmpty ? rawQr.trim() : 'unknown');
    final tag = '${p.extra['tagNo'] ?? p.extra['tag_no'] ?? p.luggageId ?? ''}';
    final passenger = '${p.extra['passenger_hint'] ?? p.extra['旅客'] ?? p.extra['passengerName'] ?? ''}';
    final flight = '${p.extra['flight_hint'] ?? p.extra['航班'] ?? p.extra['flightNumber'] ?? ''}';
    return Luggage(
      id: id,
      tagNumber: tag,
      flightNumber: flight,
      passengerName: passenger,
      weight: 0,
      status: LuggageStatus.checkIn,
      checkInTime: DateTime.now(),
      lastUpdated: DateTime.now(),
      destination: '',
      notes: '',
    );
  }

  /// 扫码解析出的可能是数据库 id，也可能是行李号 [baggageNumber]，依次尝试解析。
  static Future<Luggage> getLuggageForScan(String luggageIdOrBaggageNumber) async {
    final key = luggageIdOrBaggageNumber.trim();
    if (key.isEmpty) {
      throw Exception('缺少行李标识');
    }
    try {
      return await getLuggageById(key);
    } catch (_) {
      final byTag = await searchByTagNumber(key);
      if (byTag != null) return byTag;
      throw Exception('未找到行李（已按ID与行李号尝试）: $key');
    }
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
      throw Exception('查询行李失败: $e');
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
      throw Exception('更新行李失败: $e');
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
      throw Exception('上传行李失败: $e');
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
      throw Exception('更新行李位置失败: $e');
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

  /// 更新行李扫码位置与状态
  ///
  /// 调用后端接口: PUT /baggage/location
  /// 请求: { baggageNumber, location, status? }（status 为后端中文，如「已达」）
  static Future<Map<String, dynamic>> updateScanLocation({
    required String baggageNumber,
    required String location,
    String? status,
  }) async {
    try {
      return await BaggageApiService.updateBaggageLocation(
        baggageNumber: baggageNumber,
        location: location,
        status: status,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 获取需要处理的超重行李列表（重量 > 免费额度）
  static Future<List<Luggage>> getOverweightLuggage() async {
    try {
      final result = await getLuggageList(page: 1, pageSize: 9999);
      return result.items
          .where((item) => item.weight > AppConstants.freeBaggageWeightKg)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取无人认领行李列表（已到达但超过 [hours] 小时未交付）
  static Future<List<Luggage>> getUnclaimedLuggage({int hours = 24}) async {
    try {
      final result = await getLuggageList(page: 1, pageSize: 9999);
      final threshold = DateTime.now().subtract(Duration(hours: hours));
      return result.items
          .where((item) =>
              item.status == LuggageStatus.arrived &&
              item.lastUpdated.isBefore(threshold))
          .toList();
    } catch (e) {
      return [];
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

  static bool _isPlausibleCoordinate(Position p) {
    final lat = p.latitude;
    final lng = p.longitude;
    if (lat.isNaN || lng.isNaN) return false;
    if (lat.abs() < 1e-7 && lng.abs() < 1e-7) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    return true;
  }

  static Duration _locationTimeoutForAccuracy(LocationAccuracy a) {
    switch (a) {
      case LocationAccuracy.lowest:
        return const Duration(seconds: 22);
      case LocationAccuracy.low:
        return const Duration(seconds: 22);
      case LocationAccuracy.medium:
        return const Duration(seconds: 14);
      default:
        return const Duration(seconds: 12);
    }
  }

  /// 获取设备当前位置（优先「能拿到」，不追求高精度）
  ///
  /// 策略：
  /// 1. [getLastKnownPosition]：7 天内缓存直接用；实时全失败后再用更旧缓存兜底
  /// 2. 实时定位顺序：**lowest → low → medium**（网络/基站优先，弱 GPS 室内更易成功）
  /// 3. 不使用 high/best，避免长时间等卫星
  static Future<Position?> getCurrentDevicePosition({
    int retryPerAccuracy = 2,
    Duration? timeout,
  }) async {
    Position? oldButPlausibleLast;

    // 1) 最近已知位置
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && _isPlausibleCoordinate(last)) {
        oldButPlausibleLast = last;
        final age = DateTime.now().difference(last.timestamp);
        if (age.inDays <= 7) {
          debugPrint(
            'getCurrentDevicePosition: 使用最近已知位置（约 ${age.inHours} 小时前，精度不限）',
          );
          return last;
        }
      }
    } catch (e) {
      debugPrint('getCurrentDevicePosition: lastKnown 失败 $e');
    }

    // 2) 实时：从最低精度到 medium
    const order = <LocationAccuracy>[
      LocationAccuracy.lowest,
      LocationAccuracy.low,
      LocationAccuracy.medium,
    ];

    for (final accuracy in order) {
      final t = timeout ?? _locationTimeoutForAccuracy(accuracy);
      for (int attempt = 0; attempt < retryPerAccuracy; attempt++) {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: accuracy,
            timeLimit: t,
          );
          if (_isPlausibleCoordinate(position)) {
            debugPrint(
              'getCurrentDevicePosition: 实时成功 accuracy=$accuracy 第${attempt + 1}次',
            );
            return position;
          }
        } catch (e) {
          debugPrint(
            'getCurrentDevicePosition: accuracy=$accuracy 第${attempt + 1}次失败 $e',
          );
          if (attempt < retryPerAccuracy - 1) {
            await Future.delayed(const Duration(milliseconds: 700));
          }
        }
      }
    }

    // 3) 兜底：超过 7 天的 lastKnown 仍优于无坐标
    if (oldButPlausibleLast != null) {
      debugPrint('getCurrentDevicePosition: 使用较旧的缓存位置作为兜底');
      return oldButPlausibleLast;
    }

    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && _isPlausibleCoordinate(last)) {
        return last;
      }
    } catch (_) {}

    debugPrint('getCurrentDevicePosition: 所有策略均失败，返回 null');
    return null;
  }

  /// 检查 GPS 服务是否启用
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}

