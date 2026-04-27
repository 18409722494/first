import 'package:flutter/foundation.dart';
import '../models/luggage.dart';
import '../services/evidence_service.dart';
import '../services/hash_service.dart';
import '../services/baggage_api_service.dart';
import '../services/oss_service.dart';

/// 破损报告提交阶段枚举
enum DamageReportStage {
  hash,
  ossSignature,
  ossUpload,
  businessApi,
  verify,
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

  const DamageReportResult._({
    required this.success,
    this.failedStage,
    this.statusCode,
    this.responseBody,
    this.exceptionMessage,
    this.executionHistory = const [],
    this.statusSyncCompleted = false,
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
  }) =>
      DamageReportResult._(
        success: false,
        failedStage: stage,
        statusCode: statusCode,
        responseBody: responseBody,
        exceptionMessage: exceptionMessage,
        executionHistory: executionHistory,
      );

  /// 人类可读的阶段名称
  String get stageLabel {
    switch (failedStage) {
      case DamageReportStage.hash:
        return '哈希计算';
      case DamageReportStage.ossSignature:
        return 'OSS 签名获取';
      case DamageReportStage.ossUpload:
        return 'OSS 图片上传';
      case DamageReportStage.businessApi:
        return '业务接口提交';
      case DamageReportStage.verify:
        return '哈希校验';
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
  /// 1. 哈希计算
  /// 2. 图片上传到 OSS
  /// 3. 业务接口提交破损记录
  /// 4. 同步行李状态为"已损坏"
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
      // ── 阶段 1：哈希计算 ──────────────────────────────
      try {
        final hash = await HashService.calculateDamageEvidenceHash(
          imageBytes: imageBytes,
          luggageId: luggageId,
          timestamp: timestamp,
          latitude: latitude,
          longitude: longitude,
        );
        addHistory(DamageReportStage.hash, '哈希计算', true, '哈希计算完成: ${hash.substring(0, 16)}...');
      } catch (e) {
        addHistory(DamageReportStage.hash, '哈希计算', false, '哈希计算失败: $e');
        return DamageReportResult.fail(
          stage: DamageReportStage.hash,
          exceptionMessage: e.toString(),
          executionHistory: history,
        );
      }

      // ── 阶段 2：图片上传 ──────────────────────────────
      String photoUrl;
      try {
        photoUrl = await OssService.uploadImage(imageBytes);
        addHistory(DamageReportStage.ossUpload, '图片上传', true, '图片上传完成');
      } on OssUploadException catch (e) {
        addHistory(DamageReportStage.ossUpload, '图片上传', false, '上传失败: ${e.message}');
        return DamageReportResult.fail(
          stage: DamageReportStage.ossUpload,
          statusCode: e.statusCode,
          responseBody: e.body,
          exceptionMessage: e.message,
          executionHistory: history,
        );
      } on OssSignatureException catch (e) {
        addHistory(DamageReportStage.ossSignature, 'OSS签名', false, '签名获取失败: ${e.message}');
        return DamageReportResult.fail(
          stage: DamageReportStage.ossSignature,
          statusCode: e.statusCode,
          responseBody: e.body,
          exceptionMessage: e.message,
          executionHistory: history,
        );
      }

      // ── 阶段 3：业务接口提交 ─────────────────────────
      final tag = luggageId.trim();
      final apiResult = await EvidenceService.uploadAbnormalBaggageDetailed(
        baggageNumber: tag,
        timestamp: timestamp.toUtc().toIso8601String(),
        location: '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
        imageUrl: photoUrl,
        damageDescription: damageDescription.trim(),
        baggageHash: await HashService.calculateDamageEvidenceHash(
          imageBytes: imageBytes,
          luggageId: luggageId,
          timestamp: timestamp,
          latitude: latitude,
          longitude: longitude,
        ),
      );

      if (!apiResult.isSuccess) {
        addHistory(DamageReportStage.businessApi, '业务提交', false, '提交失败: HTTP ${apiResult.statusCode}');
        return DamageReportResult.fail(
          stage: DamageReportStage.businessApi,
          statusCode: apiResult.statusCode,
          responseBody: apiResult.body,
          executionHistory: history,
        );
      }
      addHistory(DamageReportStage.businessApi, '业务提交', true, '破损记录已提交');

      // ── 阶段 4：可选二次校验 ─────────────────────────
      try {
        final verifyResult = await EvidenceService.verifyEvidenceHash(
          await HashService.calculateDamageEvidenceHash(
            imageBytes: imageBytes,
            luggageId: luggageId,
            timestamp: timestamp,
            latitude: latitude,
            longitude: longitude,
          ),
        );
        if (verifyResult.verified && !verifyResult.matches) {
          addHistory(DamageReportStage.verify, '哈希校验', false, '校验未通过');
          return DamageReportResult.fail(
            stage: DamageReportStage.verify,
            responseBody: verifyResult.message ?? '哈希校验失败',
            executionHistory: history,
          );
        }
        addHistory(
          DamageReportStage.verify,
          '哈希校验',
          true,
          verifyResult.verified && verifyResult.matches ? '校验通过' : '跳过校验',
        );
      } catch (e) {
        // 校验失败不阻断流程，只记录
        addHistory(DamageReportStage.verify, '哈希校验', true, '校验跳过: $e');
      }

      // ── 阶段 5：同步行李状态 ─────────────────────────
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
        );
        statusSyncCompleted = true;
        addHistory(DamageReportStage.statusSync, '状态同步', true, '行李状态已更新为已损坏');
      } catch (e) {
        statusSyncError = e.toString();
        addHistory(DamageReportStage.statusSync, '状态同步', false, '状态同步失败: $e');
        // 注意：这里不返回失败，因为破损记录已经成功提交
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
      return DamageReportResult.fail(
        stage: DamageReportStage.businessApi,
        exceptionMessage: e.toString(),
        executionHistory: history,
      );
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
