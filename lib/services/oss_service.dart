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
    try {
      // 1. 生成唯一文件名
      final finalFileName = fileName ?? 'damage_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // 2. 构建多部分请求
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadEndpoint),
      );
      
      // 3. 添加文件
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: finalFileName,
      ));
      
      // 4. 发送请求
      final response = await request.send();
      
      // 5. 处理响应
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = json.decode(responseString);
        
        if (jsonResponse.containsKey('photoUrl')) {
          return jsonResponse['photoUrl'] as String;
        } else {
          throw Exception('上传成功但未返回photoUrl');
        }
      } else {
        final errorData = await response.stream.toBytes();
        final errorString = String.fromCharCodes(errorData);
        throw Exception('上传失败: $errorString');
      }
    } catch (e) {
      print('OSS上传失败: $e');
      rethrow;
    }
  }
}
