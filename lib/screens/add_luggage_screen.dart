import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/luggage.dart';
import '../services/luggage_service.dart';
import '../providers/auth_provider.dart';

/// 添加行李页面
/// 用于手动录入行李信息
class AddLuggageScreen extends StatefulWidget {
  const AddLuggageScreen({super.key});

  @override
  State<AddLuggageScreen> createState() => _AddLuggageScreenState();
}

class _AddLuggageScreenState extends State<AddLuggageScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 表单字段
  final _tagNumberController = TextEditingController();
  final _flightNumberController = TextEditingController();
  final _passengerNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  
  // 图片上传
  List<String> _images = [];
  bool _isUploading = false;
  
  // 选择的状态
  LuggageStatus _selectedStatus = LuggageStatus.checkIn;
  
  // 加载状态
  bool _isLoading = false;
  
  @override
  void dispose() {
    _tagNumberController.dispose();
    _flightNumberController.dispose();
    _passengerNameController.dispose();
    _weightController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  /// 上传图片
  Future<void> _uploadImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传3张照片')),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      // 模拟图片上传，实际项目中应该调用图片上传API
      await Future.delayed(const Duration(seconds: 1));
      
      // 生成模拟图片URL
      final mockImageUrl = 'https://picsum.photos/seed/${Random().nextInt(1000)}/300/300';
      
      setState(() {
        _images.add(mockImageUrl);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('照片上传成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败：$e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// 提交表单
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // 检查是否上传了照片
    if (_images.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('您还没有上传行李照片，这是定责的重要依据。确定要继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('继续'),
            ),
          ],
        ),
      );
      
      if (confirm != true) {
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 获取当前登录用户
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      
      // 创建行李对象
      final luggage = Luggage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tagNumber: _tagNumberController.text.trim(),
        flightNumber: _flightNumberController.text.trim(),
        passengerName: _passengerNameController.text.trim(),
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
        status: _selectedStatus,
        checkInTime: DateTime.now(),
        lastUpdated: DateTime.now(),
        destination: _destinationController.text.trim(),
        notes: '${_notesController.text.trim()} ${_images.isNotEmpty ? '[已上传${_images.length}张照片]' : ''} ${currentUser != null ? '[操作员工：${currentUser.username}]' : ''}',
        // 模拟位置数据
        latitude: 39.9042 + (Random().nextDouble() - 0.5) * 0.1,
        longitude: 116.4074 + (Random().nextDouble() - 0.5) * 0.1,
      );
      
      // 调用服务添加行李
      await LuggageService.addLuggage(luggage);
      
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('行李信息添加成功！'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 返回上一页
      Navigator.of(context).pop();
    } catch (e) {
      // 显示错误消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('添加失败：${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加行李信息'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 行李标签号
              TextFormField(
                controller: _tagNumberController,
                decoration: const InputDecoration(
                  labelText: '行李标签号',
                  hintText: '请输入行李标签号',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入行李标签号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 航班号
              TextFormField(
                controller: _flightNumberController,
                decoration: const InputDecoration(
                  labelText: '航班号',
                  hintText: '请输入航班号',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入航班号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 乘客姓名
              TextFormField(
                controller: _passengerNameController,
                decoration: const InputDecoration(
                  labelText: '乘客姓名',
                  hintText: '请输入乘客姓名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入乘客姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 行李重量
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: '行李重量 (kg)',
                  hintText: '请输入行李重量',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入行李重量';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的重量';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 目的地
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: '目的地',
                  hintText: '请输入目的地',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入目的地';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 行李状态
              DropdownButtonFormField<LuggageStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: '行李状态',
                  border: OutlineInputBorder(),
                ),
                items: LuggageStatus.values.map((status) {
                  return DropdownMenuItem<LuggageStatus>(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 备注
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '请输入备注信息（可选）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // 操作员工
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final currentUser = authProvider.user;
                  return TextFormField(
                    initialValue: currentUser?.username ?? '未知用户',
                    decoration: const InputDecoration(
                      labelText: '操作员工',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // 位置信息
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '${39.9042 + (Random().nextDouble() - 0.5) * 0.1}',
                      decoration: const InputDecoration(
                        labelText: '纬度',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: '${116.4074 + (Random().nextDouble() - 0.5) * 0.1}',
                      decoration: const InputDecoration(
                        labelText: '经度',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('位置信息将自动获取', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 16),
              
              // 图片上传
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('上传照片', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('请上传行李外观照片，作为定责依据', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 12),
                  
                  // 图片预览和上传按钮
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        // 图片预览网格
                        if (_images.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      image: DecorationImage(
                                        image: NetworkImage(_images[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        
                        // 上传按钮
                        GestureDetector(
                          onTap: _isUploading ? null : _uploadImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.grey[300]!, width: 1, style: BorderStyle.solid),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  _isUploading ? '上传中...' : '点击上传照片',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text('最多上传3张', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          '添加行李',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 获取状态文本
  String _getStatusText(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.checkIn:
        return '已办理托运';
      case LuggageStatus.inTransit:
        return '运输中';
      case LuggageStatus.arrived:
        return '已到达';
      case LuggageStatus.delivered:
        return '已交付';
      case LuggageStatus.damaged:
        return '已损坏';
      case LuggageStatus.lost:
        return '已丢失';
      default:
        return '未知状态';
    }
  }
}
