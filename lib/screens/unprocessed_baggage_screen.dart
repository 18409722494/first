import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/baggage_api_service.dart';
import '../services/storage_service.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../utils/responsive.dart';

/// 未处理行李页面
/// 快捷操作入口，逻辑与 TodoScreen 选中航班后的未处理行李一致
/// 仅展示未处理行李，不包含破损行李
class UnprocessedBaggageScreen extends StatefulWidget {
  const UnprocessedBaggageScreen({super.key});

  @override
  State<UnprocessedBaggageScreen> createState() => _UnprocessedBaggageScreenState();
}

class _UnprocessedBaggageScreenState extends State<UnprocessedBaggageScreen> {
  List<String> _flightNumbers = [];
  String? _selectedFlight;
  bool _isLoadingFlights = false;
  bool _hasLoadedFlights = false;
  String? _flightError;

  List<_UnprocessedItem> _items = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadFlightNumbers() async {
    if (_isLoadingFlights || _hasLoadedFlights) return;

    setState(() {
      _isLoadingFlights = true;
      _flightError = null;
    });

    try {
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
          _hasLoadedFlights = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _flightError = e.toString();
          _isLoadingFlights = false;
          _hasLoadedFlights = true;
        });
      }
    }
  }

  Future<void> _onFlightSelected(String? flight) async {
    if (flight == null) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _selectedFlight = flight;
      _items = [];
      _isLoading = true;
      _error = null;
    });

    try {
      final employeeId = await StorageService.getEmployeeId();
      if (employeeId != null) {
        final unprocessedList = await BaggageApiService.getUnprocessedBaggage(
          flightNumber: flight,
          employeeId: employeeId,
        );

        final items = unprocessedList.map((luggage) {
          return _UnprocessedItem(
            tagNumber: luggage.tagNumber.isNotEmpty ? luggage.tagNumber : luggage.id,
            flightNumber: flight,
            timestamp: DateTime.now(),
          );
        }).toList();

        if (mounted) {
          setState(() {
            _items = items;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = l10n.loadingFailed(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitStatus(String tagNumber, String status) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final employeeId = await StorageService.getEmployeeId();
      if (employeeId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.unableGetEmployeeId),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final result = await BaggageApiService.updateBaggageLocation(
        baggageNumber: tagNumber,
        location: '',
        status: status,
        employeeId: employeeId,
      );

      if (result['result'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.luggageMarkedAs(tagNumber, status)),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (mounted) {
          setState(() {
            _items.removeWhere((i) => i.tagNumber == tagNumber);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? l10n.updateFailed('')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        title: Text(
          l10n.unprocessedBaggage,
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
            onPressed: _isLoading ? null : () => _onFlightSelected(_selectedFlight),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildFlightSelector(context),
        Expanded(child: _buildList(context)),
      ],
    );
  }

  Widget _buildFlightSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
              Icon(Icons.flight, size: Responsive.iconSize(context, 18), color: AppColors.primary),
              SizedBox(width: Responsive.spacing(context, 8)),
              Text(
                l10n.selectFlight,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (_isLoadingFlights)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
          _buildFlightDropdown(context),
          if (_selectedFlight != null) ...[
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text(
              l10n.unprocessedLuggageCount(_items.length),
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingFlights) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, AppSpacing.md),
          vertical: Responsive.padding(context, AppSpacing.sm),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_empty, size: 18, color: AppColors.textHintDark),
            SizedBox(width: Responsive.spacing(context, 8)),
            Text(l10n.loading, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ],
        ),
      );
    }

    if (_flightError != null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, AppSpacing.md),
          vertical: Responsive.padding(context, AppSpacing.sm),
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: AppColors.error),
            SizedBox(width: Responsive.spacing(context, 8)),
            Expanded(
              child: Text(_flightError!, style: TextStyle(color: AppColors.error, fontSize: 13)),
            ),
            GestureDetector(
              onTap: _loadFlightNumbers,
              child: Text(l10n.reload, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
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
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: AppColors.textHintDark),
            SizedBox(width: Responsive.spacing(context, 8)),
            Text(l10n.noFlightHistory, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, AppSpacing.md)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.primary),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(
            children: [
              Icon(Icons.airplanemode_active, size: 18, color: AppColors.primary),
              SizedBox(width: Responsive.spacing(context, 8)),
              Text(l10n.pleaseSelectFlight, style: TextStyle(color: isDark ? AppColors.textHintDark : AppColors.textHintLight)),
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
                  Text(flight, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                ],
              ),
            );
          }).toList(),
          onChanged: _onFlightSelected,
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_hasLoadedFlights && !_isLoadingFlights) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFlightNumbers());
    }

    if (_isLoading && _items.isEmpty && _selectedFlight != null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.textSecondaryLight)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onFlightSelected(_selectedFlight),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
            Icon(
              _selectedFlight != null ? Icons.check_circle_outline : Icons.flight_outlined,
              size: 64,
              color: _selectedFlight != null ? AppColors.success.withValues(alpha: 0.5) : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFlight != null ? l10n.noUnprocessedBaggage : l10n.pleaseSelectFlightFirst,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondaryLight),
            ),
            if (_selectedFlight == null) ...[
              const SizedBox(height: 8),
              Text(l10n.selectFlightFromDropdown, style: TextStyle(fontSize: 13, color: AppColors.textHintLight)),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _onFlightSelected(_selectedFlight!),
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        children: [
          Row(
            children: [
              Text(
                l10n.unprocessedBaggage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _items.length - 1 ? Responsive.spacing(context, AppSpacing.sm) : 0,
              ),
              child: _buildItemCard(context, item),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, _UnprocessedItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => _showStatusDialog(context, item),
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, 12)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.warning.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.luggage_outlined,
                size: Responsive.iconSize(context, 18),
                color: AppColors.warning,
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.unprocessedLuggage,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.fontSize(context, 14),
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    '${item.tagNumber}',
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
            Icon(Icons.chevron_right, color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, _UnprocessedItem item) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedStatus;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
            title: Row(
              children: [
                Icon(Icons.edit_note, color: AppColors.primary),
                SizedBox(width: Responsive.spacing(context, 8)),
                Text(
                  l10n.updateLuggageStatus,
                  style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
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
                  l10n.selectStatus,
                  style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                _buildStatusOption(
                  context,
                  l10n.lost,
                  Icons.search_off,
                  AppColors.error,
                  selectedStatus == l10n.lost,
                  () => setDialogState(() => selectedStatus = l10n.lost),
                  isDark,
                ),
                SizedBox(height: Responsive.spacing(context, 8)),
                _buildStatusOption(
                  context,
                  l10n.stopTransit,
                  Icons.block,
                  AppColors.warning,
                  selectedStatus == l10n.stopTransit,
                  () => setDialogState(() => selectedStatus = l10n.stopTransit),
                  isDark,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: Text(l10n.cancel, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ),
              FilledButton(
                onPressed: (selectedStatus == null || isSubmitting)
                    ? null
                    : () async {
                        setDialogState(() => isSubmitting = true);
                        await _submitStatus(item.tagNumber, selectedStatus!);
                        if (context.mounted) Navigator.pop(context);
                      },
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.confirm),
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
                color: isSelected ? color : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

/// 未处理行李项
class _UnprocessedItem {
  final String tagNumber;
  final String flightNumber;
  final DateTime timestamp;

  _UnprocessedItem({
    required this.tagNumber,
    required this.flightNumber,
    required this.timestamp,
  });
}
