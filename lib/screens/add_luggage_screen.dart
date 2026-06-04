import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../components/status_badge.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../l10n/app_localizations.dart';

/// 更改行李页面
/// 用于扫码无法识别时手动查找并更新行李状态和位置
class AddLuggageScreen extends StatefulWidget {
  const AddLuggageScreen({super.key});

  @override
  State<AddLuggageScreen> createState() => _AddLuggageScreenState();
}

class _AddLuggageScreenState extends State<AddLuggageScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tagNumberController = TextEditingController();
  final _locationController = TextEditingController();

  LuggageStatus _selectedStatus = LuggageStatus.checkIn;
  bool _isLoading = false;

  @override
  void dispose() {
    _tagNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// 提交表单（仅更新行李位置和状态）
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tagNumber = _tagNumberController.text.trim();
    final location = _locationController.text.trim();
    if (tagNumber.isEmpty || location.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('行李标签号和位置不能为空'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      final employeeId = currentUser?.username ?? '';

      await LuggageService.updateScanLocation(
        baggageNumber: tagNumber,
        location: location,
        status: BaggageStatusMapper.toBackendLocationStatus(_selectedStatus),
        employeeId: employeeId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('行李状态和位置已更新'),
          backgroundColor: AppColors.success,
        ),
      );

      _tagNumberController.clear();
      _locationController.clear();
      setState(() {
        _selectedStatus = LuggageStatus.checkIn;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新失败: ${e.toString()}'),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addLuggageInfo),
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
                    AppTextField(
                      controller: _tagNumberController,
                      label: l10n.luggageTagNoLabel,
                      hint: l10n.enterLuggageTagNo,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterLuggageTagNo;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    AppTextField(
                      controller: _locationController,
                      label: l10n.destination,
                      hint: l10n.enterDestination,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterDestination;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                    Text(
                      l10n.luggageStatus,
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

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final currentUser = authProvider.user;
                        return AppTextField(
                          controller: TextEditingController(
                              text: currentUser?.employeeId ?? l10n.unknownUser),
                          label: l10n.operatorEmployee,
                          readOnly: true,
                        );
                      },
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
                text: '确认更改',
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
