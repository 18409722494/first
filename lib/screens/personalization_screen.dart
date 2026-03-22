import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  void _showChangeAvatarDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('修改头像'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请选择头像来源'),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ==================== 相册权限 - 使用 PermissionService ====================
                FilledButton.icon(
                  onPressed: () async {
                    final hasPermission = await PermissionService.requestPhotos(context);

                    if (hasPermission) {
                      Navigator.pop(dialogContext);

                      try {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );

                        if (image != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('头像选择成功: ${image.name}')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已取消选择')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('选择图片失败: ${e.toString()}')),
                        );
                      }
                    } else {
                      Navigator.pop(dialogContext);
                    }
                  },
                  icon: Icon(Icons.photo_library_outlined, size: Responsive.iconSize(context, 20)),
                  label: Text('相册', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                ),
                // ==================== 相机权限 - 使用 PermissionService ====================
                FilledButton.icon(
                  onPressed: () async {
                    final hasPermission = await PermissionService.requestCamera(context);

                    if (hasPermission) {
                      Navigator.pop(dialogContext);

                      try {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 80,
                        );

                        if (image != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('头像拍摄成功: ${image.name}')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已取消拍摄')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('拍摄失败: ${e.toString()}')),
                        );
                      }
                    } else {
                      Navigator.pop(dialogContext);
                    }
                  },
                  icon: Icon(Icons.camera_alt_outlined, size: Responsive.iconSize(context, 20)),
                  label: Text('拍照', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showChangeNicknameDialog() {
    final nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: nicknameController,
          decoration: const InputDecoration(
            labelText: '新昵称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (nicknameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('昵称不能为空')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('昵称修改成功')),
                );
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个性化设置'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final username = user?.username ?? 'User';
          final avatarRadiusVal = Responsive.avatarRadius(context, 60);

          return ListView(
            padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.spacing(context, AppSpacing.lg)),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: avatarRadiusVal,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          username.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 48),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                      Text(
                        username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.fontSize(context, 20),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.account_circle_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('修改头像', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: _showChangeAvatarDialog,
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.edit_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('修改昵称', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: _showChangeNicknameDialog,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '个性化设置说明',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                      Text(
                        '• 修改头像可以让您的个人资料更加个性化\n• 修改昵称可以更改您在系统中的显示名称\n• 这些设置仅影响您的个人资料显示，不会影响您的账户安全',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: Responsive.fontSize(context, 13),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
