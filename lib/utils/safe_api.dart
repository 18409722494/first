import 'package:flutter/foundation.dart';

/// 统一 API 调用封装
/// - 自动解析 HTTP 错误
/// - 支持空值降级
/// - 统一错误消息格式
///
/// 使用示例：
/// ```dart
/// // 标准用法：异常时返回 null
/// final result = await safeApiCall(
///   () => api.getData(),
/// );
/// if (result == null) return;
///
/// // 异常时返回默认值
/// final result = await safeApiCall(
///   () => api.getData(),
///   fallback: [],
/// );
///
/// // 不降级，直接抛出
/// final result = await safeApiCall(
///   () => api.getData(),
///   rethrow: true,
/// );
/// ```
Future<T?> safeApiCall<T>(
  Future<T> Function() apiCall, {
  T? fallback,
  bool propagate = false,
  String? errorLabel,
}) async {
  try {
    return await apiCall();
  } catch (e) {
    if (propagate) rethrow;
    debugPrint('[safeApiCall${errorLabel != null ? ' [$errorLabel]' : ''}] $e');
    return fallback;
  }
}

/// 同步版本
T? safeCall<T>(
  T Function() block, {
  T? fallback,
  bool propagate = false,
}) {
  try {
    return block();
  } catch (e) {
    if (propagate) rethrow;
    return fallback;
  }
}

/// HTTP 响应解析辅助
///
/// 解析常见的 API 响应格式：
/// - `{"data": [...]}` → List
/// - `{"data": {...}}` → Map
/// - `[...]` → List
/// - `{...}` → Map
///
/// 解析失败时返回空集合或 null。
T? parseApiResponse<T>(dynamic responseBody, T Function(dynamic) converter) {
  try {
    if (responseBody == null) return null;
    return converter(responseBody);
  } catch (_) {
    return null;
  }
}

/// 从 HTTP 响应体解析 List
List<T> parseApiList<T>(dynamic responseBody, T Function(Map<String, dynamic>) fromJson) {
  try {
    if (responseBody == null) return [];
    if (responseBody is List) {
      return responseBody
          .whereType<Map>()
          .map((m) => fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    if (responseBody is Map && responseBody['data'] is List) {
      return parseApiList(responseBody['data'], fromJson);
    }
    return [];
  } catch (_) {
    return [];
  }
}

/// 从 HTTP 响应体解析 Map
Map<String, dynamic>? parseApiMap(dynamic responseBody) {
  try {
    if (responseBody is Map<String, dynamic>) return responseBody;
    if (responseBody is Map) return Map<String, dynamic>.from(responseBody);
    return null;
  } catch (_) {
    return null;
  }
}
