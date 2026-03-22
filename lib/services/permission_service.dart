import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../models/permission_type.dart';

/// 统一权限管理服务
/// 提供简洁的权限请求接口，统一处理权限相关的用户交互
class PermissionService {
  PermissionService._();

  /// 请求单个权限
  ///
  /// [type] 权限类型
  /// [context] BuildContext，用于显示对话框
  /// 返回 true 表示权限已授权，false 表示未授权
  static Future<bool> request(
    PermissionType type, {
    BuildContext? context,
  }) async {
    final status = await type.permission.request();
    return _handleStatus(type, status, context);
  }

  /// 批量请求多个权限
  ///
  /// [types] 权限类型列表
  /// [context] BuildContext，用于显示对话框
  /// 返回授权成功的权限类型列表
  static Future<List<PermissionType>> requestMultiple(
    List<PermissionType> types, {
    BuildContext? context,
  }) async {
    // 批量请求权限
    final permissions = types.map((t) => t.permission).toList();
    final results = await permissions.request();

    // 处理结果
    final granted = <PermissionType>[];
    for (var i = 0; i < types.length; i++) {
      final status = results[permissions[i]] ?? PermissionStatus.denied;
      if (await _handleStatus(types[i], status, context)) {
        granted.add(types[i]);
      }
    }
    return granted;
  }

  /// 检查权限状态
  ///
  /// [type] 权限类型
  /// 返回权限状态
  static Future<PermissionStatus> check(PermissionType type) async {
    return await type.permission.status;
  }

  /// 打开应用设置页面
  ///
  /// 返回是否成功打开
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// 显示权限被拒绝的对话框
  ///
  /// [context] BuildContext
  /// [type] 权限类型
  static Future<void> showDeniedDialog(
    BuildContext context,
    PermissionType type,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('权限被拒绝'),
        content: Text(type.permanentlyDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              openSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 显示 SnackBar 提示
  ///
  /// [context] BuildContext
  /// [message] 提示消息
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 请求相机权限
  /// 简化调用方式
  static Future<bool> requestCamera(BuildContext context) async {
    final granted = await request(PermissionType.camera, context: context);
    if (!granted) {
      showSnackBar(context, PermissionType.camera.deniedMessage);
    }
    return granted;
  }

  /// 请求相册权限
  /// 简化调用方式
  static Future<bool> requestPhotos(BuildContext context) async {
    final granted = await request(PermissionType.photos, context: context);
    if (!granted) {
      showSnackBar(context, PermissionType.photos.deniedMessage);
    }
    return granted;
  }

  /// 请求电话权限
  /// 简化调用方式
  static Future<bool> requestPhone(BuildContext context) async {
    final granted = await request(PermissionType.phone, context: context);
    if (!granted) {
      showSnackBar(context, PermissionType.phone.deniedMessage);
    }
    return granted;
  }

  /// 请求位置权限 (使用 Geolocator)
  /// 包含位置权限的特殊处理逻辑
  ///
  /// [context] BuildContext
  /// [showDeniedSnackBar] 是否显示被拒绝的 SnackBar
  /// 返回 true 表示权限已授权，false 表示未授权
  static Future<bool> requestLocation(
    BuildContext context, {
    bool showDeniedSnackBar = true,
  }) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await showDeniedDialog(context, PermissionType.location);
        return false;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }

      if (showDeniedSnackBar) {
        showSnackBar(context, PermissionType.location.deniedMessage);
      }
      return false;
    } catch (e) {
      debugPrint('位置权限请求失败: $e');
      if (showDeniedSnackBar) {
        showSnackBar(context, '获取位置信息失败，请稍后重试');
      }
      return false;
    }
  }

  /// 处理权限状态
  /// 返回 true 表示已授权
  static Future<bool> _handleStatus(
    PermissionType type,
    PermissionStatus status,
    BuildContext? context,
  ) async {
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context != null) {
        await showDeniedDialog(context, type);
      }
      return false;
    }

    // 被拒绝但不是永久拒绝
    if (context != null) {
      showSnackBar(context, type.deniedMessage);
    }
    return false;
  }
}
