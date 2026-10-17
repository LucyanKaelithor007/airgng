import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Client HTTP tunggal untuk seluruh aplikasi (singleton).
/// Semua service (JelajahiService, PesanService, dst.) memakai ini,
/// jadi header, token, timeout, dan error handling cukup diatur di sini.
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  /// Token login (JWT dari backend). Memakai ValueNotifier agar halaman seperti
  /// Profil bisa otomatis memuat ulang saat pengguna login atau keluar.
  /// Cara pakai tidak berubah: ApiClient().token = '...'  /  ApiClient().token = null
  final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);
  String? get token => tokenNotifier.value;
  set token(String? value) => tokenNotifier.value = value;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  Future<dynamic> get(String path) =>
      _send(() => http.get(_uri(path), headers: _headers));

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) => _send(
      () => http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) => _send(
      () => http.put(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> delete(String path) =>
      _send(() => http.delete(_uri(path), headers: _headers));

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final res = await request().timeout(AppConfig.timeout);
      final decoded =
          res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));

      if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

      final msg = (decoded is Map && decoded['message'] != null)
          ? decoded['message'].toString()
          : 'Terjadi kesalahan (${res.statusCode})';
      throw ApiException(msg, statusCode: res.statusCode);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Periksa jaringan atau server.');
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }
}