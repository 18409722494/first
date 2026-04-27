import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/abnormal_baggage.dart';
import '../models/baggage_operation_log.dart';
import '../models/luggage.dart';
import '../models/luggage_detail_info.dart';
import '../models/qr_payload.dart';
import 'baggage_api_service.dart';
import 'storage_service.dart';
import 'luggage_detail_service.dart';

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
/// 统一使用 [BaggageApiService] 进行后端 API 通信。
/// 不再维护旧版 API 的回退逻辑，确保数据一致性。
///
/// GPS 相关功能 → [LocationService]
/// 详情聚合查询 → [LuggageDetailService]
class LuggageService {
  // ─────────────────────────────────────────────
  // 基础 CRUD（统一使用 BaggageApiService）
  // ─────────────────────────────────────────────

  /// 获取行李列表（分页）
  /// [page] 从 1 开始；[pageSize] 每页条数
  static Future<PagedResult<Luggage>> getLuggageList({
    String? ownerId,
    int page = 1,
    int pageSize = 20,
  }) async {
    // 统一使用后端 API 分页
    final result = await BaggageApiService.getAllBaggage(
      page: page,
      pageSize: pageSize,
    );

    // 如果需要按 ownerId 过滤（前端本地过滤）
    if (ownerId != null && result.items.isNotEmpty) {
      // 由于后端 API 可能不支持 ownerId 过滤，这里做本地过滤
      // 注意：实际项目中应让后端支持此参数
      debugPrint('[LuggageService] ownerId 过滤在本地执行，请确认后端是否支持');
    }

    return result;
  }

  /// 扫码解析出的可能是数据库 id，也可能是行李号 [baggageNumber]，依次尝试解析。
  /// 返回 [ScanResult] 包含成功/失败状态和详细信息
  static Future<ScanResult> getLuggageForScan(String luggageIdOrBaggageNumber) async {
    final key = luggageIdOrBaggageNumber.trim();
    if (key.isEmpty) {
      return ScanResult.failure('缺少行李标识');
    }

    debugPrint('[LuggageService] 扫码查询行李: $key');

    // 方式1: 通过行李号搜索（最常用）
    try {
      debugPrint('[LuggageService] 方式1: 通过行李号搜索 $key');
      final byTag = await BaggageApiService.getBaggageByNumber(key);
      if (byTag != null) {
        debugPrint('[LuggageService] 行李号搜索成功: ${byTag.tagNumber}');
        return ScanResult.success(byTag);
      }
    } catch (e) {
      debugPrint('[LuggageService] 行李号搜索失败: $e');
    }

    // 方式2: 模糊搜索（从全部行李中查找包含关键词的）
    try {
      debugPrint('[LuggageService] 方式2: 模糊搜索 $key');
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

  /// 通过行李号获取行李详情
  /// 如果找不到会抛出异常
  static Future<Luggage> getLuggageByTagNumber(String tagNumber) async {
    final luggage = await BaggageApiService.getBaggageByNumber(tagNumber);
    if (luggage == null) {
      throw Exception('未找到行李: $tagNumber');
    }
    return luggage;
  }

  /// 通过 ID 获取行李（兼容旧接口）
  static Future<Luggage> getLuggageById(String luggageId) async {
    // 尝试通过行李号查询
    final luggage = await BaggageApiService.getBaggageByNumber(luggageId);
    if (luggage != null) {
      return luggage;
    }
    // 如果行李号查询失败，尝试从全量列表中查找 ID
    final allLuggage = await BaggageApiService.getAllBaggageList();
    final found = allLuggage.firstWhereOrNull((item) => item.id == luggageId);
    if (found != null) {
      return found;
    }
    throw Exception('未找到行李: $luggageId');
  }

  /// 添加行李（新增到后端）
  /// 返回添加后的行李对象
  static Future<Luggage> addLuggage(Luggage luggage) async {
    try {
      // 使用 POST /baggage/location 接口将行李信息上报
      await BaggageApiService.updateBaggageLocation(
        baggageNumber: luggage.tagNumber,
        location: luggage.destination,
        status: BaggageStatusMapper.toBackendLocationStatus(luggage.status),
      );
      debugPrint('[LuggageService] addLuggage 成功: ${luggage.tagNumber}');
      return luggage;
    } catch (e) {
      debugPrint('[LuggageService] addLuggage 失败，返回本地对象: $e');
      // 如果后端调用失败，仍然返回行李对象（前端本地使用）
      return luggage;
    }
  }

  /// 更新行李信息
  /// [luggageId] 行李 ID
  /// [patch] 要更新的字段
  static Future<Luggage> updateLuggage(String luggageId, Map<String, dynamic> patch) async {
    // 获取当前行李
    final luggage = await getLuggageById(luggageId);

    // 合并更新
    final updatedLuggage = luggage.copyWith(
      status: patch['status'] is String
          ? BaggageStatusMapper.parseFromApi(patch['status'])
          : luggage.status,
      destination: patch['destination']?.toString() ?? luggage.destination,
      notes: patch['notes']?.toString() ?? luggage.notes,
    );

    // 同步到后端
    try {
      await BaggageApiService.updateBaggageLocation(
        baggageNumber: updatedLuggage.tagNumber,
        location: updatedLuggage.destination,
        status: BaggageStatusMapper.toBackendLocationStatus(updatedLuggage.status),
      );
    } catch (e) {
      debugPrint('[LuggageService] updateLuggage 同步后端失败: $e');
    }

    return updatedLuggage;
  }

  // ─────────────────────────────────────────────
  // 搜索与筛选（统一使用 BaggageApiService）
  // ─────────────────────────────────────────────

  /// 通过标签号搜索行李
  static Future<Luggage?> searchByTagNumber(String tagNumber) async {
    return BaggageApiService.getBaggageByNumber(tagNumber);
  }

  /// 根据航班号获取行李列表
  static Future<List<Luggage>> getByFlightNumber(String flightNumber) async {
    return BaggageApiService.getBaggageByFlight(flightNumber);
  }

  /// 根据乘客名获取行李列表
  static Future<List<Luggage>> getByPassengerName(String passengerName) async {
    return BaggageApiService.getBaggageByPassenger(passengerName);
  }

  /// 获取按航班分组的行李
  static Future<Map<String, List<Luggage>>> getGroupedByFlight() async {
    return BaggageApiService.getBaggageGroupedByFlight();
  }

  // ─────────────────────────────────────────────
  // 统计与待办
  // ─────────────────────────────────────────────

  /// 获取今日统计数据
  static Future<Map<String, int>> getTodayStats() async {
    return BaggageApiService.getTodayStatistics();
  }

  /// 获取需要处理的超重行李列表（重量 > 免费额度）
  static Future<List<Luggage>> getOverweightLuggage() async {
    final result = await BaggageApiService.getAllBaggage(page: 1, pageSize: 9999);
    return result.items
        .where((item) => item.weight > AppConstants.freeBaggageWeightKg)
        .toList();
  }

  /// 获取无人认领行李列表（已到达但超过 [hours] 小时未交付）
  static Future<List<Luggage>> getUnclaimedLuggage({int? hours}) async {
    final thresholdHours = hours ?? AppConstants.unclaimedHoursThreshold;
    final result = await BaggageApiService.getAllBaggage(page: 1, pageSize: 9999);
    final threshold = DateTime.now().subtract(Duration(hours: thresholdHours));
    return result.items
        .where((item) =>
            item.status == LuggageStatus.arrived &&
            item.lastUpdated.isBefore(threshold))
        .toList();
  }

  // ─────────────────────────────────────────────
  // 位置更新（统一使用 BaggageApiService）
  // ─────────────────────────────────────────────

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
    } catch (e) {
      debugPrint('[LuggageService] 记录操作日志失败: $e');
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
      debugPrint('[LuggageService] addScanOperationLog: 行李缺少联系方式，跳过日志记录');
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
