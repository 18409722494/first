import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/qr_payload.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'luggage_detail_screen.dart';

/// 二维码扫描界面
/// 使用摄像头扫描行李二维码
/// 支持闪光灯切换和前后摄像头切换
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({Key? key}) : super(key: key);

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  /// 移动扫描控制器
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// 是否已导航到详情页（防止重复导航）
  bool _navigated = false;
  
  /// 最后识别的原始二维码内容
  String? _lastRaw;

  @override
  void dispose() {
    // 释放扫描控制器资源
    _controller.dispose();
    super.dispose();
  }

  /// 二维码识别回调
  /// 当扫描到二维码时调用，解析二维码内容并导航到行李详情页
  /// [capture] 扫描捕获的数据
  void _onDetected(BarcodeCapture capture) async {
    if (_navigated) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    setState(() => _lastRaw = raw);

    final payload = QrPayload.fromRaw(raw);
    if (payload.luggageId == null || payload.luggageId!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('二维码中未包含 luggageId（请检查二维码内容格式）')),
      );
      return;
    }

    _navigated = true;
    await _controller.stop();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Text(
                      _lastRaw == null ? '对准二维码进行识别' : '已识别：$_lastRaw',
                      style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 13)),
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
              '提示：如果你在 Windows/Android Studio 第一次编译遇到"需要启用 Developer Mode 才能创建 symlink"，请在系统设置里打开开发者模式。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
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
