/// 应用圆角系统
/// 统一的圆角半径定义
class AppRadius {
  AppRadius._();

  /// 小圆角 - 8px
  static const double sm = 8.0;

  /// 中等圆角 - 12px
  static const double md = 12.0;

  /// 大圆角 - 16px
  static const double lg = 16.0;

  /// 超大圆角 - 20px
  static const double xl = 20.0;

  /// 全圆角（用于胶囊按钮等）
  static const double full = 999.0;

  // ==================== 组件专用圆角 ====================
  /// 按钮圆角
  static const double button = md;

  /// 卡片圆角
  static const double card = md;

  /// 输入框圆角
  static const double input = md;

  /// Chip 圆角
  static const double chip = full;

  /// 对话框圆角
  static const double dialog = lg;

  /// 底部弹窗圆角
  static const double bottomSheet = xl;

  /// 头像圆角
  static const double avatar = full;

  /// 搜索框圆角
  static const double searchBar = md;
}
