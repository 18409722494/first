import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/permission_type.dart';
import '../services/permission_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 图片选择器字段组件
///
/// 支持：
/// - 点击选择图片来源（相机/相册）
/// - 权限自动申请
/// - 图片预览
///
/// 使用示例：
/// ```dart
/// ImagePickerField(
///   imageBytes: _imageBytes,
///   onImageSelected: (bytes, file) { ... },
///   imageQuality: 80,
/// )
/// ```
class ImagePickerField extends StatelessWidget {
  /// 当前的图片字节数据
  final Uint8List? imageBytes;

  /// 图片文件
  final XFile? imageFile;

  /// 图片选择后的回调
  final void Function(Uint8List bytes, XFile file) onImageSelected;

  /// 图片质量 (0-100)
  final int imageQuality;

  /// 预览区域高度
  final double? height;

  /// 错误提示文本的本地化回调
  final String Function(String key) l10n;

  const ImagePickerField({
    super.key,
    this.imageBytes,
    this.imageFile,
    required this.onImageSelected,
    this.imageQuality = 80,
    this.height,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        height: height ?? Responsive.height(context, 200),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.file(
                  File(imageFile!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: Responsive.iconSize(context, 48),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                  Text(
                    l10n('tapSelectPhoto'),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.fontSize(context, 14),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    final l10nStr = l10n('selectImageSource');
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10nStr),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _pickImageFromSource(context, ImageSource.camera);
            },
            child: Text(l10n('camera')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _pickImageFromSource(context, ImageSource.gallery);
            },
            child: Text(l10n('album')),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromSource(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();

    try {
      if (source == ImageSource.camera) {
        final ok = await PermissionService.request(
          PermissionType.camera,
          context: context,
        );
        if (!ok) return;
      } else {
        if (!Platform.isAndroid) {
          final ok = await PermissionService.request(
            PermissionType.photos,
            context: context,
          );
          if (!ok) return;
        }
      }

      XFile? pickedFile;
      try {
        pickedFile = await picker.pickImage(
          source: source,
          imageQuality: imageQuality,
        );
      } catch (_) {
        if (source == ImageSource.gallery && Platform.isAndroid && context.mounted) {
          final ok = await PermissionService.request(
            PermissionType.photos,
            context: context,
          );
          if (ok) {
            pickedFile = await picker.pickImage(
              source: source,
              imageQuality: imageQuality,
            );
          }
        } else {
          rethrow;
        }
      }

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        onImageSelected(bytes, pickedFile);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n('imageSelectFailed'))),
        );
      }
    }
  }
}
