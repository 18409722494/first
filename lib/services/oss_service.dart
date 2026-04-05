import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'damage_report_service.dart';

/// OSS服务类
/// 流程：Flutter → 后端签名接口 → 拿签名URL PUT上传到OSS
class OssService {
  /// 后端签名接口地址
  static String get _signatureApi => '${AppConstants.apiBaseUrl}/oss/generate-url';

  /// 生成OSS文件路径（存储在Bucket内的路径）
  static String _generateObjectName({String? fileName}) {
    final dateStr =
        DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');
    final name =
        fileName ?? 'damage_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return 'damage/$dateStr/$name';
  }

  /// 从后端获取OSS签名上传URL
  static Future<String> _getSignedUrl(String objectName) async {
    try {
      final response = await http
          .post(
            Uri.parse(_signatureApi),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'objectName': objectName}),
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

      return jsonResponse['data'] as String;
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
      final putResponse = await http
          .put(
            Uri.parse(signedUrl),
            body: imageBytes,
            headers: {'Content-Type': 'image/jpeg'},
          )
          .timeout(const Duration(seconds: 30));

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

    return 'https://gra-duation-project.oss-cn-beijing.aliyuncs.com/$objectName';
  }
}
