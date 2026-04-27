import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/baggage_api_service.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 未处理行李页面
/// 用于查看并处理未被当前账号扫码处理的行李
class UnprocessedBaggageScreen extends StatefulWidget {
  const UnprocessedBaggageScreen({super.key});

  @override
  State<UnprocessedBaggageScreen> createState() => _UnprocessedBaggageScreenState();
}

class _UnprocessedBaggageScreenState extends State<UnprocessedBaggageScreen> {
  bool _isLoadingFlights = false;
  bool _isLoadingBaggage = false;
  bool _isSubmitting = false;
  String? _error;

  List<String> _flightNumbers = [];
  String? _selectedFlight;
  List<String> _unprocessedBaggage = [];
  final Set<String> _selectedBaggage = {};

  @override
  void initState() {
    super.initState();
    _loadFlightNumbers();
  }

  Future<void> _loadFlightNumbers() async {
    final authProvider = context.read<AuthProvider>();
    final employeeId = authProvider.user?.employeeId;
    if (employeeId == null || employeeId.isEmpty) {
      setState(() {
        _error = '无法获取员工信息';
      });
      return;
    }

    setState(() {
      _isLoadingFlights = true;
      _error = null;
    });

    try {
      // 从行李列表中提取唯一的航班号
      final result = await LuggageService.getLuggageList(page: 1, pageSize: 9999);
      final uniqueFlights = <String>{};
      for (final luggage in result.items) {
        if (luggage.flightNumber.isNotEmpty) {
          uniqueFlights.add(luggage.flightNumber);
        }
      }
      setState(() {
        _flightNumbers = uniqueFlights.toList()..sort();
        _isLoadingFlights = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载航班列表失败: $e';
        _isLoadingFlights = false;
      });
    }
  }

  Future<void> _loadUnprocessedBaggage() async {
    if (_selectedFlight == null) return;

    final authProvider = context.read<AuthProvider>();
    final employeeId = authProvider.user?.employeeId;
    if (employeeId == null || employeeId.isEmpty) return;

    setState(() {
      _isLoadingBaggage = true;
      _error = null;
      _unprocessedBaggage = [];
      _selectedBaggage.clear();
    });

    try {
      // 调用 /baggage/unprocessed 接口获取该航班中未处理的行李
      final unprocessedList = await BaggageApiService.getUnprocessedBaggage(
        flightNumber: _selectedFlight!,
        employeeId: employeeId,
      );
      final baggageNumbers = unprocessedList
          .map((luggage) => luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id)
          .where((number) => number.isNotEmpty)
          .toList();
      setState(() {
        _unprocessedBaggage = baggageNumbers;
        _isLoadingBaggage = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载未处理行李失败: $e';
        _isLoadingBaggage = false;
      });
    }
  }

  Future<void> _markSelectedAsLost() async {
    if (_selectedBaggage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要标记为丢失的行李')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认标记'),
        content: Text(
          '确定要将 ${_selectedBaggage.length} 件行李标记为丢失吗？\n\n行李号：\n${_selectedBaggage.join('\n')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('确认标记'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final authProvider = context.read<AuthProvider>();
    final employeeId = authProvider.user?.employeeId ?? '';
    const location = '39.110711,117.346881'; // 默认位置

    setState(() => _isSubmitting = true);

    int successCount = 0;
    int failCount = 0;
    List<String> failedItems = [];

    for (final baggageNumber in _selectedBaggage) {
      try {
        await BaggageApiService.markBaggageAsLost(
          baggageNumber: baggageNumber,
          location: location,
          employeeId: employeeId,
        );
        successCount++;
      } catch (e) {
        failCount++;
        failedItems.add(baggageNumber);
      }
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (failCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功标记 $successCount 件行李为丢失'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUnprocessedBaggage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '部分失败：成功 $successCount 件，失败 $failCount 件\n失败行李：${failedItems.join(", ")}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        // 移除成功的，从列表刷新
        setState(() {
          _unprocessedBaggage = failedItems;
          _selectedBaggage.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('未处理行李'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 航班选择区
          _buildFlightSelector(),
          const Divider(height: 1),
          // 行李列表区
          Expanded(
            child: _buildBaggageList(),
          ),
          // 底部操作栏
          if (_unprocessedBaggage.isNotEmpty) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildFlightSelector() {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择航班',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
          if (_isLoadingFlights)
            const Center(child: CircularProgressIndicator())
          else if (_flightNumbers.isEmpty)
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[500], size: 20),
                  SizedBox(width: Responsive.spacing(context, 8)),
                  Expanded(
                    child: Text(
                      '暂无可用航班',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 12)),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('请选择航班'),
                  value: _selectedFlight,
                  items: _flightNumbers.map((flight) {
                    return DropdownMenuItem<String>(
                      value: flight,
                      child: Text(flight),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFlight = value);
                      _loadUnprocessedBaggage();
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBaggageList() {
    if (_selectedFlight == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flight_outlined, size: 64, color: Colors.grey[300]),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            Text(
              '请先选择航班',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_isLoadingBaggage) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.7)),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            Text(_error!, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            ElevatedButton(
              onPressed: _loadUnprocessedBaggage,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_unprocessedBaggage.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            Text(
              '该航班暂无未处理行李',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      itemCount: _unprocessedBaggage.length,
      itemBuilder: (context, index) {
        final baggageNumber = _unprocessedBaggage[index];
        final isSelected = _selectedBaggage.contains(baggageNumber);

        return Padding(
          padding: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.sm)),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedBaggage.remove(baggageNumber);
                } else {
                  _selectedBaggage.add(baggageNumber);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: Responsive.spacing(context, 12)),
                  Icon(
                    Icons.luggage_outlined,
                    color: AppColors.warning,
                    size: Responsive.iconSize(context, 24),
                  ),
                  SizedBox(width: Responsive.spacing(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          baggageNumber,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 15),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 2)),
                        Text(
                          _selectedFlight ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '待处理',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选择 ${_selectedBaggage.length} 件',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '共 ${_unprocessedBaggage.length} 件未处理行李',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _markSelectedAsLost,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, AppSpacing.lg),
                  vertical: Responsive.spacing(context, AppSpacing.md),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.warning_amber),
              label: Text(_isSubmitting ? '处理中...' : '标记丢失'),
            ),
          ],
        ),
      ),
    );
  }
}
