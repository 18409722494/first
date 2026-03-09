import 'package:flutter/material.dart';

import '../models/luggage.dart';
import '../models/qr_payload.dart';
import '../services/luggage_service.dart';
import 'luggage_map_screen.dart';

/// 行李详情界面
/// 显示行李的详细信息，支持查看和编辑
/// 可以更新行李的状态、位置、备注等信息
class LuggageDetailScreen extends StatefulWidget {
  /// 二维码解析后的载荷数据
  final QrPayload qrPayload;
  
  /// 原始二维码字符串
  final String raw;

  const LuggageDetailScreen({
    Key? key,
    required this.qrPayload,
    required this.raw,
  }) : super(key: key);

  @override
  State<LuggageDetailScreen> createState() => _LuggageDetailScreenState();
}

class _LuggageDetailScreenState extends State<LuggageDetailScreen> {
  /// 是否正在加载
  bool _loading = true;
  
  /// 错误信息
  String? _error;
  
  /// 行李数据
  Luggage? _luggage;

  /// 状态输入控制器
  final TextEditingController _statusCtrl = TextEditingController();
  
  /// 位置输入控制器
  final TextEditingController _locationCtrl = TextEditingController();
  
  /// 备注输入控制器
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化时加载行李数据
    _load();
  }

  @override
  void dispose() {
    // 释放资源
    _statusCtrl.dispose();
    _locationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  /// 加载行李详情数据
  /// 从服务器获取行李的完整信息
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final luggageId = widget.qrPayload.luggageId!;
      final luggage = await LuggageService.getLuggageById(luggageId);
      _luggage = luggage;
      _statusCtrl.text = luggage.status.toString().split('.').last;
      _locationCtrl.text = luggage.destination;
      _noteCtrl.text = luggage.notes;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _update() async {
    if (_luggage == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 转换状态字符串为 LuggageStatus 枚举
      LuggageStatus? status;
      final statusText = _statusCtrl.text.trim();
      if (statusText.isNotEmpty) {
        try {
          status = LuggageStatus.values.firstWhere(
            (s) => s.toString().split('.').last == statusText,
          );
        } catch (e) {
          // 如果转换失败，使用默认状态
          status = LuggageStatus.checkIn;
        }
      }

      final updated = await LuggageService.updateLuggage(_luggage!.id, {
        'status': status?.toString().split('.').last,
        'destination': _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        'notes': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      });
      _luggage = updated;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新成功')));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadPlaceholder() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 占位：实际项目里这里一般是“补录/新增行李”
      final created = await LuggageService.uploadLuggage({
        'tagNumber': widget.qrPayload.extra['tagNo'] ?? widget.qrPayload.extra['tag_no'] ?? '',
        'flightNumber': '',
        'passengerName': '',
        'weight': 0.0,
        'status': _statusCtrl.text.trim(),
        'checkInTime': DateTime.now().toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
        'destination': _locationCtrl.text.trim(),
        'notes': _noteCtrl.text.trim(),
      });
      _luggage = created;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('上传/创建成功')));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.qrPayload;

    return Scaffold(
      appBar: AppBar(
        title: const Text('行李信息'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // 标签页
                  const TabBar(
                    tabs: [
                      Tab(text: '基本信息'),
                      Tab(text: '历史日志'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 基本信息标签页
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('二维码解析结果', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    Text('raw: ${widget.raw}'),
                                    Text('userId: ${payload.userId ?? '-'}'),
                                    Text('luggageId: ${payload.luggageId ?? '-'}'),
                                    Text('role: ${payload.role ?? '-'}'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('行李详情', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 12),
                                    _kv('id', _luggage?.id ?? payload.luggageId ?? '-'),
                                    _kv('tagNumber', _luggage?.tagNumber ?? (payload.extra['tagNo']?.toString() ?? '-')),
                                    _kv('flightNumber', _luggage?.flightNumber ?? '-'),
                                    _kv('passengerName', _luggage?.passengerName ?? '-'),
                                    _kv('weight', _luggage?.weight?.toString() ?? '-'),
                                    _kv('status', _luggage?.status?.displayName ?? '-'),
                                    _kv('destination', _luggage?.destination ?? '-'),
                                    _kv('lastUpdated', _luggage?.lastUpdated?.toIso8601String() ?? '-'),
                                    _kv('latitude', _luggage?.latitude?.toString() ?? '-'),
                                    _kv('longitude', _luggage?.longitude?.toString() ?? '-'),
                                    const Divider(height: 24),
                                    TextField(
                                      controller: _statusCtrl,
                                      decoration: const InputDecoration(labelText: '状态 status'),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _locationCtrl,
                                      decoration: const InputDecoration(labelText: '位置 location'),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _noteCtrl,
                                      decoration: const InputDecoration(labelText: '备注 note'),
                                      minLines: 1,
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: _loading ? null : _update,
                                            child: const Text('更新(PUT)'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: _loading ? null : _uploadPlaceholder,
                                            child: const Text('上传/创建(POST)'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (_luggage?.latitude != null && _luggage?.longitude != null)
                                      FilledButton.icon(
                                        onPressed: () {
                                          // 跳转到地图页面
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const LuggageMapScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.map),
                                        label: const Text('在地图上查看'),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 历史日志标签页
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('操作历史日志', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 16),
                                    // 模拟历史操作日志
                                    _buildLogItem('系统', '创建行李记录', '2026-01-29 10:00:00', '系统自动创建'),
                                    _buildLogItem('员工001', '扫描行李', '2026-01-29 10:05:30', '通过二维码扫描'),
                                    _buildLogItem('员工002', '更新状态', '2026-01-29 10:10:20', '从 已办理托运 改为 运输中'),
                                    _buildLogItem('员工002', '上传照片', '2026-01-29 10:15:45', '上传了2张行李照片'),
                                    _buildLogItem('系统', '位置更新', '2026-01-29 11:00:00', '自动更新位置信息'),
                                    _buildLogItem('员工003', '更新状态', '2026-01-29 12:30:15', '从 运输中 改为 已到达'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text('$k:')),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  /// 构建日志项
  Widget _buildLogItem(String operator, String action, String time, String details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.blue, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                action,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('操作人: $operator', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(details, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

