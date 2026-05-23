import 'package:flutter/material.dart';
import '../components/luggage_card.dart';
import '../l10n/app_localizations.dart';
import '../models/luggage.dart';
import '../models/qr_payload.dart';
import '../services/baggage_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/luggage_utils.dart';
import '../utils/responsive.dart';
import 'qr_scan_screen.dart';
import 'luggage_detail_screen.dart';

/// ============================================================
/// 行李搜索页面
/// ============================================================
/// 功能说明：
/// - 支持按行李号、旅客姓名进行关键词搜索
/// - 支持按行李状态进行筛选
/// - 搜索结果以列表形式展示
/// - 点击行李卡片可跳转到行李详情页
///
/// 数据来源：BaggageApiService.getAllBaggageList() + searchBaggage()
/// ============================================================
class SearchLuggageScreen extends StatefulWidget {
  const SearchLuggageScreen({super.key});

  @override
  State<SearchLuggageScreen> createState() => _SearchLuggageScreenState();
}

class _SearchLuggageScreenState extends State<SearchLuggageScreen> {
  final _searchController = TextEditingController();

  List<Luggage> _searchResults = [];
  LuggageStatus? _selectedStatus;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 执行搜索
  /// 逻辑：
  /// 1. 获取所有行李数据
  /// 2. 按关键词过滤（行李号、旅客名模糊匹配）
  /// 3. 按状态筛选（如已选择）
  Future<void> _performSearch() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      final searchTerm = _searchController.text.toLowerCase().trim();
      List<Luggage> results;

      if (searchTerm.isNotEmpty) {
        final allResults = await BaggageApiService.searchBaggage(searchTerm);
        results = _selectedStatus == null
            ? allResults
            : allResults.where((l) => l.status == _selectedStatus).toList();
      } else {
        final allResults = await BaggageApiService.getAllBaggageList();
        results = _selectedStatus == null
            ? allResults
            : allResults.where((l) => l.status == _selectedStatus).toList();
      }

      if (!mounted) return;
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.searchFailedCheckNetwork),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 重置搜索条件，清空输入和结果
  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _searchResults.clear();
    });
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
          l10n.luggageSearch,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrScanScreen()),
              );
            },
            tooltip: l10n.scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框区域
          Container(
            padding: EdgeInsets.all(padMd),
            color: AppColors.backgroundLight,
            child: Column(
              children: [
                // 搜索输入框
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.searchPlaceholder,
                            hintStyle: const TextStyle(
                              color: AppColors.textHintLight,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondaryLight,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                    onPressed: _resetSearch,
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      // 搜索按钮
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _performSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.executeSearch,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                // 状态筛选
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(
                        label: l10n.allStatuses,
                        isSelected: _selectedStatus == null,
                        onTap: () {
                          setState(() => _selectedStatus = null);
                          _performSearch();
                        },
                      ),
                      SizedBox(width: Responsive.spacing(context, 8)),
                      ...LuggageStatus.values.map((status) {
                        return Padding(
                          padding: EdgeInsets.only(
                              right: Responsive.spacing(context, 8)),
                          child: _buildFilterChip(
                            label: LuggageUtils.getStatusText(status),
                            isSelected: _selectedStatus == status,
                            onTap: () {
                              setState(() => _selectedStatus = status);
                              _performSearch();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 搜索结果
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.textHintLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.enterSearchCondition,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scanOrAddLuggage,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHintLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final luggage = _searchResults[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: Responsive.spacing(context, AppSpacing.sm),
          ),
          child: LuggageCard(
            luggage: luggage,
            compact: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LuggageDetailScreen(
                    qrPayload: _buildQrPayload(luggage),
                    raw: luggage.tagNumber,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 构造行李卡片的QrPayload（用于跳转到详情页）
  QrPayload _buildQrPayload(Luggage luggage) {
    return QrPayload(
      userId: null,
      luggageId: luggage.tagNumber,
      role: null,
      extra: {
        'tagNo': luggage.tagNumber,
        'flight_hint': luggage.flightNumber,
        'passenger_hint': luggage.passengerName,
      },
    );
  }
}
