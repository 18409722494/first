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
import '../utils/luggage_utils.dart';
import '../l10n/app_localizations.dart';

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

class _LuggageDetailScreenState extends State<LuggageDetailScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  String? _error;
  LuggageDetailInfo? _detail;

  final TextEditingController _statusCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusCtrl.dispose();
    _locationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
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
        forceRefresh: true,
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
    final l10n = AppLocalizations.of(context)!;
    if (_locationCtrl.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterLocation)),
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
      final locationText = _locationCtrl.text.trim();

      await LuggageService.updateScanLocation(
        baggageNumber: baggageNumber,
        location: locationText,
        status: BaggageStatusMapper.toBackendLocationStatus(bag.status),
        employeeId: employeeId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationSynced)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.updateFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _update() async {
    final l10n = AppLocalizations.of(context)!;
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

      final employeeId = await StorageService.getEmployeeId();

      if (baggageNumber.isNotEmpty) {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.updateSuccess)));
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.luggageDetail),
        actions: [
          IconButton(
            tooltip: l10n.reload,
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
                  TabBar(
                    tabs: [
                      Tab(text: l10n.basicInfoTab),
                      Tab(text: l10n.damageTab),
                      Tab(text: l10n.logTab),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBasicTab(context, payload, theme, l10n),
                        _buildDamageTab(context, theme, l10n),
                        _buildLogsTab(context, theme, l10n),
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
  Widget _buildBasicTab(BuildContext context, QrPayload payload, ThemeData theme, AppLocalizations l10n) {
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
        _buildLuggageCard(context, bag, theme, l10n),
      ],
    );
  }

  Widget _buildLuggageCard(BuildContext context, Luggage bag, ThemeData theme, AppLocalizations l10n) {
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
                Text(l10n.luggageDetail, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            const Divider(height: 1),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            _kv(l10n.tagNumber, bag.tagNumber.isNotEmpty ? bag.tagNumber : '-'),
            _kv(l10n.flightNo, bag.flightNumber.isNotEmpty ? bag.flightNumber : '-'),
            _kv(l10n.passengerName, bag.passengerName.isNotEmpty ? bag.passengerName : '-'),
            _kv(l10n.weight, bag.weight > 0 ? l10n.weightKg(bag.weight.toString()) : '-'),
            _kv(l10n.status, '', status: bag.status),
            _kv(l10n.destination, bag.destination.isNotEmpty
                ? LuggageUtils.cleanLocationString(bag.destination)
                : '-'),
            _kv(l10n.contactPhone, bag.contact != null && bag.contact!.isNotEmpty ? bag.contact! : '-'),
            _kv(l10n.lastUpdated, _formatDateTime(bag.lastUpdated)),
            _kv(l10n.note, bag.notes.isNotEmpty ? bag.notes : '-'),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

            // 可编辑区
            AppTextField(
              controller: _statusCtrl,
              label: l10n.status,
              prefixIcon: Icons.flag_outlined,
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            AppTextField(
              controller: _locationCtrl,
              label: l10n.location,
              prefixIcon: Icons.location_on_outlined,
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            AppTextField(
              controller: _noteCtrl,
              label: l10n.note,
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: l10n.updateStatus,
                    type: AppButtonType.primary,
                    onPressed: _loading ? null : _update,
                    fullWidth: true,
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                Expanded(
                  child: AppButton(
                    text: l10n.updateLocation,
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
  Widget _buildDamageTab(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final records = _detail?.abnormalRecords ?? [];

    if (records.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.broken_image_outlined,
          title: l10n.noDamageRecord,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return _buildDamageCard(context, r, theme, l10n);
      },
    );
  }

  Widget _buildDamageCard(BuildContext context, AbnormalBaggage r, ThemeData theme, AppLocalizations l10n) {
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
            _kv(l10n.damageDescription, r.damageDescription),
            _kv(l10n.damageLocation, LuggageUtils.cleanLocationString(r.location)),
            _kv(l10n.image, r.imageUrl.isNotEmpty ? r.imageUrl : '-'),
            _kv(l10n.damageReportTime, r.formattedDate),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 操作日志
  // ─────────────────────────────────────────────
  // 操作日志
  // ─────────────────────────────────────────────
  Widget _buildLogsTab(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final logs = _detail?.operationLogs ?? [];

    if (logs.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.history,
          title: l10n.noOperationLog,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogItem(context, log, theme, l10n);
      },
    );
  }

  Widget _buildLogItem(BuildContext context, BaggageOperationLog log, ThemeData theme, AppLocalizations l10n) {
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
                  log.action.isNotEmpty ? log.action : l10n.operation,
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
            l10n.operator(log.operatorName),
            style: TextStyle(fontSize: Responsive.fontSize(context, 12), color: theme.colorScheme.onSurfaceVariant),
          ),
          if (log.details.isNotEmpty)
            Text(
              LuggageUtils.cleanLocationString(log.details),
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
