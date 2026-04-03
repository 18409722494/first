import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
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

    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    setState(() {
      _lastRaw = raw;
      _processing = true;
    });

    final payload = QrPayload.fromRaw(raw);
    if (payload.luggageId == null || payload.luggageId!.isEmpty) {
      if (!mounted) return;
      _showErrorSnackBar('二维码中未包含行李ID（请检查二维码内容格式）');
      setState(() => _processing = false);
      return;
    }

    // 获取行李信息
    late Luggage luggage;
    try {
      luggage = await LuggageService.getLuggageById(payload.luggageId!);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('获取行李信息失败: $e');
      setState(() => _processing = false);
      return;
    }

    // 获取 GPS 并上传位置
    String locationName = '';
    Position? position;
    try {
      final hasPermission = await LuggageService.checkLocationPermission();
      if (hasPermission) {
        position = await LuggageService.getCurrentDevicePosition();
        if (position != null) {
          locationName = '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
          // 上传到后端
          final baggageNumber = luggage.tagNumber.isNotEmpty
              ? luggage.tagNumber
              : payload.extra['tagNo']?.toString() ?? payload.luggageId ?? '';
          await LuggageService.updateScanLocation(
            baggageNumber: baggageNumber,
            location: locationName,
          );
        } else {
          locationName = luggage.destination.isNotEmpty ? luggage.destination : '未知位置';
        }
      } else {
        locationName = luggage.destination.isNotEmpty ? luggage.destination : '未知位置';
      }
    } catch (e) {
      locationName = luggage.destination.isNotEmpty ? luggage.destination : '未知位置';
    }

    await _controller.stop();
    if (!mounted) return;

    // 弹出操作选项菜单
    await ScanResultDialog.show(
      context: context,
      luggage: luggage,
      rawQr: raw,
      onConfirmArrived: () => _handleConfirmArrived(luggage, raw, payload, locationName),
      onReportDamage: () => _handleReportDamage(luggage, raw, payload),
      onOverweight: () => _handleOverweight(luggage, raw, payload),
      onContactPassenger: () => _handleContactPassenger(luggage, raw, payload),
      onViewDetail: () => _handleViewDetail(luggage, raw, payload),
    );

    setState(() => _processing = false);
    await _controller.start();
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ==================== 操作处理 ====================

  /// 确认到达：更新状态 → arrived
  Future<void> _handleConfirmArrived(
    Luggage luggage,
    String raw,
    QrPayload payload,
    String locationName,
  ) async {
    try {
      await LuggageService.updateLuggage(luggage.id, {
        'status': 'arrived',
        'destination': locationName,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('状态已更新为：已到达')),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('更新状态失败: $e');
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
        builder: (_) => DamageReportScreen(luggageId: luggage.id),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码'),
        actions: [
          IconButton(
            tooltip: '切换闪光灯',
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            tooltip: '切换摄像头',
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
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            '正在获取位置并上传...',
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
                      _lastRaw == null ? '对准二维码进行识别' : '已识别：$_lastRaw',
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
              '提示：扫码后系统将自动获取GPS并上传位置，然后弹出操作选项。',
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
