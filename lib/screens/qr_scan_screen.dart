import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_payload.dart';
import '../models/luggage.dart';
import '../services/location_service.dart';
import '../services/luggage_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../components/scan_result_dialog.dart';
import 'luggage_detail_screen.dart';
import 'damage_report_screen.dart';
import 'overweight_screen.dart';
import 'contact_passenger_screen.dart';
import 'add_luggage_screen.dart';

/// 二维码扫描界面 - 深色主题UI设计
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

  String? _lastRaw;

  /// 扫码时是否正在处理（防止重复触发）
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 二维码识别回调
  void _onDetected(BarcodeCapture capture) async {
    if (_processing) return;
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
        // 使用新的 ScanResult 方法获取更好的错误提示
        final scanResult = await LuggageService.getLuggageForScan(payload.luggageId!);
        if (!scanResult.success) {
          if (!mounted) return;
          _showErrorSnackBar(scanResult.errorMessage ?? l10n.getLuggageFailed('未知错误'));
          return;
        }
        luggage = scanResult.luggage!;
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
      final employeeId = await StorageService.getEmployeeId();

      debugPrint('[QrScan] 开始获取GPS和上传位置');

      try {
        // ① 检查 GPS 服务开关
        final serviceEnabled = await LocationService.isLocationServiceEnabled();

        if (!serviceEnabled) {
          debugPrint('[QrScan] GPS服务未开启，使用行李目的地');
          locationName =
              luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation;
          // 尝试上传位置信息（即使GPS不可用也记录当前位置）
          try {
            await LuggageService.updateScanLocation(
              baggageNumber: baggageNumber,
              location: locationName,
              employeeId: employeeId,
            );
            debugPrint('[QrScan] 位置上传成功（使用目的地）');
          } catch (e) {
            debugPrint('[QrScan] 位置上传失败: $e');
            // 不阻塞流程，只是提示
            if (mounted) {
              _showTipSnackBar('位置上传失败: $e');
            }
          }
        } else {
          // ② 多级降级定位
          debugPrint('[QrScan] 开始获取GPS位置');
          position = await LocationService.getCurrentDevicePosition();

          if (position != null) {
            locationName =
                '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
            debugPrint('[QrScan] GPS获取成功: $locationName');

            // ③ 上传到后端
            try {
              await LuggageService.updateScanLocation(
                baggageNumber: baggageNumber,
                location: locationName,
                employeeId: employeeId,
              );
              debugPrint('[QrScan] 位置上传成功');
            } catch (e) {
              debugPrint('[QrScan] 位置上传失败: $e');
              // 位置上传失败不影响后续操作
              if (mounted) {
                _showTipSnackBar('位置上传失败，但不影响操作');
              }
            }
          } else {
            debugPrint('[QrScan] GPS获取失败，使用行李目的地');
            locationName =
                luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation;
            // 仍然尝试上传
            try {
              await LuggageService.updateScanLocation(
                baggageNumber: baggageNumber,
                location: locationName,
                employeeId: employeeId,
              );
            } catch (_) {}
          }
        }
      } catch (e) {
        debugPrint('[QrScan] GPS/位置更新异常: $e');
        locationName =
            luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation;
      }

      // 停止相机
      try {
        await _controller.stop();
      } catch (_) {}

      if (!mounted) return;

      // 弹出操作选项菜单
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
      final employeeId = await StorageService.getEmployeeId();
      final finalLocation = locationName.isNotEmpty ? locationName : luggage.destination;

      // 更新行李位置和状态到后端
      await LuggageService.updateScanLocation(
        baggageNumber: baggageNumber,
        location: finalLocation,
        status: BaggageStatusMapper.toBackendLocationStatus(LuggageStatus.arrived),
        employeeId: employeeId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.statusUpdatedArrived)),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(l10n.updateStatusFailed(e.toString()));
    }
  }

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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // 深色状态栏
          _buildStatusBar(),
          // 顶部导航栏
          _buildAppBar(l10n),
          // 相机区域
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetected,
                ),
                // 扫描框覆盖层 - 适配扫描框位置
                LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      painter: _ScanOverlayPainter(
                        scanTop: 80,
                        scanAreaSize: 220,
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    );
                  },
                ),
                // 扫描框 - 位置上移，给底部操作区域留出空间
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  child: Center(child: _buildScanFrame()),
                ),
                // 底部提示
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomSection(l10n),
                ),
                // 处理中遮罩
                if (_processing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            l10n.processing,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 状态栏
  Widget _buildStatusBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.black.withValues(alpha: 0.5),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '09:41',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          Text(
            '5G',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 顶部导航栏
  Widget _buildAppBar(AppLocalizations l10n) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.black.withValues(alpha: 0.6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              l10n.scan,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white, size: 24),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
    );
  }

  /// 扫描框
  Widget _buildScanFrame() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: Stack(
        children: [
          // 扫描线动画
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _ScanLineAnimation(),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部区域 - GPS信息和操作选项
  Widget _buildBottomSection(AppLocalizations l10n) {
    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // GPS位置信息
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.surfaceDark,
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.textSecondaryDark, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lastRaw == null
                          ? 'GPS: 等待定位...'
                          : 'GPS: ${_lastRaw!.substring(0, _lastRaw!.length > 20 ? 20 : _lastRaw!.length)}...',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.textSecondaryDark, size: 16),
                    onPressed: _refreshGps,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // 操作选项
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '操作选项',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOperationGrid(),
                  const SizedBox(height: 20),
                  // 手动输入按钮
                  _buildManualInputButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 操作按钮网格
  Widget _buildOperationGrid() {
    return Row(
      children: [
        Expanded(child: _buildOperationItem(Icons.luggage_outlined, '行李登记', _handleLuggageRegister)),
        const SizedBox(width: 12),
        Expanded(child: _buildOperationItem(Icons.check_circle_outline, '确认认领', _handleConfirmClaim)),
        const SizedBox(width: 12),
        Expanded(child: _buildOperationItem(Icons.camera_alt_outlined, '拍照取证', _handlePhotoEvidence)),
        const SizedBox(width: 12),
        Expanded(child: _buildOperationItem(Icons.upload_outlined, 'GPS上传', _handleGpsUpload)),
      ],
    );
  }

  /// 行李登记
  void _handleLuggageRegister() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('行李登记'),
        content: const Text('是否进入行李登记页面？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddLuggageScreen()),
      );
    }
  }

  /// 确认认领 - 需要先扫码
  void _handleConfirmClaim() async {
    _showTipSnackBar('请先扫描行李二维码');
  }

  /// 拍照取证
  void _handlePhotoEvidence() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拍照取证'),
        content: const Text('是否进入拍照取证页面？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DamageReportScreen()),
      );
    }
  }

  /// GPS上传
  void _handleGpsUpload() async {
    try {
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showTipSnackBar('GPS定位服务未开启');
        return;
      }
      final position = await LocationService.getCurrentDevicePosition();
      if (position != null) {
        _showTipSnackBar('当前GPS: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}');
      } else {
        _showTipSnackBar('无法获取GPS位置');
      }
    } catch (e) {
      _showTipSnackBar('GPS获取失败');
    }
  }

  void _showTipSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  /// 刷新GPS位置
  Future<void> _refreshGps() async {
    try {
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showTipSnackBar('GPS定位服务未开启');
        return;
      }
      final position = await LocationService.getCurrentDevicePosition();
      if (position != null) {
        setState(() {
          _lastRaw = '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
        });
        _showTipSnackBar('GPS已刷新');
      } else {
        _showTipSnackBar('无法获取GPS位置');
      }
    } catch (e) {
      _showTipSnackBar('GPS获取失败');
    }
  }

  /// 单个操作项
  Widget _buildOperationItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 手动输入按钮
  Widget _buildManualInputButton() {
    return InkWell(
      onTap: _showManualInputDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark, width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: AppColors.textSecondaryDark, size: 20),
            SizedBox(width: 8),
            Text(
              '手动输入行李号',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 手动输入行李号对话框
  void _showManualInputDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动输入行李号'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入行李号或标签号',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      await _processManualInput(result);
    }
  }

  /// 处理手动输入的行李号
  Future<void> _processManualInput(String baggageNumber) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _processing = true;
      _lastRaw = baggageNumber;
    });

    debugPrint('[QrScan] 手动输入行李号: $baggageNumber');

    try {
      late Luggage luggage;
      try {
        // 使用新的 ScanResult 方法
        final scanResult = await LuggageService.getLuggageForScan(baggageNumber);
        if (!scanResult.success) {
          if (!mounted) return;
          _showErrorSnackBar(scanResult.errorMessage ?? l10n.getLuggageFailed('未知错误'));
          return;
        }
        luggage = scanResult.luggage!;
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar(l10n.getLuggageFailed(e.toString()));
        return;
      }

      if (!mounted) return;

      // 获取GPS位置
      String locationName = '';
      Position? position;
      final employeeId = await StorageService.getEmployeeId();
      try {
        final serviceEnabled = await LocationService.isLocationServiceEnabled();
        if (serviceEnabled) {
          position = await LocationService.getCurrentDevicePosition();
          if (position != null) {
            locationName = '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
            try {
              await LuggageService.updateScanLocation(
                baggageNumber: luggage.tagNumber.isNotEmpty ? luggage.tagNumber : baggageNumber,
                location: locationName,
                employeeId: employeeId,
              );
            } catch (e) {
              debugPrint('[QrScan] 手动输入位置上传失败: $e');
              if (mounted) {
                _showTipSnackBar('位置上传失败');
              }
            }
          }
        }
      } catch (_) {}

      locationName = locationName.isEmpty
          ? (luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation)
          : locationName;

      if (!mounted) return;

      // 弹出操作选项
      final choice = await ScanResultDialog.show(
        context: context,
        luggage: luggage,
        rawQr: baggageNumber,
      );

      if (!mounted) return;

      switch (choice) {
        case 'confirm_arrived':
          await _handleConfirmArrived(luggage, baggageNumber, QrPayload(
            userId: null,
            luggageId: luggage.id,
            role: 'manual',
            extra: {'tagNo': luggage.tagNumber},
          ), locationName);
          break;
        case 'report_damage':
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DamageReportScreen(
                luggageId: luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id,
                luggageDbId: luggage.id,
              ),
            ),
          );
          break;
        case 'overweight':
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OverweightScreen(luggage: luggage)),
          );
          break;
        case 'contact_passenger':
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ContactPassengerScreen(luggage: luggage)),
          );
          break;
        case 'view_detail':
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LuggageDetailScreen(
                qrPayload: QrPayload(
                  userId: null,
                  luggageId: luggage.id,
                  role: 'manual',
                  extra: {'tagNo': luggage.tagNumber},
                ),
                raw: baggageNumber,
              ),
            ),
          );
          break;
        default:
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }
}

/// 扫描框遮罩Painter
class _ScanOverlayPainter extends CustomPainter {
  final double scanTop;
  final double scanAreaSize;

  _ScanOverlayPainter({
    this.scanTop = 80,
    this.scanAreaSize = 220,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final scanLeft = (size.width - scanAreaSize) / 2;

    // 绘制四周遮罩
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(scanLeft, scanTop, scanAreaSize, scanAreaSize),
              const Radius.circular(4),
            ),
          ),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanTop != scanTop || oldDelegate.scanAreaSize != scanAreaSize;
}

/// 扫描线动画
class _ScanLineAnimation extends StatefulWidget {
  @override
  State<_ScanLineAnimation> createState() => _ScanLineAnimationState();
}

class _ScanLineAnimationState extends State<_ScanLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanLinePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 扫描线Painter
class _ScanLinePainter extends CustomPainter {
  final double progress;

  _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 10, size.width, 20));

    canvas.drawRect(Rect.fromLTWH(0, y - 2, size.width, 4), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
