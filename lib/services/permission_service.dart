import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../models/permission_type.dart';

/// 统一权限管理服务
/// 提供简洁的权限请求接口，统一处理权限相关的用户交互
class PermissionService {
  PermissionService._();

  /// 显示 SnackBar 提示（内部用，提前捕获 messenger）
  static void _showSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示权限被拒绝的对话框
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

  /// 打开应用设置页面
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// 请求单个权限
  ///
  /// [type] 权限类型
  /// [context] BuildContext，用于显示对话框
  /// 返回 true 表示权限已授权，false 表示未授权
  static Future<bool> request(
    PermissionType type, {
    required BuildContext context,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final status = await type.permission.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      // ignore: use_build_context_synchronously — 静态方法无 mounted，调用方需确保 widget 未卸载
      await showDeniedDialog(context, type);
      return false;
    }

    _showSnackBar(messenger, type.deniedMessage);
    return false;
  }

  /// 批量请求多个权限
  ///
  /// [types] 权限类型列表
  /// [context] BuildContext，用于显示对话框
  /// 返回授权成功的权限类型列表
  static Future<List<PermissionType>> requestMultiple(
    List<PermissionType> types, {
    required BuildContext context,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final permissions = types.map((t) => t.permission).toList();
    final results = await permissions.request();

    final granted = <PermissionType>[];
    for (var i = 0; i < types.length; i++) {
      final status = results[permissions[i]] ?? PermissionStatus.denied;

      if (status.isGranted) {
        granted.add(types[i]);
        continue;
      }

      if (status.isPermanentlyDenied) {
        // ignore: use_build_context_synchronously
        await showDeniedDialog(context, types[i]);
        continue;
      }

      _showSnackBar(messenger, types[i].deniedMessage);
    }
    return granted;
  }

  /// 检查权限状态
  static Future<PermissionStatus> check(PermissionType type) async {
    return await type.permission.status;
  }

  /// 请求相机权限
  static Future<bool> requestCamera(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final granted = await request(PermissionType.camera, context: context);
    if (!granted) {
      _showSnackBar(messenger, PermissionType.camera.deniedMessage);
    }
    return granted;
  }

  /// 请求相册权限
  static Future<bool> requestPhotos(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final granted = await request(PermissionType.photos, context: context);
    if (!granted) {
      _showSnackBar(messenger, PermissionType.photos.deniedMessage);
    }
    return granted;
  }

  /// 请求电话权限
  static Future<bool> requestPhone(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final granted = await request(PermissionType.phone, context: context);
    if (!granted) {
      _showSnackBar(messenger, PermissionType.phone.deniedMessage);
    }
    return granted;
  }

  /// 请求位置权限 (使用 Geolocator)
  ///
  /// [context] BuildContext
  /// [showDeniedSnackBar] 是否显示被拒绝的 SnackBar
  /// 返回 true 表示权限已授权，false 表示未授权
  static Future<bool> requestLocation(
    BuildContext context, {
    bool showDeniedSnackBar = true,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // ignore: use_build_context_synchronously
        await showDeniedDialog(context, PermissionType.location);
        return false;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }

      if (showDeniedSnackBar) {
        _showSnackBar(messenger, PermissionType.location.deniedMessage);
      }
      return false;
    } catch (e) {
      if (showDeniedSnackBar) {
        _showSnackBar(messenger, '获取位置信息失败，请稍后重试');
      }
      return false;
    }
  }
}
