import '../core/app_config.dart';
import '../models/profil.dart';
import 'api_client.dart';

class ProfilService {
  final ApiClient _api = ApiClient();

  /// GET /api/profil (wajib login)
  Future<Profil> getProfil() async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return Profil(
        id: 1,
        kontak: 'ardana@gmail.com',
        email: 'ardana@gmail.com',
        namaDepan: 'Ardana',
        namaBelakang: 'Wijaya',
        tanggalLahir: '2004-05-01',
      );
    }
    final res = await _api.get('/profil');
    return Profil.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// PUT /api/profil
  Future<Profil> updateProfil({
    required String namaDepan,
    String namaBelakang = '',
    String? email,
    String? tanggalLahir,
  }) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return Profil(
        id: 1,
        kontak: 'ardana@gmail.com',
        email: email ?? '',
        namaDepan: namaDepan,
        namaBelakang: namaBelakang,
        tanggalLahir: tanggalLahir ?? '',
      );
    }
    final res = await _api.put('/profil', body: {
      'nama_depan': namaDepan,
      'nama_belakang': namaBelakang,
      'email': email,
      'tanggal_lahir': tanggalLahir,
    });
    return Profil.fromJson(res['data'] as Map<String, dynamic>);
  }
}
