import 'package:flutter/foundation.dart';
import '../models/luggage.dart';
import '../services/evidence_service.dart';
import '../services/hash_service.dart';
import '../services/baggage_api_service.dart';
import '../services/luggage_service.dart';
import '../services/oss_service.dart';

/// 破损报告提交结果（区分阶段）
enum DamageReportStage {
  hash,
  ossSignature,
  ossUpload,
  businessApi,
}

/// 单次提交的详细错误信息
class DamageReportResult {
  /// true = 成功
  final bool success;
  /// 失败所在的阶段
  final DamageReportStage? failedStage;
  /// 失败时的 HTTP 状态码（仅 businessApi / ossSignature / ossUpload 阶段有）
  final int? statusCode;
  /// 失败时的响应体原文
  final String? responseBody;
  /// 异常消息（网络超时、DNS 失败等底层异常）
  final String? exceptionMessage;

  const DamageReportResult._({
    required this.success,
    this.failedStage,
    this.statusCode,
    this.responseBody,
    this.exceptionMessage,
  });

  factory DamageReportResult.ok() =>
      const DamageReportResult._(success: true);

  factory DamageReportResult.fail({
    required DamageReportStage stage,
    int? statusCode,
    String? responseBody,
    String? exceptionMessage,
  }) =>
      DamageReportResult._(
        success: false,
        failedStage: stage,
        statusCode: statusCode,
        responseBody: responseBody,
        exceptionMessage: exceptionMessage,
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
      case null:
        return '未知';
    }
  }

  /// 人类可读的错误摘要（用于展示给用户）
  String get summary {
    if (success) return '提交成功';
    final sb = StringBuffer('[$stageLabel] ');
    if (exceptionMessage != null) {
      sb.write(exceptionMessage);
    }
    if (statusCode != null) {
      sb.write(' HTTP $statusCode');
    }
    if (responseBody != null && responseBody!.isNotEmpty) {
      // 截断太长的响应体
      final trimmed = responseBody!.length > 200
          ? '${responseBody!.substring(0, 200)}…'
          : responseBody!;
      sb.write(' | $trimmed');
    }
    return sb.toString();
  }
}

/// 破损报告服务
/// 对接新API: http://8.137.145.195:3338/abnormal-baggage/upload
class DamageReportService {
  /// 提交破损报告
  /// [onStageDone] 可选回调，每完成一个阶段时通知（用于 UI 进度展示）
  /// [luggageDbId] 可选；仅当 [luggageId] 无法用于旧版 `PUT /luggage` 回退时保留
  static Future<DamageReportResult> submitDamageReport({
    required Uint8List imageBytes,
    required String luggageId,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required String damageDescription,
    void Function(String stageLabel)? onStageDone,
    String? luggageDbId,
  }) async {
    try {
      // ── 阶段 1：哈希计算 ──────────────────────────────
      final hash = await HashService.calculateDamageEvidenceHash(
        imageBytes: imageBytes,
        luggageId: luggageId,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
      );
      onStageDone?.call('哈希计算完成');

      // ── 阶段 2：OSS 签名获取 ─────────────────────────
      final photoUrl = await OssService.uploadImage(imageBytes);
      onStageDone?.call('图片上传完成');

      // ── 阶段 3：业务接口提交 ─────────────────────────
      final apiResult = await EvidenceService.uploadAbnormalBaggageDetailed(
        baggageNumber: luggageId.trim(),
        timestamp: timestamp.toUtc().toIso8601String(),
        location: '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
        imageUrl: photoUrl,
        damageDescription: damageDescription.trim(),
        baggageHash: hash,
      );
      onStageDone?.call('接口调用完成');

      if (apiResult.isSuccess) {
        // ── 阶段 4：可选二次校验 GET /abnormal-baggage/verify ────
        final verifyResult = await EvidenceService.verifyEvidenceHash(hash);
        if (verifyResult.verified && !verifyResult.matches) {
          return DamageReportResult.fail(
            stage: DamageReportStage.businessApi,
            responseBody:
                '哈希校验未通过：${verifyResult.message ?? '与后端记录不一致'}（图片或元数据可能被篡改）',
          );
        }
        if (verifyResult.backendUnavailable) {
          onStageDone?.call('⚠ 跳过二次哈希校验（接口不可用或响应无法解析）');
        } else if (verifyResult.verified && verifyResult.matches) {
          onStageDone?.call('哈希验证通过');
        } else {
          onStageDone?.call('提交成功（后端未返回明确校验结果，以 upload 成功为准）');
        }

        // ── 阶段 5：同步主表 baggageStatus（与 GET /baggage/all 同源）────────
        // 原先 PUT /luggage/{id} 不会更新 baggage 表，故列表里 baggageStatus 仍为 null。
        final tag = luggageId.trim();
        if (tag.isNotEmpty) {
          try {
            final loc =
                '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
            await BaggageApiService.updateBaggageLocation(
              baggageNumber: tag,
              location: loc,
              status: BaggageStatusMapper.toBackendLocationStatus(
                LuggageStatus.damaged,
              ),
            );
            onStageDone?.call('行李状态已同步为已损坏');
          } catch (e) {
            debugPrint('POST /baggage/location 同步破损状态失败: $e');
            if (luggageDbId != null && luggageDbId.isNotEmpty) {
              try {
                await LuggageService.updateLuggage(luggageDbId, {
                  'status': LuggageStatus.damaged.name,
                });
                onStageDone?.call('行李状态已同步为已损坏（旧接口）');
              } catch (e2) {
                debugPrint('PUT /luggage 同步失败: $e2');
              }
            }
          }
        }

        return DamageReportResult.ok();
      }
      return DamageReportResult.fail(
        stage: DamageReportStage.businessApi,
        statusCode: apiResult.statusCode,
        responseBody: apiResult.body,
      );
    } on OssSignatureException catch (e) {
      return DamageReportResult.fail(
        stage: DamageReportStage.ossSignature,
        statusCode: e.statusCode,
        responseBody: e.body,
        exceptionMessage: e.message,
      );
    } on OssUploadException catch (e) {
      return DamageReportResult.fail(
        stage: DamageReportStage.ossUpload,
        statusCode: e.statusCode,
        responseBody: e.body,
        exceptionMessage: e.message,
      );
    } catch (e) {
      return DamageReportResult.fail(
        stage: DamageReportStage.businessApi,
        exceptionMessage: e.toString(),
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
