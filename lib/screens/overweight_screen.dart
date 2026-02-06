import 'package:flutter/material.dart';
import '../models/luggage.dart';

/// 超重费用/称重页面
/// 用于确认补缴费用或重新称重录入
class OverweightScreen extends StatefulWidget {
  final Luggage luggage;

  const OverweightScreen({super.key, required this.luggage});

  @override
  State<OverweightScreen> createState() => _OverweightScreenState();
}

class _OverweightScreenState extends State<OverweightScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.luggage.weight.toString();
    // 计算超重费用（假设超重1kg收费100元）
    final overweight = widget.luggage.weight - 20.0; // 假设免费额度为20kg
    if (overweight > 0) {
      _feeController.text = (overweight * 100).toStringAsFixed(2);
    } else {
      _feeController.text = '0.00';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟提交数据
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('处理成功')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理失败: $e')),
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

  void _updateFee() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final overweight = weight - 20.0; // 假设免费额度为20kg
    if (overweight > 0) {
      _feeController.text = (overweight * 100).toStringAsFixed(2);
    } else {
      _feeController.text = '0.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('超重费用/称重'),
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
                    Text('乘客: ${widget.luggage.passengerName}'),
                  ],
                ),
              ),
            ),

            // 称重信息
            const SizedBox(height: 16),
            Text('称重信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: '行李重量 (kg)',
                hintText: '请输入实际重量',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateFee(),
            ),

            // 费用信息
            const SizedBox(height: 16),
            Text('费用信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _feeController,
              decoration: const InputDecoration(
                labelText: '超重费用 (元)',
                hintText: '自动计算',
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),

            // 提示信息
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                border: Border.all(color: Colors.yellow[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '提示：超重费用将自动计算，确认后将通知旅客补缴。',
                style: TextStyle(color: Colors.amber[800]),
              ),
            ),

            // 提交按钮
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('确认处理'),
            ),
          ],
        ),
      ),
    );
  }
}
