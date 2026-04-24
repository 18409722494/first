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

  // 行李状态超时规则
  /// 无人认领判定时间（小时）
  static const int unclaimedHoursThreshold = 24;

  // 分页配置
  static const int pageSize = 20;
  static const double preloadThreshold = 100.0;
}