import 'package:flutter/material.dart';
import '../models/abnormal_baggage.dart';
import '../models/baggage_operation_log.dart';
import '../models/luggage.dart';
import '../models/luggage_detail_info.dart';
import '../models/qr_payload.dart';
import '../services/luggage_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../components/status_badge.dart';
import '../components/empty_state.dart';
import '../utils/responsive.dart';

/// 行李详情页面
class LuggageDetailScreen extends StatefulWidget {
  final QrPayload qrPayload;
  final String raw;

  const LuggageDetailScreen({
    super.key,
    required this.qrPayload,
    required this.raw,
  });

  @override
  State<LuggageDetailScreen> createState() => _LuggageDetailScreenState();
}

class _LuggageDetailScreenState extends State<LuggageDetailScreen> {
  bool _loading = true;
  String? _error;
  LuggageDetailInfo? _detail;

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
      final detail = await LuggageService.getBaggageDetail(
        qrPayload: widget.qrPayload,
        rawQr: widget.raw,
      );
      _detail = detail;
      _statusCtrl.text = detail.luggage.status.displayName;
      _locationCtrl.text = detail.luggage.destination;
      _noteCtrl.text = detail.luggage.notes;
    } catch (e) {
      _error = '加载异常: $e';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Luggage get _luggage => _detail?.luggage ?? Luggage(
        id: widget.qrPayload.luggageId ?? widget.raw,
        tagNumber: '${widget.qrPayload.extra['tagNo'] ?? widget.qrPayload.extra['tag_no'] ?? ''}',
        flightNumber: '${widget.qrPayload.extra['flight_hint'] ?? widget.qrPayload.extra['航班'] ?? ''}',
        passengerName: '${widget.qrPayload.extra['passenger_hint'] ?? widget.qrPayload.extra['旅客'] ?? ''}',
        weight: 0,
        status: LuggageStatus.checkIn,
        checkInTime: DateTime.now(),
        lastUpdated: DateTime.now(),
        destination: '',
        notes: '',
        contact: widget.qrPayload.extra['contact']?.toString(),
      );

  /// 获取当前扫描位置并更新到后端
  Future<void> _updateLocationToBackend() async {
    if (_locationCtrl.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入位置信息')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final bag = _luggage;
      final baggageNumber = bag.tagNumber.isNotEmpty
          ? bag.tagNumber
          : widget.qrPayload.luggageId ?? '';
      final employeeId = await StorageService.getEmployeeId();

      await LuggageService.updateScanLocation(
        baggageNumber: baggageNumber,
        location: _locationCtrl.text.trim(),
        status: BaggageStatusMapper.toBackendLocationStatus(bag.status),
        employeeId: employeeId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置与状态已同步到后端')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新位置失败: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _update() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bag = _luggage;
      final status = BaggageStatusMapper.parseFromUserInput(
        _statusCtrl.text,
        bag.status,
      );
      final baggageNumber = bag.tagNumber.isNotEmpty
          ? bag.tagNumber
          : widget.qrPayload.luggageId ?? '';
      final locationText = _locationCtrl.text.trim();
      final locationForApi = locationText.isNotEmpty
          ? locationText
          : (bag.destination.isNotEmpty ? bag.destination : '未知位置');

      if (baggageNumber.isNotEmpty) {
        final employeeId = await StorageService.getEmployeeId();
        await LuggageService.updateScanLocation(
          baggageNumber: baggageNumber,
          location: locationForApi,
          status: BaggageStatusMapper.toBackendLocationStatus(status),
          employeeId: employeeId,
        );
      }

      Luggage updated;
      try {
        updated = await LuggageService.updateLuggage(bag.id, {
          'status': status.name,
          'destination': locationText.isEmpty ? null : locationText,
          'notes': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        });
      } catch (_) {
        updated = bag.copyWith(
          status: status,
          destination: locationText.isNotEmpty ? locationText : bag.destination,
          notes: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : bag.notes,
          lastUpdated: DateTime.now(),
        );
      }

      // 同步更新本地状态
      _detail = LuggageDetailInfo(
        luggage: updated,
        abnormalRecords: _detail?.abnormalRecords ?? [],
        operationLogs: _detail?.operationLogs ?? [],
      );
      _statusCtrl.text = updated.status.displayName;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新成功')));
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
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: '基本信息'),
                      Tab(text: '破损记录'),
                      Tab(text: '操作日志'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBasicTab(context, payload, theme),
                        _buildDamageTab(context, theme),
                        _buildLogsTab(context, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────
  // 基本信息
  // ─────────────────────────────────────────────
  Widget _buildBasicTab(BuildContext context, QrPayload payload, ThemeData theme) {
    final bag = _luggage;

    return ListView(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      children: [
        // 接口提示（有融合扫码数据时显示）
        if (_error != null)
          Container(
            margin: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.sm)),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, AppSpacing.md),
              vertical: Responsive.spacing(context, AppSpacing.sm),
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: Responsive.iconSize(context, 18)),
                SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.warning, fontSize: Responsive.fontSize(context, 13)),
                  ),
                ),
              ],
            ),
          ),

        // 行李基础信息
        _buildLuggageCard(context, bag, theme),
      ],
    );
  }

  Widget _buildLuggageCard(BuildContext context, Luggage bag, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
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
                  child: Icon(Icons.luggage, color: AppColors.primary, size: Responsive.iconSize(context, 18)),
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                Text('行李详情', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            const Divider(height: 1),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            _kv('行李号', bag.tagNumber.isNotEmpty ? bag.tagNumber : '-'),
            _kv('航班', bag.flightNumber.isNotEmpty ? bag.flightNumber : '-'),
            _kv('旅客', bag.passengerName.isNotEmpty ? bag.passengerName : '-'),
            _kv('重量', bag.weight > 0 ? '${bag.weight} kg' : '-'),
            _kv('状态', '', status: bag.status),
            _kv('当前位置', bag.destination.isNotEmpty ? bag.destination : '-'),
            _kv('联系手机', bag.contact != null && bag.contact!.isNotEmpty ? bag.contact! : '-'),
            _kv('最后更新', _formatDateTime(bag.lastUpdated)),
            _kv('备注', bag.notes.isNotEmpty ? bag.notes : '-'),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

            // 可编辑区
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
                    text: '更新位置',
                    icon: Icons.location_on,
                    type: AppButtonType.outline,
                    onPressed: _loading ? null : _updateLocationToBackend,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 破损记录
  // ─────────────────────────────────────────────
  Widget _buildDamageTab(BuildContext context, ThemeData theme) {
    final records = _detail?.abnormalRecords ?? [];

    if (records.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.broken_image_outlined,
          title: '暂无破损记录',
          subtitle: '来自后端 GET /abnormal-baggage/all',
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return _buildDamageCard(context, r, theme);
      },
    );
  }

  Widget _buildDamageCard(BuildContext context, AbnormalBaggage r, ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.sm)),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: AppColors.damaged.withValues(alpha: 0.4), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.broken_image_outlined, color: AppColors.damaged, size: Responsive.iconSize(context, 20)),
                SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                Expanded(
                  child: Text(
                    r.baggageNumber,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: Responsive.fontSize(context, 14)),
                  ),
                ),
                Text(
                  r.formattedTime,
                  style: TextStyle(fontSize: Responsive.fontSize(context, 12), color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            _kv('破损描述', r.damageDescription),
            _kv('上报位置', r.location),
            _kv('行李哈希', r.baggageHash.isNotEmpty ? r.baggageHash : '-'),
            _kv('图片', r.imageUrl.isNotEmpty ? r.imageUrl : '-'),
            _kv('上报时间', r.formattedDate),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 操作日志
  // ─────────────────────────────────────────────
  Widget _buildLogsTab(BuildContext context, ThemeData theme) {
    final logs = _detail?.operationLogs ?? [];

    if (logs.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.history,
          title: '暂无操作日志',
          subtitle: '来自后端 GET /baggage/operationLogs',
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogItem(context, log, theme);
      },
    );
  }

  Widget _buildLogItem(BuildContext context, BaggageOperationLog log, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.xs)),
      padding: EdgeInsets.all(Responsive.spacing(context, AppSpacing.sm)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  log.action.isNotEmpty ? log.action : '操作',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: Responsive.fontSize(context, 13)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
              Text(
                _formatDateTime(log.time),
                style: TextStyle(fontSize: Responsive.fontSize(context, 11), color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 2)),
          Text(
            '操作人: ${log.operatorName}',
            style: TextStyle(fontSize: Responsive.fontSize(context, 12), color: theme.colorScheme.onSurfaceVariant),
          ),
          if (log.details.isNotEmpty)
            Text(
              log.details,
              style: TextStyle(fontSize: Responsive.fontSize(context, 12), color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 通用工具
  // ─────────────────────────────────────────────
  double get _kvLabelWidth {
    final w = MediaQuery.sizeOf(context).width;
    return (w * 0.38).clamp(112.0, 168.0);
  }

  Widget _kv(String k, String v, {LuggageStatus? status}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _kvLabelWidth,
            child: Text(
              '$k:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: Responsive.fontSize(context, 13),
              ),
            ),
          ),
          if (status != null)
            StatusBadge(status: status)
          else
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

  String _formatDateTime(DateTime t) {
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
