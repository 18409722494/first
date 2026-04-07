import 'abnormal_baggage.dart';
import 'baggage_operation_log.dart';
import 'luggage.dart';

/// 行李完整详情（详情页多接口聚合用）
/// 聚合：基础信息 + 破损记录列表 + 操作日志列表
class LuggageDetailInfo {
  /// 行李基础信息（来自 GET /baggage/all 或 POST /baggage/upload）
  final Luggage luggage;

  /// 关联的破损记录（来自 GET /abnormal-baggage/all，按行李号过滤）
  final List<AbnormalBaggage> abnormalRecords;

  /// 操作历史（来自 GET /baggage/operationLogs）
  final List<BaggageOperationLog> operationLogs;

  const LuggageDetailInfo({
    required this.luggage,
    required this.abnormalRecords,
    required this.operationLogs,
  });
}
