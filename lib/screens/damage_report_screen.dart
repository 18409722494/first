import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
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

  const DamageReportScreen({super.key, this.luggageId, this.luggageDbId});

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

  // ==================== 位置：权限 + 统一走 LuggageService（优先任意可用坐标） ====================

  /// 不因「系统定位开关」直接放弃：部分机型 isLocationServiceEnabled 误报，仍可能拿到网络/缓存位置。
  Future<Position?> _resolvePosition({
    required bool showPermissionDeniedSnack,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted && showPermissionDeniedSnack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enableLocationService),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (!mounted) return null;
    final hasPermission = await PermissionService.requestLocation(
      context,
      showDeniedSnackBar: showPermissionDeniedSnack,
    );
    if (!hasPermission) return null;

    return LuggageService.getCurrentDevicePosition();
  }

  /// 刷新页面上的 [_position]。
  Future<void> _refreshLocation({bool showFailureSnack = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final pos = await _resolvePosition(showPermissionDeniedSnack: showFailureSnack);
    if (!mounted) return;
    setState(() => _position = pos);
    if (pos == null && showFailureSnack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enableGpsHint),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ==================== 图片选择 - 使用 PermissionService ====================

  Future<void> _showImageSourceDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectImageSource),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImageFromSource(ImageSource.camera);
            },
            child: Text(l10n.camera),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImageFromSource(ImageSource.gallery);
            },
            child: Text(l10n.album),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imageSelectFailed)),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    if (_imageBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectOneImage)),
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
            SnackBar(
              content: Text(l10n.noLocationHint),
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
          SnackBar(content: Text(l10n.damageReportSuccess)),
        );
        _resetForm();
      } else {
        _showDetailedError(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.submitReportFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDetailedError(DamageReportResult result) {
    final l10n = AppLocalizations.of(context)!;
    final stage = result.stageLabel;
    final statusCode = result.statusCode;
    final body = result.responseBody;
    final exception = result.exceptionMessage;

    String message;
    if (exception != null && statusCode == null) {
      message = l10n.networkError(stage, exception);
    } else if (statusCode == 0) {
      message = l10n.serverNotConnected(stage, body ?? '');
    } else if (statusCode == 404) {
      message = l10n.apiNotFound(stage);
    } else if (statusCode == 403 || statusCode == 401) {
      message = l10n.authFailed(stage, statusCode.toString());
    } else if (statusCode != null) {
      final hint = _parseBusinessHint(body);
      message = '[$stage] HTTP $statusCode${hint.isNotEmpty ? '：$hint' : ''}';
    } else {
      message = l10n.unknownError(stage);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 13)),
          duration: Duration(seconds: body != null && body.length > 100 ? 8 : 5),
          action: SnackBarAction(
            label: l10n.detail,
            onPressed: () => _showErrorDetailDialog(result),
          ),
        ),
      );
    }
  }

  String _parseBusinessHint(String? body) {
    if (body == null || body.isEmpty) return '';
    final l10n = AppLocalizations.of(context)!;
    try {
      // 尝试解析 JSON，取其中 message/msg/result 等常见字段
      final lower = body.toLowerCase();
      if (lower.contains('not found') || lower.contains('不存在')) {
        return l10n.baggageNotExist;
      }
      if (lower.contains('duplicate') || lower.contains('重复')) {
        return l10n.duplicateReport;
      }
      if (lower.contains('hash')) {
        return l10n.hashCheckFailed;
      }
      // 简单返回原始 body 前 80 字符
      return body.length > 80 ? '${body.substring(0, 80)}…' : body;
    } catch (_) {
      return body.length > 80 ? '${body.substring(0, 80)}…' : body;
    }
  }

  void _showErrorDetailDialog(DamageReportResult result) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stageDetail(result.stageLabel)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(l10n.stage, result.stageLabel),
              if (result.statusCode != null)
                _detailRow(l10n.httpStatusCode, '${result.statusCode}'),
              if (result.exceptionMessage != null)
                _detailRow(l10n.exceptionInfo, result.exceptionMessage!),
              if (result.responseBody != null)
                _detailRow(l10n.responseBody, result.responseBody!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
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
    final l10n = AppLocalizations.of(context)!;
    final paddingMd = Responsive.padding(context, AppSpacing.md);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.damageReportTitle),
        actions: [
          IconButton(
            tooltip: l10n.reloadLocation,
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
                              l10n.tapSelectPhoto,
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
                label: l10n.luggageId,
                hint: l10n.enterLuggageId,
                prefixIcon: Icons.luggage,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterLuggageId;
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              AppTextField(
                controller: _descriptionController,
                label: l10n.damageDescription,
                hint: l10n.enterDamageDesc,
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterDamageDesc;
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
                          l10n.locationCoords(
                            _position!.latitude.toStringAsFixed(6),
                            _position!.longitude.toStringAsFixed(6),
                          ),
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
                          l10n.noLocationYet,
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
                        child: Text(l10n.getLocation),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              AppButton(
                text: l10n.submitReport,
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
