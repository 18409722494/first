import 'package:latlong2/latlong.dart';

/// 地理位置搜索结果模型
/// 用于存储地名搜索的返回结果
class SearchResult {
  /// 完整地址名称
  final String name;

  /// 简略名称（用于列表显示）
  final String displayName;

  /// 经纬度坐标
  final LatLng location;

  /// 匹配级别（省/市/区/街道/POI）
  final String level;

  /// 详细地址（可选）
  final String? address;

  const SearchResult({
    required this.name,
    required this.displayName,
    required this.location,
    required this.level,
    this.address,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'];

    if (locationData == null) {
      throw Exception('SearchResult.fromJson: 缺少 location 字段');
    }

    if (locationData is! Map) {
      throw Exception('SearchResult.fromJson: location 字段类型错误，期望 Map');
    }

    final locationMap = locationData as Map<String, dynamic>;

    return SearchResult(
      name: json['name'] ?? json['keyWord'] ?? '',
      displayName: json['name'] ?? json['keyWord'] ?? '',
      location: LatLng(
        double.tryParse(locationMap['lat']?.toString() ?? '') ?? 0,
        double.tryParse(locationMap['lon']?.toString() ?? '') ?? 0,
      ),
      level: locationMap['level'] ?? '',
      address: json['address'],
    );
  }

  @override
  String toString() => 'SearchResult(name: $name, location: $location)';
}
