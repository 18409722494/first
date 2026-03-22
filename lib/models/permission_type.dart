import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// 权限类型枚举
/// 统一管理应用中使用的所有权限类型
enum PermissionType {
  /// 相机权限 - 用于拍照和扫描二维码
  camera(
    displayName: '相机',
    description: '用于拍照和扫描二维码',
    icon: Icons.camera_alt_outlined,
  ),

  /// 相册权限 - 用于选择照片
  photos(
    displayName: '相册',
    description: '用于从相册选择照片',
    icon: Icons.photo_library_outlined,
  ),

  /// 位置权限 - 用于获取当前位置信息
  location(
    displayName: '位置',
    description: '用于获取当前位置信息',
    icon: Icons.location_on_outlined,
  ),

  /// 电话权限 - 用于拨打电话
  phone(
    displayName: '电话',
    description: '用于拨打客服电话',
    icon: Icons.phone_outlined,
  );

  const PermissionType({
    required this.displayName,
    required this.description,
    required this.icon,
  });

  /// 显示名称
  final String displayName;

  /// 权限描述
  final String description;

  /// 对应图标
  final IconData icon;

  /// 映射到 permission_handler 的 Permission
  Permission get permission {
    switch (this) {
      case PermissionType.camera:
        return Permission.camera;
      case PermissionType.photos:
        return Permission.photos;
      case PermissionType.location:
        return Permission.location;
      case PermissionType.phone:
        return Permission.phone;
    }
  }

  /// 获取权限被拒绝时的提示消息
  String get deniedMessage {
    switch (this) {
      case PermissionType.camera:
        return '需要相机权限才能使用此功能';
      case PermissionType.photos:
        return '需要相册权限才能选择照片';
      case PermissionType.location:
        return '需要位置权限才能获取当前位置';
      case PermissionType.phone:
        return '需要电话权限才能拨打电话';
    }
  }

  /// 获取权限被永久拒绝时的提示消息
  String get permanentlyDeniedMessage {
    switch (this) {
      case PermissionType.camera:
        return '相机权限已被永久拒绝，请在系统设置中开启';
      case PermissionType.photos:
        return '相册权限已被永久拒绝，请在系统设置中开启';
      case PermissionType.location:
        return '位置权限已被永久拒绝，请在系统设置中开启';
      case PermissionType.phone:
        return '电话权限已被永久拒绝，请在系统设置中开启';
    }
  }

  /// 获取权限请求提示消息
  String get requestMessage {
    return '需要$displayName权限，$description';
  }
}
