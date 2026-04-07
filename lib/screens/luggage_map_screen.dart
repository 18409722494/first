import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_constants.dart';
import '../models/luggage.dart';
import '../models/qr_payload.dart';
import '../models/search_result.dart';
import '../services/luggage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../components/status_badge.dart';
import '../components/app_button.dart';
import '../utils/responsive.dart';
import '../widgets/location_search_bar.dart';
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

class _LuggageMapScreenState extends State<LuggageMapScreen> {
  List<Luggage> _luggages = [];
  bool _isLoading = true;
  String? _error;
  bool _tileError = false;
  SearchResult? _searchResult;

  /// 预缓存的行李标记，key 与 _luggages 一一对应，只在数据加载/刷新时重建一次
  List<Marker> _luggageMarkerCache = [];

  /// 第一个有坐标行李的位置，用于地图初始中心
  LatLng? _firstLuggagePosition;

  late final MapController _mapController;

  static const _defaultCenter = LatLng(30.5928, 114.3055);
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

  Future<void> _loadLuggageData() async {
    setState(() => _isLoading = true);
    try {
      final result = await LuggageService.getLuggageList(page: 1, pageSize: 5000);
      final list = result.items;
      setState(() {
        _luggages = list;
        _isLoading = false;
        _error = null;
      });
      _rebuildMarkerCache(list);
    } catch (e) {
      setState(() {
        _luggages = [];
        _isLoading = false;
        _error = '加载行李数据失败: $e';
      });
      _rebuildMarkerCache([]);
    }
  }

  /// 根据行李列表一次性构建 marker 列表，避免每次地图 rebuild 重复创建对象
  void _rebuildMarkerCache(List<Luggage> luggages) {
    final validLuggages = luggages
        .where((l) => l.latitude != null && l.longitude != null)
        .toList();
    _firstLuggagePosition = validLuggages.isNotEmpty
        ? LatLng(validLuggages.first.latitude!, validLuggages.first.longitude!)
        : null;
    _luggageMarkerCache = [
      for (final luggage in validLuggages) _buildMarker(luggage),
    ];
  }

  Marker _buildMarker(Luggage luggage) {
    return Marker(
      point: LatLng(luggage.latitude!, luggage.longitude!),
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () => _onMarkerTap(luggage),
        child: Container(
          decoration: BoxDecoration(
            color: _markerColor(luggage).withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(_markerIcon(luggage), color: Colors.white, size: 22),
        ),
      ),
    );
  }

  LatLng _luggagePosition(Luggage luggage) {
    if (luggage.latitude != null && luggage.longitude != null) {
      return LatLng(luggage.latitude!, luggage.longitude!);
    }
    return _defaultCenter;
  }

  void _onMarkerTap(Luggage luggage) {
    _showLuggageDetailSheet(luggage);
  }

  void _showLuggageDetailSheet(Luggage luggage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LuggageDetailBottomSheet(
        luggage: luggage,
        onViewDetail: () {
          Navigator.pop(context);
          _viewDetail(luggage);
        },
        onClose: () => Navigator.pop(context),
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
    if (_luggages.isNotEmpty) {
      final pos = _luggagePosition(_luggages.first);
      _mapController.move(pos, 10.0);
    }
  }

  void _onSearchResult(SearchResult result) {
    setState(() {
      _searchResult = result;
    });
    // 定位到目标并缩放到合适层级（14 级适合城市视图）
    _mapController.move(result.location, 14.0);
  }

  void _clearSearchResult() {
    setState(() {
      _searchResult = null;
    });
  }

  void _fitAllMarkers() {
    if (_luggages.isEmpty) return;
    final validPoints = _luggages
        .where((l) => l.latitude != null && l.longitude != null)
        .map(_luggagePosition)
        .toList();
    if (validPoints.isEmpty) return;

    if (validPoints.length == 1) {
      _mapController.move(validPoints.first, 10.0);
      return;
    }

    final bounds = LatLngBounds.fromPoints(validPoints);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  Color _markerColor(Luggage luggage) {
    switch (luggage.status) {
      case LuggageStatus.checkIn:
        return AppColors.checkIn;
      case LuggageStatus.inTransit:
        return AppColors.inTransit;
      case LuggageStatus.arrived:
        return AppColors.arrived;
      case LuggageStatus.delivered:
        return AppColors.delivered;
      case LuggageStatus.damaged:
        return AppColors.damaged;
      case LuggageStatus.lost:
        return AppColors.lost;
    }
  }

  IconData _markerIcon(Luggage luggage) {
    if (luggage.status == LuggageStatus.damaged) {
      return Icons.luggage_outlined;
    }
    return Icons.luggage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行李地图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: _loadLuggageData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: '更多',
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
                    Text('显示全部行李', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'location',
                child: Row(
                  children: [
                    Icon(Icons.luggage, size: Responsive.iconSize(context, 20)),
                    SizedBox(width: Responsive.spacing(context, AppSpacing.sm + 4)),
                    Text('定位行李', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
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
          _buildLegend(),
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
          initialCenter: _firstLuggagePosition ?? _defaultCenter,
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
              ..._luggageMarkerCache,
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
                Text('加载行李数据...', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
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
                  '地图瓦片加载失败，请检查网络',
                  style: TextStyle(
                    color: isDark ? Colors.red.shade200 : Colors.red.shade800,
                    fontSize: Responsive.fontSize(context, 13),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: Responsive.iconSize(context, 20), color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                onPressed: () => setState(() => _tileError = false),
                tooltip: '关闭提示',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
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
                '行李状态',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 13),
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              _legendItem(AppColors.checkIn, '已办理托运', isDark),
              _legendItem(AppColors.inTransit, '运输中', isDark),
              _legendItem(AppColors.arrived, '已到达', isDark),
              _legendItem(AppColors.delivered, '已交付', isDark),
              _legendItem(AppColors.damaged, '已损坏', isDark),
              _legendItem(AppColors.lost, '已丢失', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, bool isDark) {
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
                  '航班',
                  luggage.flightNumber,
                  isDark,
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm + 4)),
                _infoRow(
                  context,
                  Icons.location_on,
                  '目的地',
                  luggage.destination,
                  isDark,
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm + 4)),
                _infoRow(
                  context,
                  Icons.schedule,
                  '更新时间',
                  _formatTime(luggage.lastUpdated),
                  isDark,
                ),
                SizedBox(height: Responsive.spacing(context, AppSpacing.sm + 4)),
                _infoRow(
                  context,
                  Icons.info_outline,
                  '状态',
                  '',
                  isDark,
                  trailing: StatusBadge(status: luggage.status),
                ),
                if (luggage.notes.isNotEmpty) ...[
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm + 4)),
                  _infoRow(
                    context,
                    Icons.note,
                    '备注',
                    luggage.notes,
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
              text: '查看详情',
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
