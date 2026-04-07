import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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

/// 行李列表页面
class LuggageListScreen extends StatefulWidget {
  const LuggageListScreen({super.key});

  @override
  State<LuggageListScreen> createState() => _LuggageListScreenState();
}

class _LuggageListScreenState extends State<LuggageListScreen> {
  // 数据
  final List<Luggage> _allItems = [];
  List<Luggage> _filteredItems = [];
  bool _isLoadingFirst = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;
  int _currentPage = 1;
  static const int _pageSize = 20;

  // 筛选
  String _searchQuery = '';
  String? _statusFilter;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadFirstPage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 首次加载（第 1 页）
  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingFirst = true;
      _error = null;
      _hasMoreData = true;
      _currentPage = 1;
      _allItems.clear();
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      final result = await LuggageService.getLuggageList(
        ownerId: userId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _allItems.clear();
        _allItems.addAll(result.items);
        _hasMoreData = result.hasMore;
        _isLoadingFirst = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingFirst = false;
      });
    }
  }

  /// 加载更多（下一页）
  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      final result = await LuggageService.getLuggageList(
        ownerId: userId,
        page: _currentPage + 1,
        pageSize: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _currentPage++;
        _allItems.addAll(result.items);
        _hasMoreData = result.hasMore;
        _isLoadingMore = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  /// 刷新（回到第 1 页）
  Future<void> _refresh() async {
    await _loadFirstPage();
  }

  /// 在 _allItems 上应用筛选，结果存入 _filteredItems
  void _applyFilters() {
    _filteredItems = _allItems.where((luggage) {
      final matchesSearch = _searchQuery.isEmpty ||
          luggage.tagNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          luggage.passengerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          luggage.destination.toLowerCase().contains(_searchQuery.toLowerCase());
      // 使用 enum.name：LuggageStatus.toString() 返回中文 displayName，不能用于筛选键
      final matchesStatus =
          _statusFilter == null || luggage.status.name == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _applyFilters();
  }

  void _setStatusFilter(String? status) {
    setState(() => _statusFilter = status);
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = null;
    });
    _searchController.clear();
    _applyFilters();
  }

  /// 滚动至底部 200px 时触发加载更多
  void _onScroll() {
    if (!_hasMoreData || _isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMoreItems();
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
        builder: (_) => LuggageDetailScreen(qrPayload: qrPayload, raw: luggage.id),
      ),
    ).then((_) => _refresh());
  }

  void _showFilterBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark
              ? AppColors.cardDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: EdgeInsets.only(top: Responsive.spacing(ctx, AppSpacing.sm)),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.padding(ctx, AppSpacing.md)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.filterConditions,
                    style: TextStyle(fontSize: Responsive.fontSize(ctx, 18), fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () { Navigator.pop(ctx); _clearFilters(); },
                  child: Text(l10n.clearFilter, style: TextStyle(fontSize: Responsive.fontSize(ctx, 13))),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(ctx, AppSpacing.md),
                vertical: Responsive.spacing(ctx, AppSpacing.sm)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(ctx, 14))),
              SizedBox(height: Responsive.spacing(ctx, AppSpacing.sm)),
              Wrap(
                spacing: Responsive.spacing(ctx, AppSpacing.sm),
                runSpacing: Responsive.spacing(ctx, AppSpacing.sm),
                children: [
                  _buildFilterChip(ctx, l10n.all, null),
                  _buildFilterChip(ctx, l10n.checkIn, 'checkIn'),
                  _buildFilterChip(ctx, l10n.inTransit, 'inTransit'),
                  _buildFilterChip(ctx, l10n.arrived, 'arrived'),
                  _buildFilterChip(ctx, l10n.delivered, 'delivered'),
                  _buildFilterChip(ctx, l10n.damaged, 'damaged'),
                  _buildFilterChip(ctx, l10n.lost, 'lost'),
                ],
              ),
            ]),
          ),
          SizedBox(height: Responsive.spacing(ctx, AppSpacing.lg)),
        ]),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext ctx, String label, String? status) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: Responsive.fontSize(ctx, 13))),
      selected: isSelected,
      onSelected: (_) {
        Navigator.pop(ctx);
        _setStatusFilter(status);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  void _showLongPressMenu(BuildContext ctx, Luggage luggage) {
    final l10n = AppLocalizations.of(ctx)!;
    showModalBottomSheet(
      context: ctx,
      builder: (ctx2) => Container(
        padding: EdgeInsets.all(Responsive.padding(ctx2, AppSpacing.md)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(Icons.edit, size: Responsive.iconSize(ctx2, 20)),
            title: Text(l10n.changeStatus, style: TextStyle(fontSize: Responsive.fontSize(ctx2, 14))),
            onTap: () { Navigator.pop(ctx2); _navigateToDetail(luggage); },
          ),
          ListTile(
            leading: Icon(Icons.report_problem, size: Responsive.iconSize(ctx2, 20)),
            title: Text(l10n.markDamaged, style: TextStyle(fontSize: Responsive.fontSize(ctx2, 14))),
            onTap: () {
              Navigator.pop(ctx2);
              Navigator.of(ctx2).push(
                MaterialPageRoute(builder: (_) => DamageReportScreen(
                  luggageId: luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id,
                  luggageDbId: luggage.id,
                )),
              ).then((result) { if (result == true) _refresh(); });
            },
          ),
          ListTile(
            leading: Icon(Icons.history, size: Responsive.iconSize(ctx2, 20)),
            title: Text(l10n.viewHistoryLog, style: TextStyle(fontSize: Responsive.fontSize(ctx2, 14))),
            onTap: () { Navigator.pop(ctx2); _navigateToDetail(luggage); },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padMd = Responsive.padding(context, AppSpacing.md);
    final spSm = Responsive.spacing(context, AppSpacing.sm);
    final spXs = Responsive.spacing(context, AppSpacing.xs);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.luggageManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _isLoadingFirst ? null : _showFilterBottomSheet,
            tooltip: l10n.filter,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingFirst ? null : _refresh,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(children: [
        // 搜索框
        Padding(
          padding: EdgeInsets.all(padMd),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.searchLuggageTag,
              prefixIcon: Icon(Icons.search, size: Responsive.iconSize(context, 20)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearFilters)
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: padMd,
                  vertical: Responsive.spacing(context, AppSpacing.buttonPadding)),
            ),
          ),
        ),
        // 统计行
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padMd, vertical: spXs),
          child: Row(children: [
            Text(
              l10n.totalLuggage(_filteredItems.length),
              style: TextStyle(color: Colors.grey[600], fontSize: Responsive.fontSize(context, 14)),
            ),
            if (_hasMoreData && !_isLoadingFirst)
              Padding(
                padding: EdgeInsets.only(left: spXs),
                child: Text(
                  l10n.loadMore,
                  style: TextStyle(color: Colors.grey[400], fontSize: Responsive.fontSize(context, 12)),
                ),
              ),
          ]),
        ),
        // 筛选标签
        if (_statusFilter != null || _searchQuery.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: padMd, vertical: spSm),
            child: Row(children: [
              if (_statusFilter != null)
                Container(
                  margin: EdgeInsets.only(right: spSm),
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context, 12),
                      vertical: Responsive.spacing(context, 4)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    StatusBadge(statusKey: _statusFilter, compact: true),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    GestureDetector(
                      onTap: () => _setStatusFilter(null),
                      child: Icon(Icons.close, size: Responsive.iconSize(context, 14), color: AppColors.primary),
                    ),
                  ]),
                ),
              if (_searchQuery.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context, 12),
                      vertical: Responsive.spacing(context, 4)),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('"$_searchQuery"', style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    GestureDetector(
                      onTap: _clearFilters,
                      child: Icon(Icons.close, size: Responsive.iconSize(context, 14), color: Colors.grey[600]),
                    ),
                  ]),
                ),
            ]),
          ),
        // 列表主体
        Expanded(
          child: _isLoadingFirst
              ? const LoadingState()
              : _error != null
                  ? ErrorState(message: _error!, onRetry: _loadFirstPage)
                  : _filteredItems.isEmpty
                      ? EmptyState.search(context, keyword: _searchQuery.isNotEmpty ? _searchQuery : null)
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(padMd),
                            // 列表项数 + 底部指示器
                            itemCount: _filteredItems.length +
                                ((_isLoadingMore || _hasMoreData) ? 1 : 0),
                            itemBuilder: (ctx, index) {
                              if (index == _filteredItems.length) {
                                if (_isLoadingMore) {
                                  return Container(
                                    padding: EdgeInsets.all(padMd),
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(),
                                  );
                                }
                                if (!_hasMoreData) {
                                  return Container(
                                    padding: EdgeInsets.all(padMd),
                                    alignment: Alignment.center,
                                    child: Text(
                                      l10n.allLoaded(_allItems.length),
                                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                              final luggage = _filteredItems[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: spSm),
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
      ]),
    );
  }
}
