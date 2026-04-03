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
        final userInfo = await StorageService.getUserInfo();
        final token = await StorageService.getToken();
        
        if (userInfo['userId'] != null) {
          _user = User(
            id: userInfo['userId']!,
            username: userInfo['username'] ?? '',
            email: userInfo['email'] ?? '',
            token: token,
            employeeId: userInfo['employeeId'],
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(
        username: username.trim(),
        password: password,
      );
      
      if (response.success) {
        final savedUserInfo = await StorageService.getUserInfo();
        final savedEmployeeId = savedUserInfo['employeeId'];
        
        await StorageService.saveUserInfo(
          userId: username.trim(),
          username: username.trim(),
          email: '',
          employeeId: savedEmployeeId,
        );

        _user = User(
          id: username.trim(),
          username: username.trim(),
          email: '',
          token: response.token,
          employeeId: savedEmployeeId,
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

  /// 注册（航司员工：工号须已在后台预置且尚未激活）
  /// 注册成功返回 true，但用户仍需调用登录接口
  Future<bool> register(
    String employeeId,
    String username,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final empId = employeeId.trim();
      final name = username.trim();
      final response = await ApiService.register(empId, name, password);
      
      if (response.success) {
        // 注册成功，保存员工工号到本地（用于后续登录后关联）
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

  /// 先请求服务端注销，再清除本地会话。返回非 null 表示服务端提示（本地仍会清除）。
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
