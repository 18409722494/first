import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/luggage.dart';
import '../models/todo_item.dart';
import '../services/evidence_service.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'damage_report_screen.dart';
import 'overweight_screen.dart';
import 'contact_passenger_screen.dart';

/// 待办事项页面 - 基于 UI 设计风格
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoItem> _items = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  Future<void> _loadTodoItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final todos = await _fetchAllTodoItems();
      setState(() {
        _items = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<TodoItem>> _fetchAllTodoItems() async {
    final results = await Future.wait([
      _fetchDamageTodos(),
      _fetchOverweightTodos(),
      _fetchUnclaimedTodos(),
    ]);
    return [...results[0], ...results[1], ...results[2]];
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

  Future<List<TodoItem>> _fetchOverweightTodos() async {
    try {
      final list = await LuggageService.getOverweightLuggage();
      return list.map((luggage) => TodoItem.fromOverweightLuggage(
        tagNumber: luggage.tagNumber,
        luggageId: luggage.id,
        weight: luggage.weight,
        timestamp: luggage.lastUpdated,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<TodoItem>> _fetchUnclaimedTodos() async {
    try {
      final hours = AppConstants.unclaimedHoursThreshold;
      final list = await LuggageService.getUnclaimedLuggage();
      return list.map((luggage) => TodoItem.fromUnclaimedLuggage(
        tagNumber: luggage.tagNumber,
        luggageId: luggage.id,
        passengerName: luggage.passengerName,
        arrivedAt: luggage.lastUpdated,
        unclaimedHours: hours,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          '待办事项',
          style: TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
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
    if (_isLoading && _items.isEmpty) {
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
            const Text(
              '暂无待办事项',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '所有任务都已处理完成',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHintLight,
              ),
            ),
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
    return GestureDetector(
      onTap: () => _navigateTo(context, item),
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, 12)),
        decoration: BoxDecoration(
          color: Colors.white,
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
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // 箭头
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHintLight,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, TodoItem item) {
    switch (item.type) {
      case TodoType.damage:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DamageReportScreen(luggageId: item.luggageId ?? item.tagNumber),
          ),
        );
        break;
      case TodoType.overweight:
        _loadAndNavigateOverweight(context, item);
        break;
      case TodoType.unclaimed:
        _loadAndNavigateContact(context, item);
        break;
    }
  }

  Future<Luggage> _resolveLuggageForNavigation(TodoItem item) async {
    final tag = item.tagNumber.trim();
    if (tag.isNotEmpty) {
      final byTag = await LuggageService.searchByTagNumber(tag);
      if (byTag != null) return byTag;
    }
    final id = item.luggageId?.trim();
    if (id != null && id.isNotEmpty) {
      final result = await LuggageService.getLuggageForScan(id);
      if (result.success && result.luggage != null) {
        return result.luggage!;
      }
      throw Exception(result.errorMessage ?? '未找到行李: $id');
    }
    throw Exception('未找到行李: ${tag.isNotEmpty ? tag : item.luggageId ?? ''}');
  }

  Future<void> _loadAndNavigateOverweight(BuildContext context, TodoItem item) async {
    try {
      final luggage = await _resolveLuggageForNavigation(item);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OverweightScreen(luggage: luggage),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadAndNavigateContact(BuildContext context, TodoItem item) async {
    try {
      final luggage = await _resolveLuggageForNavigation(item);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ContactPassengerScreen(luggage: luggage),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
