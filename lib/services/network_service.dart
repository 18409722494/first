import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络状态服务
/// 用于检测网络连接状态，提供离线模式支持
class NetworkService {
  static final NetworkService _instance = NetworkService._();
  factory NetworkService() => _instance;

  NetworkService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  /// 网络连接状态流
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  /// 订阅引用，用于 dispose 时取消
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// 初始化网络监听
  Future<void> initialize() async {
    try {
      final initialStatus = await _connectivity.checkConnectivity();
      _controller.add(initialStatus);
    } catch (e) {
      _controller.add([]);
    }

    try {
      _subscription = _connectivity.onConnectivityChanged.listen((result) {
        _controller.add(result);
      });
    } catch (e) {
      // 处理监听失败的情况
    }
  }

  /// 检查当前网络状态
  Future<List<ConnectivityResult>> checkConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return [];
    }
  }

  /// 是否在线
  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return true;
    }
  }

  /// 关闭流和取消订阅
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
