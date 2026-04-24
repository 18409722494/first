import 'package:flutter/material.dart';

/// 颜色系统 - 基于 UI 设计文档 (深色主题风格)
/// 设计来源: react/src/styles/Frame21.css
class AppColors {
  AppColors._();

  // ==================== 主色系 ====================
  // 主色/按钮背景 - 蓝色 (#2563EB)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // ==================== 功能色 ====================
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ==================== 行李状态色 ====================
  static const Color checkIn = Color(0xFF3B82F6);
  static const Color inTransit = Color(0xFFF59E0B);
  static const Color arrived = Color(0xFF22C55E);
  static const Color delivered = Color(0xFF06B6D4);
  static const Color damaged = Color(0xFFEF4444);
  static const Color lost = Color(0xFF94A3B8);

  // 行李状态背景色 (深色主题)
  static const Color checkInBg = Color(0xFF1E3A5F);
  static const Color inTransitBg = Color(0xFF451A03);
  static const Color arrivedBg = Color(0xFF14532D);
  static const Color deliveredBg = Color(0xFF164E63);
  static const Color damagedBg = Color(0xFF450A0A);
  static const Color lostBg = Color(0xFF1E293B);

  // ==================== 深色主题 (与 UI 设计保持一致) ====================
  // 深色背景 (#0F172A)
  static const Color backgroundDark = Color(0xFF0F172A);
  // 卡片/表面色 (#1E293B)
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);

  // 深色边框 (#334155)
  static const Color borderDark = Color(0xFF334155);

  // 深色文字
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  // 灰色文字 (#94A3B8)
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  // 灰色文字提示 (#64748B)
  static const Color textHintDark = Color(0xFF64748B);

  // ==================== 浅色模式 (保留但深色主题优先) ====================
  // 浅色背景
  static const Color backgroundLight = Color(0xFFF8F9FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // 浅色边框
  static const Color borderLight = Color(0xFFE2E8F0);

  // 浅色文字
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textHintLight = Color(0xFF94A3B8);

  // ==================== 中性色（兼容） ====================
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF334155);

  // ==================== UI 设计特有颜色 ====================
  // Logo 区域渐变色
  static const Color logoGradientStart = Color(0xFF1E3A5F);
  static const Color logoGradientEnd = Color(0xFF0F172A);

  // 卡片悬浮/选中状态
  static const Color cardHoverDark = Color(0xFF283548);

  // 禁用状态
  static const Color disabledDark = Color(0xFF475569);
}
