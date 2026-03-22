import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../components/stat_card.dart';
import '../providers/auth_provider.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'qr_scan_screen.dart';
import 'search_luggage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacingSm = Responsive.spacing(context, AppSpacing.sm);
    final spacingMd = Responsive.spacing(context, AppSpacing.md);

    return Scaffold(
      appBar: AppBar(
        title: const Text('行李管理工作台'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _navigateToSearch(context),
            icon: Icon(Icons.search, size: Responsive.iconSize(context, 24)),
            tooltip: '查询行李',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, AppSpacing.pageHorizontal),
            ),
            child: Column(
              children: [
                SizedBox(height: spacingSm),
                _buildWelcomeCard(context, authProvider.user),
                SizedBox(height: spacingMd),
                _buildStartWorkingSection(context),
                SizedBox(height: spacingMd),
                _buildStatsSection(context),
                SizedBox(height: spacingMd),
                _buildChartSection(context),
                const Spacer(),
                _buildScanButton(context),
                SizedBox(height: spacingMd),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, user) {
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
                    '欢迎回来，航司工作人员',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: Responsive.fontSize(context, 12),
                        ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    user?.username.isNotEmpty == true ? user!.username : '员工',
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

  Widget _buildStartWorkingSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '开始工作',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 16),
                  ),
            ),
            SizedBox(height: Responsive.spacing(context, 2)),
            Text(
              '点击扫描行李二维码',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.fontSize(context, 12),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final spacingSmVal = Responsive.spacing(context, AppSpacing.sm);
    final spacingMdVal = Responsive.spacing(context, AppSpacing.md);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日概览',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.fontSize(context, 15),
              ),
        ),
        SizedBox(height: spacingMdVal),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: '今日处理',
                value: '${AppConstants.mockTodayProcessed}',
                unit: '件',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: spacingSmVal),
            Expanded(
              child: StatCard(
                title: '异常行李',
                value: '${AppConstants.mockAbnormalLuggage}',
                unit: '件',
                icon: Icons.warning_amber_outlined,
                color: AppColors.warning,
              ),
            ),
            SizedBox(width: spacingSmVal),
            Expanded(
              child: StatCard(
                title: '待办事项',
                value: '${AppConstants.mockPendingTasks}',
                unit: '件',
                icon: Icons.pending_actions_outlined,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context) {
    final paddingVal = Responsive.padding(context, AppSpacing.sm);
    final chartH = Responsive.cardHeight(context, min: 120, max: 200);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Padding(
        padding: EdgeInsets.all(paddingVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工作统计',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 14),
                  ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            SizedBox(
              height: chartH,
              child: const _WorkStatsBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    final btnH = Responsive.buttonHeight(context, 48);

    return SizedBox(
      width: double.infinity,
      height: btnH,
      child: FilledButton.icon(
        onPressed: () => _navigateToQrScan(context),
        icon: Icon(Icons.qr_code_scanner, size: Responsive.iconSize(context, 20)),
        label: Text('扫描行李二维码', style: TextStyle(fontSize: Responsive.fontSize(context, 15))),
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
}

class _WorkStatsBarChart extends StatelessWidget {
  const _WorkStatsBarChart();

  @override
  Widget build(BuildContext context) {
    final peak = [...AppConstants.weekProcessed, ...AppConstants.weekAbnormal]
        .reduce((a, b) => a > b ? a : b);
    final maxY = (peak + 4.0).clamp(8.0, 1e9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _legendDot(AppConstants.chartProcessedColor, '处理行李'),
            SizedBox(width: Responsive.spacing(context, 16)),
            _legendDot(AppConstants.chartAbnormalColor, '异常行李'),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 8)),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: Responsive.spacing(context, 28),
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= AppConstants.weekDayLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: Responsive.spacing(context, 6)),
                        child: Text(
                          AppConstants.weekDayLabels[i],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: Responsive.fontSize(context, 11),
                              ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: Responsive.spacing(context, 32),
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: Responsive.fontSize(context, 11),
                          ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 20 ? 5 : 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
                  strokeWidth: 1,
                ),
              ),
              barGroups: List.generate(AppConstants.weekDayLabels.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barsSpace: Responsive.spacing(context, 6).toInt().toDouble(),
                  barRods: [
                    BarChartRodData(
                      toY: AppConstants.weekProcessed[i],
                      color: AppConstants.chartProcessedColor,
                      width: Responsive.spacing(context, 10),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: AppConstants.weekAbnormal[i],
                      color: AppConstants.chartAbnormalColor,
                      width: Responsive.spacing(context, 10),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
