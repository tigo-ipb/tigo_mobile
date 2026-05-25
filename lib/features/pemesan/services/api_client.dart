import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

/// Exception khusus untuk error dari API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// HTTP Client terpusat yang otomatis menyisipkan token Authorization
class ApiClient {
  static const _storage = FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static Future<Map<String, String>> _buildHeaders({
    bool withAuth = true,
    bool isMultipart = false,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (withAuth) {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Map<String, dynamic> _parseBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (_) {
      return {};
    }
  }

  static void _checkSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final body = _parseBody(response);
    final message = body['message'] as String? ?? 'Terjadi kesalahan server.';
    throw ApiException(message, statusCode: response.statusCode);
  }

  // ---------------------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------------------

  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: AppConstants.userRoleKey, value: role);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: AppConstants.tokenKey);
  }

  static Future<String?> getRole() async {
    return _storage.read(key: AppConstants.userRoleKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userRoleKey);
  }

  // ---------------------------------------------------------------------------
  // HTTP Methods
  // ---------------------------------------------------------------------------

  /// GET request
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}$path',
    ).replace(queryParameters: queryParams);
    final headers = await _buildHeaders(withAuth: withAuth);

    try {
      final response = await http.get(uri, headers: headers);
      _checkSuccess(response);
      return _parseBody(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan: $e');
    }
  }

  /// POST request (JSON body)
  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final headers = await _buildHeaders(withAuth: withAuth);

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      _checkSuccess(response);
      return _parseBody(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan: $e');
    }
  }

  /// PUT request (JSON body)
  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final headers = await _buildHeaders(withAuth: withAuth);

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      _checkSuccess(response);
      return _parseBody(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan: $e');
    }
  }

  /// POST Multipart (untuk upload file/foto profil)
  static Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    File? file,
    String fileFieldName = 'profile_photo',
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final headers = await _buildHeaders(withAuth: withAuth, isMultipart: true);

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields.addAll(fields);

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _checkSuccess(response);
      return _parseBody(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan: $e');
    }
  }
}
