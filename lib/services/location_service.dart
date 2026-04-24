import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// 设备位置服务
///
/// 负责 GPS 定位相关逻辑：
/// - 权限检查
/// - 多精度降级定位（优先「能拿到」而非「高精度」）
/// - GPS 服务状态检查
class LocationService {
  /// 检查并请求位置权限
  static Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static bool _isPlausibleCoordinate(Position p) {
    final lat = p.latitude;
    final lng = p.longitude;
    if (lat.isNaN || lng.isNaN) return false;
    if (lat.abs() < 1e-7 && lng.abs() < 1e-7) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    return true;
  }

  static Duration _locationTimeoutForAccuracy(LocationAccuracy a) {
    switch (a) {
      case LocationAccuracy.lowest:
        return const Duration(seconds: 22);
      case LocationAccuracy.low:
        return const Duration(seconds: 22);
      case LocationAccuracy.medium:
        return const Duration(seconds: 14);
      default:
        return const Duration(seconds: 12);
    }
  }

  /// 获取设备当前位置（优先「能拿到」，不追求高精度）
  ///
  /// 策略：
  /// 1. [getLastKnownPosition]：7 天内缓存直接用；实时全失败后再用更旧缓存兜底
  /// 2. 实时定位顺序：**lowest → low → medium**（网络/基站优先，弱 GPS 室内更易成功）
  /// 3. 不使用 high/best，避免长时间等卫星
  static Future<Position?> getCurrentDevicePosition({
    int retryPerAccuracy = 2,
    Duration? timeout,
  }) async {
    Position? oldButPlausibleLast;

    // 1) 最近已知位置
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && _isPlausibleCoordinate(last)) {
        oldButPlausibleLast = last;
        final age = DateTime.now().difference(last.timestamp);
        if (age.inDays <= 7) {
          debugPrint(
            'getCurrentDevicePosition: 使用最近已知位置（约 ${age.inHours} 小时前，精度不限）',
          );
          return last;
        }
      }
    } catch (e) {
      debugPrint('getCurrentDevicePosition: lastKnown 失败 $e');
    }

    // 2) 实时：从最低精度到 medium
    const order = <LocationAccuracy>[
      LocationAccuracy.lowest,
      LocationAccuracy.low,
      LocationAccuracy.medium,
    ];

    for (final accuracy in order) {
      final t = timeout ?? _locationTimeoutForAccuracy(accuracy);
      for (int attempt = 0; attempt < retryPerAccuracy; attempt++) {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: accuracy,
            timeLimit: t,
          );
          if (_isPlausibleCoordinate(position)) {
            debugPrint(
              'getCurrentDevicePosition: 实时成功 accuracy=$accuracy 第${attempt + 1}次',
            );
            return position;
          }
        } catch (e) {
          debugPrint(
            'getCurrentDevicePosition: accuracy=$accuracy 第${attempt + 1}次失败 $e',
          );
          if (attempt < retryPerAccuracy - 1) {
            await Future.delayed(const Duration(milliseconds: 700));
          }
        }
      }
    }

    // 3) 兜底：超过 7 天的 lastKnown 仍优于无坐标
    if (oldButPlausibleLast != null) {
      debugPrint('getCurrentDevicePosition: 使用较旧的缓存位置作为兜底');
      return oldButPlausibleLast;
    }

    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && _isPlausibleCoordinate(last)) {
        return last;
      }
    } catch (_) {}

    debugPrint('getCurrentDevicePosition: 所有策略均失败，返回 null');
    return null;
  }

  /// 检查 GPS 服务是否启用
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
