import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../constants/app_constants.dart';
import '../models/luggage.dart';
import '../models/qr_payload.dart';
import '../models/search_result.dart';
import '../services/location_search_service.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../components/status_badge.dart';
import '../components/app_button.dart';
import '../utils/responsive.dart';
import '../widgets/location_search_bar.dart';
import '../l10n/app_localizations.dart';
import 'luggage_detail_screen.dart';

/// 行李地图页面
/// 使用 flutter_map + 天地图卫星影像显示行李位置
/// 瓦片：天地图影像底图（img_w）+ 影像标注层（cia_w）
/// 支持地图缩放、拖拽、点击行李查看详情
class LuggageMapScreen extends StatefulWidget {
  const LuggageMapScreen({super.key});

  @override
  State<LuggageMapScreen> createState() => _LuggageMapScreenState();
}

/// 行李 + latlong2.LatLng 坐标的组合
class _LuggageCoords {
  final Luggage luggage;
  final latlong2.LatLng position;
  const _LuggageCoords(this.luggage, this.position);
}

class _LuggageMapScreenState extends State<LuggageMapScreen> {
  /// 滞留行李按位置分组: 位置名 → 该位置下所有行李（含坐标）
  Map<String, List<_LuggageCoords>> _strandedGroups = {};

  /// 当前地图上要渲染的所有标记
  List<Marker> _markers = [];

  /// 第一个标记位置，用于地图初始中心
  latlong2.LatLng? _firstMarkerPosition;

  bool _isLoading = true;
  String? _error;
  bool _tileError = false;
  SearchResult? _searchResult;

  late final MapController _mapController;

  static const _defaultCenter = latlong2.LatLng(30.5928, 114.3055);
  static const _defaultZoom = 5.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadLuggageData();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  int get _strandedCount =>
      _strandedGroups.values.fold(0, (sum, list) => sum + list.length);

  Future<void> _loadLuggageData() async {
    setState(() => _isLoading = true);
    try {
      final strandedItems = await LuggageService.getStrandedLuggage(
        forceRefresh: true,
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        throw TimeoutException('加载行李超时，请检查网络连接');
      });

      debugPrint('[地图] 获取到滞留行李 ${strandedItems.length} 件');
      for (final l in strandedItems) {
        debugPrint(
            '  - ${l.tagNumber} 状态:${l.status.displayName} 坐标:(${l.latitude},${l.longitude}) 位置:${l.currentLocation}');
      }

      // 分类：有 GPS 坐标 vs 无 GPS 坐标（需地理编码）
      final Map<String, List<_LuggageCoords>> groups = {};
      final List<Luggage> needGeoCode = [];
      latlong2.LatLng? firstPos;

      for (final luggage in strandedItems) {
        if (luggage.latitude != null && luggage.longitude != null) {
          final pos = latlong2.LatLng(luggage.latitude!, luggage.longitude!);
          firstPos ??= pos;
          final key = luggage.currentLocation.isNotEmpty ? luggage.currentLocation : '未知位置';
          groups.putIfAbsent(key, () => []).add(_LuggageCoords(luggage, pos));
        } else if (luggage.currentLocation.isNotEmpty) {
          needGeoCode.add(luggage);
        }
      }

      debugPrint('[地图] 有坐标行李 ${groups.length} 组，无坐标需地理编码 ${needGeoCode.length} 件');

      // 天地图地理编码（已有 10 分钟内存缓存，不会重复请求）
      for (final luggage in needGeoCode) {
        final pos = await LocationSearchService.geocode(luggage.currentLocation);
        if (pos != null) {
          final ll = latlong2.LatLng(pos.latitude, pos.longitude);
          firstPos ??= ll;
          groups.putIfAbsent(luggage.currentLocation, () => []).add(_LuggageCoords(luggage, ll));
          debugPrint('[地图] 地理编码成功: ${luggage.currentLocation} → (${pos.latitude}, ${pos.longitude})');
        } else {
          debugPrint('[地图] 地理编码失败: ${luggage.currentLocation}');
        }
      }

      final markers = <Marker>[];
      for (final entry in groups.entries) {
        markers.add(_buildLocationMarker(entry.key, entry.value));
      }

      debugPrint('[地图] 渲染标记 ${markers.length} 个');

      setState(() {
        _strandedGroups = groups;
        _markers = markers;
        _firstMarkerPosition = firstPos;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('[地图] 加载失败: $e');
      setState(() {
        _strandedGroups = {};
        _markers = [];
        _isLoading = false;
        _error = '加载行李数据失败: $e';
      });
    }
  }

  Marker _buildLocationMarker(String locationName, List<_LuggageCoords> items) {
    final pos = items.first.position;
    return Marker(
      point: pos,
      width: 80,
      height: 80,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => _onMarkerTap(locationName),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
              ),
              child: Text(
                items.length > 1 ? '${items.first.luggage.tagNumber}等${items.length}件' : items.first.luggage.tagNumber,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMarkerTap(String locationName) {
    final items = _strandedGroups[locationName];
    if (items == null || items.isEmpty) return;
    _showLocationSheet(locationName, items);
  }

  void _showLocationSheet(String locationName, List<_LuggageCoords> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '${items.length}件',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...items.map((item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.luggage, color: Color(0xFFF97316), size: 18),
              ),
              title: Text(
                item.luggage.tagNumber,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                '${item.luggage.flightNumber} · ${item.luggage.passengerName}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () {
                Navigator.pop(context);
                _viewDetail(item.luggage);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _viewDetail(Luggage luggage) {
    final qrPayload = QrPayload(
      userId: '',
      luggageId: luggage.id,
      role: 'owner',
      extra: {'tagNo': luggage.tagNumber},
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LuggageDetailScreen(
          qrPayload: qrPayload,
          raw: luggage.id,
        ),
      ),
    );
  }

  void _goToLuggage() {
    if (_markers.isNotEmpty && _firstMarkerPosition != null) {
      _mapController.move(_firstMarkerPosition!, 10.0);
    }
  }

  void _onSearchResult(SearchResult result) {
    setState(() {
      _searchResult = result;
    });
    _mapController.move(result.location, 14.0);
  }

  void _clearSearchResult() {
    setState(() {
      _searchResult = null;
    });
  }

  void _fitAllMarkers() {
    if (_markers.isEmpty) return;

    if (_markers.length == 1) {
      _mapController.move(_markers.first.point, 10.0);
      return;
    }

    final points = _markers.map((m) => m.point).toList();
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.strandedLuggageMonitor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: _loadLuggageData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: l10n.more,
            onSelected: (v) {
              if (v == 'fit') _fitAllMarkers();
              if (v == 'location') _goToLuggage();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'fit',
                child: Row(
                  children: [
                    Icon(Icons.fit_screen, size: Responsive.iconSize(context, 20)),
                    SizedBox(width: Responsive.spacing(context, AppSpacing.sm + 4)),
                    Text(l10n.showAllLuggage, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'location',
                child: Row(
                  children: [
                    Icon(Icons.luggage, size: Responsive.iconSize(context, 20)),
                    SizedBox(width: Responsive.spacing(context, AppSpacing.sm + 4)),
                    Text(l10n.locateLuggage, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          if (_isLoading) _buildLoadingOverlay(),
          if (_tileError) _buildTileErrorBanner(),
          if (_error != null) _buildErrorBanner(),
          _buildSearchBar(),
          _buildZoomControls(),
          _buildStatisticsCard(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GestureDetector(
      onDoubleTap: () {
        final currentZoom = _mapController.camera.zoom;
        if (currentZoom < 17) {
          _mapController.move(
            _mapController.camera.center,
            (currentZoom + 1).clamp(4, 17),
          );
        }
      },
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _firstMarkerPosition ?? _defaultCenter,
          initialZoom: _defaultZoom,
          minZoom: 4,
          maxZoom: 17,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.doubleTapZoom,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: AppConstants.tiandituImageTileUrl,
            userAgentPackageName: 'com.example.my_first_app',
            maxZoom: 17,
            minZoom: 4,
            tileProvider: NetworkTileProvider(),
          ),
          TileLayer(
            urlTemplate: AppConstants.tiandituAnnotationTileUrl,
            userAgentPackageName: 'com.example.my_first_app',
            maxZoom: 17,
            minZoom: 4,
            tileProvider: NetworkTileProvider(),
          ),
          MarkerLayer(
            markers: [
              ..._markers,
              if (_searchResult != null)
                Marker(
                  point: _searchResult!.location,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black26,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.lg)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: Responsive.iconSize(context, 20),
                  height: Responsive.iconSize(context, 20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.md)),
                Text(l10n.loadingLuggageData, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context, AppSpacing.md),
            vertical: Responsive.spacing(context, AppSpacing.sm + 2),
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: Responsive.iconSize(context, 20),
              ),
              SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
              Expanded(
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.warning,
                    fontSize: Responsive.fontSize(context, 14),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: Responsive.iconSize(context, 20)),
                onPressed: _loadLuggageData,
                color: isDark ? Colors.white70 : AppColors.warning,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTileErrorBanner() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      top: _error != null ? 72 : 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context, AppSpacing.md),
            vertical: Responsive.spacing(context, AppSpacing.sm + 2),
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.red.shade900.withValues(alpha: 0.85)
                : Colors.red.shade50.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark
                  ? Colors.red.shade700
                  : Colors.red.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.map_outlined,
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                size: Responsive.iconSize(context, 20),
              ),
              SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
              Expanded(
                child: Text(
                  l10n.mapTileLoadFailed,
                  style: TextStyle(
                    color: isDark ? Colors.red.shade200 : Colors.red.shade800,
                    fontSize: Responsive.fontSize(context, 13),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: Responsive.iconSize(context, 20), color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                onPressed: () => setState(() => _tileError = false),
                tooltip: l10n.closeHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: 100,
      right: Responsive.padding(context, AppSpacing.md),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        child: Padding(
          padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm + 4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.strandedLuggageStats,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 13),
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              _statItem(AppColors.warning, l10n.strandedLuggage, '$_strandedCount 件', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(Color color, String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 12),
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 12),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 0,
      left: Responsive.padding(context, AppSpacing.md),
      right: Responsive.padding(context, AppSpacing.md),
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.only(top: Responsive.padding(context, AppSpacing.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          LocationSearchBar(
            onSearchResult: _onSearchResult,
          ),
          if (_searchResult != null)
            Container(
              margin: EdgeInsets.only(top: Responsive.spacing(context, AppSpacing.sm)),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, AppSpacing.md),
                vertical: Responsive.spacing(context, AppSpacing.sm),
              ),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _searchResult!.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _clearSearchResult,
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: Responsive.padding(context, AppSpacing.md),
      right: Responsive.padding(context, AppSpacing.md),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sm),
                ),
                onTap: _zoomIn,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                    size: Responsive.iconSize(context, 24),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              width: 32,
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.sm),
                ),
                onTap: _zoomOut,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.remove,
                    color: Theme.of(context).colorScheme.primary,
                    size: Responsive.iconSize(context, 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 17) {
      _mapController.move(
        _mapController.camera.center,
        (currentZoom + 1).clamp(4, 17),
      );
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 4) {
      _mapController.move(
        _mapController.camera.center,
        (currentZoom - 1).clamp(4, 17),
      );
    }
  }
}

/// 行李详情底部弹窗
class LuggageDetailBottomSheet extends StatelessWidget {
  final Luggage luggage;
  final VoidCallback onViewDetail;
  final VoidCallback onClose;

  const LuggageDetailBottomSheet({
    super.key,
    required this.luggage,
    required this.onViewDetail,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: Responsive.spacing(context, AppSpacing.sm + 4)),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.lg)),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.luggage,
                    size: Responsive.iconSize(context, 28),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.md)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        luggage.tagNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 17),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                      Text(
                        luggage.passengerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: luggage.status),
                SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: Responsive.iconSize(context, 20),
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.lg)),
            child: Column(
              children: [
                _infoRow(
                  context,
                  Icons.flight,
                  l10n.flight,
                  luggage.flightNumber,
                  isDark,
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm + 4)),
                _infoRow(
                  context,
                  Icons.location_on,
                  l10n.location,
                  luggage.currentLocation,
                  isDark,
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm + 4)),
                _infoRow(
                  context,
                  Icons.schedule,
                  l10n.updateTime,
                  _formatTime(luggage.lastUpdated),
                  isDark,
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm + 4)),
                _infoRow(
                  context,
                  Icons.info_outline,
                  l10n.status,
                  '',
                  isDark,
                  trailing: StatusBadge(status: luggage.status),
                ),
                if (luggage.notes.isNotEmpty) ...[
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm + 4)),
                  _infoRow(
                    context,
                    Icons.note,
                    l10n.remark(luggage.notes),
                    '',
                    isDark,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.padding(context, AppSpacing.lg),
              0,
              Responsive.padding(context, AppSpacing.lg),
              MediaQuery.of(context).padding.bottom + Responsive.padding(context, AppSpacing.lg),
            ),
            child: AppButton(
              text: l10n.viewDetail,
              icon: Icons.visibility,
              fullWidth: true,
              onPressed: onViewDetail,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Row(
            children: [
              Icon(
                icon,
                size: Responsive.iconSize(context, 18),
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
              SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null)
          trailing
        else
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 15),
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
