import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

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

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(username, password);
      
      if (response.success && response.token != null) {
        final userId = response.user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
        final userEmail = response.user?.email ?? '';
        
        await StorageService.saveToken(response.token!);
        await StorageService.saveUserInfo(
          userId: userId,
          username: username,
          email: userEmail,
        );

        _user = User(
          id: userId,
          username: username,
          email: userEmail,
          token: response.token!,
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

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.register(username, password);
      
      if (response.success && response.token != null) {
        final userId = response.user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
        final userEmail = response.user?.email ?? '';
        
        await StorageService.saveToken(response.token!);
        await StorageService.saveUserInfo(
          userId: userId,
          username: username,
          email: userEmail,
        );

        _user = User(
          id: userId,
          username: username,
          email: userEmail,
          token: response.token!,
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

  Future<void> logout() async {
    await StorageService.clearAll();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
