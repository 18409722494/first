import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 应用常量
class AppConstants {
  AppConstants._();

  /// 未打包进 APK 的 `.env` 时 [dotenv] 可能未初始化，直接读 [dotenv.env] 会抛 [NotInitializedError]。
  static String? _tryDotenv(String key) {
    try {
      final v = dotenv.env[key];
      if (v == null || v.trim().isEmpty) return null;
      return v.trim();
    } catch (_) {
      return null;
    }
  }

  // API 地址解析顺序：编译参数 → 本地 .env（开发机）→ 默认后端（真机未带 .env 时的回退）
  // 生产环境建议：`flutter build apk --dart-define=API_BASE_URL=https://你的域名`
  static const String _fallbackApiBaseUrl = 'http://8.137.145.195:3338';

  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine.trim();

    final fromDot = _tryDotenv('API_BASE_URL');
    if (fromDot != null) return fromDot;

    return _fallbackApiBaseUrl;
  }

  static String get ossUploadEndpoint => '$apiBaseUrl/upload';

  /// 天地图 Key：编译参数 → .env；真机若未配置，打开地图相关页会报错（登录不受影响）
  static String get tiandituApiKey {
    const fromDefine = String.fromEnvironment('TIANDITU_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine.trim();

    final fromDot = _tryDotenv('TIANDITU_API_KEY');
    if (fromDot != null) return fromDot;

    throw StateError(
      '未配置天地图密钥：真机 APK 未包含 .env 时，请使用 '
      'flutter run/build 添加 --dart-define=TIANDITU_API_KEY=你的密钥',
    );
  }

  /// 天地图影像底图瓦片 URL
  static String get tiandituImageTileUrl =>
      'https://t0.tianditu.gov.cn/img_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$tiandituApiKey';

  /// 天地图影像标注层瓦片 URL
  static String get tiandituAnnotationTileUrl =>
      'https://t0.tianditu.gov.cn/cia_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cia&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$tiandituApiKey';

  // 行李超重规则
  static const double freeBaggageWeightKg = 20.0;
  static const double overweightFeePerKg = 100.0;

  static double calculateOverweightFee(double actualWeightKg) {
    final overweight = actualWeightKg - freeBaggageWeightKg;
    return overweight > 0 ? overweight * overweightFeePerKg : 0.0;
  }

  // 分页配置
  static const int pageSize = 20;
  static const double preloadThreshold = 100.0;

  // 行李状态颜色
  static const Map<String, Color> luggageStatusColors = {
    'checkIn':    Color(0xFF2196F3),
    'inTransit':  Color.fromARGB(255, 5, 13, 34),
    'arrived':    Color(0xFF4CAF50),
    'delivered':  Color.fromARGB(255, 117, 33, 22),
    'damaged':    Color.fromARGB(255, 189, 187, 65),
    'lost':       Color(0xFF9E9E9E),
  };

  static const Map<String, Color> luggageStatusBgColors = {
    'checkIn':    Color(0xFFE3F2FD),
    'inTransit':  Color(0xFFFFF3E0),
    'arrived':    Color(0xFFE8F5E9),
    'delivered':  Color(0xFFE1F5FE),
    'damaged':    Color(0xFFFFEBEE),
    'lost':       Color(0xFFF5F5F5),
  };

  static Color getStatusColor(String statusKey) {
    return luggageStatusColors[statusKey] ?? Colors.grey;
  }

  static Color getStatusBgColor(String statusKey) {
    return luggageStatusBgColors[statusKey] ?? Colors.grey.shade100;
  }

}
