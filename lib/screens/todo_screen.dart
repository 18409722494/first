import 'package:flutter/material.dart';
import '../services/baggage_api_service.dart';
import '../services/storage_service.dart';
import '../services/luggage_service.dart';
import '../models/todo_item.dart';
import '../services/evidence_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../utils/responsive.dart';

/// 待办事项页面
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoItem> _items = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  // 航班相关
  List<String> _flightNumbers = [];
  String? _selectedFlight;
  bool _isLoadingFlights = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadTodoItems() async {
    if (_isLoading || _hasLoaded) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final todos = await _fetchAllTodoItems();
      if (!mounted) return;
      setState(() {
        _items = todos;
        _isLoading = false;
        _hasLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败: $e';
        _isLoading = false;
        _hasLoaded = true;
      });
    }
  }

  Future<void> _loadFlightNumbers() async {
    if (_isLoadingFlights) return;

    setState(() => _isLoadingFlights = true);

    try {
      // 从行李列表中提取唯一的航班号
      final result = await LuggageService.getLuggageList(page: 1, pageSize: 9999);
      final uniqueFlights = <String>{};
      for (final luggage in result.items) {
        if (luggage.flightNumber.isNotEmpty) {
          uniqueFlights.add(luggage.flightNumber);
        }
      }
      if (mounted) {
        setState(() {
          _flightNumbers = uniqueFlights.toList()..sort();
          _isLoadingFlights = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFlights = false);
      }
    }
  }

  Future<void> _onFlightSelected(String? flight) async {
    if (flight == null) return;

    setState(() {
      _selectedFlight = flight;
      _items = [];
      _isLoading = true;
    });

    try {
      final employeeId = await StorageService.getEmployeeId();
      if (employeeId != null) {
        // 调用 /baggage/unprocessed 接口获取该航班中未处理的行李
        final unprocessedList = await BaggageApiService.getUnprocessedBaggage(
          flightNumber: flight,
          employeeId: employeeId,
        );

        final todos = unprocessedList.map((luggage) {
          return TodoItem.fromUnprocessed(
            baggageNumber: luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id,
            flightNumber: flight,
            timestamp: DateTime.now(),
          );
        }).toList();

        if (mounted) {
          setState(() {
            _items = todos;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<List<TodoItem>> _fetchAllTodoItems() async {
    final results = await Future.wait([
      _fetchDamageTodos().timeout(const Duration(seconds: 10), onTimeout: () => []),
      _fetchUnclaimedTodos().timeout(const Duration(seconds: 8), onTimeout: () => []),
    ]);
    return [...results[0], ...results[1]];
  }

  Future<List<TodoItem>> _fetchDamageTodos() async {
    try {
      final records = await EvidenceService.getAllAbnormalBaggage();
      return records.map((r) => TodoItem.fromAbnormalBaggage(
        id: r.id.toString(),
        baggageNumber: r.baggageNumber,
        damageDescription: r.damageDescription,
        timestamp: r.timestamp,
        luggageId: r.baggageHash.isEmpty ? null : null,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<TodoItem>> _fetchUnclaimedTodos() async {
    try {
      final list = await LuggageService.getUnclaimedLuggage();
      return list.map((luggage) => TodoItem.fromUnclaimedLuggage(
        tagNumber: luggage.tagNumber,
        luggageId: luggage.id,
        passengerName: luggage.passengerName,
        arrivedAt: luggage.lastUpdated,
        unclaimedHours: 24,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        title: Text(
          '待办事项',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadTodoItems,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: '刷新',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!_hasLoaded && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTodoItems();
        _loadFlightNumbers();
      });
    }

    return Column(
      children: [
        // 航班选择器
        _buildFlightSelector(context),

        // 待办列表
        Expanded(
          child: _buildTodoList(context),
        ),
      ],
    );
  }

  Widget _buildFlightSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flight,
                size: Responsive.iconSize(context, 18),
                color: AppColors.primary,
              ),
              SizedBox(width: Responsive.spacing(context, 8)),
              Text(
                '选择航班',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (_isLoadingFlights)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
          _buildFlightDropdown(context),
          if (_selectedFlight != null) ...[
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text(
              '未处理行李数量: ${_items.length}',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 12),
                color: AppColors.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlightDropdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingFlights) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, AppSpacing.md),
          vertical: Responsive.padding(context, AppSpacing.sm),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_empty, size: 18, color: AppColors.textHintDark),
            SizedBox(width: Responsive.spacing(context, 8)),
            Text(
              '加载中...',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    if (_flightNumbers.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, AppSpacing.md),
          vertical: Responsive.padding(context, AppSpacing.sm),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: AppColors.textHintDark),
            SizedBox(width: Responsive.spacing(context, 8)),
            Text(
              '暂无历史航班记录',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, AppSpacing.md),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: AppColors.primary,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(
            children: [
              Icon(Icons.airplanemode_active, size: 18, color: AppColors.primary),
              SizedBox(width: Responsive.spacing(context, 8)),
              Text(
                '请选择航班',
                style: TextStyle(
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
              ),
            ],
          ),
          value: _selectedFlight,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
          items: _flightNumbers.map((flight) {
            return DropdownMenuItem<String>(
              value: flight,
              child: Row(
                children: [
                  Icon(Icons.flight_takeoff, size: 18, color: AppColors.primary),
                  SizedBox(width: Responsive.spacing(context, 8)),
                  Text(
                    flight,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: _onFlightSelected,
        ),
      ),
    );
  }

  Widget _buildTodoList(BuildContext context) {
    if (_isLoading && _items.isEmpty && _selectedFlight != null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodoItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFlight != null ? '该航班暂无未处理行李' : '请先选择航班',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (_selectedFlight == null) ...[
              const SizedBox(height: 8),
              const Text(
                '从上方下拉菜单选择一个航班',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHintLight,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodoItems,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        children: [
          // 标题和数量
          Row(
            children: [
              const Text(
                '异常行李',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_items.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
          // 待办列表
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _items.length - 1
                    ? Responsive.spacing(context, AppSpacing.sm)
                    : 0,
              ),
              child: _buildTodoItem(context, item),
            );
          }),
          // 底部安全区
          SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
        ],
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, TodoItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showStatusDialog(context, item),
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, 12)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: item.color.withValues(alpha: 0.15),
              ),
              child: Icon(
                item.icon,
                size: Responsive.iconSize(context, 18),
                color: item.color,
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.fontSize(context, 14),
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // 箭头
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, TodoItem item) {
    if (item.type != TodoType.unprocessed) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedStatus;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            title: Row(
              children: [
                Icon(Icons.edit_note, color: AppColors.primary),
                SizedBox(width: Responsive.spacing(context, 8)),
                Text(
                  '更新行李状态',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '行李号: ${item.tagNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                Text(
                  '选择状态:',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                // 状态选项
                _buildStatusOption(
                  context,
                  '已丢失',
                  Icons.search_off,
                  AppColors.error,
                  selectedStatus == '已丢失',
                  () => setDialogState(() => selectedStatus = '已丢失'),
                  isDark,
                ),
                SizedBox(height: Responsive.spacing(context, 8)),
                _buildStatusOption(
                  context,
                  '停止托运',
                  Icons.block,
                  AppColors.warning,
                  selectedStatus == '停止托运',
                  () => setDialogState(() => selectedStatus = '停止托运'),
                  isDark,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              FilledButton(
                onPressed: (selectedStatus == null || isSubmitting)
                    ? null
                    : () async {
                        setDialogState(() => isSubmitting = true);
                        await _submitStatus(context, item, selectedStatus!);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('确认'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: Responsive.spacing(context, 12)),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? color
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submitStatus(BuildContext context, TodoItem item, String status) async {
    try {
      final employeeId = await StorageService.getEmployeeId();
      if (employeeId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('无法获取员工工号'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // 调用 location 接口更新状态
      final result = await BaggageApiService.updateBaggageLocation(
        baggageNumber: item.tagNumber,
        location: '', // 位置可为空
        status: status,
        employeeId: employeeId,
      );

      if (result['result'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('行李 ${item.tagNumber} 已标记为: $status'),
              backgroundColor: AppColors.success,
            ),
          );
        }

        // 从列表中移除已处理的行李
        if (mounted) {
          setState(() {
            _items.removeWhere((i) => i.tagNumber == item.tagNumber);
          });
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '更新失败'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
