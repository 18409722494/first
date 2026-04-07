import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/abnormal_baggage.dart';
import '../constants/app_constants.dart';

/// 业务接口返回的详细信息（含 HTTP 状态码和响应体）
class ApiResponse {
  final bool isSuccess;
  final int statusCode;
  final String body;
  const ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    required this.body,
  });
}

/// 证据/破损行李查询服务
class EvidenceService {
  static const Duration _timeout = Duration(seconds: 15);
  static String get _baseUrl => AppConstants.apiBaseUrl;

  /// 查询所有破损行李记录
  /// GET /abnormal-baggage/all
  static Future<List<AbnormalBaggage>> getAllAbnormalBaggage() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/abnormal-baggage/all'))
          .timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => AbnormalBaggage.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('获取数据失败（${response.statusCode}）');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 上传破损行李报告（布尔版，保留兼容性）
  /// POST /abnormal-baggage/upload
  static Future<bool> uploadAbnormalBaggage({
    required String baggageNumber,
    required String timestamp,
    required String location,
    required String imageUrl,
    required String damageDescription,
    required String baggageHash,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/abnormal-baggage/upload'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'baggageNumber': baggageNumber.trim(),
              'timestamp': timestamp,
              'location': location.trim(),
              'imageUrl': imageUrl,
              'damageDescription': damageDescription.trim(),
              'baggageHash': baggageHash,
            }),
          )
          .timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// 上传破损行李报告（含详细返回，用于调试）
  /// POST /abnormal-baggage/upload
  static Future<ApiResponse> uploadAbnormalBaggageDetailed({
    required String baggageNumber,
    required String timestamp,
    required String location,
    required String imageUrl,
    required String damageDescription,
    required String baggageHash,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/abnormal-baggage/upload'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'baggageNumber': baggageNumber.trim(),
              'timestamp': timestamp,
              'location': location.trim(),
              'imageUrl': imageUrl,
              'damageDescription': damageDescription.trim(),
              'baggageHash': baggageHash,
            }),
          )
          .timeout(_timeout, onTimeout: () => throw Exception('请求超时'));

      final isOk = response.statusCode >= 200 && response.statusCode < 300;
      return ApiResponse(
        isSuccess: isOk,
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (e) {
      // 网络 / 超时异常：statusCode = 0 表示无法到达服务器
      return ApiResponse(
        isSuccess: false,
        statusCode: 0,
        body: e.toString(),
      );
    }
  }

  /// 根据行李号筛选
  static Future<List<AbnormalBaggage>> getByBaggageNumber(String baggageNumber) async {
    final all = await getAllAbnormalBaggage();
    return all.where((item) =>
        item.baggageNumber.toLowerCase().contains(baggageNumber.toLowerCase())).toList();
  }

  /// 根据日期范围筛选
  static Future<List<AbnormalBaggage>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final all = await getAllAbnormalBaggage();
    return all.where((item) =>
        item.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
        item.timestamp.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  /// 根据行李号和日期范围筛选
  static Future<List<AbnormalBaggage>> search({
    String? baggageNumber,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<AbnormalBaggage> result = await getAllAbnormalBaggage();

    if (baggageNumber != null && baggageNumber.trim().isNotEmpty) {
      result = result.where((item) =>
          item.baggageNumber.toLowerCase().contains(baggageNumber.toLowerCase())).toList();
    }

    if (startDate != null) {
      result = result.where((item) =>
          item.timestamp.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
    }

    if (endDate != null) {
      result = result.where((item) =>
          item.timestamp.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }

    // 按时间倒序
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result;
  }

  /// 验证证据哈希（新增）
  /// GET /abnormal-baggage/verify
  /// [expectedHash] 提交时计算的哈希值
  /// 返回 { "verified": bool, "matches": bool }
  static Future<HashVerifyResult> verifyEvidenceHash(String expectedHash) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/abnormal-baggage/verify?baggageHash=$expectedHash'),
          )
          .timeout(_timeout, onTimeout: () => throw Exception('验证请求超时'));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final map =
            decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
        final data = map['data'];
        final inner = data is Map<String, dynamic> ? data : map;

        // 仅当后端显式声明「已做校验」时，matches 才有意义；否则勿与 upload 成功对立
        final explicitVerified = inner['verified'] == true ||
            inner['verified'] == 'true' ||
            inner['hashVerified'] == true;

        final matches = inner['matches'] == true ||
            inner['matches'] == 'true' ||
            inner['hashValid'] == true ||
            inner['hashValid'] == 'true' ||
            inner['valid'] == true ||
            inner['valid'] == 'true';

        final message =
            inner['message']?.toString() ?? map['message']?.toString();

        if (explicitVerified) {
          return HashVerifyResult(
            verified: true,
            matches: matches,
            message: message,
          );
        }

        // 200 但无 verified 语义（例如仅 { result: success }）：不当作校验失败
        return HashVerifyResult(
          verified: false,
          matches: false,
          message: message ?? '响应中无 verified 字段，跳过客户端二次强校验',
          backendUnavailable: true,
        );
      }

      // 后端不支持验证接口（4xx/5xx），降级为"未验证"
      return HashVerifyResult(
        verified: false,
        matches: false,
        message: '后端不支持哈希验证（HTTP ${response.statusCode}）',
        backendUnavailable: true,
      );
    } catch (e) {
      return HashVerifyResult(
        verified: false,
        matches: false,
        message: '哈希验证失败: $e',
        backendUnavailable: true,
      );
    }
  }
}

/// 哈希验证结果
class HashVerifyResult {
  /// 后端是否执行了验证
  final bool verified;
  /// 哈希是否匹配（仅 verified=true 时有意义）
  final bool matches;
  final String? message;
  /// 后端是否不可用（降级场景）
  final bool backendUnavailable;

  const HashVerifyResult({
    required this.verified,
    required this.matches,
    this.message,
    this.backendUnavailable = false,
  });
}
