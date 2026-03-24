import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// OSS服务类
/// 负责将图片上传到OSS存储
class OssService {
  /// OSS上传端点
  static const String uploadEndpoint = AppConstants.ossUploadEndpoint;

  /// 上传图片到OSS
  /// [imageBytes] 图片字节流
  /// [fileName] 文件名（可选）
  /// 返回OSS上的图片URL
  static Future<String> uploadImage(Uint8List imageBytes, {String? fileName}) async {
    final finalFileName = fileName ?? 'damage_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(uploadEndpoint),
    );

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: finalFileName,
    ));

    http.StreamedResponse response;
    try {
      response = await request.send();
    } catch (e) {
      throw Exception('上传请求失败: $e');
    }

    // 只读取一次响应流，避免流被消费后无法再次读取
    final bytes = await response.stream.toBytes();

    if (response.statusCode == 200) {
      final responseString = String.fromCharCodes(bytes);
      final jsonResponse = json.decode(responseString);

      if (jsonResponse.containsKey('photoUrl')) {
        return jsonResponse['photoUrl'] as String;
      } else {
        throw Exception('上传成功但未返回photoUrl');
      }
    } else {
      final errorString = String.fromCharCodes(bytes);
      throw Exception('上传失败: $errorString');
    }
  }
}
