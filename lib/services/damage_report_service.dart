import 'dart:typed_data';
import 'hash_service.dart';
import 'oss_service.dart';
import 'local_queue_service.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// 破损报告服务
class DamageReportService {
  /// 提交破损报告
  static Future<bool> submitDamageReport({
    required Uint8List imageBytes,
    required String luggageId,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required String damageDescription,
  }) async {
    try {
      // 计算哈希
      final hash = await HashService.calculateDamageEvidenceHash(
        imageBytes: imageBytes,
        luggageId: luggageId,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
      );

      // 上传图片
      final photoUrl = await OssService.uploadImage(imageBytes);

      // 构建请求
      final requestData = {
        'luggageId': luggageId.trim(),
        'timestamp': timestamp.toUtc().toIso8601String(),
        'location': "${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}",
        'hash': hash,
        'photoUrl': photoUrl,
        'damageDescription': damageDescription,
      };

      // 发送请求
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('未登录或token缺失');
      }

      final response = await ApiService.authenticatedRequest(
        'POST', '/damage-report', requestData, token,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        await _saveToLocalQueue({...requestData, 'imageBytes': imageBytes});
        return false;
      }
    } catch (e) {
      await _saveToLocalQueue({
        'luggageId': luggageId.trim(),
        'timestamp': timestamp.toUtc().toIso8601String(),
        'location': "${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}",
        'damageDescription': damageDescription,
        'imageBytes': imageBytes,
      });
      return false;
    }
  }

  /// 从本地队列提交报告
  static Future<bool> submitFromLocalQueue(Map<String, dynamic> reportData) async {
    try {
      if (!reportData.containsKey('imageBytes') || reportData['imageBytes'] == null) {
        throw Exception('报告数据缺少图片字节');
      }

      final imageBytes = reportData['imageBytes'] as Uint8List;
      final luggageId = reportData['luggageId'] as String;
      final timestamp = DateTime.parse(reportData['timestamp'] as String);
      final locationParts = (reportData['location'] as String).split(',');
      if (locationParts.length < 2) {
        throw Exception('报告数据中位置信息格式错误: ${reportData['location']}');
      }
      final latitude = double.parse(locationParts[0]);
      final longitude = double.parse(locationParts[1]);
      final damageDescription = reportData['damageDescription'] as String;

      final hash = await HashService.calculateDamageEvidenceHash(
        imageBytes: imageBytes,
        luggageId: luggageId,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
      );

      final photoUrl = await OssService.uploadImage(imageBytes);

      final requestData = {
        'luggageId': luggageId,
        'timestamp': timestamp.toIso8601String(),
        'location': reportData['location'] as String,
        'hash': hash,
        'photoUrl': photoUrl,
        'damageDescription': damageDescription,
      };

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('未登录或token缺失');
      }

      final response = await ApiService.authenticatedRequest(
        'POST', '/damage-report', requestData, token,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// 处理本地队列
  static Future<void> processLocalQueue() async {
    try {
      final queueItems = await LocalQueueService.getQueueItems();

      for (int i = 0; i < queueItems.length; i++) {
        final success = await submitFromLocalQueue(queueItems[i]);
        if (success) {
          await LocalQueueService.removeFromQueue(i);
        }
      }
    } catch (e) {
      // 保存到本地队列失败，静默处理
    }
  }

  /// 保存到本地队列
  static Future<void> _saveToLocalQueue(Map<String, dynamic> reportData) async {
    try {
      final serializableData = Map<String, dynamic>.from(reportData);
      await LocalQueueService.saveToQueue(serializableData);
    } catch (e) {
      // 保存到本地队列失败，静默处理
    }
  }
}
