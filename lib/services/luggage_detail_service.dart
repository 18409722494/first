import 'package:flutter/foundation.dart';
import '../models/abnormal_baggage.dart';
import '../models/baggage_operation_log.dart';
import '../models/luggage.dart';
import '../models/luggage_detail_info.dart';
import '../models/qr_payload.dart';
import 'baggage_api_service.dart';
import 'luggage_service.dart';

/// 行李详情聚合服务
///
/// 负责整合多接口数据：
/// - 从 /baggage/all 获取行李基础信息
/// - 拉取破损记录
/// - 拉取操作日志
/// - 与扫码数据进行融合
class LuggageDetailService {
  /// 优先从 /baggage/all 接口获取行李详情，同时并发拉取操作日志和破损记录。
  /// 全部失败时基于扫码 [qrPayload] 构造基础信息。
  static Future<LuggageDetailInfo> getBaggageDetail({
    required QrPayload qrPayload,
    required String rawQr,
  }) async {
    // 从 QR 中提取行李号
    final tagNo = (qrPayload.extra['tagNo'] ??
            qrPayload.extra['tag_no'] ??
            qrPayload.luggageId ??
            '')
        .toString()
        .trim();

    // 1. 优先从 /baggage/all 获取行李信息
    Luggage? luggage;
    if (tagNo.isNotEmpty) {
      try {
        final found = await BaggageApiService.getBaggageByNumber(tagNo);
        if (found != null) {
          luggage = _mergeApiAndQr(found, qrPayload);
        }
      } catch (e) {
        debugPrint('[LuggageDetailService] 通过行李号获取失败: $e');
      }
    }

    // 2. 如果行李号查询失败，尝试通过 ID 查询
    if (luggage == null) {
      final luggageId = qrPayload.luggageId?.trim() ?? '';
      if (luggageId.isNotEmpty) {
        try {
          final found = await LuggageService.getLuggageById(luggageId);
          luggage = _mergeApiAndQr(found, qrPayload);
        } catch (e) {
          debugPrint('[LuggageDetailService] 通过ID获取失败: $e');
        }
      }
    }

    // 3. 完全兜底：仅用扫码数据构造
    if (luggage == null) {
      luggage = _buildFromQrOnly(qrPayload, rawQr);
    }

    // 4. 并发拉取操作日志和破损记录
    final effectiveTagNo = luggage.tagNumber.trim().isNotEmpty
        ? luggage.tagNumber.trim()
        : tagNo;

    // 使用 POST /baggage/history/by-number 获取操作历史（后端自动记录）
    List<BaggageOperationLog> logs = [];
    if (effectiveTagNo.isNotEmpty) {
      logs = await LuggageService.getOperationHistoryByNumber(effectiveTagNo);
    }

    final abnormalFuture = effectiveTagNo.isNotEmpty
        ? LuggageService.getAbnormalRecords(effectiveTagNo)
        : Future.value(<AbnormalBaggage>[]);

    final abnormalRecords = await abnormalFuture;

    logs.sort((a, b) => b.time.compareTo(a.time));
    abnormalRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return LuggageDetailInfo(
      luggage: luggage,
      abnormalRecords: abnormalRecords,
      operationLogs: logs,
    );
  }

  /// 写入扫码操作日志
  static Future<bool> addScanOperationLog({
    required Luggage luggage,
    required String action,
    String? location,
    String? employeeId,
    String? details,
  }) =>
      LuggageService.addScanOperationLog(
        luggage: luggage,
        action: action,
        location: location,
        employeeId: employeeId,
        details: details,
      );

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
    final contact = p.extra['contact']?.toString();
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
      contact: contact,
    );
  }
}
