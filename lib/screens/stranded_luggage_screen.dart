import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/luggage.dart';
import '../services/baggage_api_service.dart';
import '../services/luggage_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// 滞留件列表页面
/// 显示状态为"滞留"的行李（由 LuggageService.getStrandedLuggage 根据12小时阈值自动标记）
class StrandedLuggageScreen extends StatefulWidget {
  const StrandedLuggageScreen({super.key});

  @override
  State<StrandedLuggageScreen> createState() => _StrandedLuggageScreenState();
}

class _StrandedLuggageScreenState extends State<StrandedLuggageScreen> {
  List<Luggage> _strandedLuggage = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _loadingItems = {};

  @override
  void initState() {
    super.initState();
    _loadStrandedLuggage();
  }

  Future<void> _loadStrandedLuggage() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 使用统一服务：自动将超时行李标记为滞留，并返回所有滞留行李
      final stranded = await LuggageService.getStrandedLuggage(forceRefresh: true);

      // 按滞留天数降序排序（滞留越久的排前面）
      stranded.sort((a, b) {
        final daysA = DateTime.now().difference(a.lastUpdated).inDays;
        final daysB = DateTime.now().difference(b.lastUpdated).inDays;
        return daysB.compareTo(daysA);
      });

      if (mounted) {
        setState(() {
          _strandedLuggage = stranded;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.loadFailed(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  /// 联系旅客
  Future<void> _contactPassenger(Luggage luggage) async {
    final l10n = AppLocalizations.of(context)!;

    if (_loadingItems.contains(luggage.tagNumber)) return;

    setState(() {
      _loadingItems.add(luggage.tagNumber);
    });

    try {
      final contact = await BaggageApiService.getPassengerContact(luggage.tagNumber);

      if (!mounted) return;

      if (contact == null || contact.isEmpty) {
        _showErrorSnackBar(l10n.getPhoneFailedRetry);
        return;
      }

      _showContactOptions(contact, luggage.passengerName);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('${l10n.getPhoneFailed}: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingItems.remove(luggage.tagNumber);
        });
      }
    }
  }

  void _showContactOptions(String phone, String passengerName) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.contactPassenger}: $passengerName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContactButton(
                    icon: Icons.phone,
                    label: l10n.callPhone,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _makePhoneCall(phone);
                    },
                  ),
                  _buildContactButton(
                    icon: Icons.message,
                    label: l10n.sendSms,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _sendSms(phone);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar(l10n.cannotMakeCall);
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar(l10n.cannotSendSms);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.strandedLuggage),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStrandedLuggage,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadStrandedLuggage,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_strandedLuggage.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noStrandedLuggage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.allLuggageProcessed,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStrandedLuggage,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _strandedLuggage.length,
        itemBuilder: (context, index) {
          final luggage = _strandedLuggage[index];
          return _buildLuggageCard(luggage, index);
        },
      ),
    );
  }

  Widget _buildLuggageCard(Luggage luggage, int index) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final strandedAt = luggage.strandedAt ?? luggage.lastUpdated;
    final daysStranded = now.difference(strandedAt).inDays;
    final isLoading = _loadingItems.contains(luggage.tagNumber);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              luggage.tagNumber,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.strandedLuggage,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF97316),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.flight}: ${luggage.flightNumber}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.stranded.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.stranded,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.strandedDays(daysStranded),
                        style: TextStyle(
                          color: AppColors.stranded,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        luggage.passengerName.isNotEmpty
                            ? luggage.passengerName
                            : l10n.unknownUser,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        luggage.currentLocation.isNotEmpty
                            ? luggage.currentLocation
                            : l10n.unknownLocation,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _contactPassenger(luggage),
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.phone, size: 18),
                  label: Text(l10n.contactPassenger),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.scale, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${l10n.weight}: ${luggage.weight.toStringAsFixed(1)}kg',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
