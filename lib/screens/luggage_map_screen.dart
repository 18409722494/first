import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';

/// 行李位置地图页面
/// 使用 OpenStreetMap 展示行李位置
/// 支持在线模式和离线模式
class LuggageMapScreen extends StatefulWidget {
  const LuggageMapScreen({Key? key}) : super(key: key);

  @override
  State<LuggageMapScreen> createState() => _LuggageMapScreenState();
}

class _LuggageMapScreenState extends State<LuggageMapScreen> {
  List<Luggage> _luggages = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _offlineMode = false;
  
  /// 地图控制器，用于处理地图操作
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadLuggageData();
  }

  Future<void> _loadLuggageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 请求位置权限
      final locationStatus = await Permission.location.request();
      
      LatLng? currentLocation;

      if (locationStatus.isGranted) {
        // 权限已授予，获取用户位置
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('位置权限已授予，正在获取当前位置...')),
        );

        try {
          // 获取当前位置
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          currentLocation = LatLng(position.latitude, position.longitude);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('当前位置: ${position.latitude}, ${position.longitude}')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('获取位置失败: ${e.toString()}')),
          );
        }
      } else if (locationStatus.isDenied) {
        // 权限被拒绝，使用默认位置
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('位置权限被拒绝，使用默认位置')),
        );
      } else if (locationStatus.isPermanentlyDenied) {
        // 权限被永久拒绝，引导用户去设置
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('位置权限已被永久拒绝，请在系统设置中开启')),
        );
      }

      final luggages = await LuggageService.getLuggageList();
      setState(() {
        _luggages = luggages;
        _isLoading = false;
      });

      // 如果获取到当前位置，更新地图中心点
      if (currentLocation != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _mapController.move(currentLocation!, 10);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '获取行李数据失败: ${e.toString()}';
        _luggages = _getMockLuggageData();
        _isLoading = false;
      });
    }
  }

  List<Luggage> _getMockLuggageData() {
    return [
      Luggage(
        id: '1',
        tagNumber: 'BA12345',
        flightNumber: 'CA1234',
        passengerName: '张三',
        weight: 20.5,
        status: LuggageStatus.inTransit,
        checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        destination: '上海',
        notes: '红色行李箱',
        latitude: 40.0799,
        longitude: 116.6031,
      ),
      Luggage(
        id: '2',
        tagNumber: 'BA67890',
        flightNumber: 'MU5678',
        passengerName: '李四',
        weight: 15.2,
        status: LuggageStatus.delivered,
        checkInTime: DateTime.now().subtract(const Duration(hours: 4)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        destination: '广州',
        notes: '蓝色背包',
        latitude: 31.1978,
        longitude: 121.8108,
      ),
      Luggage(
        id: '3',
        tagNumber: 'BA24680',
        flightNumber: 'CZ7890',
        passengerName: '王五',
        weight: 18.7,
        status: LuggageStatus.checkIn,
        checkInTime: DateTime.now().subtract(const Duration(minutes: 45)),
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
        destination: '深圳',
        notes: '黑色拉杆箱',
        latitude: 23.3964,
        longitude: 113.2986,
      ),
      Luggage(
        id: '4',
        tagNumber: 'BA11111',
        flightNumber: 'HU2468',
        passengerName: '赵六',
        weight: 25.0,
        status: LuggageStatus.lost,
        checkInTime: DateTime.now().subtract(const Duration(hours: 6)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        destination: '成都',
        notes: '灰色托运箱',
        latitude: 22.6231,
        longitude: 113.9357,
      ),
      Luggage(
        id: '5',
        tagNumber: 'BA22222',
        flightNumber: 'SF3456',
        passengerName: '钱七',
        weight: 12.3,
        status: LuggageStatus.inTransit,
        checkInTime: DateTime.now().subtract(const Duration(hours: 3)),
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
        destination: '西安',
        notes: '旅行背包',
        latitude: 30.5833,
        longitude: 103.9333,
      ),
    ];
  }

  Widget _buildMap() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载行李数据...'),
          ],
        ),
      );
    }

    final List<Marker> luggageMarkers = _luggages
        .where((l) => l.latitude != null && l.longitude != null)
        .map((l) => Marker(
              width: 80,
              height: 80,
              point: LatLng(l.latitude!, l.longitude!),
              child: GestureDetector(
                onTap: () => _showLuggageDetail(l),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(l.status),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.luggage,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        l.tagNumber,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();

    // 计算地图中心点
    LatLng center = const LatLng(39.9042, 116.4074); // 默认北京
    if (luggageMarkers.isNotEmpty) {
      center = luggageMarkers[0].point;
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 5,
        minZoom: 3,
        maxZoom: 18,
        onTap: (_, __) {
          // 点击地图空白处可以关闭详情面板
        },
        // 启用默认的交互功能，包括双击缩放
        interactiveFlags: InteractiveFlag.all,
      ),
      children: [
        // 高德地图瓦片图层（国内可访问）
        TileLayer(
          urlTemplate: 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
          subdomains: ['1', '2', '3', '4'],
          userAgentPackageName: 'com.example.my_first_app',
        ),
        // 行李标记图层
        MarkerLayer(markers: luggageMarkers),
      ],
    );
  }

  Widget _buildOfflineList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.amber[100],
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '地图加载失败，切换到列表模式显示行李位置信息',
                  style: TextStyle(color: Colors.amber[800]),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _offlineMode = false;
                  });
                  _loadLuggageData();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _luggages.length,
            itemBuilder: (context, index) {
              final luggage = _luggages[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _showLuggageDetail(luggage),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    luggage.tagNumber,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      luggage.passengerName,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(luggage.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(luggage.status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusText(luggage.status),
                                style: TextStyle(
                                  color: _getStatusColor(luggage.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                luggage.destination,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (luggage.latitude != null && luggage.longitude != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.map, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '经度: ${luggage.longitude!.toStringAsFixed(4)}, 纬度: ${luggage.latitude!.toStringAsFixed(4)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '更新于: ${_formatDateTime(luggage.lastUpdated)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showLuggageDetail(Luggage luggage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Icon(Icons.luggage, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              luggage.tagNumber,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              _getStatusText(luggage.status),
                              style: TextStyle(
                                color: _getStatusColor(luggage.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailItem(Icons.person, '乘客', luggage.passengerName),
                  _buildDetailItem(Icons.flight, '航班', luggage.flightNumber),
                  _buildDetailItem(Icons.location_on, '目的地', luggage.destination),
                  if (luggage.latitude != null && luggage.longitude != null)
                    _buildDetailItem(Icons.map, '坐标', '经度: ${luggage.longitude}, 纬度: ${luggage.latitude}'),
                  _buildDetailItem(Icons.scale, '重量', '${luggage.weight} kg'),
                  if (luggage.notes.isNotEmpty)
                    _buildDetailItem(Icons.note, '备注', luggage.notes),
                  _buildDetailItem(Icons.update, '更新时间', _formatDateTime(luggage.lastUpdated)),
                  _buildDetailItem(Icons.access_time, '办理时间', _formatDateTime(luggage.checkInTime)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(dynamic status) {
    if (status is LuggageStatus) {
      return status.displayName;
    }
    if (status is String) {
      switch (status) {
        case 'checkIn':
          return '已办理托运';
        case 'inTransit':
          return '运输中';
        case 'arrived':
          return '已到达';
        case 'delivered':
          return '已交付';
        case 'damaged':
          return '已损坏';
        case 'lost':
          return '已丢失';
        default:
          return status;
      }
    }
    return '未知';
  }

  Color _getStatusColor(dynamic status) {
    if (status is LuggageStatus) {
      switch (status) {
        case LuggageStatus.checkIn:
          return Colors.blue;
        case LuggageStatus.inTransit:
          return Colors.orange;
        case LuggageStatus.arrived:
          return Colors.green;
        case LuggageStatus.delivered:
          return Colors.purple;
        case LuggageStatus.damaged:
          return Colors.red;
        case LuggageStatus.lost:
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }
    if (status is String) {
      switch (status) {
        case 'checkIn':
          return Colors.blue;
        case 'inTransit':
          return Colors.orange;
        case 'arrived':
          return Colors.green;
        case 'delivered':
          return Colors.purple;
        case 'damaged':
          return Colors.red;
        case 'lost':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行李位置地图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              setState(() {
                _offlineMode = !_offlineMode;
              });
            },
            tooltip: _offlineMode ? '显示地图' : '显示列表',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadLuggageData,
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: _offlineMode || _errorMessage != null
          ? _buildOfflineList()
          : _buildMap(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.grey[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem(Colors.green, '已托运'),
            _buildLegendItem(Colors.orange, '运输中'),
            _buildLegendItem(Colors.blue, '已送达'),
            _buildLegendItem(Colors.red, '丢失'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
