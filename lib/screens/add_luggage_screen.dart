import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../components/status_badge.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 添加行李页面
/// 用于手动录入行李信息
class AddLuggageScreen extends StatefulWidget {
  const AddLuggageScreen({super.key});

  @override
  State<AddLuggageScreen> createState() => _AddLuggageScreenState();
}

class _AddLuggageScreenState extends State<AddLuggageScreen> {
  final _formKey = GlobalKey<FormState>();

  // 表单字段
  final _tagNumberController = TextEditingController();
  final _flightNumberController = TextEditingController();
  final _passengerNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();

  // 图片上传
  final List<String> _images = [];
  bool _isUploading = false;

  // 选择的状态
  LuggageStatus _selectedStatus = LuggageStatus.checkIn;

  // 加载状态
  bool _isLoading = false;

  // 位置信息（初始化一次，不再重新生成）
  late final double _latitude;
  late final double _longitude;

  _AddLuggageScreenState() {
    final random = Random();
    _latitude = 39.9042 + (random.nextDouble() - 0.5) * 0.1;
    _longitude = 116.4074 + (random.nextDouble() - 0.5) * 0.1;
  }

  @override
  void dispose() {
    _tagNumberController.dispose();
    _flightNumberController.dispose();
    _passengerNameController.dispose();
    _weightController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 上传图片
  Future<void> _uploadImage() async {
    if (_images.length >= 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传3张照片')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockImageUrl = 'https://picsum.photos/seed/${Random().nextInt(1000)}/300/300';

      if (!mounted) return;
      setState(() {
        _images.add(mockImageUrl);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('照片上传成功')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败：$e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// 提交表单
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('您还没有上传行李照片，这是定责的重要依据。确定要继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('继续'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      final luggage = Luggage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tagNumber: _tagNumberController.text.trim(),
        flightNumber: _flightNumberController.text.trim(),
        passengerName: _passengerNameController.text.trim(),
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
        status: _selectedStatus,
        checkInTime: DateTime.now(),
        lastUpdated: DateTime.now(),
        destination: _destinationController.text.trim(),
        notes: '${_notesController.text.trim()} ${_images.isNotEmpty ? '[已上传${_images.length}张照片]' : ''} ${currentUser != null ? '[操作员工：${currentUser.username}]' : ''}',
        latitude: _latitude,
        longitude: _longitude,
      );

      await LuggageService.addLuggage(luggage);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('行李信息添加成功！'),
          backgroundColor: AppColors.success,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('添加失败：${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加行李信息'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 行李标签号
                    AppTextField(
                      controller: _tagNumberController,
                      label: '行李标签号',
                      hint: '请输入行李标签号',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入行李标签号';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 航班号
                    AppTextField(
                      controller: _flightNumberController,
                      label: '航班号',
                      hint: '请输入航班号',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入航班号';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 乘客姓名
                    AppTextField(
                      controller: _passengerNameController,
                      label: '乘客姓名',
                      hint: '请输入乘客姓名',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入乘客姓名';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 行李重量
                    AppTextField(
                      controller: _weightController,
                      label: '行李重量 (kg)',
                      hint: '请输入行李重量',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入行李重量';
                        }
                        if (double.tryParse(value) == null) {
                          return '请输入有效的重量';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 目的地
                    AppTextField(
                      controller: _destinationController,
                      label: '目的地',
                      hint: '请输入目的地',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入目的地';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 行李状态
                    Text(
                      '行李状态',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 12),
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                    StatusBadgeSelector(
                      currentStatus: _selectedStatus,
                      onStatusChanged: (status) {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 备注
                    AppTextField(
                      controller: _notesController,
                      label: '备注',
                      hint: '请输入备注信息（可选）',
                      maxLines: 2,
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 操作员工
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final currentUser = authProvider.user;
                        return AppTextField(
                          controller: TextEditingController(text: currentUser?.username ?? '未知用户'),
                          label: '操作员工',
                          readOnly: true,
                        );
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 位置信息
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: TextEditingController(text: _latitude.toStringAsFixed(6)),
                            label: '纬度',
                            readOnly: true,
                          ),
                        ),
                        SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                        Expanded(
                          child: AppTextField(
                            controller: TextEditingController(text: _longitude.toStringAsFixed(6)),
                            label: '经度',
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                    Text(
                      '位置信息将自动获取',
                      style: TextStyle(fontSize: Responsive.fontSize(context, 11), color: AppColors.textSecondary),
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    // 图片上传
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '上传照片',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(context, 13)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '请上传行李外观照片，作为定责依据',
                          style: TextStyle(fontSize: Responsive.fontSize(context, 11), color: AppColors.textSecondary),
                        ),
                        SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),

                        Container(
                          padding: EdgeInsets.all(Responsive.spacing(context, AppSpacing.xs)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: Colors.grey[300]!, width: 2),
                          ),
                          child: Column(
                            children: [
                              if (_images.isNotEmpty)
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: AppSpacing.sm,
                                    mainAxisSpacing: AppSpacing.sm,
                                  ),
                                  itemCount: _images.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                            image: DecorationImage(
                                              image: NetworkImage(_images[index]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _images.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Colors.black.withValues(alpha: 0.5),
                                              ),
                                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                              GestureDetector(
                                onTap: _isUploading ? null : _uploadImage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.add_photo_alternate, size: Responsive.iconSize(context, 28), color: Colors.grey[400]),
                                      SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                                      Text(
                                        _isUploading ? '上传中...' : '点击上传照片',
                                        style: TextStyle(color: Colors.grey[600], fontSize: Responsive.fontSize(context, 13)),
                                      ),
                                      Text(
                                        '最多上传3张',
                                        style: TextStyle(fontSize: Responsive.fontSize(context, 11), color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                  ],
                ),
              ),
            ),
          ),
          AppBottomBar(
            children: [
              AppButton(
                text: '添加行李',
                type: AppButtonType.primary,
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: _submitForm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
