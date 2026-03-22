import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../services/damage_report_service.dart';
import '../services/local_queue_service.dart';
import '../services/permission_service.dart';
import '../models/permission_type.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 破损报告界面
/// 用于提交行李破损报告，包括图片上传、信息填写和哈希计算
class DamageReportScreen extends StatefulWidget {
  final String? luggageId;

  const DamageReportScreen({Key? key, this.luggageId}) : super(key: key);

  @override
  State<DamageReportScreen> createState() => _DamageReportScreenState();
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _luggageIdController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _imageBytes;
  Position? _position;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initLocalQueue();
    if (widget.luggageId != null) {
      _luggageIdController.text = widget.luggageId!;
    }
    _getCurrentLocation();
  }

  Future<void> _initLocalQueue() async {
    try {
      await LocalQueueService.init();
      await DamageReportService.processLocalQueue();
    } catch (e) {
      debugPrint('初始化本地队列失败: $e');
    }
  }

  // ==================== 位置权限 - 使用 PermissionService ====================

  Future<void> _getCurrentLocation() async {
    // 使用 PermissionService 请求位置权限
    final hasPermission = await PermissionService.requestLocation(context);

    if (!hasPermission) {
      return;
    }

    // 权限获取成功后，尝试获取位置
    Position? position;
    for (int i = 0; i < 3; i++) {
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        break;
      } catch (e) {
        debugPrint('第${i + 1}次获取位置失败：$e');
        if (i < 2) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    if (position != null) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    } else {
      if (mounted) {
        PermissionService.showSnackBar(
          context,
          '无法获取位置信息，请检查 GPS 是否开启',
        );
      }
    }
  }

  // ==================== 图片选择 - 使用 PermissionService ====================

  Future<void> _showImageSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图片来源'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImageFromSource(ImageSource.camera);
            },
            child: const Text('相机'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImageFromSource(ImageSource.gallery);
            },
            child: const Text('相册'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      // 使用 PermissionService 请求对应权限
      final PermissionType permissionType = source == ImageSource.camera
          ? PermissionType.camera
          : PermissionType.photos;

      final hasPermission = await PermissionService.request(
        permissionType,
        context: context,
      );

      if (!hasPermission) {
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _selectedImage = pickedFile;
          });
        }
        _imageBytes = await pickedFile.readAsBytes();
      }
    } catch (e) {
      debugPrint('选择图片失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('选择图片失败')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请选择一张图片')),
          );
        }
        return;
      }

      if (_position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('正在获取位置信息，请稍后再试')),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      try {
        final success = await DamageReportService.submitDamageReport(
          imageBytes: _imageBytes!,
          luggageId: _luggageIdController.text.trim(),
          timestamp: DateTime.now(),
          latitude: _position!.latitude,
          longitude: _position!.longitude,
          damageDescription: _descriptionController.text.trim(),
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('报告提交成功')),
            );
            _resetForm();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('报告提交失败，已保存到本地队列')),
            );
          }
        }
      } catch (e) {
        debugPrint('提交报告失败: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('提交报告失败，请稍后再试')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _resetForm() {
    if (mounted) {
      setState(() {
        _selectedImage = null;
        _imageBytes = null;
        _luggageIdController.clear();
        _descriptionController.clear();
      });
    }
  }

  @override
  void dispose() {
    _luggageIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingMd = Responsive.padding(context, AppSpacing.md);

    return Scaffold(
      appBar: AppBar(
        title: const Text('行李破损报告'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: Responsive.height(context, 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
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
                              '点击选择破损照片',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: Responsive.fontSize(context, 14),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              AppTextField(
                controller: _luggageIdController,
                label: '行李ID',
                hint: '请输入行李ID',
                prefixIcon: Icons.luggage,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入行李ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              AppTextField(
                controller: _descriptionController,
                label: '破损描述',
                hint: '请描述行李破损情况',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入破损描述';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              if (_position != null)
                Container(
                  padding: EdgeInsets.all(paddingMd),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: Responsive.iconSize(context, 20),
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                      Expanded(
                        child: Text(
                          '位置: ${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 14),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              AppButton(
                text: '提交报告',
                type: AppButtonType.primary,
                size: AppButtonSize.large,
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: _submitReport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
