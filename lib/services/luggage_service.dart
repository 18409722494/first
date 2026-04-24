import 'dart:convert';
import 'package:http/http.dart' as http;
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
import 'location_service.dart';
import 'luggage_detail_service.dart';
import 'package:flutter/foundation.dart';

/// 扫码结果包装器
class ScanResult {
  final bool success;
  final String? errorMessage;
  final Luggage? luggage;

  const ScanResult._({required this.success, this.errorMessage, this.luggage});

  factory ScanResult.success(Luggage luggage) => ScanResult._(success: true, luggage: luggage);
  factory ScanResult.failure(String message) => ScanResult._(success: false, errorMessage: message);
}

/// 行李核心服务
///
/// 提供行李基础 CRUD 操作：
/// - 列表查询（分页）
/// - 单条查询
/// - 添加/更新/删除
/// - 搜索和筛选
///
/// GPS 相关功能 → [LocationService]
/// 详情聚合查询 → [LuggageDetailService]
class LuggageService {
  /// 获取会话 Token（后端不需要认证时返回空字符串）
  static Future<String> _sessionToken() async {
    if (!await StorageService.isLoggedIn()) {
      return '';
    }
    return (await StorageService.getToken()) ?? '';
  }

  // ─────────────────────────────────────────────
  // 基础 CRUD
  // ─────────────────────────────────────────────

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

  /// 扫码解析出的可能是数据库 id，也可能是行李号 [baggageNumber]，依次尝试解析。
  /// 返回 [ScanResult] 包含成功/失败状态和详细信息
  static Future<ScanResult> getLuggageForScan(String luggageIdOrBaggageNumber) async {
    final key = luggageIdOrBaggageNumber.trim();
    if (key.isEmpty) {
      return ScanResult.failure('缺少行李标识');
    }

    debugPrint('[LuggageService] 扫码查询行李: $key');

    // 方式1: 通过 ID 查询
    try {
      debugPrint('[LuggageService] 方式1: 通过ID查询 $key');
      final luggage = await getLuggageById(key);
      debugPrint('[LuggageService] ID查询成功: ${luggage.tagNumber}');
      return ScanResult.success(luggage);
    } catch (e) {
      debugPrint('[LuggageService] ID查询失败: $e');
    }

    // 方式2: 通过行李号搜索（调用后端 API）
    try {
      debugPrint('[LuggageService] 方式2: 通过行李号搜索 $key');
      final byTag = await searchByTagNumber(key);
      if (byTag != null) {
        debugPrint('[LuggageService] 行李号搜索成功: ${byTag.tagNumber}');
        return ScanResult.success(byTag);
      }
    } catch (e) {
      debugPrint('[LuggageService] 行李号搜索失败: $e');
    }

    // 方式3: 模糊搜索（从全部行李中查找包含关键词的）
    try {
      debugPrint('[LuggageService] 方式3: 模糊搜索 $key');
      final result = await BaggageApiService.getAllBaggageList();
      final found = result.firstWhereOrNull(
        (item) =>
            item.tagNumber.toLowerCase().contains(key.toLowerCase()) ||
            item.id.toLowerCase().contains(key.toLowerCase()) ||
            item.passengerName.toLowerCase().contains(key.toLowerCase()),
      );
      if (found != null) {
        debugPrint('[LuggageService] 模糊搜索成功: ${found.tagNumber}');
        return ScanResult.success(found);
      }
    } catch (e) {
      debugPrint('[LuggageService] 模糊搜索失败: $e');
    }

    final errorMsg = '未找到行李: $key\n\n可能原因:\n1. 行李尚未录入系统\n2. 行李标签号有误\n3. 网络连接不稳定';
    debugPrint('[LuggageService] 所有查询方式均失败: $errorMsg');
    return ScanResult.failure(errorMsg);
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

  // ─────────────────────────────────────────────
  // 搜索与筛选
  // ─────────────────────────────────────────────

  /// 通过标签号搜索行李（调用后端 API）
  static Future<Luggage?> searchByTagNumber(String tagNumber) async {
    try {
      return await BaggageApiService.getBaggageByNumber(tagNumber);
    } catch (_) {
      // 回退到本地搜索
      final result = await getLuggageList(page: 1, pageSize: 100);
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
      final result = await getLuggageList(page: 1, pageSize: 100);
      return result.items.where((item) => item.flightNumber == flightNumber).toList();
    }
  }

  /// 根据乘客名获取行李列表
  static Future<List<Luggage>> getByPassengerName(String passengerName) async {
    try {
      return await BaggageApiService.getBaggageByPassenger(passengerName);
    } catch (_) {
      final result = await getLuggageList(page: 1, pageSize: 100);
      return result.items.where((item) => item.passengerName == passengerName).toList();
    }
  }

  /// 获取按航班分组的行李
  static Future<Map<String, List<Luggage>>> getGroupedByFlight() async {
    try {
      return await BaggageApiService.getBaggageGroupedByFlight();
    } catch (_) {
      final result = await getLuggageList(page: 1, pageSize: 100);
      final Map<String, List<Luggage>> grouped = {};
      for (final luggage in result.items) {
        final flight = luggage.flightNumber;
        grouped.putIfAbsent(flight, () => []).add(luggage);
      }
      return grouped;
    }
  }

  // ─────────────────────────────────────────────
  // 统计与待办
  // ─────────────────────────────────────────────

  /// 获取今日统计数据
  static Future<Map<String, int>> getTodayStats() async {
    try {
      return await BaggageApiService.getTodayStatistics();
    } catch (_) {
      return {'todayProcessed': 0, 'abnormal': 0};
    }
  }

  /// 获取需要处理的超重行李列表（重量 > 免费额度）
  static Future<List<Luggage>> getOverweightLuggage() async {
    try {
      final result = await getLuggageList(page: 1, pageSize: 100);
      return result.items
          .where((item) => item.weight > AppConstants.freeBaggageWeightKg)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取无人认领行李列表（已到达但超过 [hours] 小时未交付）
  static Future<List<Luggage>> getUnclaimedLuggage({int? hours}) async {
    final thresholdHours = hours ?? AppConstants.unclaimedHoursThreshold;
    try {
      final result = await getLuggageList(page: 1, pageSize: 100);
      final threshold = DateTime.now().subtract(Duration(hours: thresholdHours));
      return result.items
          .where((item) =>
              item.status == LuggageStatus.arrived &&
              item.lastUpdated.isBefore(threshold))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // 位置更新
  // ─────────────────────────────────────────────

  /// 更新行李位置（使用旧 API）
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

  /// 更新行李扫码位置与状态（POST /baggage/location）
  ///
  /// 请求: { baggageNumber, location, status?, employeeId }
  /// 注意：操作日志由后端自动记录（通过外键关联），无需前端手动记录
  /// 带有重试机制和详细错误提示
  /// [employeeId] 如果不传，将自动从本地存储读取
  static Future<Map<String, dynamic>> updateScanLocation({
    required String baggageNumber,
    required String location,
    String? status,
    String? employeeId,
  }) async {
    debugPrint('[LuggageService] 更新行李位置: baggageNumber=$baggageNumber, location=$location');

    // 如果没有传入 employeeId，从本地存储读取
    String? resolvedEmployeeId = employeeId;
    if (resolvedEmployeeId == null || resolvedEmployeeId.isEmpty) {
      resolvedEmployeeId = await StorageService.getEmployeeId();
      debugPrint('[LuggageService] 从本地读取员工工号: $resolvedEmployeeId');
    }

    // 尝试更新位置（最多重试2次）
    const maxRetries = 2;
    String? lastError;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('[LuggageService] 位置更新第$attempt次尝试');
        final result = await BaggageApiService.updateBaggageLocation(
          baggageNumber: baggageNumber,
          location: location,
          status: status,
          employeeId: resolvedEmployeeId,
        );
        debugPrint('[LuggageService] 位置更新成功: $result');
        return result;
      } catch (e) {
        lastError = e.toString();
        debugPrint('[LuggageService] 位置更新第$attempt次失败: $e');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    // 所有重试都失败
    debugPrint('[LuggageService] 位置更新全部失败，最后错误: $lastError');
    throw Exception('更新行李位置失败: $lastError\n\n请检查:\n1. 网络连接是否正常\n2. 后端服务是否可用');
  }

  /// 通过行李号获取操作历史（调用 POST /baggage/history/by-number）
  static Future<List<BaggageOperationLog>> getOperationHistoryByNumber(
    String baggageNumber,
  ) async {
    return BaggageApiService.getOperationHistoryByNumber(baggageNumber);
  }

  /// 主动记录操作日志（供外部调用）
  /// 用于扫码确认、手动更新等场景
  static Future<bool> recordOperation({
    required String baggageNumber,
    required String action,
    String? location,
    String? employeeId,
    String? details,
    String? phone,
  }) async {
    try {
      return await BaggageApiService.addOperationLog(
        baggageNumber: baggageNumber,
        phone: phone ?? '',
        action: action,
        location: location,
        employeeId: employeeId,
        details: details,
      );
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // 操作日志
  // ─────────────────────────────────────────────

  /// 行李操作历史（后端 `/baggage/operationLogs`）
  static Future<List<BaggageOperationLog>> getBaggageOperationLogs({
    String? baggageNumber,
    String? baggageId,
  }) =>
      BaggageApiService.getOperationLogs(
        baggageNumber: baggageNumber,
        baggageId: baggageId,
      );

  /// 获取行李操作历史（POST /baggage/history）
  static Future<List<BaggageOperationLog>> getBaggageOperationHistory({
    required String baggageNumber,
    required String phone,
  }) =>
      BaggageApiService.getOperationHistory(
        baggageNumber: baggageNumber,
        phone: phone,
      );

  /// 写入操作日志（扫码时调用）
  static Future<bool> addScanOperationLog({
    required Luggage luggage,
    required String action,
    String? location,
    String? employeeId,
    String? details,
  }) async {
    final phone = luggage.contact?.trim();
    if (phone == null || phone.isEmpty) {
      return false;
    }
    return BaggageApiService.addOperationLog(
      baggageNumber: luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id,
      phone: phone,
      action: action,
      location: location,
      employeeId: employeeId,
      details: details,
    );
  }

  // ─────────────────────────────────────────────
  // 破损记录（委托给 BaggageApiService）
  // ─────────────────────────────────────────────

  /// 获取指定行李的破损记录（按行李号过滤）
  static Future<List<AbnormalBaggage>> getAbnormalRecords(String baggageNumber) =>
      BaggageApiService.getAbnormalRecords(baggageNumber);

  // ─────────────────────────────────────────────
  // 详情聚合（委托给 LuggageDetailService）
  // ─────────────────────────────────────────────

  /// 优先从 /baggage/all 接口获取行李详情，同时并发拉取操作日志和破损记录。
  /// 全部失败时基于扫码 [qrPayload] 构造基础信息。
  static Future<LuggageDetailInfo> getBaggageDetail({
    required QrPayload qrPayload,
    required String rawQr,
  }) =>
      LuggageDetailService.getBaggageDetail(
        qrPayload: qrPayload,
        rawQr: rawQr,
      );
}
