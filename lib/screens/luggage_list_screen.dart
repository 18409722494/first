import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';
import '../providers/auth_provider.dart';
import 'luggage_detail_screen.dart';
import 'luggage_map_screen.dart';
import 'damage_report_screen.dart';
import '../models/qr_payload.dart';

/// 行李列表界面
/// 显示当前用户的所有行李信息
/// 支持下拉刷新、点击查看详情、搜索过滤等功能
class LuggageListScreen extends StatefulWidget {
  const LuggageListScreen({super.key});

  @override
  State<LuggageListScreen> createState() => _LuggageListScreenState();
}

class _LuggageListScreenState extends State<LuggageListScreen> {
  List<Luggage> _luggageList = [];
  List<Luggage> _filteredList = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLuggageList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLuggageList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      final list = await LuggageService.getLuggageList(ownerId: userId);
      setState(() {
        _luggageList = list;
        _filteredList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterList() {
    setState(() {
      _filteredList = _luggageList.where((luggage) {
        final matchesSearch = _searchQuery.isEmpty ||
            (luggage.tagNumber.toLowerCase().contains(_searchQuery.toLowerCase())) ||
            (luggage.passengerName.toLowerCase().contains(_searchQuery.toLowerCase())) ||
            (luggage.destination.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        final matchesStatus = _statusFilter == null || luggage.status.toString().split('.').last == _statusFilter;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _filterList();
  }

  void _setStatusFilter(String? status) {
    setState(() {
      _statusFilter = status;
    });
    _filterList();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = null;
      _filteredList = _luggageList;
    });
    _searchController.clear();
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

  void _navigateToDetail(Luggage luggage) {
    final qrPayload = QrPayload(
      userId: '', // 暂时使用空字符串，后续可从用户信息中获取
      luggageId: luggage.id,
      role: 'owner',
      extra: {'tagNo': luggage.tagNumber},
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LuggageDetailScreen(
          qrPayload: qrPayload,
          raw: luggage.id,
        ),
      ),
    ).then((_) {
      _loadLuggageList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '筛选条件',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearFilters();
                    },
                    child: const Text('清除筛选'),
                  ),
                ],
              ),
            ),
            // 状态筛选
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('状态', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildFilterChip('全部', null),
                      _buildFilterChip('已办理托运', 'checkIn'),
                      _buildFilterChip('运输中', 'inTransit'),
                      _buildFilterChip('已到达', 'arrived'),
                      _buildFilterChip('已交付', 'delivered'),
                      _buildFilterChip('已损坏', 'damaged'),
                      _buildFilterChip('已丢失', 'lost'),
                    ],
                  ),
                ],
              ),
            ),
            // 时间筛选
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('时间', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildFilterChip('今天', 'today'),
                      _buildFilterChip('昨天', 'yesterday'),
                      _buildFilterChip('本周', 'this_week'),
                      _buildFilterChip('本月', 'this_month'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (value) {
        Navigator.pop(context);
        _setStatusFilter(status);
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
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

  /// 显示长按菜单
  void _showLongPressMenu(BuildContext context, Luggage luggage) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('修改状态'),
              onTap: () {
                Navigator.of(context).pop();
                // 导航到详情页进行状态修改
                _navigateToDetail(luggage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('标记破损'),
              onTap: () {
                Navigator.of(context).pop();
                // 导航到破损登记页面
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DamageReportScreen(luggage: luggage),
                  ),
                ).then((result) {
                  if (result == true) {
                    _loadLuggageList();
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('查看历史日志'),
              onTap: () {
                Navigator.of(context).pop();
                // 导航到详情页查看历史日志
                _navigateToDetail(luggage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('查看位置'),
              onTap: () {
                Navigator.of(context).pop();
                // 导航到地图页面查看位置
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LuggageMapScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行李管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _isLoading ? null : _showFilterBottomSheet,
            tooltip: '筛选',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadLuggageList,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '搜索行李标签、所有者、位置...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilters,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // 筛选标签显示
          if (_statusFilter != null || _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_statusFilter != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStatusText(_statusFilter),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => _setStatusFilter(null),
                            child: Icon(Icons.close, size: 14, color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  if (_searchQuery.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '"$_searchQuery"',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: _clearFilters,
                            child: Icon(Icons.close, size: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          // 统计信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '共 ${_filteredList.length} 个行李',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              '加载失败',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _error!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadLuggageList,
                              icon: const Icon(Icons.refresh),
                              label: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : _filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.luggage_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  '暂无行李',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty || _statusFilter != null
                                      ? '尝试调整搜索条件或清除筛选'
                                      : '扫描二维码添加行李或等待系统同步',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_searchQuery.isNotEmpty || _statusFilter != null)
                                  const SizedBox(height: 16),
                                if (_searchQuery.isNotEmpty || _statusFilter != null)
                                  ElevatedButton.icon(
                                    onPressed: _clearFilters,
                                    icon: const Icon(Icons.clear),
                                    label: const Text('清除筛选'),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadLuggageList,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredList.length,
                              itemBuilder: (context, index) {
                                final luggage = _filteredList[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () => _navigateToDetail(luggage),
                                    onLongPress: () => _showLongPressMenu(context, luggage),
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
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 4),
                                                      child: Text(
                                                        luggage.passengerName,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: Colors.grey[600],
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(luggage.status)
                                                      .withOpacity(0.1),
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
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    luggage.destination,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Colors.grey[600],
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.scale_outlined,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${luggage.weight} kg',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
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
          ),
        ],
      ),
    );
  }
}
