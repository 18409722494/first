import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/luggage.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// 行李相关API服务
/// 封装所有与行李相关的后端API调用
/// 注意：请根据实际后端API路径调整endpoint
class LuggageService {
  /// 获取认证令牌的私有方法
  /// 如果token不存在或为空，抛出异常
  /// 返回有效的认证令牌
  static Future<String> _requireToken() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('未登录或token缺失');
    }
    return token;
  }

  /// 获取用户的行李列表
  /// [ownerId] 行李所有者ID（可选），如果提供则只获取该用户的行李
  /// 返回行李列表，如果失败则使用模拟数据
  static Future<List<Luggage>> getLuggageList({String? ownerId}) async {
    try {
      final token = await _requireToken();
      final endpoint = ownerId != null 
          ? '/luggage?ownerId=$ownerId' 
          : '/luggage';
      
      final http.Response res = await ApiService.authenticatedRequest(
        'GET',
        endpoint,
        null,
        token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // 兼容：{data:[...]} 或直接 [...]
        final list = (data is Map<String, dynamic> && data['data'] is List)
            ? (data['data'] as List)
            : (data is List ? data : []);
        
        return list.map((item) => Luggage.fromJson(item as Map<String, dynamic>)).toList();
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '获取行李列表失败(${res.statusCode})');
    } catch (e) {
      // API调用失败，返回模拟数据
      return _getMockLuggageData();
    }
  }

  /// 获取模拟行李数据
  /// 当API调用失败时使用此方法
  /// 返回模拟的行李列表
  static List<Luggage> _getMockLuggageData() {
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

  /// 根据ID查询行李详情
  /// [luggageId] 行李的唯一标识符
  /// 返回Luggage对象，如果失败则使用模拟数据
  static Future<Luggage> getLuggageById(String luggageId) async {
    try {
      final token = await _requireToken();
      final http.Response res = await ApiService.authenticatedRequest(
        'GET',
        '/luggage/$luggageId',
        null,
        token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // 兼容：{data:{...}} 或直接 {...}
        final payload = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
            ? (data['data'] as Map<String, dynamic>)
            : (data as Map<String, dynamic>);
        return Luggage.fromJson(payload);
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '查询行李失败(${res.statusCode})');
    } catch (e) {
      // API调用失败，返回模拟数据
      final mockData = _getMockLuggageData();
      // 尝试根据ID找到对应的行李，如果找不到则返回第一个
      final luggage = mockData.firstWhere(
        (item) => item.id == luggageId,
        orElse: () => mockData[0],
      );
      return luggage;
    }
  }

  /// 更新行李信息
  /// 可以更新行李的状态、位置、备注等信息
  /// [luggageId] 要更新的行李ID
  /// [patch] 包含要更新字段的Map（例如：status、location、note等）
  /// 返回更新后的Luggage对象，如果失败则使用模拟数据
  static Future<Luggage> updateLuggage(String luggageId, Map<String, dynamic> patch) async {
    try {
      final token = await _requireToken();
      final http.Response res = await ApiService.authenticatedRequest(
        'PUT',
        '/luggage/$luggageId',
        patch,
        token,
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
      // API调用失败，返回模拟数据
      final mockData = _getMockLuggageData();
      // 尝试根据ID找到对应的行李，如果找不到则返回第一个
      var luggage = mockData.firstWhere(
        (item) => item.id == luggageId,
        orElse: () => mockData[0],
      );
      // 应用更新字段
      if (patch.containsKey('status')) {
        try {
          final statusStr = patch['status'] as String;
          final status = LuggageStatus.values.firstWhere(
            (s) => s.toString().split('.').last == statusStr,
          );
          luggage = luggage.copyWith(status: status);
        } catch (e) {
          // 如果转换失败，保持原有状态
        }
      }
      if (patch.containsKey('destination')) luggage = luggage.copyWith(destination: patch['destination']);
      if (patch.containsKey('latitude')) luggage = luggage.copyWith(latitude: patch['latitude']);
      if (patch.containsKey('longitude')) luggage = luggage.copyWith(longitude: patch['longitude']);
      if (patch.containsKey('notes')) luggage = luggage.copyWith(notes: patch['notes']);
      return luggage.copyWith(lastUpdated: DateTime.now());
    }
  }

  /// 上传/补录行李信息
  /// 用于创建新的行李记录或补录已有行李的信息
  /// 注意：请根据后端实际要求调整endpoint路径
  /// [payload] 包含行李信息的Map（例如：ownerId、status、location、tagNo等）
  /// 返回创建/更新后的Luggage对象，如果失败则使用模拟数据
  static Future<Luggage> uploadLuggage(Map<String, dynamic> payload) async {
    try {
      final token = await _requireToken();
      final http.Response res = await ApiService.authenticatedRequest(
        'POST',
        '/luggage',
        payload,
        token,
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
      // API调用失败，返回模拟数据
      // 根据payload创建模拟行李
      LuggageStatus status = LuggageStatus.checkIn;
      try {
        final statusStr = payload['status']?.toString() ?? '';
        if (statusStr.isNotEmpty) {
          status = LuggageStatus.values.firstWhere(
            (s) => s.toString().split('.').last == statusStr,
          );
        }
      } catch (e) {
        // 如果转换失败，使用默认状态
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

  /// 更新行李位置信息
  /// 用于实时更新行李的地理位置
  /// [luggageId] 行李ID
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [locationName] 位置名称（可选）
  /// 返回更新后的Luggage对象，如果失败则使用模拟数据
  static Future<Luggage> updateLuggageLocation({
    required String luggageId,
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    try {
      final token = await _requireToken();
      final payload = {
        'latitude': latitude,
        'longitude': longitude,
        if (locationName != null) 'location': locationName,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final http.Response res = await ApiService.authenticatedRequest(
        'PUT',
        '/luggage/$luggageId',
        payload,
        token,
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
      // API调用失败，返回模拟数据
      final mockData = _getMockLuggageData();
      // 尝试根据ID找到对应的行李，如果找不到则返回第一个
      var luggage = mockData.firstWhere(
        (item) => item.id == luggageId,
        orElse: () => mockData[0],
      );
      // 应用位置更新
      return luggage.copyWith(
        latitude: latitude,
        longitude: longitude,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// 添加行李
  /// 用于创建新的行李记录
  /// [luggage] 行李对象
  /// 返回创建后的Luggage对象，如果失败则使用模拟数据
  static Future<Luggage> addLuggage(Luggage luggage) async {
    try {
      final token = await _requireToken();
      final payload = luggage.toJson();

      final http.Response res = await ApiService.authenticatedRequest(
        'POST',
        '/luggage',
        payload,
        token,
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
      // API调用失败，返回模拟数据
      return luggage;
    }
  }
}

