import 'package:flutter/material.dart';
import '../models/abnormal_baggage.dart';
import '../services/evidence_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'evidence_detail_screen.dart';

/// 证据查询列表页面
class EvidenceListScreen extends StatefulWidget {
  const EvidenceListScreen({Key? key}) : super(key: key);

  @override
  State<EvidenceListScreen> createState() => _EvidenceListScreenState();
}

class _EvidenceListScreenState extends State<EvidenceListScreen> {
  List<AbnormalBaggage> _allItems = [];
  List<AbnormalBaggage> _filteredItems = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await EvidenceService.getAllAbnormalBaggage();
      if (!mounted) return;
      setState(() {
        _allItems = data;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredItems = _allItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.baggageNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.damageDescription.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesDate = true;
      if (_dateRange != null) {
        matchesDate = item.timestamp.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            item.timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _applyFilters();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _applyFilters();
    }
  }

  void _clearDateFilter() {
    setState(() => _dateRange = null);
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _dateRange = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  void _navigateToDetail(AbnormalBaggage item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EvidenceDetailScreen(baggage: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padMd = Responsive.padding(context, AppSpacing.md);
    final padSm = Responsive.padding(context, AppSpacing.sm);
    final spSm = Responsive.spacing(context, AppSpacing.sm);

    return Scaffold(
      appBar: AppBar(
        title: const Text('证据查询'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(padMd),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '搜索行李号、地点、描述...',
                    prefixIcon: Icon(Icons.search, size: Responsive.iconSize(context, 20)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearAllFilters,
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: padMd,
                      vertical: Responsive.spacing(context, AppSpacing.buttonPadding),
                    ),
                  ),
                ),
                SizedBox(height: spSm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: Icon(Icons.date_range, size: Responsive.iconSize(context, 18)),
                        label: Text(
                          _dateRange != null
                              ? '${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}'
                              : '选择日期范围',
                          style: TextStyle(fontSize: Responsive.fontSize(context, 13)),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _dateRange != null ? AppColors.primary : null,
                          side: BorderSide(
                            color: _dateRange != null ? AppColors.primary : AppColors.divider,
                          ),
                        ),
                      ),
                    ),
                    if (_dateRange != null) ...[
                      SizedBox(width: spSm),
                      IconButton(
                        icon: Icon(Icons.clear, size: Responsive.iconSize(context, 20)),
                        onPressed: _clearDateFilter,
                        tooltip: '清除日期筛选',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padMd, vertical: Responsive.spacing(context, AppSpacing.xs)),
            child: Row(
              children: [
                Text(
                  '共 ${_filteredItems.length} 条记录',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: Responsive.fontSize(context, 13),
                  ),
                ),
                const Spacer(),
                if (_searchQuery.isNotEmpty || _dateRange != null)
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: Text(
                      '清除筛选',
                      style: TextStyle(fontSize: Responsive.fontSize(context, 12)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: Responsive.iconSize(context, 48), color: AppColors.error),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text(
              _error!,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 13),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: Responsive.iconSize(context, 64),
              color: Colors.grey[300],
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            Text(
              _searchQuery.isNotEmpty || _dateRange != null ? '未找到匹配的记录' : '暂无破损证据记录',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 15),
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isEmpty && _dateRange == null) ...[
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              Text(
                '请扫描破损行李并提交报告',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 13),
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return _buildEvidenceCard(item);
        },
      ),
    );
  }

  Widget _buildEvidenceCard(AbnormalBaggage item) {
    final padSm = Responsive.padding(context, AppSpacing.sm);
    final spXs = Responsive.spacing(context, AppSpacing.xs);
    final spSm = Responsive.spacing(context, AppSpacing.sm);

    return Card(
      margin: EdgeInsets.only(bottom: spSm),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      child: InkWell(
        onTap: () => _navigateToDetail(item),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: EdgeInsets.all(padSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  color: AppColors.backgroundLight,
                ),
                child: item.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image_outlined,
                              size: Responsive.iconSize(context, 32),
                              color: Colors.grey[400],
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.broken_image_outlined,
                        size: Responsive.iconSize(context, 32),
                        color: Colors.grey[400],
                      ),
              ),
              SizedBox(width: spSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '行李号: ${item.baggageNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.fontSize(context, 14),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context, 8),
                            vertical: Responsive.spacing(context, 2),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '破损',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: Responsive.fontSize(context, 11),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spXs),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: Responsive.iconSize(context, 12), color: Colors.grey[500]),
                        SizedBox(width: Responsive.spacing(context, 4)),
                        Text(
                          item.formattedTime,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: Responsive.fontSize(context, 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spXs),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: Responsive.iconSize(context, 12), color: Colors.grey[500]),
                        SizedBox(width: Responsive.spacing(context, 4)),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: Responsive.fontSize(context, 12),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spXs),
                    Text(
                      item.damageDescription,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: Responsive.fontSize(context, 12),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
