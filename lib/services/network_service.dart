import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络状态服务
/// 用于检测网络连接状态，提供离线模式支持
class NetworkService {
  static final NetworkService _instance = NetworkService._();
  factory NetworkService() => _instance;
  
  NetworkService._();
  
  final Connectivity _connectivity = Connectivity();
  final StreamController<List<ConnectivityResult>> _controller = StreamController<List<ConnectivityResult>>.broadcast();
  
  /// 网络连接状态流
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;
  
  /// 初始化网络监听
  Future<void> initialize() async {
    try {
      // 初始状态
      final initialStatus = await _connectivity.checkConnectivity();
      _controller.add(initialStatus);
    } catch (e) {
      // 处理初始化失败的情况，避免阻塞应用启动
      _controller.add([]);
    }
    
    try {
      // 监听状态变化
      _connectivity.onConnectivityChanged.listen((result) {
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
      // 处理网络状态检查失败的情况，返回空列表
      return [];
    }
  }
  
  /// 是否在线
  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      // 处理网络状态检查失败的情况，默认返回在线
      return true;
    }
  }
  
  /// 关闭流控制器
  void dispose() {
    _controller.close();
  }
}
