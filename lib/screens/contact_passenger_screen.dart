import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/luggage.dart';
import '../services/baggage_api_service.dart';
import '../theme/app_spacing.dart';
import '../components/empty_state.dart';
import '../utils/responsive.dart';
import '../l10n/app_localizations.dart';

/// 旅客联系/认领页
/// 显示旅客信息及通话记录
/// [luggage] 为空时展示行李列表供选择
class ContactPassengerScreen extends StatefulWidget {
  final Luggage? luggage;

  const ContactPassengerScreen({super.key, this.luggage});

  @override
  State<ContactPassengerScreen> createState() => _ContactPassengerScreenState();
}

class _ContactPassengerScreenState extends State<ContactPassengerScreen> {
  bool _isLoading = false;
  Luggage? _selectedLuggage;
  List<Luggage> _luggageList = [];
  bool _loadingList = false;

  @override
  void initState() {
    super.initState();
    _selectedLuggage = widget.luggage;
    if (_selectedLuggage == null) {
      _loadLuggageList();
    }
  }

  Future<void> _loadLuggageList() async {
    setState(() => _loadingList = true);
    try {
      final result = await BaggageApiService.getAllBaggage(page: 1, pageSize: 100);
      if (mounted) {
        setState(() {
          _luggageList = result.items;
          _loadingList = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedLuggage == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.passengerContact)),
        body: _loadingList
            ? const Center(child: CircularProgressIndicator())
            : _luggageList.isEmpty
                ? Center(child: Text(l10n.noLuggage))
                : ListView.builder(
                    padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                    itemCount: _luggageList.length,
                    itemBuilder: (ctx, i) {
                      final item = _luggageList[i];
                      return Card(
                        margin: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.xs)),
                        child: ListTile(
                          leading: const Icon(Icons.luggage_outlined),
                          title: Text(item.tagNumber),
                          subtitle: Text(item.passengerName),
                          onTap: () => setState(() => _selectedLuggage = item),
                        ),
                      );
                    },
                  ),
      );
    }

    final bag = _selectedLuggage!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.passengerContact),
        leading: widget.luggage == null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedLuggage = null),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行李基本信息
            Card(
              margin: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.sm)),
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.luggageInfo, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Responsive.fontSize(context, 14))),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                    Text('${l10n.luggageTagNoLabel}: ${bag.tagNumber}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    Text('${l10n.flightNo}: ${bag.flightNumber}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    Text('${l10n.destination}: ${bag.currentLocation}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                  ],
                ),
              ),
            ),

            // 旅客信息
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text(l10n.passengerInfo, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Responsive.fontSize(context, 14))),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l10n.name}: ${bag.passengerName}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                    Text('${l10n.phoneNumber}: ${bag.contact ?? "—"}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                    Text('${l10n.email}: ******@example.com', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                  ],
                ),
              ),
            ),

            // 通话记录
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text(l10n.callLog, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Responsive.fontSize(context, 14))),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                child: EmptyState(
                  icon: Icons.call_end_outlined,
                  title: '暂无通话记录',
                  iconSize: Responsive.iconSize(context, 40),
                ),
              ),
            ),

            // 联系按钮
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _makePhoneCall(),
                    icon: Icon(Icons.phone, size: Responsive.iconSize(context, 18)),
                    label: Text(l10n.makeCall, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _sendSms(),
                    icon: Icon(Icons.sms, size: Responsive.iconSize(context, 18)),
                    label: Text(l10n.sendMessage, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  ),
                ),
              ],
            ),

            // 认领确认
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text(l10n.claimConfirmation, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Responsive.fontSize(context, 14))),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.confirmPassengerIdentity, style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                    FilledButton(
                      onPressed: _isLoading ? null : _confirmClaim,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(double.infinity, Responsive.buttonHeight(context, 44)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(l10n.confirmClaim, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClaim() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟提交数据
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.claimSuccess)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.claimFailed(e.toString()))),
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

  /// 拨打电话
  Future<void> _makePhoneCall() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneNumber = _selectedLuggage?.contact;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无联系电话')),
        );
      }
      return;
    }
    final uri = Uri.parse('tel:$phoneNumber');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cannotMakeCall)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.callFailed(e.toString()))),
        );
      }
    }
  }

  /// 发送短信
  Future<void> _sendSms() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneNumber = _selectedLuggage?.contact;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无联系电话')),
        );
      }
      return;
    }
    final uri = Uri.parse('sms:$phoneNumber');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cannotSendMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.messageSendFailed(e.toString()))),
        );
      }
    }
  }
}
