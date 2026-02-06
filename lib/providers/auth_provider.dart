import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

/// 认证状态管理Provider
/// 使用Provider模式管理用户认证状态
/// 负责处理登录、注册、登出等认证相关操作
class AuthProvider with ChangeNotifier {
  // 私有状态变量
  /// 当前登录的用户信息
  User? _user;
  
  /// 是否正在加载中
  bool _isLoading = false;
  
  /// 错误消息
  String? _errorMessage;

  // 公共getter方法
  /// 获取当前用户信息
  User? get user => _user;
  
  /// 获取加载状态
  bool get isLoading => _isLoading;
  
  /// 获取错误消息
  String? get errorMessage => _errorMessage;
  
  /// 判断用户是否已认证
  bool get isAuthenticated => _user != null;

  /// 初始化方法
  /// 在应用启动时调用，检查本地存储中是否有已保存的登录信息
  /// 如果有，则自动恢复用户登录状态
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        final userInfo = await StorageService.getUserInfo();
        final token = await StorageService.getToken();
        
        if (userInfo['userId'] != null && token != null) {
          _user = User(
            id: userInfo['userId']!,
            username: userInfo['username'] ?? '',
            email: userInfo['email'] ?? '',
            token: token,
          );
        }
      }
    } catch (e) {
      _errorMessage = '初始化失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 用户登录方法
  /// [username] 用户名
  /// [password] 密码
  /// 返回true表示登录成功，false表示登录失败
  /// 登录成功后会保存用户信息和token到本地存储
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 直接使用模拟数据登录，跳过API调用
      return await _loginWithMockData(username, password);
    } catch (e) {
      _errorMessage = '登录失败: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 使用模拟数据登录
  /// 当API调用失败时使用此方法
  /// 模拟登录成功，生成模拟用户信息和token
  Future<bool> _loginWithMockData(String username, String password) async {
    try {
      // 生成模拟用户信息
      final mockUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: username.contains('@') ? username : '$username@example.com',
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // 保存模拟用户信息到本地存储
      await StorageService.saveToken(mockUser.token!);
      await StorageService.saveUserInfo(
        userId: mockUser.id,
        username: mockUser.username,
        email: mockUser.email,
      );

      // 更新用户状态
      _user = mockUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '模拟登录失败: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 用户注册方法
  /// [username] 用户名
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回true表示注册成功，false表示注册失败
  /// 注册成功后会保存用户信息和token到本地存储
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 直接使用模拟数据注册，跳过API调用
      return await _registerWithMockData(username, email, password);
    } catch (e) {
      _errorMessage = '注册失败: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 使用模拟数据注册
  /// 当API调用失败时使用此方法
  /// 模拟注册成功，生成模拟用户信息和token
  Future<bool> _registerWithMockData(String username, String email, String password) async {
    try {
      // 生成模拟用户信息
      final mockUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // 保存模拟用户信息到本地存储
      await StorageService.saveToken(mockUser.token!);
      await StorageService.saveUserInfo(
        userId: mockUser.id,
        username: mockUser.username,
        email: mockUser.email,
      );

      // 更新用户状态
      _user = mockUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '模拟注册失败: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 用户登出方法
  /// 清除本地存储的所有用户信息和token
  /// 重置用户状态和错误信息
  Future<void> logout() async {
    await StorageService.clearAll();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// 清除错误信息
  /// 用于手动清除当前显示的错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
