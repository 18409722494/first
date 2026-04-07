import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.changeAvatar),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.selectAvatarSource),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ==================== 相册权限 - 使用 PermissionService ====================
                FilledButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(dialogContext);
                    final messenger = ScaffoldMessenger.of(context);
                    final hasPermission = await PermissionService.requestPhotos(context);

                    if (!mounted) return;

                    if (hasPermission) {
                      navigator.pop();

                      try {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );

                        if (!mounted) return;

                        if (image != null) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.avatarSelected(image.name))),
                          );
                        } else {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.avatarCancelled)),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.imageSelectFailed)),
                        );
                      }
                    } else {
                      navigator.pop();
                    }
                  },
                  icon: Icon(Icons.photo_library_outlined, size: Responsive.iconSize(context, 20)),
                  label: Text(l10n.album, style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                ),
                // ==================== 相机权限 - 使用 PermissionService ====================
                FilledButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(dialogContext);
                    final messenger = ScaffoldMessenger.of(context);
                    final hasPermission = await PermissionService.requestCamera(context);

                    if (!mounted) return;

                    if (hasPermission) {
                      navigator.pop();

                      try {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 80,
                        );

                        if (!mounted) return;

                        if (image != null) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.avatarCaptureSuccess(image.name))),
                          );
                        } else {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.avatarCancelled)),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.imageSelectFailed)),
                        );
                      }
                    } else {
                      navigator.pop();
                    }
                  },
                  icon: Icon(Icons.camera_alt_outlined, size: Responsive.iconSize(context, 20)),
                  label: Text(l10n.camera, style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showChangeNicknameDialog() {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.changeNickname),
        content: TextField(
          controller: nicknameController,
          decoration: InputDecoration(
            labelText: l10n.newNickname,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (nicknameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.nicknameEmpty)),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.nicknameChangedSuccess)),
                );
              });
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personalizationTitle),
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
                      title: Text(l10n.changeAvatar, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: _showChangeAvatarDialog,
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.edit_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text(l10n.changeNickname, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
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
                        l10n.personalizationNote,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                      Text(
                        l10n.personalizationNoteContent,
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
