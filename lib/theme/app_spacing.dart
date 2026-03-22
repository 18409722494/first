/// 应用间距系统
/// 基于 8px 网格系统，确保间距一致性
class AppSpacing {
  AppSpacing._();

  /// 超小间距 - 4px
  static const double xs = 4.0;

  /// 小间距 - 8px
  static const double sm = 8.0;

  /// 中等间距 - 16px
  static const double md = 16.0;

  /// 大间距 - 24px
  static const double lg = 24.0;

  /// 超大间距 - 32px
  static const double xl = 32.0;

  /// 特大间距 - 48px
  static const double xxl = 48.0;

  // ==================== 常用边距组合 ====================
  /// 页面水平边距
  static const double pageHorizontal = md;

  /// 页面垂直边距
  static const double pageVertical = md;

  /// 卡片内边距
  static const double cardPadding = md;

  /// 列表项内边距
  static const double listItemPadding = md;

  /// 按钮内边距
  static const double buttonPadding = 14.0;

  // ==================== 间距倍数 ====================
  /// 2倍基础间距
  static const double x2 = sm * 2;

  /// 3倍基础间距
  static const double x3 = sm * 3;

  /// 4倍基础间距
  static const double x4 = md;

  /// 6倍基础间距
  static const double x6 = md + lg;
}
