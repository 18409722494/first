import 'package:flutter/material.dart';

/// 颜色系统
class AppColors {
  AppColors._();

  // 主色系（淡蓝）
  static const Color primary = Color(0xFF42A5F5);
  static const Color primaryLight = Color(0xFF90CAF9);
  static const Color primaryDark = Color(0xFF1976D2);

  // 功能色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // 行李状态色
  static const Color checkIn = Color(0xFF2196F3);
  static const Color inTransit = Color(0xFFFF9800);
  static const Color arrived = Color(0xFF4CAF50);
  static const Color delivered = Color(0xFF0288D1);
  static const Color damaged = Color(0xFFF44336);
  static const Color lost = Color(0xFF9E9E9E);

  // 行李状态背景色
  static const Color checkInBg = Color(0xFFE3F2FD);
  static const Color inTransitBg = Color(0xFFFFF3E0);
  static const Color arrivedBg = Color(0xFFE8F5E9);
  static const Color deliveredBg = Color(0xFFE1F5FE);
  static const Color damagedBg = Color(0xFFFFEBEE);
  static const Color lostBg = Color(0xFFF5F5F5);

  // 图表色
  static const Color chartProcessed = Color(0xFF3498db);
  static const Color chartAbnormal = Color(0xFFf39c12);

  // 中性色
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
}
