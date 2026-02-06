import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/network_service.dart';
import 'components/offline_indicator.dart';

/// 应用入口点
void main() {
  // 异步初始化网络服务，不阻塞应用启动
  NetworkService().initialize();
  runApp(const MyApp());
}

/// 应用根组件
/// 配置Provider和MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // 创建AuthProvider并初始化
      create: (_) => AuthProvider()..init(),
      child: MaterialApp(
        title: '行李管理系统',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        builder: (context, child) {
          return Column(
            children: [
              const OfflineIndicator(),
              Expanded(child: child!),
            ],
          );
        },
      ),
    );
  }
}

/// 认证包装器组件
/// 根据用户认证状态决定显示登录页还是主界面
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 如果正在加载，显示加载页面
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 如果已登录，显示主界面（带底部导航栏）；否则显示登录页
        return authProvider.isAuthenticated
            ? const MainScreen()
            : const LoginScreen();
      },
    );
  }
}
