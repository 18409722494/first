import 'package:flutter/material.dart';
import '../models/luggage.dart';
import '../data/mock_data.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 旅客联系/认领页
/// 显示旅客信息及通话记录
class ContactPassengerScreen extends StatefulWidget {
  final Luggage luggage;

  const ContactPassengerScreen({Key? key, required this.luggage}) : super(key: key);

  @override
  State<ContactPassengerScreen> createState() => _ContactPassengerScreenState();
}

class _ContactPassengerScreenState extends State<ContactPassengerScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('旅客联系/认领'),
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
                    Text('行李信息', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Responsive.fontSize(context, 14))),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                    Text('标签号: ${widget.luggage.tagNumber}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    Text('航班号: ${widget.luggage.flightNumber}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    Text('目的地: ${widget.luggage.destination}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                  ],
                ),
              ),
            ),

            // 旅客信息
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text('旅客信息', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Responsive.fontSize(context, 14))),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('姓名: ${widget.luggage.passengerName}', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                    Text('手机号: ******1234', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                    Text('邮箱: ******@example.com', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                  ],
                ),
              ),
            ),

            // 通话记录
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text('通话记录', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Responsive.fontSize(context, 14))),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  for (final record in MockData.callRecords)
                    _buildCallRecord(record['time']!, record['status']!, record['description']!),
                  ],
                ),
              ),
            ),

            // 联系按钮
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('正在拨打...')),
                      );
                    },
                    icon: Icon(Icons.phone, size: Responsive.iconSize(context, 18)),
                    label: Text('拨打电话', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('发送短信')),
                      );
                    },
                    icon: Icon(Icons.sms, size: Responsive.iconSize(context, 18)),
                    label: Text('发送短信', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  ),
                ),
              ],
            ),

            // 认领确认
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Text('认领确认', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Responsive.fontSize(context, 14))),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('请确认旅客身份后，点击下方按钮完成认领流程。', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
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
                          : Text('确认认领', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
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

  /// 构建通话记录项
  Widget _buildCallRecord(String time, String status, String description) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 6)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(fontSize: Responsive.fontSize(context, 11), color: Colors.grey)),
              Text(status, style: TextStyle(fontSize: Responsive.fontSize(context, 11), color: Colors.red)),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 2)),
          Text(description, style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
        ],
      ),
    );
  }

  Future<void> _confirmClaim() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟提交数据
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('认领成功')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('认领失败: $e')),
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
}
