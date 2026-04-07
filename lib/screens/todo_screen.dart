import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/luggage.dart';
import '../models/todo_item.dart';
import '../services/evidence_service.dart';
import '../services/luggage_service.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';
import 'damage_report_screen.dart';
import 'overweight_screen.dart';
import 'contact_passenger_screen.dart';

/// 待办事项页面
/// 从数据库实时拉取：破损记录、超重行李、无人认领行李
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

  /// 并发拉取三类待办数据
  Future<List<TodoItem>> _fetchAllTodoItems() async {
    final results = await Future.wait([
      _fetchDamageTodos(),
      _fetchOverweightTodos(),
      _fetchUnclaimedTodos(),
    ]);
    return [...results[0], ...results[1], ...results[2]];
  }

  /// 破损行李（来源: abnormal-baggage 表）
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

  /// 超重行李（来源: luggage 表，weight > freeBaggageWeightKg）
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

  /// 无人认领行李（来源: luggage 表，arrived 超过 24h 未交付）
  Future<List<TodoItem>> _fetchUnclaimedTodos() async {
    try {
      final list = await LuggageService.getUnclaimedLuggage(hours: 24);
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todoTitle),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadTodoItems,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadTodoItems,
              child: Text(l10n.reload),
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
            Icon(Icons.check_circle_outline, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              l10n.noTodoItems,
              style: TextStyle(fontSize: Responsive.fontSize(context, 15), color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.abnormalLuggage,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 15),
                  fontWeight: FontWeight.bold,
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
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTodoItems,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom +
                      kBottomNavigationBarHeight +
                      24,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < _items.length - 1
                          ? Responsive.spacing(context, 8)
                          : 0,
                    ),
                    child: _buildTodoItem(context, item),
                  );
                },
              ),
            ),
          ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withValues(alpha: 0.3)),
          color: item.color.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: item.color.withValues(alpha: 0.18),
              ),
              child: Icon(item.icon, size: Responsive.iconSize(context, 18), color: item.color),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 14),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 12),
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
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

  /// 待办列表来自 /baggage/all，[id] 多为库内主键；旧版 [GET /luggage/:id] 可能不认该 id。
  /// 优先用行李号 [tagNumber] 走 baggage 查询，与扫码逻辑一致。
  Future<Luggage> _resolveLuggageForNavigation(TodoItem item) async {
    final tag = item.tagNumber.trim();
    if (tag.isNotEmpty) {
      final byTag = await LuggageService.searchByTagNumber(tag);
      if (byTag != null) return byTag;
    }
    final id = item.luggageId?.trim();
    if (id != null && id.isNotEmpty) {
      return LuggageService.getLuggageForScan(id);
    }
      throw Exception('未找到行李: ${tag.isNotEmpty ? tag : id ?? ''}');
  }

  Future<void> _loadAndNavigateOverweight(BuildContext context, TodoItem item) async {
    final l10n = AppLocalizations.of(context)!;

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
          SnackBar(content: Text(l10n.loadLuggageFailed(e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _loadAndNavigateContact(BuildContext context, TodoItem item) async {
    final l10n = AppLocalizations.of(context)!;

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
          SnackBar(content: Text(l10n.loadLuggageFailed(e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }
}