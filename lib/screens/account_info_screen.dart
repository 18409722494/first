import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../utils/responsive.dart';

/// 账户信息详情页面
/// 显示员工的详细账户信息，并支持修改个人信息
class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isFetching = false;

  final _formKey = GlobalKey<FormState>();
  final _genderController = TextEditingController();
  final _hometownController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _contactController = TextEditingController();
  final _hireDateController = TextEditingController();

  @override
  void dispose() {
    _genderController.dispose();
    _hometownController.dispose();
    _birthDateController.dispose();
    _contactController.dispose();
    _hireDateController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    _clearControllers();
    setState(() => _isEditing = false);
  }

  void _clearControllers() {
    _genderController.clear();
    _hometownController.clear();
    _birthDateController.clear();
    _contactController.clear();
    _hireDateController.clear();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null || user.employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法获取用户信息')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.updateDetails(
      employeeId: user.employeeId!,
      gender: _genderController.text.trim().isEmpty ? null : _genderController.text.trim(),
      hometown: _hometownController.text.trim().isEmpty ? null : _hometownController.text.trim(),
      birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
      contact: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      hireDate: _hireDateController.text.trim().isEmpty ? null : _hireDateController.text.trim(),
    );

    setState(() => _isLoading = false);

    final l10n = AppLocalizations.of(context)!;

    if (response.success) {
      // 保存成功后更新本地用户状态
      authProvider.updateUserDetails(
        gender: _genderController.text.trim().isEmpty ? null : _genderController.text.trim(),
        hometown: _hometownController.text.trim().isEmpty ? null : _hometownController.text.trim(),
        birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
        contact: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        hireDate: _hireDateController.text.trim().isEmpty ? null : _hireDateController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.personalInfoChangedSuccess),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _isEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final initialDate = controller.text.isNotEmpty
        ? DateTime.tryParse(controller.text) ?? now
        : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      helpText: l10n.selectDate,
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  void _loadUserDetailsToControllers(user) {
    _genderController.text = user?.gender ?? '';
    _hometownController.text = user?.hometown ?? '';
    _birthDateController.text = user?.birthDate ?? '';
    _contactController.text = user?.contact ?? '';
    _hireDateController.text = user?.hireDate ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          l10n.accountInfo,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        actions: [
          if (!_isEditing && !_isFetching)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _startEditing,
              tooltip: l10n.edit,
            ),
          if (_isFetching)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (_isEditing) {
            if (_genderController.text.isEmpty &&
                _hometownController.text.isEmpty &&
                _birthDateController.text.isEmpty &&
                _contactController.text.isEmpty &&
                _hireDateController.text.isEmpty) {
              _loadUserDetailsToControllers(user);
            }
            return _buildEditForm(context, user?.employeeId ?? '');
          }

          return _buildInfoView(context, user);
        },
      ),
    );
  }

  Widget _buildInfoView(BuildContext context, user) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListView(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      children: [
        Card(
          color: cardBg,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.badge_outlined, size: Responsive.iconSize(context, 24), color: AppColors.primary),
                title: Text(l10n.employeeId, style: TextStyle(fontSize: Responsive.fontSize(context, 14), color: textSecondary)),
                subtitle: Text(
                  user?.employeeId ?? '-',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),
        Card(
          color: cardBg,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.wc_outlined, size: Responsive.iconSize(context, 24), color: AppColors.primary),
                title: Text(l10n.gender, style: TextStyle(fontSize: Responsive.fontSize(context, 14), color: textSecondary)),
                subtitle: Text(
                  user?.gender ?? l10n.notSet,
                  style: TextStyle(fontSize: Responsive.fontSize(context, 16), color: textPrimary),
                ),
              ),
              Divider(height: 1, indent: Responsive.spacing(context, 40)),
              ListTile(
                leading: Icon(Icons.location_on_outlined, size: Responsive.iconSize(context, 24), color: AppColors.primary),
                title: Text(l10n.hometown, style: TextStyle(fontSize: Responsive.fontSize(context, 14), color: textSecondary)),
                subtitle: Text(
                  user?.hometown ?? l10n.notSet,
                  style: TextStyle(fontSize: Responsive.fontSize(context, 16), color: textPrimary),
                ),
              ),
              Divider(height: 1, indent: Responsive.spacing(context, 40)),
              ListTile(
                leading: Icon(Icons.cake_outlined, size: Responsive.iconSize(context, 24), color: AppColors.primary),
                title: Text(l10n.birthDate, style: TextStyle(fontSize: Responsive.fontSize(context, 14), color: textSecondary)),
                subtitle: Text(
                  user?.birthDate ?? l10n.notSet,
                  style: TextStyle(fontSize: Responsive.fontSize(context, 16), color: textPrimary),
                ),
              ),
              Divider(height: 1, indent: Responsive.spacing(context, 40)),
              ListTile(
                leading: Icon(Icons.phone_outlined, size: Responsive.iconSize(context, 24), color: AppColors.primary),
                title: Text(l10n.contact, style: TextStyle(fontSize: Responsive.fontSize(context, 14), color: textSecondary)),
                subtitle: Text(
                  user?.contact ?? l10n.notSet,
                  style: TextStyle(fontSize: Responsive.fontSize(context, 16), color: textPrimary),
                ),
              ),
              Divider(height: 1, indent: Responsive.spacing(context, 40)),
              ListTile(
                leading: Icon(Icons.calendar_today_outlined, size: Responsive.iconSize(context, 24), color: AppColors.primary),
                title: Text(l10n.hireDate, style: TextStyle(fontSize: Responsive.fontSize(context, 14), color: textSecondary)),
                subtitle: Text(
                  user?.hireDate ?? l10n.notSet,
                  style: TextStyle(fontSize: Responsive.fontSize(context, 16), color: textPrimary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),
        Card(
          color: cardBg,
          child: Padding(
            padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.accountInfoNote,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                Text(
                  l10n.accountInfoNoteContent,
                  style: TextStyle(
                    color: textSecondary,
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
  }

  Widget _buildEditForm(BuildContext context, String employeeId) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              child: ListView(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
                children: [
                  Card(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    child: Padding(
                      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.personalInfo,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                          _buildReadOnlyField(
                            context,
                            label: l10n.employeeId,
                            value: employeeId,
                            icon: Icons.badge_outlined,
                            isDark: isDark,
                          ),
                          SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                          _buildTextField(
                            context,
                            controller: _genderController,
                            label: l10n.gender,
                            hint: l10n.enterGender,
                            icon: Icons.wc_outlined,
                            isDark: isDark,
                          ),
                          SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                          _buildTextField(
                            context,
                            controller: _hometownController,
                            label: l10n.hometown,
                            hint: l10n.enterHometown,
                            icon: Icons.location_on_outlined,
                            isDark: isDark,
                          ),
                          SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                          _buildDateField(
                            context,
                            controller: _birthDateController,
                            label: l10n.birthDate,
                            icon: Icons.cake_outlined,
                            isDark: isDark,
                          ),
                          SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                          _buildTextField(
                            context,
                            controller: _contactController,
                            label: l10n.contact,
                            hint: l10n.enterContact,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            isDark: isDark,
                          ),
                          SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                          _buildDateField(
                            context,
                            controller: _hireDateController,
                            label: l10n.hireDate,
                            icon: Icons.calendar_today_outlined,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildActionButtons(context, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool isDark = false,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.grey[100],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isDark = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isDark = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.primary),
          onPressed: () => _selectDate(context, controller),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      onTap: () => _selectDate(context, controller),
    );
  }

  Widget _buildActionButtons(BuildContext context, {bool isDark = false}) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _cancelEditing,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.primary,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.spacing(context, AppSpacing.md),
                  ),
                ),
                child: Text(l10n.cancel),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, AppSpacing.md)),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.spacing(context, AppSpacing.md),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
