import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/empty_state.dart';
import '../components/luggage_card.dart';
import '../components/status_badge.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'luggage_detail_screen.dart';
import 'damage_report_screen.dart';
import '../models/qr_payload.dart';

/// 行李列表界面
/// 显示当前用户的所有行李信息
/// 支持下拉刷新、点击查看详情、搜索过滤等功能
class LuggageListScreen extends StatefulWidget {
  const LuggageListScreen({Key? key}) : super(key: key);

  @override
  State<LuggageListScreen> createState() => _LuggageListScreenState();
}

class _LuggageListScreenState extends State<LuggageListScreen> {
  List<Luggage> _luggageList = [];
  List<Luggage> _filteredList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadLuggageList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLuggageList() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _hasMoreData = true;
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

  /// 加载更多行李数据
  Future<void> _loadMoreLuggage() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      final moreLuggage = await LuggageService.getLuggageList(ownerId: userId);
      setState(() {
        _hasMoreData = false;
        if (moreLuggage.isNotEmpty) {
          _luggageList.addAll(moreLuggage);
          _filteredList = _luggageList;
          _filterList();
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
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

  void _onScroll() {
    if (_isLoadingMore || !_hasMoreData) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 100) {
      _loadMoreLuggage();
    }
  }

  void _navigateToDetail(Luggage luggage) {
    final qrPayload = QrPayload(
      userId: '',
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
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: Responsive.spacing(context, AppSpacing.sm)),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '筛选条件',
                    style: TextStyle(fontSize: Responsive.fontSize(context, 18), fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearFilters();
                    },
                    child: Text('清除筛选', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, AppSpacing.md), vertical: Responsive.spacing(context, AppSpacing.sm)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('状态', style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(context, 14))),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                  Wrap(
                    spacing: Responsive.spacing(context, AppSpacing.sm),
                    runSpacing: Responsive.spacing(context, AppSpacing.sm),
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
            SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
      selected: isSelected,
      onSelected: (value) {
        Navigator.pop(context);
        _setStatusFilter(status);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  /// 显示长按菜单
  void _showLongPressMenu(BuildContext context, Luggage luggage) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, size: Responsive.iconSize(context, 20)),
              title: Text('修改状态', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToDetail(luggage);
              },
            ),
            ListTile(
              leading: Icon(Icons.report_problem, size: Responsive.iconSize(context, 20)),
              title: Text('标记破损', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DamageReportScreen(luggageId: luggage.id),
                  ),
                ).then((result) {
                  if (result == true) {
                    _loadLuggageList();
                  }
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.history, size: Responsive.iconSize(context, 20)),
              title: Text('查看历史日志', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToDetail(luggage);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paddingMd = Responsive.padding(context, AppSpacing.md);
    final paddingSm = Responsive.padding(context, AppSpacing.sm);
    final spacingSm = Responsive.spacing(context, AppSpacing.sm);
    final spacingXs = Responsive.spacing(context, AppSpacing.xs);

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
          Padding(
            padding: EdgeInsets.all(paddingMd),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '搜索行李标签、所有者、位置...',
                prefixIcon: Icon(Icons.search, size: Responsive.iconSize(context, 20)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilters,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: paddingMd,
                  vertical: Responsive.spacing(context, AppSpacing.buttonPadding),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingMd, vertical: spacingXs),
            child: Row(
              children: [
                Text(
                  '共 ${_filteredList.length} 个行李',
                  style: TextStyle(color: Colors.grey[600], fontSize: Responsive.fontSize(context, 14)),
                ),
              ],
            ),
          ),
          if (_statusFilter != null || _searchQuery.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: paddingMd, vertical: spacingSm),
              child: Row(
                children: [
                  if (_statusFilter != null)
                    Container(
                      margin: EdgeInsets.only(right: spacingSm),
                      padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 12), vertical: Responsive.spacing(context, 4)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(statusKey: _statusFilter, compact: true),
                          SizedBox(width: Responsive.spacing(context, 4)),
                          GestureDetector(
                            onTap: () => _setStatusFilter(null),
                            child: Icon(Icons.close, size: Responsive.iconSize(context, 14), color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  if (_searchQuery.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 12), vertical: Responsive.spacing(context, 4)),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '"$_searchQuery"',
                            style: TextStyle(fontSize: Responsive.fontSize(context, 12)),
                          ),
                          SizedBox(width: Responsive.spacing(context, 4)),
                          GestureDetector(
                            onTap: _clearFilters,
                            child: Icon(Icons.close, size: Responsive.iconSize(context, 14), color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const LoadingState()
                : _error != null
                    ? ErrorState(
                        message: _error!,
                        onRetry: _loadLuggageList,
                      )
                    : _filteredList.isEmpty
                        ? EmptyState.search(keyword: _searchQuery.isNotEmpty ? _searchQuery : null)
                        : RefreshIndicator(
                            onRefresh: _loadLuggageList,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(paddingMd),
                              itemCount: _filteredList.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filteredList.length) {
                                  return Container(
                                    padding: EdgeInsets.all(paddingMd),
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(),
                                  );
                                }
                                final luggage = _filteredList[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: spacingSm),
                                  child: LuggageCard(
                                    luggage: luggage,
                                    onTap: () => _navigateToDetail(luggage),
                                    onLongPress: () => _showLongPressMenu(context, luggage),
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
