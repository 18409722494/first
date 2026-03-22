import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// 哈希服务类
/// 负责计算行李破损证据的哈希值
class HashService {
  /// 计算行李破损证据的哈希值
  /// [imageBytes] 图片字节流
  /// [luggageId] 行李ID
  /// [timestamp] 时间戳
  /// [latitude] 纬度
  /// [longitude] 经度
  /// 返回SHA-256哈希值（64位十六进制字符串）
  static Future<String> calculateDamageEvidenceHash({
    required Uint8List imageBytes,
    required String luggageId,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
  }) async {
    // 1. 数据准备与标准化
    final normalizedId = luggageId.trim();
    final utcTime = timestamp.toUtc();
    final timeString = utcTime.toIso8601String();
    final locationString = "${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}";
    
    // 2. 计算各部分字节
    final idBytes = utf8.encode(normalizedId);
    final timeBytes = utf8.encode(timeString);
    final locationBytes = utf8.encode(locationString);
    
    // 3. 长度前缀策略（4字节，大端序）
    final idLength = ByteData(4)..setUint32(0, idBytes.length, Endian.big);
    final timeLength = ByteData(4)..setUint32(0, timeBytes.length, Endian.big);
    final locationLength = ByteData(4)..setUint32(0, locationBytes.length, Endian.big);
    final imageLength = ByteData(4)..setUint32(0, imageBytes.length, Endian.big);
    
    // 4. 组合所有数据
    final combinedBytes = BytesBuilder()
      ..add(idLength.buffer.asUint8List())
      ..add(idBytes)
      ..add(timeLength.buffer.asUint8List())
      ..add(timeBytes)
      ..add(locationLength.buffer.asUint8List())
      ..add(locationBytes)
      ..add(imageLength.buffer.asUint8List())
      ..add(imageBytes);
    
    // 5. 计算SHA-256哈希
    final digest = sha256.convert(combinedBytes.toBytes());
    return digest.toString();
  }
}
