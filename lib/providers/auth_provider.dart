import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

/// 用户认证状态管理
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        // 一次异步读取所有字段
        final data = await StorageService.readAuthData();
        if (data['userId'] != null) {
          _user = User(
            id: data['userId']!,
            username: data['username'] ?? '',
            email: data['email'] ?? '',
            token: data['token'],
            employeeId: data['employeeId'],
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

  Future<bool> login({
    required String username,
    required String password,
    required String employeeId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(
        username: username.trim(),
        password: password,
        employeeId: employeeId.trim(),
      );

      if (response.success) {
        // 保存用户信息，包括工号
        await StorageService.saveUserInfo(
          userId: username.trim(),
          username: username.trim(),
          email: '',
          employeeId: employeeId,
        );

        _user = User(
          id: username.trim(),
          username: username.trim(),
          email: '',
          token: response.token,
          employeeId: employeeId,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '登录失败: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String employeeId,
    String username,
    String password,
    String airport,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final empId = employeeId.trim();
      final name = username.trim();
      final response = await ApiService.register(empId, name, password, airport);

      if (response.success) {
        await StorageService.saveUserInfo(
          userId: name,
          username: name,
          email: '',
          employeeId: empId,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '注册失败: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> logout() async {
    final id = _user?.employeeId?.trim();
    String? serverMessage;
    if (id != null && id.isNotEmpty) {
      final response = await ApiService.logout(id);
      if (!response.success) {
        serverMessage = response.message;
      }
    }
    await StorageService.clearAll();
    _user = null;
    _errorMessage = null;
    notifyListeners();
    return serverMessage;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
