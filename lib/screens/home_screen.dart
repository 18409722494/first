import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'qr_scan_screen.dart';
import 'search_luggage_screen.dart';
import 'damage_report_screen.dart';
import 'evidence_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacingMd = Responsive.spacing(context, AppSpacing.md);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _navigateToSearch(context),
            icon: Icon(Icons.search, size: Responsive.iconSize(context, 24)),
            tooltip: l10n.searchLuggage,
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, AppSpacing.sm + 4),
              vertical: Responsive.spacing(context, AppSpacing.sm),
            ),
            children: [
              _buildWelcomeCard(context, authProvider.user),
              SizedBox(height: spacingMd),
              _buildQuickActionsSection(context),
              SizedBox(height: spacingMd),
              _buildScanButton(context),
              SizedBox(height: spacingMd),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, user) {
    final l10n = AppLocalizations.of(context)!;
    final avatarR = Responsive.avatarRadius(context, 22);
    final iconSizeVal = Responsive.iconSize(context, 22);
    final hPadding = Responsive.padding(context, AppSpacing.md);
    final vPadding = Responsive.spacing(context, AppSpacing.sm + 4);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarR,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: Icon(Icons.badge_outlined, color: Colors.white, size: iconSizeVal),
            ),
            SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.welcomeBack,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: Responsive.fontSize(context, 12),
                        ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    user?.username.isNotEmpty == true ? user!.username : l10n.employee,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacingMd = Responsive.spacing(context, AppSpacing.md);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 16),
              ),
        ),
        SizedBox(height: spacingMd),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: spacingMd,
          crossAxisSpacing: spacingMd,
          // 略增高单元格，避免英文副标题两行 + 图标区在窄屏下底部溢出
          childAspectRatio: 0.88,
          children: [
            _buildActionCard(
              context,
              icon: Icons.qr_code_scanner,
              title: l10n.scanProcess,
              subtitle: l10n.scanProcessDesc,
              color: Theme.of(context).colorScheme.primary,
              onTap: () => _navigateToQrScan(context),
            ),
            _buildActionCard(
              context,
              icon: Icons.search,
              title: l10n.searchLuggage,
              subtitle: l10n.searchLuggageDesc,
              color: AppColors.info,
              onTap: () => _navigateToSearch(context),
            ),
            _buildActionCard(
              context,
              icon: Icons.report_problem_outlined,
              title: l10n.damageRegistration,
              subtitle: l10n.damageRegistrationDesc,
              color: AppColors.warning,
              onTap: () => _navigateToDamageReport(context),
            ),
            _buildActionCard(
              context,
              icon: Icons.photo_library_outlined,
              title: l10n.evidenceQuery,
              subtitle: l10n.evidenceQueryDesc,
              color: AppColors.error,
              onTap: () => _navigateToEvidence(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.spacing(context, AppSpacing.sm)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  size: Responsive.iconSize(context, 28),
                  color: color,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 15),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 2)),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: Responsive.fontSize(context, 12),
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final btnH = Responsive.buttonHeight(context, 54);

    return SizedBox(
      width: double.infinity,
      height: btnH,
      child: FilledButton.icon(
        onPressed: () => _navigateToQrScan(context),
        icon: Icon(Icons.qr_code_scanner, size: Responsive.iconSize(context, 20)),
        label: Text(l10n.scanQRCode, style: TextStyle(fontSize: Responsive.fontSize(context, 15))),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchLuggageScreen()),
    );
  }

  void _navigateToQrScan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
  }

  void _navigateToDamageReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DamageReportScreen()),
    );
  }

  void _navigateToEvidence(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EvidenceListScreen()),
    );
  }
}
