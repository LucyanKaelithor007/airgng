import '../core/app_config.dart';
import '../data/mock_data.dart';
import '../models/detail_penginapan.dart';
import 'api_client.dart';

class PenginapanService {
  final ApiClient _api = ApiClient();

  /// GET /api/penginapan/:id  -> Detail Kamar
  Future<DetailPenginapan> getDetail(int id) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      final semua = MockData.jelajahi().seksi.expand((s) => s.items);
      final p = semua.firstWhere((e) => e.id == id, orElse: () => semua.first);
      return DetailPenginapan(
        penginapan: p,
        tipe: 'Rumah',
        deskripsi: 'Deskripsi contoh untuk ${p.judul}.',
        tuanRumah: 'Tuan rumah',
        jumlahUlasan: 100,
        kapasitasTamu: 4,
        galeri: [p.gambar],
        ulasan: [],
      );
    }
    final res = await _api.get('/penginapan/$id');
    return DetailPenginapan.fromJson(res['data'] as Map<String, dynamic>);
  }
}
