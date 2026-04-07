import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../services/damage_report_service.dart';
import '../services/permission_service.dart';
import '../services/luggage_service.dart';
import '../models/permission_type.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 破损报告界面
/// 用于提交行李破损报告，包括图片上传、信息填写和哈希计算
class DamageReportScreen extends StatefulWidget {
  /// 从扫码页跳转时传入的行李标识（可能是行李号 tagNumber，也可能是数据库 id）
  final String? luggageId;
  /// 行李的数据库 id（可选），用于提交成功后同步更新行李状态
  final String? luggageDbId;

  const DamageReportScreen({Key? key, this.luggageId, this.luggageDbId}) : super(key: key);

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
  /// 行李的数据库 id，优先用构造器传入的值；若未传入则从行李号查询
  String? _resolvedLuggageDbId;

  @override
  void initState() {
    super.initState();
    if (widget.luggageId != null) {
      _luggageIdController.text = widget.luggageId!;
    }
    _resolvedLuggageDbId = widget.luggageDbId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshLocation(showFailureSnack: true);
        _resolveLuggageDbId();
      }
    });
  }

  /// 若构造器未传 luggageDbId，则通过行李号查询对应的数据库 id
  Future<void> _resolveLuggageDbId() async {
    if (_resolvedLuggageDbId != null) return;
    final tag = _luggageIdController.text.trim();
    if (tag.isEmpty) return;
    try {
      final luggage = await LuggageService.getLuggageForScan(tag);
      if (mounted && luggage.id.isNotEmpty) {
        setState(() => _resolvedLuggageDbId = luggage.id);
      }
    } catch (_) {}
  }

  // ==================== 位置：服务开关 + 最近位置 + 降级精度 ====================

  /// 解析当前坐标。室内/弱 GPS 时 [high] 易超时，故依次尝试最近位置与 medium/low。
  Future<Position?> _resolvePosition({
    required bool showPermissionDeniedSnack,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted && showPermissionDeniedSnack) {
        PermissionService.showSnackBar(
          context,
          '请打开手机「定位服务」后重试，或点右上角定位图标',
        );
      }
      return null;
    }

    final hasPermission = await PermissionService.requestLocation(
      context,
      showDeniedSnackBar: showPermissionDeniedSnack,
    );
    if (!hasPermission) return null;

    // 1) 最近已知位置（秒级返回，室内常用）
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        final age = DateTime.now().difference(last.timestamp);
        if (age.inMinutes <= 60) {
          return last;
        }
      }
    } catch (_) {}

    // 2) 实时定位：先 medium（室内比 high 容易成功），再 low
    for (final accuracy in [
      LocationAccuracy.medium,
      LocationAccuracy.low,
    ]) {
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: accuracy,
            timeLimit: const Duration(seconds: 25),
          );
        } catch (_) {
          if (attempt < 1) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }
    }

    return null;
  }

  /// 刷新页面上的 [_position]。
  Future<void> _refreshLocation({bool showFailureSnack = false}) async {
    final pos = await _resolvePosition(showPermissionDeniedSnack: showFailureSnack);
    if (!mounted) return;
    setState(() => _position = pos);
    if (pos == null && showFailureSnack) {
      PermissionService.showSnackBar(
        context,
        '无法获取位置：请开启定位/GPS，或到空旷处后点右上角「重新定位」',
      );
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
      if (source == ImageSource.camera) {
        final ok = await PermissionService.request(
          PermissionType.camera,
          context: context,
        );
        if (!ok) return;
      } else {
        // Android 13+ 上 image_picker 走系统 Photo Picker，多数机型无需 READ_MEDIA_IMAGES；
        // 部分国产系统先调 permission_handler 会拿不到系统弹窗、直接 denied，导致永远进不了相册。
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
        pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );
      } catch (_) {
        // Android 低版本若必须先授权存储，再请求一次后重试
        if (source == ImageSource.gallery && Platform.isAndroid && mounted) {
          final ok = await PermissionService.request(
            PermissionType.photos,
            context: context,
          );
          if (ok) {
            pickedFile = await _picker.pickImage(
              source: source,
              imageQuality: 80,
            );
          }
        } else {
          rethrow;
        }
      }

      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _selectedImage = pickedFile;
          });
        }
        _imageBytes = await pickedFile.readAsBytes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择一张图片')),
        );
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      // 进入页时可能未拿到坐标（室内高精度超时等），提交前再完整尝试一次
      Position? pos = _position;
      if (pos == null) {
        pos = await _resolvePosition(showPermissionDeniedSnack: true);
        if (mounted && pos != null) {
          setState(() => _position = pos);
        }
      }

      if (pos == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '未获取到位置：请打开手机定位与 GPS，或到窗边/室外后点右上角「重新定位」再提交',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      final result = await DamageReportService.submitDamageReport(
        imageBytes: _imageBytes!,
        luggageId: _luggageIdController.text.trim(),
        timestamp: DateTime.now(),
        latitude: pos.latitude,
        longitude: pos.longitude,
        damageDescription: _descriptionController.text.trim(),
        luggageDbId: _resolvedLuggageDbId,
      );

      if (!mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('报告提交成功，行李状态已同步为已损坏')),
        );
        _resetForm();
      } else {
        _showDetailedError(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交报告失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDetailedError(DamageReportResult result) {
    final stage = result.stageLabel;
    final statusCode = result.statusCode;
    final body = result.responseBody;
    final exception = result.exceptionMessage;

    String message;
    if (exception != null && statusCode == null) {
      // 网络 / DNS / 超时等底层异常
      message = '[$stage] 网络异常：$exception';
    } else if (statusCode == 0) {
      message = '[$stage] 无法连接服务器（HTTP 0）：$body';
    } else if (statusCode == 404) {
      message = '[$stage] 接口不存在（404）：请确认后端已启动并部署';
    } else if (statusCode == 403 || statusCode == 401) {
      message = '[$stage] 权限/认证失败（$statusCode）：请检查后端接口权限';
    } else if (statusCode != null) {
      // 业务错误（400/409/500 等），展示后端返回的 body
      final hint = _parseBusinessHint(body);
      message = '[$stage] HTTP $statusCode${hint.isNotEmpty ? '：$hint' : ''}';
    } else {
      message = '[$stage] 未知错误';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 13)),
          duration: Duration(seconds: body != null && body.length > 100 ? 8 : 5),
          action: SnackBarAction(
            label: '详情',
            onPressed: () => _showErrorDetailDialog(result),
          ),
        ),
      );
    }
  }

  String _parseBusinessHint(String? body) {
    if (body == null || body.isEmpty) return '';
    try {
      // 尝试解析 JSON，取其中 message/msg/result 等常见字段
      final lower = body.toLowerCase();
      if (lower.contains('not found') || lower.contains('不存在')) {
        return '行李号在系统中不存在';
      }
      if (lower.contains('duplicate') || lower.contains('重复')) {
        return '该行李已存在破损报告（重复提交）';
      }
      if (lower.contains('hash')) {
        return '哈希校验失败';
      }
      // 简单返回原始 body 前 80 字符
      return body.length > 80 ? '${body.substring(0, 80)}…' : body;
    } catch (_) {
      return body.length > 80 ? '${body.substring(0, 80)}…' : body;
    }
  }

  void _showErrorDetailDialog(DamageReportResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('[${result.stageLabel}] 详细信息'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('阶段', result.stageLabel),
              if (result.statusCode != null)
                _detailRow('HTTP 状态码', '${result.statusCode}'),
              if (result.exceptionMessage != null)
                _detailRow('异常信息', result.exceptionMessage!),
              if (result.responseBody != null)
                _detailRow('响应正文', result.responseBody!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
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
        actions: [
          IconButton(
            tooltip: '重新获取位置',
            onPressed: _isLoading
                ? null
                : () => _refreshLocation(showFailureSnack: true),
            icon: const Icon(Icons.my_location),
          ),
        ],
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
                )
              else
                Container(
                  padding: EdgeInsets.all(paddingMd),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: Responsive.iconSize(context, 20),
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                      Expanded(
                        child: Text(
                          '尚未获取到位置。请开启定位/GPS；提交时会自动再试，也可点右上角或下方按钮刷新。',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 13),
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => _refreshLocation(showFailureSnack: true),
                        child: const Text('获取位置'),
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
