import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../constants/app_constants.dart';
import '../models/search_result.dart';

/// 地理位置搜索服务
/// 使用天地图地理编码 API 实现地名搜索功能
class LocationSearchService {
  LocationSearchService._();

  /// 天地图地理编码 API 地址
  static const String _geocodingUrl = 'https://api.tianditu.gov.cn/geocoder';

  /// 搜索缓存（避免重复请求）
  static final Map<String, List<SearchResult>> _cache = {};

  /// 搜索地址
  ///
  /// [keyword] 搜索关键词（地名、地址等）
  /// 返回搜索结果列表
  static Future<List<SearchResult>> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    final trimmedKeyword = keyword.trim();

    // 检查缓存
    if (_cache.containsKey(trimmedKeyword)) {
      return _cache[trimmedKeyword]!;
    }

    try {
      final results = await _searchFromTianditu(trimmedKeyword);
      // 缓存结果
      _cache[trimmedKeyword] = results;
      return results;
    } catch (e) {
      // 如果天地图失败，尝试备用方案
      try {
        final results = await _searchFromNominatim(trimmedKeyword);
        return results;
      } catch (_) {
        return [];
      }
    }
  }

  /// 从天地图 API 搜索
  static Future<List<SearchResult>> _searchFromTianditu(String keyword) async {
    final uri = Uri.parse(_geocodingUrl).replace(
      queryParameters: {
        'ds': '{"keyWord":"$keyword"}',
        'tk': AppConstants.tiandituApiKey,
      },
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('请求超时'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseTiandituResponse(data, keyword);
    } else {
      throw Exception('API 请求失败: ${response.statusCode}');
    }
  }

  /// 解析天地图响应
  /// 官方格式：{ status, msg, location: { lon, lat, level } }，location 在顶层
  /// 兼容旧格式：{ result: { location, name, address } }
  static List<SearchResult> _parseTiandituResponse(dynamic data, String keyword) {
    if (data == null || data is! Map) return [];

    // status: 0=成功, 101=无结果, 404=错误
    final status = data['status']?.toString();
    if (status != null && status != '0') return [];

    // 优先读取顶层 location（官方格式），否则读 result.location
    dynamic location = data['location'];
    if (location == null) {
      final result = data['result'];
      location = result is Map ? result['location'] : null;
    }
    if (location == null || location is! Map) return [];

    final latVal = _toDouble(location['lat']);
    final lonVal = _toDouble(location['lon']);
    if (latVal == null || lonVal == null || (latVal == 0 && lonVal == 0)) {
      return [];
    }

    final result = data['result'];
    final name = result is Map
        ? (result['name'] ?? result['keyWord'] ?? keyword).toString()
        : keyword;
    final address = result is Map ? result['address']?.toString() : null;

    return [
      SearchResult(
        name: name,
        displayName: name,
        location: LatLng(latVal, lonVal),
        level: location['level']?.toString() ?? '',
        address: address,
      ),
    ];
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// 从 Nominatim（备用方案）搜索
  static Future<List<SearchResult>> _searchFromNominatim(String keyword) async {
    final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
      queryParameters: {
        'q': keyword,
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'LuggageTracker/1.0'},
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('搜索超时，请检查网络连接'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0;
        final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0;
        return SearchResult(
          name: item['display_name'] ?? '',
          displayName: item['name'] ?? item['display_name'] ?? '',
          location: LatLng(lat, lon),
          level: item['type'] ?? '',
          address: item['display_name'],
        );
      }).toList();
    } else {
      throw Exception('Nominatim API 请求失败: ${response.statusCode}');
    }
  }

  /// 清除缓存
  static void clearCache() {
    _cache.clear();
  }
}
