import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../constants/app_constants.dart';
import '../models/search_result.dart';

/// 地理位置搜索服务
///
/// **根因说明（历史问题）**
/// 1. 天地图「地名搜索 V2」正确调用方式为 `postStr` + `type=query`，旧版扁平参数（如 `queryZoom`）易失效，导致 POI 搜索常年无结果或异常。
/// 2. Nominatim 在国内常不可用；若天地图也未正确调用，则两路同时失败，界面即显示「请检查网络」。
///
/// **策略**
/// - 区县及以上：优先 [行政区划 API](v2/administrative) + 地理编码 geocoder（市/区/结构化地址）。
/// - 区县以下：修正后的 v2/search（`postStr` + `queryType`）+ Nominatim 备用。
class LocationSearchService {
  LocationSearchService._();

  static const String _administrativeUrl =
      'https://api.tianditu.gov.cn/v2/administrative';
  static const String _geocoderUrl = 'https://api.tianditu.gov.cn/geocoder';
  static const String _placeSearchUrl = 'https://api.tianditu.gov.cn/v2/search';
  static const String _nominatimUrl =
      'https://nominatim.openstreetmap.org/search';

  /// 全国范围搜索时的地图范围与缩放（与官方示例一致，配合 `specify` 中国）
  static const String _chinaMapBound = '73,3,136,54';
  static const String _adminSpecifyChina = '156000000';

  static final Map<String, List<SearchResult>> _cache = {};

  /// 搜索地名、地址、POI
  static Future<List<SearchResult>> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    final trimmedKeyword = keyword.trim();

    if (_cache.containsKey(trimmedKeyword)) {
      return _cache[trimmedKeyword]!;
    }

    late List<SearchResult> administrative;
    late List<SearchResult> geocoder;
    late List<SearchResult> placeSearch;
    late List<SearchResult> nominatim;
    Object? administrativeErr;
    Object? geocoderErr;
    Object? placeErr;
    Object? nominatimErr;

    await Future.wait<void>([
      () async {
        try {
          administrative =
              await _searchTiandituAdministrative(trimmedKeyword);
        } catch (e) {
          administrativeErr = e;
          administrative = [];
        }
      }(),
      () async {
        try {
          geocoder = await _searchTiandituGeocoder(trimmedKeyword);
        } catch (e) {
          geocoderErr = e;
          geocoder = [];
        }
      }(),
      () async {
        try {
          placeSearch = await _searchTiandituPlaceSearch(trimmedKeyword);
        } catch (e) {
          placeErr = e;
          placeSearch = [];
        }
      }(),
      () async {
        try {
          nominatim = await _searchFromNominatim(trimmedKeyword);
        } catch (e) {
          nominatimErr = e;
          nominatim = [];
        }
      }(),
    ]);

    if (administrativeErr != null &&
        geocoderErr != null &&
        placeErr != null &&
        nominatimErr != null) {
      final first = administrativeErr!;
      if (first is Exception) throw first;
      throw Exception(first.toString());
    }

    final merged = _mergeByPriority([
      administrative,
      geocoder,
      placeSearch,
      nominatim,
    ]);

    _cache[trimmedKeyword] = merged;
    return merged;
  }

  /// 行政区划查询（省 / 市 / 区县名，如「天津市」「东丽区」）
  static Future<List<SearchResult>> _searchTiandituAdministrative(
    String keyword,
  ) async {
    final uri = Uri.parse(_administrativeUrl).replace(
      queryParameters: {
        'keyword': keyword,
        'childLevel': '0',
        'extensions': 'false',
        'tk': AppConstants.tiandituApiKey,
      },
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 12),
      onTimeout: () => throw TimeoutException('天地图行政区划请求超时'),
    );

    if (response.statusCode != 200) {
      throw Exception('天地图行政区划 HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data is! Map) return [];

    if (data.containsKey('code') && data['code'] != null) {
      return [];
    }

    return _parseAdministrativeDistrict(data['district'], keyword);
  }

  /// 遍历 `district` 树，优先返回名称与关键词最匹配的行政区中心点。
  static List<SearchResult> _parseAdministrativeDistrict(
    dynamic districtRoot,
    String keyword,
  ) {
    final nodes = <Map<dynamic, dynamic>>[];

    void walk(dynamic node) {
      if (node == null) return;
      if (node is Map) {
        final center = node['center'];
        if (center is Map) {
          final lon = _parseDouble(center['lng'] ?? center['lon']);
          final lat = _parseDouble(center['lat']);
          final name = node['name']?.toString();
          if (name != null && name.isNotEmpty && lon != null && lat != null) {
            nodes.add(node);
          }
        }
        final children = node['children'];
        if (children is List) {
          for (final c in children) {
            walk(c);
          }
        }
      } else if (node is List) {
        for (final item in node) {
          walk(item);
        }
      }
    }

    walk(districtRoot);

    int matchScore(Map<dynamic, dynamic> node) {
      final name = node['name']?.toString() ?? '';
      if (name == keyword) return 3;
      if (name.contains(keyword)) return 2;
      if (keyword.contains(name) && name.length >= 2) return 1;
      return 0;
    }

    nodes.sort((a, b) => matchScore(b).compareTo(matchScore(a)));
    final matched = nodes.where((n) => matchScore(n) > 0).toList();
    final ordered = matched.isNotEmpty ? matched : nodes;

    return ordered.take(5).map((node) {
      final name = node['name']?.toString() ?? '';
      final center = node['center'] as Map<dynamic, dynamic>;
      final lon = _parseDouble(center['lng'] ?? center['lon'])!;
      final lat = _parseDouble(center['lat'])!;
      return SearchResult(
        name: name,
        displayName: name,
        location: LatLng(lat, lon),
        level: node['level']?.toString() ?? '行政区',
        address: name,
      );
    }).toList();
  }

  /// 地理编码：适合「市 + 路 + 门牌」等结构化地址；也可解析「天津市」等到中心点
  static Future<List<SearchResult>> _searchTiandituGeocoder(
    String keyword,
  ) async {
    final ds = jsonEncode({'keyWord': keyword});
    final uri = Uri.parse(_geocoderUrl).replace(
      queryParameters: {
        'ds': ds,
        'tk': AppConstants.tiandituApiKey,
      },
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 12),
      onTimeout: () => throw TimeoutException('天地图地理编码超时'),
    );

    if (response.statusCode != 200) {
      throw Exception('天地图地理编码 HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data is! Map) return [];

    final status = data['status']?.toString();
    if (status == '101' || status == '404') return [];
    if (status != null && status != '0') return [];

    final loc = data['location'];
    if (loc is! Map) return [];

    final lon = _parseDouble(loc['lon']);
    final lat = _parseDouble(loc['lat']);
    if (lon == null || lat == null) return [];

    final level = loc['level']?.toString() ?? '地理编码';
    final name = keyword;

    return [
      SearchResult(
        name: name,
        displayName: name,
        location: LatLng(lat, lon),
        level: level,
        address: data['result']?.toString() ?? name,
      ),
    ];
  }

  /// 地名搜索 V2（正确：`postStr` + `type=query`），用于 POI、道路、具体地名
  static Future<List<SearchResult>> _searchTiandituPlaceSearch(
    String keyword,
  ) async {
    Future<List<SearchResult>> runQuery(int queryType) async {
      final postStr = jsonEncode({
        'keyWord': keyword,
        'queryType': queryType,
        'start': 0,
        'count': 5,
        'mapBound': _chinaMapBound,
        'level': 10,
        'specify': _adminSpecifyChina,
      });

      final uri = Uri.parse(_placeSearchUrl).replace(
        queryParameters: {
          'postStr': postStr,
          'type': 'query',
          'tk': AppConstants.tiandituApiKey,
        },
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException('天地图地名搜索超时'),
      );

      if (response.statusCode != 200) {
        throw Exception('天地图地名搜索 HTTP ${response.statusCode}');
      }

      final data = json.decode(response.body);
      return _parseTiandituSearchPois(data);
    }

    // 1：普通搜索（POI、公交等）；7：地名搜索。无结果时再试 7，利于街道/地名级检索。
    final primary = await runQuery(1);
    if (primary.isNotEmpty) return primary;
    return runQuery(7);
  }

  static List<SearchResult> _parseTiandituSearchPois(dynamic data) {
    if (data == null || data is! Map) return [];

    final status = data['status']?.toString();
    if (status != null && status != '0') return [];

    final pois = data['pois'];
    if (pois == null || pois is! List || pois.isEmpty) return [];

    return pois.take(5).map((poi) {
      if (poi is! Map) return null;

      String? lonStr;
      String? latStr;
      final lonlat = poi['lonlat']?.toString();
      if (lonlat != null) {
        final parts = lonlat.split(RegExp(r'[,\s]+'));
        if (parts.length >= 2) {
          lonStr = parts[0];
          latStr = parts[1];
        }
      }

      final latVal = double.tryParse(latStr ?? '');
      final lonVal = double.tryParse(lonStr ?? '');
      if (latVal == null || lonVal == null) return null;

      return SearchResult(
        name: poi['name']?.toString() ?? '',
        displayName: poi['name']?.toString() ?? '',
        location: LatLng(latVal, lonVal),
        level: poi['type']?.toString() ?? 'POI',
        address: poi['address']?.toString(),
      );
    }).whereType<SearchResult>().toList();
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    return double.tryParse(v.toString());
  }

  /// 按数据源优先级合并并去重（先行政区与编码，再 POI，最后 OSM）
  static List<SearchResult> _mergeByPriority(
    List<List<SearchResult>> tiers,
  ) {
    final seen = <String>{};
    final combined = <SearchResult>[];

    for (final tier in tiers) {
      for (final r in tier) {
        final key =
            '${r.location.latitude.toStringAsFixed(5)}_${r.location.longitude.toStringAsFixed(5)}';
        if (!seen.contains(key)) {
          seen.add(key);
          combined.add(r);
          if (combined.length >= 5) return combined;
        }
      }
    }
    return combined;
  }

  /// Nominatim 备用（境外服务，国内可能不可用）
  static Future<List<SearchResult>> _searchFromNominatim(String keyword) async {
    final params = <String, String>{
      'q': keyword,
      'format': 'json',
      'limit': '5',
      'addressdetails': '1',
    };
    if (_looksLikeChinese(keyword)) {
      params['countrycodes'] = 'cn';
    }

    final uri = Uri.parse(_nominatimUrl).replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {
        'User-Agent':
            'LuggageMap/1.0 (Flutter luggage tracker; not a bot)',
        'Accept-Language': 'zh-CN,en',
      },
    ).timeout(
      const Duration(seconds: 12),
      onTimeout: () => throw TimeoutException('Nominatim 搜索超时'),
    );

    if (response.statusCode != 200) {
      throw Exception('Nominatim API ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((item) {
      final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0;
      final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0;
      return SearchResult(
        name: item['display_name'] ?? '',
        displayName: item['name'] ?? item['display_name'] ?? '',
        location: LatLng(lat, lon),
        level: item['type']?.toString() ?? '',
        address: item['display_name'],
      );
    }).toList();
  }

  static bool _looksLikeChinese(String s) {
    return RegExp(r'[\u4e00-\u9fff]').hasMatch(s);
  }

  static void clearCache() {
    _cache.clear();
  }
}
