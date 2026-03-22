import '../models/luggage.dart';

/// 模拟数据
class MockData {
  MockData._();

  // 行李模拟数据
  static List<Luggage> getLuggageList() {
    return [
      Luggage(
        id: '1',
        tagNumber: 'BA12345',
        flightNumber: 'CA1234',
        passengerName: '张三',
        weight: 20.5,
        status: LuggageStatus.inTransit,
        checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        destination: '上海',
        notes: '红色行李箱',
        latitude: 40.0799,
        longitude: 116.6031,
      ),
      Luggage(
        id: '2',
        tagNumber: 'BA67890',
        flightNumber: 'MU5678',
        passengerName: '李四',
        weight: 15.2,
        status: LuggageStatus.delivered,
        checkInTime: DateTime.now().subtract(const Duration(hours: 4)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        destination: '广州',
        notes: '蓝色背包',
        latitude: 31.1978,
        longitude: 121.8108,
      ),
      Luggage(
        id: '3',
        tagNumber: 'BA24680',
        flightNumber: 'CZ7890',
        passengerName: '王五',
        weight: 18.7,
        status: LuggageStatus.checkIn,
        checkInTime: DateTime.now().subtract(const Duration(minutes: 45)),
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
        destination: '深圳',
        notes: '黑色拉杆箱',
        latitude: 23.3964,
        longitude: 113.2986,
      ),
      Luggage(
        id: '4',
        tagNumber: 'BA13579',
        flightNumber: 'HU2468',
        passengerName: '赵六',
        weight: 22.3,
        status: LuggageStatus.arrived,
        checkInTime: DateTime.now().subtract(const Duration(hours: 6)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        destination: '成都',
        notes: '银色行李箱',
        latitude: 30.5728,
        longitude: 104.0668,
      ),
    ];
  }

  /// 地图页行李数据
  static List<Luggage> getLuggageForMap() {
    return [
      Luggage(
        id: '1',
        tagNumber: 'BA12345',
        flightNumber: 'CA1234',
        passengerName: '张三',
        weight: 20.5,
        status: LuggageStatus.inTransit,
        checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        destination: '上海',
        notes: '红色行李箱',
        latitude: 31.2304,
        longitude: 121.4737,
      ),
      Luggage(
        id: '2',
        tagNumber: 'BA67890',
        flightNumber: 'MU5678',
        passengerName: '李四',
        weight: 18.0,
        status: LuggageStatus.delivered,
        checkInTime: DateTime.now().subtract(const Duration(hours: 5)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        destination: '北京',
        notes: '蓝色行李箱',
        latitude: 39.9042,
        longitude: 116.4074,
      ),
    ];
  }

  /// 根据标签号创建行李
  static Luggage createByTagNumber(String tagNumber) {
    return Luggage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tagNumber: tagNumber,
      flightNumber: 'CA1234',
      passengerName: '旅客姓名',
      weight: 25.0,
      status: LuggageStatus.checkIn,
      checkInTime: DateTime.now(),
      lastUpdated: DateTime.now(),
      destination: '北京',
      notes: '',
    );
  }

  // 待办事项类型
  static const String todoTypeDamage = 'damage';
  static const String todoTypeOverweight = 'overweight';
  static const String todoTypeContact = 'contact';

  /// 待办事项数据
  static final List<Map<String, dynamic>> todoItems = [
    {
      'title': '行李破损登记',
      'description': '行李标签号: BA12345 需要登记破损情况',
      'icon': 'report_problem',
      'color': 0xFFF44336, // Colors.red
      'type': todoTypeDamage,
      'tagNumber': 'BA12345',
    },
    {
      'title': '行李超重处理',
      'description': '行李标签号: BA67890 需要重新称重',
      'icon': 'scale',
      'color': 0xFFFF9800, // Colors.orange
      'type': todoTypeOverweight,
      'tagNumber': 'BA67890',
    },
    {
      'title': '联系旅客',
      'description': '旅客行李无人认领，需要联系',
      'icon': 'phone',
      'color': 0xFF2196F3, // Colors.blue
      'type': todoTypeContact,
      'tagNumber': 'BA24680',
    },
    {
      'title': '行李破损登记',
      'description': '行李标签号: BA24680 需要登记破损情况',
      'icon': 'report_problem',
      'color': 0xFFF44336,
      'type': todoTypeDamage,
      'tagNumber': 'BA24680',
    },
  ];

  // 通话记录数据
  static final List<Map<String, String>> callRecords = [
    {'time': '2026-02-01 07:00', 'status': '未接通', 'description': '拨打旅客电话，无人接听'},
    {'time': '2026-02-01 06:30', 'status': '未接通', 'description': '拨打旅客电话，无人接听'},
    {'time': '2026-02-01 06:00', 'status': '未接通', 'description': '拨打旅客电话，无人接听'},
  ];

  // 操作日志数据
  static final List<Map<String, String>> luggageHistoryLogs = [
    {'operator': '系统',      'action': '创建行李记录', 'time': '2026-01-29 10:00:00', 'details': '系统自动创建'},
    {'operator': '员工001',   'action': '扫描行李',     'time': '2026-01-29 10:05:30', 'details': '通过二维码扫描'},
    {'operator': '员工002',   'action': '更新状态',   'time': '2026-01-29 10:10:20', 'details': '从 已办理托运 改为 运输中'},
    {'operator': '员工002',   'action': '上传照片',   'time': '2026-01-29 10:15:45', 'details': '上传了2张行李照片'},
    {'operator': '系统',      'action': '位置更新',   'time': '2026-01-29 11:00:00', 'details': '自动更新位置信息'},
    {'operator': '员工003',   'action': '更新状态',   'time': '2026-01-29 12:30:15', 'details': '从 运输中 改为 已到达'},
  ];
}
