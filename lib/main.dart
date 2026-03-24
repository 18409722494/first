import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载环境变量（TIANDITU_API_KEY 等敏感配置从 .env 读取）
  // 使用 try-catch 防止 .env 缺失或格式错误导致启动完全卡死
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // dotenv 加载失败不影响核心功能，但天地图瓦片会加载失败
    debugPrint('Warning: .env 加载失败，地图瓦片可能不可用: $e');
  }

  // 初始化Hive本地存储（用于离线队列）
  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: '行李管理系统',
        debugShowCheckedModeBanner: false,
        // 默认中国大陆简体，与天地图底图标注习惯一致（API 返回繁体时在解析时转简体）
        locale: const Locale('zh', 'CN'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// 认证状态路由封装
/// 根据用户登录状态决定显示登录页或主页
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // TODO: 正式环境取消注释，使用真实认证状态判断
        // if (!authProvider.isAuthenticated) {
        //   return const LoginScreen();
        // }
        return const MainScreen();
      },
    );
  }
}
