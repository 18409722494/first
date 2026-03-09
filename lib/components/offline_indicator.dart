import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network_service.dart';

/// 离线模式提示组件
/// 在网络断开时显示提示信息
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({Key? key}) : super(key: key);

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    // 初始化网络监听
    _checkNetworkStatus();
    try {
      _subscription = NetworkService().onConnectivityChanged.listen((result) {
        setState(() {
          _isOffline = result.contains(ConnectivityResult.none);
        });
      });
    } catch (e) {
      // 处理监听失败的情况
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _checkNetworkStatus() async {
    try {
      final isOnline = await NetworkService().isOnline();
      setState(() {
        _isOffline = !isOnline;
      });
    } catch (e) {
      // 处理网络状态检查失败的情况
      setState(() {
        _isOffline = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.red[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          const Text(
            '离线模式',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(
            '数据将在网络恢复后同步',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
