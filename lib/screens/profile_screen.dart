import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'account_info_screen.dart';
import 'account_security_screen.dart';
import 'personalization_screen.dart';
import 'system_settings_screen.dart';
import 'quick_functions_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDrawerOpen = false;
  double _dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('员工中心'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isDrawerOpen = !_isDrawerOpen;
            });
          },
        ),
      ),
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragOffset = 0;
        },
        onHorizontalDragUpdate: (details) {
          _dragOffset += details.delta.dx;
          
          if (_dragOffset > 0 && !_isDrawerOpen) {
            setState(() {
              _dragOffset = _dragOffset.clamp(0.0, 250.0);
            });
          }
        },
        onHorizontalDragEnd: (details) {
          if (_dragOffset > 100) {
            setState(() {
              _isDrawerOpen = true;
              _dragOffset = 0;
            });
          } else {
            setState(() {
              _dragOffset = 0;
            });
          }
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.translationValues(
                _isDrawerOpen ? 250.0 : _dragOffset,
                0,
                0,
              ),
              child: Scaffold(
                body: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.user;
                    final username = user?.username ?? 'User';
                    final email = user?.email ?? 'user@example.com';
                    
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    username.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  username,
                                  style:
                                      Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      email,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.badge_outlined),
                            title: const Text('账户信息'),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AccountInfoScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.lock_outlined),
                            title: const Text('账户安全'),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AccountSecurityScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.account_circle_outlined),
                            title: const Text('个性化设置'),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PersonalizationScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.settings_outlined),
                            title: const Text('系统设置'),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SystemSettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.speed_outlined),
                            title: const Text('快捷功能'),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const QuickFunctionsScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('帮助与支持'),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HelpSupportScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FilledButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('确认退出'),
                                  content: const Text('确定要退出登录吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('取消'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('退出'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                await authProvider.logout();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('退出登录'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _isDrawerOpen ? 0 : -250,
              top: 0,
              bottom: 0,
              width: 250,
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '快速导航',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('首页'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isDrawerOpen = false;
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.luggage),
                      title: const Text('行李管理'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isDrawerOpen = false;
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.task),
                      title: const Text('待办事项'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isDrawerOpen = false;
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('个人中心'),
                      onTap: () {
                        setState(() {
                          _isDrawerOpen = false;
                        });
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: const Text('扫描二维码'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isDrawerOpen = false;
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.map),
                      title: const Text('行李地图'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isDrawerOpen = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            if (_isDrawerOpen) 
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDrawerOpen = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: Colors.black.withOpacity(_isDrawerOpen ? 0.5 : 0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
