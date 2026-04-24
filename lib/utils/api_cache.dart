/// 简单的内存缓存，带 TTL（生存时间）
///
/// 用于缓存热点 API 响应，减少重复网络请求。
///
/// 使用示例：
/// ```dart
/// final cache = ApiCache<String>(maxAge: Duration(minutes: 5));
///
/// // 写入
/// cache.set('key', 'value');
///
/// // 读取（未过期返回 value，过期返回 null）
/// final value = cache.get('key');
///
/// // 删除
/// cache.remove('key');
/// ```
class ApiCache<T> {
  final Duration maxAge;
  final int maxEntries;

  final Map<String, _CacheEntry<T>> _store = {};
  DateTime _lastCleanup = DateTime.now();

  ApiCache({
    this.maxAge = const Duration(minutes: 5),
    this.maxEntries = 100,
  });

  /// 写入缓存
  void set(String key, T value) {
    _maybeCleanup();
    _store[key] = _CacheEntry(value, DateTime.now());
  }

  /// 读取缓存（未过期返回 value，过期或不存在返回 null）
  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > maxAge) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  /// 是否存在有效缓存
  bool contains(String key) => get(key) != null;

  /// 删除指定缓存
  void remove(String key) => _store.remove(key);

  /// 清空全部缓存
  void clear() => _store.clear();

  /// 缓存数量
  int get length => _store.length;

  void _maybeCleanup() {
    final now = DateTime.now();
    // 每 50 次操作触发一次清理
    if (_store.length > maxEntries || now.difference(_lastCleanup).inMinutes > 5) {
      _store.removeWhere((_, entry) => now.difference(entry.timestamp) > maxAge);
      _lastCleanup = now;
    }
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}

/// 全局行李列表缓存（5分钟过期）
final baggageListCache = ApiCache<List<Map<String, dynamic>>>(
  maxAge: const Duration(minutes: 5),
  maxEntries: 3, // 缓存 3 页数据
);

/// 全局统计信息缓存（1分钟过期）
final statsCache = ApiCache<Map<String, int>>(
  maxAge: const Duration(minutes: 1),
  maxEntries: 1,
);
