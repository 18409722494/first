import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// 使用 [HttpClient] 仅发送 Content-Type + Content-Length，
/// 避免 `package:http` 附带额外头导致与 OSS 预签名 StringToSign 不一致。
Future<http.Response> ossPresignedPut(String signedUrl, List<int> body) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(signedUrl);
    final req = await client.openUrl('PUT', uri);
    req.headers
      ..set(HttpHeaders.contentTypeHeader, 'image/jpeg')
      ..contentLength = body.length;
    req.add(body);
    final resp = await req.close();
    final text = await resp.transform(utf8.decoder).join();
    return http.Response(text, resp.statusCode);
  } finally {
    client.close(force: true);
  }
}
