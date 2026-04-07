import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_payload.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../components/scan_result_dialog.dart';
import 'luggage_detail_screen.dart';
import 'damage_report_screen.dart';
import 'overweight_screen.dart';
import 'contact_passenger_screen.dart';

/// 二维码扫描界面
///
/// 扫码后自动执行：
/// 1. 获取设备 GPS 位置
/// 2. 调用 PUT /baggage/location 上传位置
/// 3. 弹出操作选项菜单
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final bool _navigated = false;
  String? _lastRaw;

  /// 扫码时是否正在处理（防止重复触发）
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 二维码识别回调
  ///
  /// 完整流程：
  /// 1. 解析二维码 → 2. 获取行李信息 → 3. 获取GPS → 4. 上传位置 → 5. 弹出操作菜单
  void _onDetected(BarcodeCapture capture) async {
    if (_navigated || _processing) return;
    final l10n = AppLocalizations.of(context)!;

    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    setState(() {
      _lastRaw = raw;
      _processing = true;
    });

    try {
      final payload = QrPayload.fromRaw(raw);
      if (payload.luggageId == null || payload.luggageId!.isEmpty) {
        if (!mounted) return;
        _showErrorSnackBar(l10n.qrCodeNoLuggageId);
        return;
      }

      // 获取行李信息（支持 id 与行李号 baggageNumber）
      late Luggage luggage;
      try {
        luggage = await LuggageService.getLuggageForScan(payload.luggageId!);
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar(l10n.getLuggageFailed(e.toString()));
        return;
      }

      // 详情页等依赖数据库 id；纯文本码里往往是行李号
      final payloadResolved = QrPayload(
        userId: payload.userId,
        luggageId: luggage.id,
        role: payload.role,
        extra: {
          ...payload.extra,
          // 扫码原始标识（多为行李号），供 PUT /baggage/location 回退；luggageId 已改为库内 id
          if (payload.luggageId != null && payload.luggageId!.isNotEmpty)
            'scannedQrRef': payload.luggageId,
          if (luggage.tagNumber.isNotEmpty) 'tagNo': luggage.tagNumber,
        },
      );

      // 获取 GPS 并上传位置（带完整调试日志）
      String locationName = '';
      Position? position;
      final baggageNumber = luggage.tagNumber.isNotEmpty
          ? luggage.tagNumber
          : payload.extra['tagNo']?.toString() ?? payload.luggageId ?? '';
      try {
        // ① 检查 GPS 服务开关（与破损登记逻辑一致）
        final serviceEnabled = await LuggageService.isLocationServiceEnabled();

        if (!serviceEnabled) {
          locationName =
              luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation;
        } else {
          // ② 多级降级定位（已内置权限检查 + getLastKnownPosition + medium/low 降级）
          position = await LuggageService.getCurrentDevicePosition();

          if (position != null) {
            locationName =
                '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';

            // ③ 上传到后端
            await LuggageService.updateScanLocation(
              baggageNumber: baggageNumber,
              location: locationName,
            );
          } else {
            locationName =
                luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation;
          }
        }
      } catch (e) {
        locationName =
            luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation;
      }

      // 停止相机
      try {
        await _controller.stop();
      } catch (_) {}

      if (!mounted) return;

      // 弹出操作选项菜单（作为独立页面推入导航栈，支持返回）
      final choice = await ScanResultDialog.show(
        context: context,
        luggage: luggage,
        rawQr: raw,
      );

      if (!mounted) return;

      switch (choice) {
        case 'confirm_arrived':
          await _handleConfirmArrived(luggage, raw, payloadResolved, locationName);
          break;
        case 'report_damage':
          await _handleReportDamage(luggage, raw, payloadResolved);
          break;
        case 'overweight':
          await _handleOverweight(luggage, raw, payloadResolved);
          break;
        case 'contact_passenger':
          await _handleContactPassenger(luggage, raw, payloadResolved);
          break;
        case 'view_detail':
          await _handleViewDetail(luggage, raw, payloadResolved);
          break;
        default:
          // null（用户取消/返回）→ 留在扫码页，不做额外操作
          break;
      }

    } finally {
      if (mounted) {
        setState(() => _processing = false);
        try {
          await _controller.start();
        } catch (_) {}
      }
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ==================== 操作处理 ====================

  /// 确认到达：PUT /baggage/location 写入位置 + 状态「已达」，并同步本地 PUT /luggage
  Future<void> _handleConfirmArrived(
    Luggage luggage,
    String raw,
    QrPayload payload,
    String locationName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final baggageNumber = luggage.tagNumber.isNotEmpty
          ? luggage.tagNumber
          : payload.extra['tagNo']?.toString() ??
              payload.extra['scannedQrRef']?.toString() ??
              '';
      if (baggageNumber.isEmpty) {
        _showErrorSnackBar(l10n.cannotSyncMissingNo);
        return;
      }
      await LuggageService.updateScanLocation(
        baggageNumber: baggageNumber,
        location: locationName.isNotEmpty ? locationName : luggage.destination,
        status: BaggageStatusMapper.toBackendLocationStatus(LuggageStatus.arrived),
      );
      try {
        await LuggageService.updateLuggage(luggage.id, {
          'status': LuggageStatus.arrived.name,
          'destination': locationName,
        });
      } catch (_) {
        // 主数据已在 baggage/location 更新；本地 /luggage 不可用时忽略
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.statusUpdatedArrived)),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(l10n.updateStatusFailed(e.toString()));
    }
  }

  /// 标记破损：跳转破损报告页
  Future<void> _handleReportDamage(
    Luggage luggage,
    String raw,
    QrPayload payload,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DamageReportScreen(
          luggageId: luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id,
          luggageDbId: luggage.id,
        ),
      ),
    );
  }

  /// 超重处理：跳转超重费用页
  Future<void> _handleOverweight(
    Luggage luggage,
    String raw,
    QrPayload payload,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OverweightScreen(luggage: luggage),
      ),
    );
  }

  /// 联系旅客：跳转联系方式页
  Future<void> _handleContactPassenger(
    Luggage luggage,
    String raw,
    QrPayload payload,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactPassengerScreen(luggage: luggage),
      ),
    );
  }

  /// 查看详情：跳转行李详情页
  Future<void> _handleViewDetail(
    Luggage luggage,
    String raw,
    QrPayload payload,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LuggageDetailScreen(
          qrPayload: payload,
          raw: raw,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scan),
        actions: [
          IconButton(
            tooltip: l10n.toggleFlash,
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            tooltip: l10n.switchCamera,
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetected,
                ),
                if (_processing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            l10n.processing,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Text(
                      _lastRaw == null ? l10n.alignQRCode : l10n.identified(_lastRaw!),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.fontSize(context, 13),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
            child: Text(
              l10n.scanTip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
