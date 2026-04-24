import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../components/empty_state.dart';
import '../components/luggage_card.dart';
import '../components/luggage_filter_sheet.dart';
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

/// 行李列表页面 - 基于 UI 设计风格
class LuggageListScreen extends StatefulWidget {
  const LuggageListScreen({super.key});

  @override
  State<LuggageListScreen> createState() => _LuggageListScreenState();
}

class _LuggageListScreenState extends State<LuggageListScreen> {
  final List<Luggage> _allItems = [];
  List<Luggage> _filteredItems = [];
  bool _isLoadingFirst = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;
  int _currentPage = 1;
  static const int _pageSize = 20;

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

  Future<void> _refresh() async {
    await _loadFirstPage();
  }

  void _applyFilters() {
    _filteredItems = _allItems.where((luggage) {
      final matchesSearch = _searchQuery.isEmpty ||
          luggage.tagNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          luggage.passengerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          luggage.destination.toLowerCase().contains(_searchQuery.toLowerCase());
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
    showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LuggageFilterSheet(
        currentStatus: _statusFilter,
        l10n: (key) {
          final l10n = AppLocalizations.of(ctx)!;
          switch (key) {
            case 'filterConditions': return l10n.filterConditions;
            case 'clearFilter': return l10n.clearFilter;
            case 'status': return l10n.status;
            case 'all': return l10n.all;
            case 'checkIn': return l10n.checkIn;
            case 'inTransit': return l10n.inTransit;
            case 'arrived': return l10n.arrived;
            case 'delivered': return l10n.delivered;
            case 'damaged': return l10n.damaged;
            case 'lost': return l10n.lost;
            default: return key;
          }
        },
      ),
    ).then((selected) {
      if (selected != null) {
        _setStatusFilter(selected);
      }
    });
  }

  void _showLongPressMenu(BuildContext ctx, Luggage luggage) {
    final l10n = AppLocalizations.of(ctx)!;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx2) => Padding(
        padding: EdgeInsets.all(Responsive.padding(ctx2, AppSpacing.md)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            ListTile(
              leading: const Icon(Icons.edit, size: 20, color: AppColors.primary),
              title: Text(
                l10n.changeStatus,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(ctx2);
                _navigateToDetail(luggage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem, size: 20, color: AppColors.warning),
              title: Text(
                l10n.markDamaged,
                style: const TextStyle(fontSize: 14),
              ),
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
              leading: const Icon(Icons.history, size: 20, color: AppColors.info),
              title: Text(
                l10n.viewHistoryLog,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(ctx2);
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
    final l10n = AppLocalizations.of(context)!;
    final padMd = Responsive.padding(context, AppSpacing.md);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          l10n.luggageManagement,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: _isLoadingFirst ? null : _showFilterBottomSheet,
            tooltip: l10n.filter,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _isLoadingFirst ? null : _refresh,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: EdgeInsets.all(padMd),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchLuggageTag,
                        hintStyle: const TextStyle(color: AppColors.textHintLight),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondaryLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondaryLight,
                      ),
                      onPressed: _clearFilters,
                    ),
                ],
              ),
            ),
          ),
          // 统计行
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padMd, vertical: 4),
            child: Row(
              children: [
                Text(
                  l10n.totalLuggage(_filteredItems.length),
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
                if (_hasMoreData && !_isLoadingFirst)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      l10n.loadMore,
                      style: const TextStyle(
                        color: AppColors.textHintLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 筛选标签
          if (_statusFilter != null || _searchQuery.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padMd, vertical: 8),
              child: Row(
                children: [
                  if (_statusFilter != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(statusKey: _statusFilter, compact: true),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _setStatusFilter(null),
                            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  if (_searchQuery.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '"$_searchQuery"',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _clearFilters,
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          // 列表主体
          Expanded(
            child: _isLoadingFirst
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error != null
                    ? ErrorState(message: _error!, onRetry: _loadFirstPage)
                    : _filteredItems.isEmpty
                        ? EmptyState.search(context, keyword: _searchQuery.isNotEmpty ? _searchQuery : null)
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            color: AppColors.primary,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(padMd),
                              itemCount: _filteredItems.length +
                                  ((_isLoadingMore || _hasMoreData) ? 1 : 0),
                              itemBuilder: (ctx, index) {
                                if (index == _filteredItems.length) {
                                  if (_isLoadingMore) {
                                    return Container(
                                      padding: EdgeInsets.all(padMd),
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    );
                                  }
                                  if (!_hasMoreData) {
                                    return Container(
                                      padding: EdgeInsets.all(padMd),
                                      alignment: Alignment.center,
                                      child: Text(
                                        l10n.allLoaded(_allItems.length),
                                        style: const TextStyle(
                                          color: AppColors.textHintLight,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }
                                final luggage = _filteredItems[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
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
