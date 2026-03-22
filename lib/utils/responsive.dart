import 'package:flutter/material.dart';

/// 响应式工具类
/// 根据屏幕尺寸动态计算合适的值，支持手机、平板等多种设备
class Responsive {
  Responsive._();

  /// 便捷方法：用法 Responsive.of(context)
  static Responsive of(BuildContext context) => Responsive._();

  /// 是否为小屏幕（宽度 < 360）
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  /// 是否为平板（宽度 >= 600）
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  /// 获取屏幕宽度
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// 获取屏幕高度
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// 获取安全区域内宽度
  static double availableWidth(BuildContext context) =>
      MediaQuery.of(context).size.width -
      MediaQuery.of(context).padding.left -
      MediaQuery.of(context).padding.right;

  /// 获取安全区域内高度
  static double availableHeight(BuildContext context) =>
      MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      MediaQuery.of(context).padding.bottom;

  /// 根据屏幕宽度比例计算值（0.0 - 1.0）
  static double fractionWidth(BuildContext context, double fraction) =>
      availableWidth(context) * fraction;

  /// 根据屏幕高度比例计算值（0.0 - 1.0）
  static double fractionHeight(BuildContext context, double fraction) =>
      availableHeight(context) * fraction;

  /// 动态字号
  /// [base] 基准字号，[scale] 缩放系数
  static double fontSize(BuildContext context, double base, {double scale = 1.0}) {
    final width = screenWidth(context);
    final scaled = base * scale;
    // 小屏幕适当缩小，中等屏幕保持基准，大屏幕适度放大
    if (width < 360) return (scaled * 0.85).clamp(10.0, scaled);
    if (width > 600) return (scaled * 1.1).clamp(scaled, scaled * 1.3);
    return scaled;
  }

  /// 动态间距
  /// [base] 基准间距
  static double spacing(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return (base * 0.75).clamp(4.0, base);
    if (width > 600) return (base * 1.2).clamp(base, base * 1.5);
    return base;
  }

  /// 动态内边距
  /// [base] 基准内边距
  static double padding(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return (base * 0.8).clamp(4.0, base);
    if (width > 600) return (base * 1.3).clamp(base, base * 2.0);
    return base;
  }

  /// 动态高度（用于卡片、头像等）
  /// [base] 基准高度
  static double height(BuildContext context, double base) {
    final height = screenHeight(context);
    if (height < 640) return (base * 0.8).clamp(base * 0.6, base);
    if (height > 800) return (base * 1.15).clamp(base, base * 1.4);
    return base;
  }

  /// 动态图标大小
  /// [base] 基准大小
  static double iconSize(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return (base * 0.85).clamp(base * 0.7, base);
    if (width > 600) return (base * 1.15).clamp(base, base * 1.3);
    return base;
  }

  /// 动态按钮高度
  /// [base] 基准高度
  static double buttonHeight(BuildContext context, double base) {
    final height = screenHeight(context);
    if (height < 640) return (base * 0.85).clamp(base * 0.7, base);
    if (height > 800) return (base * 1.1).clamp(base, base * 1.3);
    return base;
  }

  /// 动态头像半径
  /// [base] 基准半径
  static double avatarRadius(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return (base * 0.8).clamp(base * 0.6, base);
    if (width > 600) return (base * 1.2).clamp(base, base * 1.5);
    return base;
  }

  /// 动态卡片高度（用于图表区域等）
  /// [min] 最小高度
  /// [max] 最大高度
  static double cardHeight(
    BuildContext context, {
    double min = 100,
    double max = 250,
  }) {
    final height = availableHeight(context);
    // 图表高度 = 可用高度的 20% ~ 30%，在 min ~ max 范围内
    final computed = height * 0.25;
    return computed.clamp(min, max);
  }

  /// 获取 AppBar 高度（考虑安全区）
  static double appBarHeight(BuildContext context) =>
      kToolbarHeight + MediaQuery.of(context).padding.top;

  /// 获取底部导航栏高度
  static double bottomNavHeight(BuildContext context) =>
      kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
}
