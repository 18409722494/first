/// 行李操作历史日志（与后端 `/baggage/operationLogs` 等接口对齐）
class BaggageOperationLog {
  final String operatorName;
  final String action;
  final DateTime time;
  final String details;

  const BaggageOperationLog({
    required this.operatorName,
    required this.action,
    required this.time,
    required this.details,
  });

  static DateTime? _parseTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory BaggageOperationLog.fromJson(Map<String, dynamic> json) {
    return BaggageOperationLog(
      operatorName: (json['operator'] ??
              json['operatorName'] ??
              json['employeeName'] ??
              json['userName'] ??
              '—')
          .toString(),
      action: (json['action'] ??
              json['actionType'] ??
              json['title'] ??
              json['type'] ??
              '')
          .toString(),
      time: _parseTime(
            json['time'] ??
                json['timestamp'] ??
                json['createdAt'] ??
                json['created_at'] ??
                json['operateTime'],
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      details: (json['details'] ??
              json['description'] ??
              json['remark'] ??
              json['content'] ??
              '')
          .toString(),
    );
  }
}
