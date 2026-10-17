import '../core/app_config.dart';
import '../core/helpers.dart';
import 'api_client.dart';
import '../models/auth_model.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  // Daftar kontak yang sudah "terdaftar" selama aplikasi berjalan (khusus mode mock)
  static final Set<String> _mockKontak = {};

  /// POST /api/auth/cek-kontak -> true bila kontak sudah punya akun
  Future<bool> kontakTerdaftar(String kontak) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockKontak.contains(kontak);
    }
    final response = await _client.post('/auth/cek-kontak', body: {'kontak': kontak});
    return response['data']['terdaftar'] == true;
  }

  Future<UserAuth> loginOrRegister({
    required String kontak,
    String? namaDepan,
    String? namaBelakang,
    String? tanggalLahir,
    String? email,
  }) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      _mockKontak.add(kontak);
      return UserAuth(
        id: 1,
        email: kontak.contains('@') ? kontak : '$kontak@airgng.com',
        namaDepan: namaDepan ?? 'Ardana',
        namaBelakang: namaBelakang ?? 'Wijaya',
        token: 'mock_jwt_token_airgng_12345',
      );
    }

    // POST /api/auth/login-atau-daftar
    final response = await _client.post('/auth/login-atau-daftar', body: {
      'kontak': kontak,
      if (namaDepan != null) 'nama_depan': namaDepan,
      if (namaBelakang != null) 'nama_belakang': namaBelakang,
      if (tanggalLahir != null) 'tanggal_lahir': tanggalLahir, // YYYY-MM-DD
      if (email != null) 'email': email,
    });

    // Bentuk response backend:
    // { "data": { "token": "...", "baru": true, "pengguna": { id, kontak, email, nama_depan, ... } } }
    final data = response['data'] as Map<String, dynamic>;
    final p = data['pengguna'] as Map<String, dynamic>;
    final token = data['token'] as String;

    // Wajib: token dipakai ApiClient untuk favorit, pemesanan, profil, dst.
    _client.token = token;

    return UserAuth(
      id: toInt(p['id']),
      email: (p['email'] ?? p['kontak']).toString(),
      namaDepan: (p['nama_depan'] ?? '').toString(),
      namaBelakang: (p['nama_belakang'] ?? '').toString(),
      token: token,
    );
  }
}