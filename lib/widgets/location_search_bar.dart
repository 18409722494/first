import 'dart:async';
import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../services/location_search_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 地理位置搜索栏组件
class LocationSearchBar extends StatefulWidget {
  final void Function(SearchResult result) onSearchResult;

  const LocationSearchBar({
    super.key,
    required this.onSearchResult,
  });

  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _searchResults.isNotEmpty) {
      _showOverlay();
    }
  }

  void _onSearchTextChanged(String value) {
    _debounceTimer?.cancel();

    if (value.isEmpty) {
      _clearResults();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value);
    });
  }

  void _clearResults() {
    setState(() {
      _searchResults = [];
      _errorMessage = null;
      _isSearching = false;
    });
    _removeOverlay();
  }

  Future<void> _performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    _showOverlay();

    try {
      final results = await LocationSearchService.search(keyword);

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
        if (results.isEmpty && _errorMessage == null) {
          _errorMessage = '未找到相关地点';
        }
      });
      // OverlayEntry 不在本组件树内，必须主动调用 markNeedsBuild 才能刷新下拉内容
      _overlayEntry?.markNeedsBuild();

      // 搜索成功后自动定位到第一个结果
      if (results.isNotEmpty) {
        widget.onSearchResult(results.first);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _errorMessage = '搜索失败，请检查网络';
      });
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _onSearch() {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    _debounceTimer?.cancel();
    _focusNode.unfocus();

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    _performSearch(keyword);
  }

  void _onResultTap(SearchResult result) {
    widget.onSearchResult(result);
    _removeOverlay();
    _controller.text = result.displayName;
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // 必须跟随搜索框锚点，否则 Positioned 仅有 width 时会贴在全屏 Stack 的 (0,0)，与状态栏重叠
    return OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, size.height + 4),
        child: SizedBox(
          width: size.width,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark
                : AppColors.cardLight,
            child: _buildResultsContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsContent() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: Responsive.fontSize(context, 14),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: _hideOverlay,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          '输入地名开始搜索...',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white54
                : AppColors.textSecondary,
            fontSize: Responsive.fontSize(context, 14),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.dividerDark
              : AppColors.divider,
        ),
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return _buildResultItem(result);
        },
      ),
    );
  }

  Widget _buildResultItem(SearchResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _onResultTap(result),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, AppSpacing.md),
          vertical: Responsive.spacing(context, AppSpacing.sm + 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: Responsive.iconSize(context, 20),
              color: AppColors.primary,
            ),
            SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result.displayName,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 15),
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.address != null) ...[
                    SizedBox(height: Responsive.spacing(context, 2)),
                    Text(
                      result.address!,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 12),
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (result.level.isNotEmpty)
              Container(
                margin: EdgeInsets.only(left: Responsive.spacing(context, AppSpacing.xs)),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, AppSpacing.xs + 2),
                  vertical: Responsive.spacing(context, 2),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  result.level,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 11),
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onSearchTextChanged,
                onSubmitted: (_) => _onSearch(),
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 15),
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: '搜索地名、地址...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : AppColors.textSecondary,
                    fontSize: Responsive.fontSize(context, 15),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: Responsive.iconSize(context, 22),
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: Responsive.iconSize(context, 20),
                          ),
                          onPressed: () {
                            _controller.clear();
                            _clearResults();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, AppSpacing.md),
                    vertical: Responsive.spacing(context, AppSpacing.sm + 4),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: Responsive.padding(context, AppSpacing.xs),
              ),
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: _onSearch,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.padding(context, AppSpacing.md),
                      vertical: Responsive.spacing(context, AppSpacing.sm + 2),
                    ),
                    child: Text(
                      '搜索',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: Responsive.fontSize(context, 14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
