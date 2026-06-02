import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';
import 'services/network_service.dart';
import 'services/local_queue_service.dart';
import 'services/damage_report_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 并行初始化所有基础服务
  await Future.wait([
    // 加载环境变量
    _loadEnv(),
    // 初始化 Hive 本地存储
    Hive.initFlutter(),
    // 初始化 SharedPreferences 缓存
    StorageService.init(),
  ]);

  // SettingsService 内部也会打开 Hive 盒子，Hiv e已 init，顺序无关
  await SettingsService.init();
  // 初始化网络监听
  NetworkService().initialize();
  // 初始化本地队列（用于网络不稳定时保存破损报告）
  await LocalQueueService.init();
  // 监听网络恢复，自动重试队列中的报告
  _listenNetworkRecovery();

  runApp(const MyApp());
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env 加载失败，将使用默认值: $e');
  }
}

/// 监听网络恢复，自动重试本地队列中的破损报告
void _listenNetworkRecovery() {
  NetworkService().onConnectivityChanged.listen((result) async {
    // 当网络从离线变为在线时，触发重试
    if (!result.contains(ConnectivityResult.none)) {
      await _retryQueuedReports();
    }
  });
}

/// 重试本地队列中的破损报告
Future<void> _retryQueuedReports() async {
  try {
    final items = await LocalQueueService.getQueueItems();
    if (items.isEmpty) return;

    debugPrint('[LocalQueue] 检测到 ${items.length} 条待重试的破损报告');

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      try {
        // 重新提交报告
        final result = await _retrySingleReport(item);
        if (result) {
          // 成功后从队列中移除
          await LocalQueueService.removeFromQueue(i);
          debugPrint('[LocalQueue] 报告重试成功，已从队列移除');
        }
      } catch (e) {
        debugPrint('[LocalQueue] 报告重试失败: $e');
      }
    }
  } catch (e) {
    debugPrint('[LocalQueue] 重试队列失败: $e');
  }
}

/// 重试单条破损报告
Future<bool> _retrySingleReport(Map<String, dynamic> item) async {
  final imageBytesBase64 = item['imageBytes'] as String?;
  final luggageId = item['luggageId'] as String?;
  final timestampStr = item['timestamp'] as String?;
  final latitude = item['latitude'] as double?;
  final longitude = item['longitude'] as double?;
  final damageDescription = item['damageDescription'] as String?;
  final employeeId = item['employeeId'] as String?;

  if (imageBytesBase64 == null || luggageId == null || timestampStr == null ||
      latitude == null || longitude == null || damageDescription == null || employeeId == null) {
    return false;
  }

  // 解码 base64 图片数据
  final imageBytes = base64Decode(imageBytesBase64);

  final result = await DamageReportService.submitDamageReport(
    imageBytes: imageBytes,
    luggageId: luggageId,
    timestamp: DateTime.parse(timestampStr),
    latitude: latitude,
    longitude: longitude,
    damageDescription: damageDescription,
    employeeId: employeeId,
  );

  return result.success;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'AirBaggage Pro',
            debugShowCheckedModeBanner: false,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // 默认使用浅色主题
            themeMode: ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        return const MainScreen();
      },
    );
  }
}
