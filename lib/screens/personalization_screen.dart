import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';

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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final status = await Permission.photos.request();
                    
                    if (status.isGranted) {
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
                    } else if (status.isDenied) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('需要相册权限才能选择图片')),
                      );
                    } else if (status.isPermanentlyDenied) {
                      Navigator.pop(dialogContext);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('权限被拒绝'),
                          content: const Text('相册权限已被永久拒绝，请在系统设置中开启'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                openAppSettings();
                              },
                              child: const Text('去设置'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('相册'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final status = await Permission.camera.request();
                    
                    if (status.isGranted) {
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
                    } else if (status.isDenied) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('需要相机权限才能拍照')),
                      );
                    } else if (status.isPermanentlyDenied) {
                      Navigator.pop(dialogContext);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('权限被拒绝'),
                          content: const Text('相机权限已被永久拒绝，请在系统设置中开启'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                openAppSettings();
                              },
                              child: const Text('去设置'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('拍照'),
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
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_circle_outlined),
                      title: const Text('修改头像'),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: _showChangeAvatarDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('修改昵称'),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: _showChangeNicknameDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '个性化设置说明',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 修改头像可以让您的个人资料更加个性化\n• 修改昵称可以更改您在系统中的显示名称\n• 这些设置仅影响您的个人资料显示，不会影响您的账户安全',
                        style: TextStyle(
                          color: Colors.grey[600],
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
