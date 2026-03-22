import 'package:flutter/material.dart';

/// 应用颜色系统
/// 所有颜色定义必须放在此处，禁止在业务代码中直接写死颜色值
class AppColors {
  AppColors._();

  // ==================== 主色系 ====================
  /// 深紫色主色
  static const Color primary = Color(0xFF673AB7);

  /// 主色浅色
  static const Color primaryLight = Color(0xFF9575CD);

  /// 主色深色
  static const Color primaryDark = Color(0xFF512DA8);

  // ==================== 功能色系 ====================
  /// 成功色
  static const Color success = Color(0xFF4CAF50);

  /// 警告色
  static const Color warning = Color(0xFFFF9800);

  /// 错误色
  static const Color error = Color(0xFFF44336);

  /// 信息色
  static const Color info = Color(0xFF2196F3);

  // ==================== 行李状态颜色 ====================
  /// 已办理托运
  static const Color checkIn = Color(0xFF2196F3);

  /// 运输中
  static const Color inTransit = Color(0xFFFF9800);

  /// 已到达
  static const Color arrived = Color(0xFF4CAF50);

  /// 已交付
  static const Color delivered = Color(0xFF9C27B0);

  /// 已损坏
  static const Color damaged = Color(0xFFF44336);

  /// 已丢失
  static const Color lost = Color(0xFF9E9E9E);

  // ==================== 行李状态浅色背景 ====================
  /// 已办理托运背景
  static const Color checkInBg = Color(0xFFE3F2FD);

  /// 运输中背景
  static const Color inTransitBg = Color(0xFFFFF3E0);

  /// 已到达背景
  static const Color arrivedBg = Color(0xFFE8F5E9);

  /// 已交付背景
  static const Color deliveredBg = Color(0xFFF3E5F5);

  /// 已损坏背景
  static const Color damagedBg = Color(0xFFFFEBEE);

  /// 已丢失背景
  static const Color lostBg = Color(0xFFF5F5F5);

  // ==================== 图表颜色 ====================
  /// 已处理行李图表颜色
  static const Color chartProcessed = Color(0xFF3498db);

  /// 异常行李图表颜色
  static const Color chartAbnormal = Color(0xFFf39c12);

  // ==================== 中性色系 ====================
  /// 浅色背景
  static const Color backgroundLight = Color(0xFFF5F5F5);

  /// 深色背景
  static const Color backgroundDark = Color(0xFF121212);

  /// 卡片浅色
  static const Color cardLight = Colors.white;

  /// 卡片深色
  static const Color cardDark = Color(0xFF1E1E1E);

  /// 次要文字
  static const Color textSecondary = Color(0xFF757575);

  /// 分割线
  static const Color divider = Color(0xFFE0E0E0);

  /// 深色分割线
  static const Color dividerDark = Color(0xFF424242);
}
