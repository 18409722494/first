import 'package:http/http.dart' as http;

/// Web / 无 dart:io 时使用 package:http（若遇验签问题需在后端或 Web 策略上对齐）。
Future<http.Response> ossPresignedPut(String signedUrl, List<int> body) {
  return http.put(
    Uri.parse(signedUrl),
    body: body,
    headers: const {'Content-Type': 'image/jpeg'},
  );
}
