import 'dart:convert';
import 'dart:typed_data';
import '../models/luggage.dart';
import '../services/evidence_service.dart';
import '../services/baggage_api_service.dart';
import '../services/oss_service.dart';
import '../services/local_queue_service.dart';

/// 破损报告提交阶段枚举
enum DamageReportStage {
  ossSignature,
  ossUpload,
  businessApi,
  statusSync,
}

/// 破损报告提交结果（区分阶段）
class DamageReportResult {
  /// true = 完全成功
  final bool success;
  /// 失败所在的阶段（如果有）
  final DamageReportStage? failedStage;
  /// HTTP 状态码（如果有）
  final int? statusCode;
  /// 响应体原文
  final String? responseBody;
  /// 异常消息
  final String? exceptionMessage;
  /// 阶段执行历史（用于调试）
  final List<StageExecution> executionHistory;
  /// 行李状态同步是否成功
  final bool statusSyncCompleted;
  /// 是否已保存到本地队列等待重试
  final bool savedToQueue;

  const DamageReportResult._({
    required this.success,
    this.failedStage,
    this.statusCode,
    this.responseBody,
    this.exceptionMessage,
    this.executionHistory = const [],
    this.statusSyncCompleted = false,
    this.savedToQueue = false,
  });

  factory DamageReportResult.ok({
    required List<StageExecution> history,
  }) =>
      DamageReportResult._(
        success: true,
        executionHistory: history,
        statusSyncCompleted: true,
      );

  factory DamageReportResult.partialSuccess({
    required List<StageExecution> history,
    required bool statusSyncCompleted,
    String? statusSyncError,
  }) =>
      DamageReportResult._(
        success: true,
        executionHistory: history,
        statusSyncCompleted: statusSyncCompleted,
        // 如果状态同步失败，记录警告
        exceptionMessage: statusSyncCompleted ? null : '⚠️ 状态同步失败: $statusSyncError',
      );

  factory DamageReportResult.fail({
    required DamageReportStage stage,
    int? statusCode,
    String? responseBody,
    String? exceptionMessage,
    required List<StageExecution> executionHistory,
    bool savedToQueue = false,
  }) =>
      DamageReportResult._(
        success: false,
        failedStage: stage,
        statusCode: statusCode,
        responseBody: responseBody,
        exceptionMessage: exceptionMessage,
        executionHistory: executionHistory,
        savedToQueue: savedToQueue,
      );

  /// 人类可读的阶段名称
  String get stageLabel {
    switch (failedStage) {
      case DamageReportStage.ossSignature:
        return 'OSS 签名获取';
      case DamageReportStage.ossUpload:
        return 'OSS 图片上传';
      case DamageReportStage.businessApi:
        return '业务接口提交';
      case DamageReportStage.statusSync:
        return '状态同步';
      case null:
        return '未知';
    }
  }

  /// 生成详细的状态报告
  String get detailedReport {
    final sb = StringBuffer();

    if (success) {
      sb.writeln('✅ 破损报告提交成功');
      if (!statusSyncCompleted) {
        sb.writeln('⚠️ 警告：破损记录已创建，但行李状态同步失败');
      }
    } else {
      sb.writeln('❌ 破损报告提交失败');
      sb.writeln('失败阶段: $stageLabel');
    }

    if (executionHistory.isNotEmpty) {
      sb.writeln('\n执行历史:');
      for (final exec in executionHistory) {
        final icon = exec.success ? '✅' : '❌';
        sb.writeln('  $icon ${exec.stageLabel}: ${exec.message}');
      }
    }

    return sb.toString();
  }

  /// 人类可读的错误摘要
  String get summary {
    if (success) {
      return statusSyncCompleted
          ? '提交成功'
          : '提交成功，但状态同步失败，请手动更新行李状态';
    }
    final sb = StringBuffer('[$stageLabel] ');
    if (exceptionMessage != null) {
      sb.write(exceptionMessage);
    }
    if (statusCode != null) {
      sb.write(' HTTP $statusCode');
    }
    if (responseBody != null && responseBody!.isNotEmpty) {
      final trimmed = responseBody!.length > 200
          ? '${responseBody!.substring(0, 200)}…'
          : responseBody!;
      sb.write(' | $trimmed');
    }
    return sb.toString();
  }
}

/// 阶段执行记录
class StageExecution {
  final DamageReportStage stage;
  final String stageLabel;
  final bool success;
  final String message;
  final DateTime timestamp;

  StageExecution({
    required this.stage,
    required this.stageLabel,
    required this.success,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 破损报告服务
/// 提供事务性破损报告提交，确保数据一致性
class DamageReportService {
  /// 提交破损报告（带事务性保证）
  ///
  /// 流程:
  /// 1. 图片上传到 OSS
  /// 2. 业务接口提交破损记录
  /// 3. 同步行李状态为"已损坏"
  ///
  /// 如果状态同步失败，会明确返回 [DamageReportResult.statusSyncCompleted = false]
  /// 调用方应检查此字段并提示用户
  static Future<DamageReportResult> submitDamageReport({
    required Uint8List imageBytes,
    required String luggageId,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required String damageDescription,
    required String employeeId,
    void Function(String stageLabel)? onStageDone,
  }) async {
    final history = <StageExecution>[];

    void addHistory(DamageReportStage stage, String label, bool success, String msg) {
      history.add(StageExecution(
        stage: stage,
        stageLabel: label,
        success: success,
        message: msg,
      ));
      if (success) {
        onStageDone?.call(msg);
      }
    }

    try {
      // ── 阶段 1：图片上传 ──────────────────────────────
      String photoUrl;
      try {
        photoUrl = await OssService.uploadImage(imageBytes);
        addHistory(DamageReportStage.ossUpload, '图片上传', true, '图片上传完成');
      } on OssUploadException catch (e) {
        addHistory(DamageReportStage.ossUpload, '图片上传', false, '上传失败: ${e.message}');
        final saved = await _saveToQueueIfNeeded(imageBytes, luggageId, timestamp, latitude, longitude, damageDescription, employeeId, '图片上传失败');
        return DamageReportResult.fail(
          stage: DamageReportStage.ossUpload,
          statusCode: e.statusCode,
          responseBody: e.body,
          exceptionMessage: saved ? '${e.message}（已保存到本地，网络恢复后将自动重试）' : e.message,
          executionHistory: history,
          savedToQueue: saved,
        );
      } on OssSignatureException catch (e) {
        addHistory(DamageReportStage.ossSignature, 'OSS签名', false, '签名获取失败: ${e.message}');
        final saved = await _saveToQueueIfNeeded(imageBytes, luggageId, timestamp, latitude, longitude, damageDescription, employeeId, '签名获取失败');
        return DamageReportResult.fail(
          stage: DamageReportStage.ossSignature,
          statusCode: e.statusCode,
          responseBody: e.body,
          exceptionMessage: saved ? '${e.message}（已保存到本地，网络恢复后将自动重试）' : e.message,
          executionHistory: history,
          savedToQueue: saved,
        );
      }

      // ── 阶段 2：业务接口提交 ─────────────────────────
      final tag = luggageId.trim();
      final apiResult = await EvidenceService.uploadAbnormalBaggageDetailed(
        baggageNumber: tag,
        timestamp: timestamp.toUtc().toIso8601String(),
        location: '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
        imageUrl: photoUrl,
        damageDescription: damageDescription.trim(),
      );

      if (!apiResult.isSuccess) {
        addHistory(DamageReportStage.businessApi, '业务提交', false, '提交失败: HTTP ${apiResult.statusCode}');
        // 图片已上传成功，保存数据到队列等待重试
        final saved = await _saveToQueueIfNeeded(imageBytes, luggageId, timestamp, latitude, longitude, damageDescription, employeeId, '业务提交失败');
        return DamageReportResult.fail(
          stage: DamageReportStage.businessApi,
          statusCode: apiResult.statusCode,
          responseBody: apiResult.body,
          exceptionMessage: saved ? '提交失败（已保存到本地，网络恢复后将自动重试）' : '提交失败',
          executionHistory: history,
          savedToQueue: saved,
        );
      }
      addHistory(DamageReportStage.businessApi, '业务提交', true, '破损记录已提交');

      // ── 阶段 3：同步行李状态 ─────────────────────────
      bool statusSyncCompleted = false;
      String? statusSyncError;
      try {
        final loc = '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
        await BaggageApiService.updateBaggageLocation(
          baggageNumber: tag,
          location: loc,
          status: BaggageStatusMapper.toBackendLocationStatus(
            LuggageStatus.damaged,
          ),
          employeeId: employeeId,
        );
        statusSyncCompleted = true;
        addHistory(DamageReportStage.statusSync, '状态同步', true, '行李状态已更新为已损坏');
      } catch (e) {
        statusSyncError = e.toString();
        addHistory(DamageReportStage.statusSync, '状态同步', false, '状态同步失败: $e');
      }

      // 返回结果
      if (statusSyncCompleted) {
        return DamageReportResult.ok(history: history);
      } else {
        return DamageReportResult.partialSuccess(
          history: history,
          statusSyncCompleted: false,
          statusSyncError: statusSyncError,
        );
      }
    } catch (e) {
      addHistory(DamageReportStage.businessApi, '未知错误', false, e.toString());
      final saved = await _saveToQueueIfNeeded(imageBytes, luggageId, timestamp, latitude, longitude, damageDescription, employeeId, '未知错误');
      return DamageReportResult.fail(
        stage: DamageReportStage.businessApi,
        exceptionMessage: saved ? '${e.toString()}（已保存到本地，网络恢复后将自动重试）' : e.toString(),
        executionHistory: history,
        savedToQueue: saved,
      );
    }
  }

  /// 将失败的报告保存到本地队列，返回是否保存成功
  static Future<bool> _saveToQueueIfNeeded(
    Uint8List imageBytes,
    String luggageId,
    DateTime timestamp,
    double latitude,
    double longitude,
    String damageDescription,
    String employeeId,
    String reason,
  ) async {
    try {
      await LocalQueueService.saveToQueue({
        'imageBytes': base64Encode(imageBytes),
        'luggageId': luggageId.trim(),
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'damageDescription': damageDescription.trim(),
        'employeeId': employeeId,
        'failReason': reason,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// OSS 签名阶段异常
class OssSignatureException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;
  OssSignatureException(this.message, {this.statusCode, this.body});
  @override
  String toString() => 'OssSignatureException: $message';
}

/// OSS 上传阶段异常
class OssUploadException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;
  OssUploadException(this.message, {this.statusCode, this.body});
  @override
  String toString() => 'OssUploadException: $message';
}
