import 'package:flutter/material.dart';

/// 响应式工具类
class Responsive {
  Responsive._();

  static Responsive of(BuildContext context) => Responsive._();

  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double availableWidth(BuildContext context) =>
      MediaQuery.of(context).size.width -
      MediaQuery.of(context).padding.left -
      MediaQuery.of(context).padding.right;

  static double availableHeight(BuildContext context) =>
      MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      MediaQuery.of(context).padding.bottom;

  static double fractionWidth(BuildContext context, double fraction) =>
      availableWidth(context) * fraction;

  static double fractionHeight(BuildContext context, double fraction) =>
      availableHeight(context) * fraction;

  /// 动态字号
  static double fontSize(BuildContext context, double base, {double scale = 1.0}) {
    final width = screenWidth(context);
    final scaled = base * scale;
    if (width < 360) return (scaled * 0.85).clamp(10.0, scaled);
    if (width > 600) return (scaled * 1.1).clamp(scaled, scaled * 1.3);
    return scaled;
  }

  /// 动态间距
  static double spacing(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return (base * 0.75).clamp(4.0, base);
    if (width > 600) return (base * 1.2).clamp(base, base * 1.5);
    return base;
  }

  /// 动态内边距
  static double padding(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return (base * 0.8).clamp(4.0, base);
    if (width > 600) return (base * 1.3).clamp(base, base * 2.0);
    return base;
  }

  /// 动态高度
  static double height(BuildContext context, double base) {
    final height = screenHeight(context);
    if (height < 640) return (base * 0.8).clamp(base * 0.6, base);
    if (height > 800) return (base * 1.15).clamp(base, base * 1.4);
    return base;
  }

  /// 动态图标大小
  static double iconSize(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return (base * 0.85).clamp(base * 0.7, base);
    if (width > 600) return (base * 1.15).clamp(base, base * 1.3);
    return base;
  }

  /// 动态按钮高度
  static double buttonHeight(BuildContext context, double base) {
    final height = screenHeight(context);
    if (height < 640) return (base * 0.85).clamp(base * 0.7, base);
    if (height > 800) return (base * 1.1).clamp(base, base * 1.3);
    return base;
  }

  /// 动态头像半径
  static double avatarRadius(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return (base * 0.8).clamp(base * 0.6, base);
    if (width > 600) return (base * 1.2).clamp(base, base * 1.5);
    return base;
  }

  /// 动态卡片高度
  static double cardHeight(
    BuildContext context, {
    double min = 100,
    double max = 250,
  }) {
    final height = availableHeight(context);
    final computed = height * 0.25;
    return computed.clamp(min, max);
  }

  static double appBarHeight(BuildContext context) =>
      kToolbarHeight + MediaQuery.of(context).padding.top;

  static double bottomNavHeight(BuildContext context) =>
      kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
}
