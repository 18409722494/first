import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'damage_report_service.dart';
import 'oss_presigned_put.dart';

/// OSS服务类
/// 流程：Flutter → 后端签名接口 → 拿签名URL PUT上传到OSS
class OssService {
  /// 后端签名接口地址
  static String get _signatureApi => '${AppConstants.apiBaseUrl}/oss/generate-url';

  /// 预签名 URL 的 query 里 Signature 为 Base64，常含 `+`。
  /// Dart 的 [Uri] 在解析/序列化时可能把 `+` 当成空格，导致与后端签名不一致 → SignatureDoesNotMatch。
  static String _fixSignaturePlusInUrl(String url) {
    return url.replaceAllMapped(
      RegExp(r'([?&]Signature=)([^&]*)', caseSensitive: false),
      (m) {
        final prefix = m.group(1)!;
        final sig = m.group(2)!;
        return '$prefix${sig.replaceAll('+', '%2B')}';
      },
    );
  }

  /// 生成OSS文件路径（存储在Bucket内的路径）
  static String _generateObjectName({String? fileName}) {
    final dateStr =
        DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');
    final name =
        fileName ?? 'damage_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return 'damage/$dateStr/$name';
  }

  /// 从后端获取OSS签名上传URL（POST）
  static Future<String> _getSignedUrl(String objectName) async {
    try {
      final response = await http
          .post(
            Uri.parse(_signatureApi),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'objectName': objectName,
              'contentType': 'image/jpeg',
              'expiration': 3600,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw OssSignatureException(
          '获取上传签名失败',
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['result'] != 'success') {
        throw OssSignatureException(
          '签名返回 result≠success',
          statusCode: response.statusCode,
          body: response.body,
        );
      }
      if (jsonResponse['data'] == null) {
        throw OssSignatureException(
          '签名响应无 data 字段',
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      // 后端返回的 URL 可能是 http://，保持原样使用
      return _fixSignaturePlusInUrl(jsonResponse['data'] as String);
    } on OssSignatureException {
      rethrow;
    } catch (e) {
      throw OssSignatureException(
        e.toString(),
        statusCode: null,
        body: null,
      );
    }
  }

  /// 上传图片到OSS
  /// [imageBytes] 图片字节流
  /// [fileName] 文件名（可选）
  /// 返回OSS上的图片可访问URL
  static Future<String> uploadImage(Uint8List imageBytes, {String? fileName}) async {
    final objectName = _generateObjectName(fileName: fileName);
    final signedUrl = await _getSignedUrl(objectName);

    try {
      final putResponse = await ossPresignedPut(
        signedUrl,
        imageBytes,
      ).timeout(const Duration(seconds: 30));

      if (putResponse.statusCode != 200 && putResponse.statusCode != 204) {
        throw OssUploadException(
          'OSS PUT 失败',
          statusCode: putResponse.statusCode,
          body: putResponse.body,
        );
      }
    } on OssUploadException {
      rethrow;
    } catch (e) {
      throw OssUploadException(
        e.toString(),
        statusCode: null,
        body: null,
      );
    }

    // 返回可访问的图片URL（使用 https）
    return 'https://gra-duation-project.oss-cn-beijing.aliyuncs.com/$objectName';
  }
}
