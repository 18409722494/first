import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/luggage.dart';
import '../data/mock_data.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// 行李服务
class LuggageService {
  static Future<String> _requireToken() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('未登录或token缺失');
    }
    return token;
  }

  /// 获取行李列表
  static Future<List<Luggage>> getLuggageList({String? ownerId}) async {
    try {
      final token = await _requireToken();
      final endpoint = ownerId != null
          ? '/luggage?ownerId=$ownerId'
          : '/luggage';

      final http.Response res = await ApiService.authenticatedRequest(
        'GET', endpoint, null, token,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final list = (data is Map<String, dynamic> && data['data'] is List)
            ? (data['data'] as List)
            : (data is List ? data : []);

        return list.map((item) => Luggage.fromJson(item as Map<String, dynamic>)).toList();
      }

      final msg = (data is Map<String, dynamic>) ? (data['message']?.toString()) : null;
      throw Exception(msg ?? '获取行李列表失败(${res.statusCode})');
    } catch (e) {
      return MockData.getLuggageList();
    }
  }

  static List<Luggage> _getMockLuggageData() {
    return MockData.getLuggageList();
  }

  /// 获取行李详情
  static Future<Luggage> getLuggageById(String luggageId) async {
    try {
      final token = await _requireToken();
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
      final mockData = _getMockLuggageData();
      final luggage = mockData.firstWhere(
        (item) => item.id == luggageId,
        orElse: () => mockData[0],
      );
      return luggage;
    }
  }

  /// 更新行李信息
  static Future<Luggage> updateLuggage(String luggageId, Map<String, dynamic> patch) async {
    try {
      final token = await _requireToken();
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
      final mockData = _getMockLuggageData();
      var luggage = mockData.firstWhere(
        (item) => item.id == luggageId,
        orElse: () => mockData[0],
      );
      if (patch.containsKey('status')) {
        try {
          final statusStr = patch['status'] as String;
          final status = LuggageStatus.values.firstWhere(
            (s) => s.toString().split('.').last == statusStr,
          );
          luggage = luggage.copyWith(status: status);
        } catch (_) {}
      }
      if (patch.containsKey('destination')) luggage = luggage.copyWith(destination: patch['destination']);
      if (patch.containsKey('latitude')) luggage = luggage.copyWith(latitude: patch['latitude']);
      if (patch.containsKey('longitude')) luggage = luggage.copyWith(longitude: patch['longitude']);
      if (patch.containsKey('notes')) luggage = luggage.copyWith(notes: patch['notes']);
      return luggage.copyWith(lastUpdated: DateTime.now());
    }
  }

  /// 上传行李信息
  static Future<Luggage> uploadLuggage(Map<String, dynamic> payload) async {
    try {
      final token = await _requireToken();
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
      LuggageStatus status = LuggageStatus.checkIn;
      try {
        final statusStr = payload['status']?.toString() ?? '';
        if (statusStr.isNotEmpty) {
          status = LuggageStatus.values.firstWhere(
            (s) => s.toString().split('.').last == statusStr,
          );
        }
      } catch (_) {}

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

  /// 更新行李位置
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
      final mockData = _getMockLuggageData();
      var luggage = mockData.firstWhere(
        (item) => item.id == luggageId,
        orElse: () => mockData[0],
      );
      return luggage.copyWith(
        latitude: latitude,
        longitude: longitude,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// 添加行李
  static Future<Luggage> addLuggage(Luggage luggage) async {
    try {
      final token = await _requireToken();
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
}

