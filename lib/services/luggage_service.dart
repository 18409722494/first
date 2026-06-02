import 'package:collection/collection.dart';
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

  factory ScanResult.success(Luggage luggage) =>
      ScanResult._(success: true, luggage: luggage);
  factory ScanResult.failure(String message) =>
      ScanResult._(success: false, errorMessage: message);
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
    bool forceRefresh = false,
  }) async {
    final result = await BaggageApiService.getAllBaggage(
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
    );

    return result;
  }

  /// 扫码解析出的可能是数据库 id，也可能是行李号 [baggageNumber]，依次尝试解析。
  /// 返回 [ScanResult] 包含成功/失败状态和详细信息
  static Future<ScanResult> getLuggageForScan(
      String luggageIdOrBaggageNumber) async {
    final key = luggageIdOrBaggageNumber.trim();
    if (key.isEmpty) {
      return ScanResult.failure('缺少行李标识');
    }

    // 方式1: 通过行李号搜索（最常用）
    try {
      final byTag = await BaggageApiService.getBaggageByNumber(key);
      if (byTag != null) {
        return ScanResult.success(byTag);
      }
    } catch (e) {
      // 忽略错误，继续尝试其他方式
    }

    // 方式2: 模糊搜索（从全部行李中查找包含关键词的）
    try {
      final result = await BaggageApiService.getAllBaggageList();
      final found = result.firstWhereOrNull(
        (item) =>
            item.tagNumber.toLowerCase().contains(key.toLowerCase()) ||
            item.id.toLowerCase().contains(key.toLowerCase()) ||
            item.passengerName.toLowerCase().contains(key.toLowerCase()),
      );
      if (found != null) {
        return ScanResult.success(found);
      }
    } catch (e) {
      // 忽略错误
    }

    final errorMsg =
        '未找到行李: $key\n\n可能原因:\n1. 行李尚未录入系统\n2. 行李标签号有误\n3. 网络连接不稳定';
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
      await BaggageApiService.updateBaggageLocation(
        baggageNumber: luggage.tagNumber,
        location: luggage.destination,
        status: BaggageStatusMapper.toBackendLocationStatus(luggage.status),
      );
      return luggage;
    } catch (e) {
      return luggage;
    }
  }

  /// 更新行李信息
  /// [luggageId] 行李 ID
  /// [patch] 要更新的字段
  static Future<Luggage> updateLuggage(
      String luggageId, Map<String, dynamic> patch) async {
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
        status:
            BaggageStatusMapper.toBackendLocationStatus(updatedLuggage.status),
      );
    } catch (e) {
      // 忽略同步错误
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

  /// 标记行李为滞留状态
  ///
  /// 调用 POST /baggage/location 直接修改数据库 status 字段为"滞留"
  static Future<bool> markAsStranded(Luggage luggage) async {
    try {
      final result = await BaggageApiService.updateBaggageLocation(
        baggageNumber: luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id,
        location: luggage.destination,
        status: '滞留',
      );
      return result['result'] == 'success' ||
          result['success'] == true ||
          result['code']?.toString() == '0' ||
          !result.containsKey('result');
    } catch (_) {
      return false;
    }
  }

  /// 获取滞留行李列表
  ///
  /// 从后端获取状态为"滞留"的行李，同时对"已到达"超时的行李自动标记为滞留
  static Future<List<Luggage>> getStrandedLuggage() async {
    final thresholdHours = AppConstants.strandedHoursThreshold;
    final result = await BaggageApiService.getAllBaggage(page: 1, pageSize: 9999);
    final now = DateTime.now();
    final threshold = now.subtract(Duration(hours: thresholdHours));

    final List<Luggage> strandedList = [];
    final List<Luggage> candidates = [];

    for (final item in result.items) {
      if (item.status == LuggageStatus.stranded) {
        strandedList.add(item);
      } else if (item.status == LuggageStatus.arrived &&
          item.lastUpdated.isBefore(threshold)) {
        candidates.add(item);
      }
    }

    // 对超时未更新的"已到达"行李，自动标记为滞留
    for (final luggage in candidates) {
      await markAsStranded(luggage);
      strandedList.add(luggage.copyWith(
        status: LuggageStatus.stranded,
        strandedAt: now,
      ));
    }

    return strandedList;
  }

  /// 获取无人认领行李列表（已到达但超过阈值小时未交付）
  /// [废弃：请使用 getStrandedLuggage]
  @Deprecated('请使用 getStrandedLuggage，本方法不再自动标记状态')
  static Future<List<Luggage>> getUnclaimedLuggage({int? hours}) async {
    final thresholdHours = hours ?? AppConstants.strandedHoursThreshold;
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
    String? resolvedEmployeeId = employeeId;
    if (resolvedEmployeeId == null || resolvedEmployeeId.isEmpty) {
      resolvedEmployeeId = await StorageService.getEmployeeId();
    }

    const maxRetries = 2;
    String? lastError;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await BaggageApiService.updateBaggageLocation(
          baggageNumber: baggageNumber,
          location: location,
          status: status,
          employeeId: resolvedEmployeeId,
        );
        return result;
      } catch (e) {
        lastError = e.toString();
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

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
      baggageNumber:
          luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id,
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
  static Future<List<AbnormalBaggage>> getAbnormalRecords(
          String baggageNumber) =>
      BaggageApiService.getAbnormalRecords(baggageNumber);

  // ─────────────────────────────────────────────
  // 详情聚合（委托给 LuggageDetailService）
  // ─────────────────────────────────────────────

  /// 优先从 /baggage/all 接口获取行李详情，同时并发拉取操作日志和破损记录。
  /// 全部失败时基于扫码 [qrPayload] 构造基础信息。
  static Future<LuggageDetailInfo> getBaggageDetail({
    required QrPayload qrPayload,
    required String rawQr,
    bool forceRefresh = false,
  }) =>
      LuggageDetailService.getBaggageDetail(
        qrPayload: qrPayload,
        rawQr: rawQr,
        forceRefresh: forceRefresh,
      );
}
