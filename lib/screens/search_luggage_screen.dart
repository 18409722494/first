import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';
import 'qr_scan_screen.dart';

/// 查询行李页面
/// 用于通过条件搜索行李信息
class SearchLuggageScreen extends StatefulWidget {
  const SearchLuggageScreen({super.key});

  @override
  State<SearchLuggageScreen> createState() => _SearchLuggageScreenState();
}

class _SearchLuggageScreenState extends State<SearchLuggageScreen> {
  final _searchController = TextEditingController();
  
  // 搜索结果
  List<Luggage> _searchResults = [];
  // 过滤条件
  LuggageStatus? _selectedStatus;
  // 加载状态
  bool _isLoading = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  /// 执行搜索
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 获取所有行李
      final allLuggage = await LuggageService.getLuggageList();
      
      // 应用搜索和过滤
      final results = allLuggage.where((luggage) {
        // 搜索条件
        final searchTerm = _searchController.text.toLowerCase().trim();
        final matchesSearch = searchTerm.isEmpty ||
            luggage.tagNumber.toLowerCase().contains(searchTerm) ||
            luggage.flightNumber.toLowerCase().contains(searchTerm) ||
            luggage.passengerName.toLowerCase().contains(searchTerm) ||
            luggage.destination.toLowerCase().contains(searchTerm);
        
        // 状态过滤
        final matchesStatus = _selectedStatus == null || luggage.status == _selectedStatus;
        
        return matchesSearch && matchesStatus;
      }).toList();
      
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('搜索失败：${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 重置搜索
  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _searchResults.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('查询行李'),
      ),
      body: Column(
        children: [
          // 搜索和过滤栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 搜索框
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '搜索（标签号、航班号、乘客姓名）',
                    hintText: '请输入搜索关键词',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _resetSearch,
                          icon: const Icon(Icons.clear),
                        ),
                        IconButton(
                          onPressed: _performSearch,
                          icon: const Icon(Icons.search),
                        ),
                        IconButton(
                          onPressed: () {
                            // 导航到二维码扫描页面
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QrScanScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: '扫描条形码',
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 16),
                
                // 状态过滤
                DropdownButtonFormField<LuggageStatus?>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态过滤',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<LuggageStatus?>(
                      value: null,
                      child: Text('全部状态'),
                    ),
                    ...LuggageStatus.values.map((status) {
                      return DropdownMenuItem<LuggageStatus>(
                        value: status,
                        child: Text(_getStatusText(status)),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _performSearch();
                  },
                ),
                const SizedBox(height: 8),
                
                // 搜索按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('执行搜索'),
                  ),
                ),
              ],
            ),
          ),
          
          // 搜索结果
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _searchResults.isEmpty
                    ? const Center(
                        child: Text('请输入搜索条件并点击搜索按钮'),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final luggage = _searchResults[index];
                          return _buildLuggageCard(luggage);
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  /// 构建行李卡片
  Widget _buildLuggageCard(Luggage luggage) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '行李标签号: ${luggage.tagNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(luggage.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(luggage.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.flight, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('航班: ${luggage.flightNumber}'),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('乘客: ${luggage.passengerName}'),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('目的地: ${luggage.destination}'),
                const SizedBox(width: 16),
                const Icon(Icons.scale, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('重量: ${luggage.weight}kg'),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('登记时间: ${DateFormat('yyyy-MM-dd HH:mm').format(luggage.checkInTime)}'),
              ],
            ),
            
            if (luggage.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '备注: ${luggage.notes}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 获取状态文本
  String _getStatusText(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.checkIn:
        return '已办理托运';
      case LuggageStatus.inTransit:
        return '运输中';
      case LuggageStatus.arrived:
        return '已到达';
      case LuggageStatus.delivered:
        return '已交付';
      case LuggageStatus.damaged:
        return '已损坏';
      case LuggageStatus.lost:
        return '已丢失';
      default:
        return '未知状态';
    }
  }
  
  /// 获取状态颜色
  Color _getStatusColor(LuggageStatus status) {
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
}
