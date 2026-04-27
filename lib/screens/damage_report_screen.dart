import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../components/image_picker_field.dart';
import '../services/damage_report_service.dart';
import '../services/permission_service.dart';
import '../services/location_service.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 破损报告页面 - 基于 UI 设计风格 (Frame2632)
class DamageReportScreen extends StatefulWidget {
  final String? luggageId;
  final String? luggageDbId;

  const DamageReportScreen({super.key, this.luggageId, this.luggageDbId});

  @override
  State<DamageReportScreen> createState() => _DamageReportScreenState();
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _luggageIdController = TextEditingController();
  final _descriptionController = TextEditingController();

  Uint8List? _imageBytes;
  XFile? _imageFile;
  Position? _position;
  bool _isLoading = false;
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

  Future<void> _resolveLuggageDbId() async {
    if (_resolvedLuggageDbId != null) return;
    final tag = _luggageIdController.text.trim();
    if (tag.isEmpty) return;
    try {
      final result = await LuggageService.getLuggageForScan(tag);
      if (result.success && result.luggage != null && mounted) {
        setState(() => _resolvedLuggageDbId = result.luggage!.id);
      }
    } catch (_) {}
  }

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

    return LocationService.getCurrentDevicePosition();
  }

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

  void _onImageSelected(Uint8List bytes, XFile file) {
    setState(() {
      _imageBytes = bytes;
      _imageFile = file;
    });
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
              duration: const Duration(seconds: 5),
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
      );

      if (!mounted) return;
      if (result.success) {
        // 检查状态同步是否完成
        if (!result.statusSyncCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.exceptionMessage ?? l10n.damageReportSuccess),
              backgroundColor: AppColors.warning,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.damageReportSuccess)),
          );
        }
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
        _imageBytes = null;
        _imageFile = null;
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
    final padMd = Responsive.padding(context, AppSpacing.md);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          l10n.damageReportTitle,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        actions: [
          IconButton(
            tooltip: l10n.reloadLocation,
            onPressed: _isLoading
                ? null
                : () => _refreshLocation(showFailureSnack: true),
            icon: const Icon(Icons.my_location, color: AppColors.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 提示信息
              Container(
                padding: EdgeInsets.all(padMd),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '请如实填写破损情况，证据将经哈希验证',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.warning.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 图片选择器
              ImagePickerField(
                imageBytes: _imageBytes,
                imageFile: _imageFile,
                onImageSelected: _onImageSelected,
                height: Responsive.height(context, 180),
                l10n: (key) {
                  final l10n = AppLocalizations.of(context)!;
                  switch (key) {
                    case 'selectImageSource': return l10n.selectImageSource;
                    case 'camera': return l10n.camera;
                    case 'album': return l10n.album;
                    case 'imageSelectFailed': return l10n.imageSelectFailed;
                    case 'tapSelectPhoto': return l10n.tapSelectPhoto;
                    default: return key;
                  }
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 行李信息卡片
              Container(
                padding: EdgeInsets.all(padMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.luggage_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _luggageIdController.text.isNotEmpty
                                ? _luggageIdController.text
                                : '行李号',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '请扫描或输入行李标签号',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 行李号输入框
              _buildInputField(
                controller: _luggageIdController,
                label: '行李标签号',
                hint: '扫描或手动输入',
                icon: Icons.qr_code,
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 破损类型选择
              _buildSectionTitle('破损类型'),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDamageTypeTag('外壳破损'),
                  _buildDamageTypeTag('拉链损坏'),
                  _buildDamageTypeTag('轮子损坏'),
                  _buildDamageTypeTag('提手断裂'),
                  _buildDamageTypeTag('内容物损坏'),
                ],
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 破损描述输入框
              _buildSectionTitle('破损描述'),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '请详细描述破损情况...',
                    hintStyle: const TextStyle(color: AppColors.textHintLight),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.enterDamageDesc;
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 位置信息显示
              _buildLocationCard(),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              // 提交按钮
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textHintLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.submitReport,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
              color: AppColors.textPrimaryLight,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textHintLight),
              prefixIcon: Icon(icon, color: AppColors.textSecondaryLight, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDamageTypeTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(
            _position != null ? Icons.location_on : Icons.location_off_outlined,
            size: 20,
            color: _position != null ? AppColors.success : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _position != null
                ? Text(
                    'GPS: ${_position!.latitude.toStringAsFixed(6)}°N, ${_position!.longitude.toStringAsFixed(6)}°E',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimaryLight,
                    ),
                  )
                : Text(
                    'GPS: 等待获取位置...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
          ),
          TextButton(
            onPressed: _isLoading ? null : () => _refreshLocation(showFailureSnack: true),
            child: Text(
              '刷新',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
