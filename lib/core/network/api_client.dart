import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(
    this.statusCode,
    this.errorCode,
    this.message,
    this.details,
  );

  final int statusCode;
  final String errorCode;
  final String message;
  final Map<String, dynamic> details;

  @override
  String toString() => 'ApiException($statusCode $errorCode): $message';
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required FirebaseAuth firebaseAuth,
    required http.Client client,
    required String languageCode,
  }) : _firebaseAuth = firebaseAuth,
       _client = client,
       _languageCode = languageCode;

  final String baseUrl;
  final FirebaseAuth _firebaseAuth;
  final http.Client _client;
  final String _languageCode;

  Future<dynamic> getJson(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _client.get(
        _uri(path, query: query),
        headers: await _headers(json: false),
      );
      return _ok(response);
    } on http.ClientException catch (error) {
      _throwTransport(error);
    }
  }

  Future<dynamic> postJson(String path, {Object? body}) async {
    try {
      final response = await _client.post(
        _uri(path),
        headers: await _headers(),
        body: body == null ? null : jsonEncode(body),
      );
      return _ok(response);
    } on http.ClientException catch (error) {
      _throwTransport(error);
    }
  }

  Future<dynamic> deleteJson(String path) async {
    try {
      final response = await _client.delete(
        _uri(path),
        headers: await _headers(json: false),
      );
      return _ok(response);
    } on http.ClientException catch (error) {
      _throwTransport(error);
    }
  }

  Future<Map<String, dynamic>> multipartUpload({
    required String path,
    required List<int> bytes,
    required String filename,
    required Map<String, String> fields,
    String fileField = 'file',
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(await _headers(json: false))
        ..fields.addAll(fields)
        ..files.add(
          http.MultipartFile.fromBytes(fileField, bytes, filename: filename),
        );

      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      final body = _ok(response);
      if (body is Map<String, dynamic>) return body;
      throw ApiException(
        response.statusCode,
        'INVALID_RESPONSE',
        'Unexpected response from server.',
        {},
      );
    } on http.ClientException catch (error) {
      _throwTransport(error);
    }
  }

  Future<Uint8List> getBytes(String path) async {
    try {
      final response = await _client.get(
        _uri(path),
        headers: await _headers(json: false),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      _throw(response);
    } on http.ClientException catch (error) {
      _throwTransport(error);
    }
  }

  Uri _uri(String path, {Map<String, dynamic>? query}) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath').replace(
      queryParameters:
          query
              ?.map((key, value) => MapEntry(key, value?.toString()))
              .cast<String, String?>()
            ?..removeWhere((_, value) => value == null),
    );
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _firebaseAuth.currentUser?.getIdToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        401,
        'UNAUTHORIZED',
        'You need to sign in again.',
        {},
      );
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Accept-Language': _languageCode,
      if (json) 'Content-Type': 'application/json',
    };
  }

  dynamic _ok(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    _throw(response);
  }

  Never _throw(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {
      body = {};
    }

    throw ApiException(
      response.statusCode,
      body['error_code']?.toString() ?? 'HTTP_${response.statusCode}',
      body['message']?.toString() ?? response.reasonPhrase ?? 'Request failed.',
      (body['details'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  Never _throwTransport(http.ClientException error) {
    final uri = error.uri?.toString() ?? baseUrl;
    throw ApiException(
      0,
      'NETWORK_ERROR',
      'Could not reach the Doctors for Madagascar backend. On Flutter web, run the app on '
          'http://localhost:3000 or http://localhost:8080, or add the current '
          'origin to the backend CORS allowlist.',
      {'uri': uri, 'cause': error.message},
    );
  }
}
