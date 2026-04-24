/// 行李操作历史日志（与后端 `POST /baggage/history/by-number` 接口对齐）
class BaggageOperationLog {
  final String operatorName;  // 操作人 employeeId
  final String action;        // 操作类型 status
  final DateTime time;        // 操作时间 createTime
  final String details;       // 详细信息 location

  const BaggageOperationLog({
    required this.operatorName,
    required this.action,
    required this.time,
    required this.details,
  });

  static DateTime? _parseTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is num) {
      if (v > 1e12) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
      return DateTime.fromMillisecondsSinceEpoch(v.toInt() * 1000);
    }
    final str = v.toString().trim();
    if (str.isEmpty) return null;

    final dt = DateTime.tryParse(str);
    if (dt != null) return dt;

    final parts = str.split(RegExp(r'[-T:\s+]'));
    if (parts.length >= 6) {
      try {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(parts[3]),
          int.parse(parts[4]),
          int.parse(parts[5].substring(0, 2)),
        );
      } catch (_) {}
    }
    return null;
  }

  static String _str(dynamic v, [String fallback = '']) {
    return v?.toString().trim() ?? fallback;
  }

  /// 解析后端 POST /baggage/history/by-number 返回的数据
  factory BaggageOperationLog.fromHistoryByNumber(Map<String, dynamic> json) {
    return BaggageOperationLog(
      operatorName: _str(json['employeeId'], '—'),
      action: _str(json['status'], '未知'),
      time: _parseTime(json['createTime']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      details: _str(json['location'], ''),
    );
  }

  /// 兼容旧格式解析
  factory BaggageOperationLog.fromJson(Map<String, dynamic> json) {
    // 优先使用 /history/by-number 格式
    if (json.containsKey('employeeId') || json.containsKey('createTime')) {
      return BaggageOperationLog(
        operatorName: _str(json['employeeId'], '—'),
        action: _str(json['status'], '未知'),
        time: _parseTime(json['createTime']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        details: _str(json['location'], ''),
      );
    }
    return BaggageOperationLog(
      operatorName: _str(
        json['operator'] ??
            json['operatorName'] ??
            json['employeeName'] ??
            json['userName'] ??
            json['createBy'] ??
            json['create_by'] ??
            json['updatedBy'] ??
            json['updated_by'] ??
            json['name'] ??
            json['user'] ??
            '—',
      ),
      action: _str(
        json['action'] ??
            json['actionType'] ??
            json['title'] ??
            json['type'] ??
            json['operateType'] ??
            json['operate_type'] ??
            json['operationType'] ??
            json['operation_type'] ??
            json['msg'] ??
            json['message'] ??
            json['status'] ??
            '',
      ),
      time: _parseTime(
            json['time'] ??
                json['timestamp'] ??
                json['createdAt'] ??
                json['created_at'] ??
                json['updatedAt'] ??
                json['updated_at'] ??
                json['operateTime'] ??
                json['operate_time'] ??
                json['createTime'] ??
                json['create_time'] ??
                json['updateTime'] ??
                json['update_time'] ??
                json['date'] ??
                json['datetime'] ??
                json['dateTime'],
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      details: _str(
        json['details'] ??
            json['description'] ??
            json['remark'] ??
            json['content'] ??
            json['remarkText'] ??
            json['remark_text'] ??
            json['info'] ??
            json['data'] ??
            json['location'] ??
            '',
      ),
    );
  }
}
