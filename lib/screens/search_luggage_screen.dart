import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/luggage_utils.dart';
import '../utils/responsive.dart';
import 'qr_scan_screen.dart';

/// 查询行李页面
/// 用于通过条件搜索行李信息
class SearchLuggageScreen extends StatefulWidget {
  const SearchLuggageScreen({Key? key}) : super(key: key);

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
      // 客户端筛选：拉取足够多页数据（与列表分页接口一致）
      final result = await LuggageService.getLuggageList(page: 1, pageSize: 5000);
      final allLuggage = result.items;

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
          backgroundColor: AppColors.error,
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
    final paddingSm = Responsive.padding(context, AppSpacing.sm);
    final spacingSm = Responsive.spacing(context, AppSpacing.sm);
    final spacingXs = Responsive.spacing(context, AppSpacing.xs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('查询行李'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(paddingSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: Responsive.fontSize(context, 14)),
                  decoration: InputDecoration(
                    labelText: '搜索行李',
                    hintText: '标签号、航班号、乘客姓名或目的地',
                    isDense: true,
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _resetSearch,
                          icon: Icon(Icons.clear, size: Responsive.iconSize(context, 20)),
                        ),
                        IconButton(
                          onPressed: _performSearch,
                          icon: Icon(Icons.search, size: Responsive.iconSize(context, 20)),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QrScanScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.qr_code_scanner, size: Responsive.iconSize(context, 20)),
                          tooltip: '扫描条形码',
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                SizedBox(height: spacingSm),

                DropdownButtonFormField<LuggageStatus?>(
                  value: _selectedStatus,
                  isExpanded: true,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: '状态过滤',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<LuggageStatus?>(
                      value: null,
                      child: Text('全部状态', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                    ),
                    ...LuggageStatus.values.map((status) {
                      return DropdownMenuItem<LuggageStatus>(
                        value: status,
                        child: Text(_getStatusText(status), style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
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
                SizedBox(height: spacingXs),

                // 勿用小于主题 padding+字高的固定 height，否则会裁剪按钮导致文字竖排/只显示一半
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(
                        double.infinity,
                        Responsive.buttonHeight(context, 48)
                            .clamp(kMinInteractiveDimension, 56),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: Responsive.iconSize(context, 18),
                            width: Responsive.iconSize(context, 18),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '执行搜索',
                            style: TextStyle(fontSize: Responsive.fontSize(context, 14)),
                          ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Text('请输入搜索条件并点击搜索按钮', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
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
    final spacingXs = Responsive.spacing(context, AppSpacing.xs);
    final spacingSm = Responsive.spacing(context, AppSpacing.sm);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: Responsive.padding(context, AppSpacing.sm), vertical: spacingXs),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '行李标签号: ${luggage.tagNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 14),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 10), vertical: Responsive.spacing(context, 3)),
                  decoration: BoxDecoration(
                    color: _getStatusColor(luggage.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(luggage.status),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 11),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacingXs),

            Row(
              children: [
                Icon(Icons.flight, size: Responsive.iconSize(context, 14), color: Colors.grey),
                SizedBox(width: Responsive.spacing(context, 6)),
                Text('${luggage.flightNumber}', style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                SizedBox(width: spacingSm),
                Icon(Icons.person, size: Responsive.iconSize(context, 14), color: Colors.grey),
                SizedBox(width: Responsive.spacing(context, 6)),
                Text('${luggage.passengerName}', style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
              ],
            ),
            SizedBox(height: spacingXs),

            Row(
              children: [
                Icon(Icons.location_on, size: Responsive.iconSize(context, 14), color: Colors.grey),
                SizedBox(width: Responsive.spacing(context, 6)),
                Text('${luggage.destination}', style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                SizedBox(width: spacingSm),
                Icon(Icons.scale, size: Responsive.iconSize(context, 14), color: Colors.grey),
                SizedBox(width: Responsive.spacing(context, 6)),
                Text('${luggage.weight}kg', style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
              ],
            ),
            SizedBox(height: spacingXs),

            Row(
              children: [
                Icon(Icons.access_time, size: Responsive.iconSize(context, 14), color: Colors.grey),
                SizedBox(width: Responsive.spacing(context, 6)),
                Text(DateFormat('yyyy-MM-dd HH:mm').format(luggage.checkInTime), style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
              ],
            ),

            if (luggage.notes.isNotEmpty) ...[
              SizedBox(height: spacingXs),
              Row(
                children: [
                  Icon(Icons.note, size: Responsive.iconSize(context, 14), color: Colors.grey),
                  SizedBox(width: Responsive.spacing(context, 6)),
                  Expanded(
                    child: Text(
                      '备注: ${luggage.notes}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: Responsive.fontSize(context, 12)),
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
    return LuggageUtils.getStatusText(status);
  }

  /// 获取状态颜色
  Color _getStatusColor(LuggageStatus status) {
    return LuggageUtils.getStatusColor(status);
  }
}
