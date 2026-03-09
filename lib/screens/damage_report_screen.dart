import 'package:flutter/material.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';

/// 破损登记页面
/// 用于记录行李破损情况，上传照片证据
class DamageReportScreen extends StatefulWidget {
  final Luggage luggage;

  const DamageReportScreen({Key? key, required this.luggage}) : super(key: key);

  @override
  State<DamageReportScreen> createState() => _DamageReportScreenState();
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _images = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDamageReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写破损描述')),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请上传破损照片')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await LuggageService.updateLuggage(widget.luggage.id, {
        'status': 'damaged',
        'notes': '${widget.luggage.notes} [破损] ${_descriptionController.text.trim()}',
        'damageDescription': _descriptionController.text.trim(),
        'damagePhotos': _images,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('破损登记成功')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登记失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _pickImage() {
    // 模拟图片选择
    // 实际项目中应使用 image_picker 插件
    setState(() {
      _images.add('https://picsum.photos/200/200?random=${_images.length}');
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('破损登记'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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

                  // 破损描述
                  const SizedBox(height: 16),
                  Text('破损描述', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '请详细描述行李破损情况...',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),

                  // 照片上传
                  const SizedBox(height: 16),
                  Text('上传照片', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      children: [
                        // 照片网格
                        _images.isNotEmpty
                            ? GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _images.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          _images[index],
                                          width: double.infinity,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : const Text('请上传行李破损照片作为证据'),

                        // 添加照片按钮
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('添加照片'),
                        ),
                      ],
                    ),
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
                      '提示：破损登记后将无法撤销，照片将作为定责依据，请确保信息准确。',
                      style: TextStyle(color: Colors.amber[800]),
                    ),
                  ),

                  // 提交按钮
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submitDamageReport,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('提交破损登记'),
                  ),
                ],
              ),
            ),
    );
  }
}
