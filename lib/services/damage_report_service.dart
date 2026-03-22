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
        print('破损报告提交成功');
        return true;
      } else {
        print('破损报告提交失败: ${response.statusCode}, ${response.body}');
        await _saveToLocalQueue({...requestData, 'imageBytes': imageBytes});
        return false;
      }
    } catch (e) {
      print('提交破损报告失败: $e');
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
        print('本地队列报告提交成功');
        return true;
      } else {
        print('本地队列报告提交失败: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('从本地队列提交失败: $e');
      return false;
    }
  }

  /// 处理本地队列
  static Future<void> processLocalQueue() async {
    try {
      final queueItems = await LocalQueueService.getQueueItems();
      print('本地队列中有 ${queueItems.length} 个待处理报告');

      for (int i = 0; i < queueItems.length; i++) {
        final success = await submitFromLocalQueue(queueItems[i]);
        if (success) {
          await LocalQueueService.removeFromQueue(i);
        }
      }
    } catch (e) {
      print('处理本地队列失败: $e');
    }
  }

  /// 保存到本地队列
  static Future<void> _saveToLocalQueue(Map<String, dynamic> reportData) async {
    try {
      final serializableData = Map<String, dynamic>.from(reportData);
      await LocalQueueService.saveToQueue(serializableData);
      print('报告已保存到本地队列');
    } catch (e) {
      print('保存到本地队列失败: $e');
    }
  }
}
