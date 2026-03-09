import 'package:flutter/material.dart';
import '../models/luggage.dart';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行李基本信息
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('行李信息', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('标签号: ${widget.luggage.tagNumber}'),
                    Text('航班号: ${widget.luggage.flightNumber}'),
                    Text('目的地: ${widget.luggage.destination}'),
                  ],
                ),
              ),
            ),

            // 旅客信息
            const SizedBox(height: 16),
            Text('旅客信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('姓名: ${widget.luggage.passengerName}'),
                    const SizedBox(height: 8),
                    Text('身份证号: ******************1234'), // 模拟数据
                    const SizedBox(height: 8),
                    Text('手机号: ******1234'), // 模拟数据
                    const SizedBox(height: 8),
                    Text('邮箱: ******@example.com'), // 模拟数据
                  ],
                ),
              ),
            ),

            // 通话记录
            const SizedBox(height: 16),
            Text('通话记录', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCallRecord('2026-02-01 07:00', '未接通', '拨打旅客电话，无人接听'),
                    _buildCallRecord('2026-02-01 06:30', '未接通', '拨打旅客电话，无人接听'),
                    _buildCallRecord('2026-02-01 06:00', '未接通', '拨打旅客电话，无人接听'),
                  ],
                ),
              ),
            ),

            // 联系按钮
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('正在拨打...')),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('拨打电话'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('发送短信')),
                      );
                    },
                    icon: const Icon(Icons.sms),
                    label: const Text('发送短信'),
                  ),
                ),
              ],
            ),

            // 认领确认
            const SizedBox(height: 32),
            Text('认领确认', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('请确认旅客身份后，点击下方按钮完成认领流程。'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isLoading ? null : _confirmClaim,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('确认认领'),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(status, style: const TextStyle(fontSize: 12, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 14)),
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
