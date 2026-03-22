import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/luggage.dart';
import '../constants/app_constants.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../components/status_badge.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

/// 超重费用/称重页面
/// 用于确认补缴费用或重新称重录入
class OverweightScreen extends StatefulWidget {
  final Luggage luggage;

  const OverweightScreen({Key? key, required this.luggage}) : super(key: key);

  @override
  State<OverweightScreen> createState() => _OverweightScreenState();
}

class _OverweightScreenState extends State<OverweightScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.luggage.weight.toString();
    _feeController.text = AppConstants.calculateOverweightFee(widget.luggage.weight).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('处理成功')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理失败: $e')),
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

  void _updateFee() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    _feeController.text = AppConstants.calculateOverweightFee(weight).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('超重费用/称重'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行李信息卡片
            _buildLuggageInfoCard(context, isDark),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

            // 称重信息
            Text(
              '称重信息',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.fontSize(context, 15),
                  ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            AppTextField(
              controller: _weightController,
              label: '行李重量',
              hint: '请输入实际重量',
              suffixText: 'kg',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.scale,
              onChanged: (value) => _updateFee(),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

            // 费用信息
            Text(
              '费用信息',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.fontSize(context, 15),
                  ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            _buildFeeCard(context, isDark),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

            // 提示信息
            _buildWarningCard(context, isDark),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

            // 提交按钮
            AppButton(
              text: '确认处理',
              type: AppButtonType.primary,
              fullWidth: true,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuggageInfoCard(BuildContext context, bool isDark) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行：图标 + 文字 + 状态徽章
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.spacing(context, 6)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.luggage,
                    color: AppColors.primary,
                    size: Responsive.iconSize(context, 18),
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                Expanded(
                  child: Text(
                    '行李信息',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                  ),
                ),
                StatusBadge(status: widget.luggage.status),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            const Divider(height: 1),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

            // 行李详情
            _buildInfoRow(context, '标签号', widget.luggage.tagNumber),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            _buildInfoRow(context, '航班号', widget.luggage.flightNumber),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            _buildInfoRow(context, '乘客', widget.luggage.passengerName),
            if (widget.luggage.destination.isNotEmpty) ...[
              SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
              _buildInfoRow(context, '目的地', widget.luggage.destination),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Responsive.spacing(context, 60),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: Responsive.fontSize(context, 13),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 13),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeCard(BuildContext context, bool isDark) {
    final fee = double.tryParse(_feeController.text) ?? 0.0;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      elevation: 1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.cardPadding)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primaryDark.withValues(alpha: 0.2),
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primaryLight.withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                  size: Responsive.iconSize(context, 20),
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                Text(
                  '超重费用',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: Responsive.fontSize(context, 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            AppTextField(
              controller: _feeController,
              readOnly: true,
              hint: '自动计算',
              prefixIcon: Icons.currency_yuan,
              textAlign: TextAlign.center,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, AppSpacing.sm),
                vertical: Responsive.spacing(context, AppSpacing.sm),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            if (fee > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, AppSpacing.md),
                  vertical: Responsive.spacing(context, AppSpacing.xs),
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  '需补缴费用',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: Responsive.fontSize(context, 13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: Responsive.iconSize(context, 18),
          ),
          SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
          Expanded(
            child: Text(
              '超重费用将自动计算，确认后将通知旅客补缴。',
              style: TextStyle(
                color: isDark
                    ? AppColors.warning.withValues(alpha: 0.9)
                    : AppColors.warning.withValues(alpha: 0.8),
                fontSize: Responsive.fontSize(context, 12),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
