import 'package:opencc/opencc.dart';

/// 将地名等文本规范为简体中文（天地图等接口可能返回繁体字形）
class ChineseText {
  ChineseText._();

  static ZhConverter? _t2s;

  static String toSimplified(String text) {
    if (text.isEmpty) return text;
    try {
      _t2s ??= ZhConverter('t2s', large: true);
      return _t2s!.convert(text);
    } catch (_) {
      return text;
    }
  }
}
