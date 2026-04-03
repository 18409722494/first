import 'package:flutter/material.dart';

import '../models/luggage.dart';
import '../models/qr_payload.dart';
import '../services/luggage_service.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../components/status_badge.dart';
import '../components/empty_state.dart';
import '../utils/responsive.dart';
import 'luggage_map_screen.dart';

/// 行李详情页面
class LuggageDetailScreen extends StatefulWidget {
  final QrPayload qrPayload;
  final String raw;

  const LuggageDetailScreen({
    Key? key,
    required this.qrPayload,
    required this.raw,
  }) : super(key: key);

  @override
  State<LuggageDetailScreen> createState() => _LuggageDetailScreenState();
}

class _LuggageDetailScreenState extends State<LuggageDetailScreen> {
  bool _loading = true;
  String? _error;
  Luggage? _luggage;
  final TextEditingController _statusCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _statusCtrl.dispose();
    _locationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final luggageId = widget.qrPayload.luggageId!;
      final luggage = await LuggageService.getLuggageById(luggageId);
      _luggage = luggage;
      _statusCtrl.text = luggage.status.toString().split('.').last;
      _locationCtrl.text = luggage.destination;
      _noteCtrl.text = luggage.notes;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// 获取当前扫描位置并更新到后端
  Future<void> _updateLocationToBackend() async {
    if (_luggage == null || _locationCtrl.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入位置信息')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final baggageNumber = _luggage!.tagNumber.isNotEmpty
          ? _luggage!.tagNumber
          : widget.qrPayload.extra['tagNo']?.toString() ?? widget.qrPayload.luggageId ?? '';

      await LuggageService.updateScanLocation(
        baggageNumber: baggageNumber,
        location: _locationCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置已更新到后端')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新位置失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _update() async {
    if (_luggage == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      LuggageStatus? status;
      final statusText = _statusCtrl.text.trim();
      if (statusText.isNotEmpty) {
        try {
          status = LuggageStatus.values.firstWhere(
            (s) => s.toString().split('.').last == statusText,
          );
        } catch (e) {
          status = LuggageStatus.checkIn;
        }
      }

      final updated = await LuggageService.updateLuggage(_luggage!.id, {
        'status': status?.toString().split('.').last,
        'destination': _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        'notes': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      });
      _luggage = updated;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新成功')));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadPlaceholder() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final created = await LuggageService.uploadLuggage({
        'tagNumber': widget.qrPayload.extra['tagNo'] ?? widget.qrPayload.extra['tag_no'] ?? '',
        'flightNumber': '',
        'passengerName': '',
        'weight': 0.0,
        'status': _statusCtrl.text.trim(),
        'checkInTime': DateTime.now().toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
        'destination': _locationCtrl.text.trim(),
        'notes': _noteCtrl.text.trim(),
      });
      _luggage = created;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('上传/创建成功')));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.qrPayload;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('行李信息'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const LoadingState()
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: '基本信息'),
                      Tab(text: '历史日志'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 基本信息标签页
                        ListView(
                          padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
                          children: [
                            // 二维码解析结果卡片
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(Responsive.spacing(context, 6)),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                          ),
                                          child: Icon(
                                            Icons.qr_code_2,
                                            color: theme.colorScheme.onPrimaryContainer,
                                            size: Responsive.iconSize(context, 18),
                                          ),
                                        ),
                                        SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                                        Text(
                                          '二维码解析结果',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: Responsive.fontSize(context, 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                                    const Divider(height: 1),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                                    _kv('raw', widget.raw),
                                    _kv('userId', payload.userId ?? '-'),
                                    _kv('luggageId', payload.luggageId ?? '-'),
                                    _kv('role', payload.role ?? '-'),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                            if (_error != null)
                              Padding(
                                padding: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.sm)),
                                child: Text(
                                  _error!,
                                  style: TextStyle(color: AppColors.error, fontSize: 12),
                                ),
                              ),
                            // 行李详情卡片
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                        Text(
                                          '行李详情',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: Responsive.fontSize(context, 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                                    const Divider(height: 1),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                                    _kv('id', _luggage?.id ?? payload.luggageId ?? '-'),
                                    _kv('tagNumber', _luggage?.tagNumber ?? (payload.extra['tagNo']?.toString() ?? '-')),
                                    _kv('flightNumber', _luggage?.flightNumber ?? '-'),
                                    _kv('passengerName', _luggage?.passengerName ?? '-'),
                                    _kv('weight', _luggage?.weight.toString() ?? '-'),
                                    _kvStatus('status', _luggage?.status),
                                    _kv('destination', _luggage?.destination ?? '-'),
                                    _kv('lastUpdated', _luggage?.lastUpdated.toIso8601String() ?? '-'),
                                    _kv('latitude', _luggage?.latitude?.toString() ?? '-'),
                                    _kv('longitude', _luggage?.longitude?.toString() ?? '-'),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                                    AppTextField(
                                      controller: _statusCtrl,
                                      label: '状态 status',
                                      prefixIcon: Icons.flag_outlined,
                                    ),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                                    AppTextField(
                                      controller: _locationCtrl,
                                      label: '位置 location',
                                      prefixIcon: Icons.location_on_outlined,
                                    ),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                                    AppTextField(
                                      controller: _noteCtrl,
                                      label: '备注 note',
                                      prefixIcon: Icons.note_outlined,
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppButton(
                                            text: '更新(PUT)',
                                            type: AppButtonType.primary,
                                            onPressed: _loading ? null : _update,
                                            fullWidth: true,
                                          ),
                                        ),
                                        SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                                        Expanded(
                                          child: AppButton(
                                            text: '上传/创建(POST)',
                                            type: AppButtonType.outline,
                                            onPressed: _loading ? null : _uploadPlaceholder,
                                            fullWidth: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                                    if (_luggage?.latitude != null && _luggage?.longitude != null)
                                      AppButton(
                                        text: '在地图上查看',
                                        icon: Icons.map,
                                        type: AppButtonType.primary,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const LuggageMapScreen(),
                                            ),
                                          );
                                        },
                                        fullWidth: true,
                                      ),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                                    AppButton(
                                      text: '更新位置到后端',
                                      icon: Icons.location_on,
                                      type: AppButtonType.outline,
                                      onPressed: _loading ? null : _updateLocationToBackend,
                                      fullWidth: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 历史日志标签页
                        ListView(
                          padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                          children: [
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(Responsive.spacing(context, 6)),
                                          decoration: BoxDecoration(
                                            color: AppColors.info.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                          ),
                                          child: Icon(
                                            Icons.history,
                                            color: AppColors.info,
                                            size: Responsive.iconSize(context, 18),
                                          ),
                                        ),
                                        SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                                        Text(
                                          '操作历史日志',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: Responsive.fontSize(context, 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                                    const Divider(height: 1),
                                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                                    for (final log in MockData.luggageHistoryLogs)
                                      _buildLogItem(
                                        log['operator']!,
                                        log['action']!,
                                        log['time']!,
                                        log['details']!,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Responsive.spacing(context, 90),
            child: Text(
              '$k:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: Responsive.fontSize(context, 13),
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: Responsive.fontSize(context, 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvStatus(String k, LuggageStatus? status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: Responsive.spacing(context, 90),
            child: Text(
              '$k:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: Responsive.fontSize(context, 13),
              ),
            ),
          ),
          StatusBadge(status: status),
        ],
      ),
    );
  }

  Widget _buildLogItem(String operator, String action, String time, String details) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.xs)),
      padding: EdgeInsets.all(Responsive.spacing(context, AppSpacing.xs)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  action,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: Responsive.fontSize(context, 13)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
              Text(
                time,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 11),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            '操作人: $operator',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 11),
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2),
          Text(
            details,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 11),
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
