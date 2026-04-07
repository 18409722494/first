import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// 本地队列服务类
/// 负责管理本地队列，确保在网络不稳定时数据不丢失
class LocalQueueService {
  static late Box<Map<dynamic, dynamic>> _queueBox;

  /// 初始化本地队列
  static Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
      _queueBox = await Hive.openBox<Map<dynamic, dynamic>>('damage_reports_queue');
    } catch (e) {
      rethrow;
    }
  }

  /// 保存破损报告到本地队列
  /// [reportData] 报告数据
  /// 返回保存的索引
  static Future<int> saveToQueue(Map<String, dynamic> reportData) async {
    try {
      // 确保队列已初始化
      if (!Hive.isBoxOpen('damage_reports_queue')) {
        await init();
      }

      // 保存到队列
      final index = await _queueBox.add(reportData);
      return index;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取本地队列中的所有报告
  static Future<List<Map<String, dynamic>>> getQueueItems() async {
    try {
      // 确保队列已初始化
      if (!Hive.isBoxOpen('damage_reports_queue')) {
        await init();
      }

      final items = <Map<String, dynamic>>[];
      for (int i = 0; i < _queueBox.length; i++) {
        final item = _queueBox.getAt(i);
        if (item != null) {
          items.add(Map<String, dynamic>.from(item));
        }
      }
      return items;
    } catch (e) {
      return [];
    }
  }

  /// 从队列中删除报告
  /// [index] 报告在队列中的索引
  static Future<void> removeFromQueue(int index) async {
    try {
      // 确保队列已初始化
      if (!Hive.isBoxOpen('damage_reports_queue')) {
        await init();
      }

      await _queueBox.deleteAt(index);
    } catch (e) {
      rethrow;
    }
  }

  /// 清空本地队列
  static Future<void> clearQueue() async {
    try {
      // 确保队列已初始化
      if (!Hive.isBoxOpen('damage_reports_queue')) {
        await init();
      }

      await _queueBox.clear();
    } catch (e) {
      rethrow;
    }
  }
}
