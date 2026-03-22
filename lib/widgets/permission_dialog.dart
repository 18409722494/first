import 'package:flutter/material.dart';
import '../models/permission_type.dart';

/// 权限提示对话框
/// 用于显示权限请求说明或权限被拒绝的提示
class PermissionDialog extends StatelessWidget {
  /// 权限类型
  final PermissionType type;

  /// 对话框类型
  final PermissionDialogType dialogType;

  /// 确认按钮回调
  final VoidCallback? onConfirm;

  /// 取消按钮回调
  final VoidCallback? onCancel;

  const PermissionDialog({
    super.key,
    required this.type,
    this.dialogType = PermissionDialogType.request,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    switch (dialogType) {
      case PermissionDialogType.request:
        return _buildRequestDialog(context);
      case PermissionDialogType.denied:
        return _buildDeniedDialog(context);
      case PermissionDialogType.source:
        return _buildSourceDialog(context);
    }
  }

  /// 构建权限请求说明对话框
  Widget _buildRequestDialog(BuildContext context) {
    return AlertDialog(
      title: Text('${type.displayName}权限请求'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(type.icon, size: 24, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.requestMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '是否授权此权限？',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: onConfirm ?? () => Navigator.pop(context, true),
          child: const Text('确认'),
        ),
      ],
    );
  }

  /// 构建权限被拒绝对话框
  Widget _buildDeniedDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('权限被拒绝'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 24,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.permanentlyDeniedMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: onConfirm ?? () => Navigator.pop(context, true),
          child: const Text('去设置'),
        ),
      ],
    );
  }

  /// 构建图片来源选择对话框
  /// 用于选择图片来源（相机/相册）
  Widget _buildSourceDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('选择图片来源'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('相机'),
            subtitle: const Text('拍照获取照片'),
            onTap: () => Navigator.pop(context, ImageSourceType.camera),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('相册'),
            subtitle: const Text('从相册选择照片'),
            onTap: () => Navigator.pop(context, ImageSourceType.gallery),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context, null),
          child: const Text('取消'),
        ),
      ],
    );
  }

  /// 显示权限请求对话框
  static Future<bool> showRequestDialog(
    BuildContext context,
    PermissionType type,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PermissionDialog(
        type: type,
        dialogType: PermissionDialogType.request,
      ),
    );
    return result ?? false;
  }

  /// 显示权限被拒绝对话框
  static Future<bool> showDeniedDialog(
    BuildContext context,
    PermissionType type,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PermissionDialog(
        type: type,
        dialogType: PermissionDialogType.denied,
      ),
    );
    return result ?? false;
  }

  /// 显示图片来源选择对话框
  /// 返回选择的图片来源类型
  static Future<ImageSourceType?> showSourceDialog(BuildContext context) async {
    return await showDialog<ImageSourceType>(
      context: context,
      builder: (context) => const PermissionDialog(
        type: PermissionType.camera,
        dialogType: PermissionDialogType.source,
      ),
    );
  }
}

/// 对话框类型
enum PermissionDialogType {
  /// 权限请求说明
  request,

  /// 权限被拒绝
  denied,

  /// 图片来源选择
  source,
}

/// 图片来源类型
enum ImageSourceType {
  camera,
  gallery,
}
