import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'luggage_list_screen.dart';
import 'profile_screen.dart';
import 'todo_screen.dart';
import 'luggage_map_screen.dart';

/// 主界面组件
/// 包含底部导航栏，管理四个主要页面：首页、行李管理、行李地图、个人中心
/// 使用IndexedStack保持各页面状态，避免切换时重建
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// 当前选中的底部导航栏索引
  int _currentIndex = 0;

  /// 所有页面的列表
  final List<Widget> _screens = [
    const HomeScreen(),
    const LuggageListScreen(),
    const TodoScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用IndexedStack保持页面状态
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // 底部导航栏
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage),
            label: '行李管理',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: '待办事项',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '个人中心',
          ),
        ],
      ),
    );
  }
}
