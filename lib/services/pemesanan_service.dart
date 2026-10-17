import '../core/app_config.dart';
import '../models/pemesanan.dart';
import 'api_client.dart';

class PemesananService {
  final ApiClient _api = ApiClient();

  /// POST /api/pemesanan  (wajib login)
  /// Tanggal harus berformat "YYYY-MM-DD". Total dihitung oleh server.
  Future<HasilPemesanan> buat({
    required int penginapanId,
    required String tanggalMasuk,
    required String tanggalKeluar,
    required int jumlahTamu,
    required String metodePembayaran,
    String waktuPembayaran = 'sekarang', // 'sekarang' atau 'nanti'
  }) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      final malam = DateTime.parse(tanggalKeluar).difference(DateTime.parse(tanggalMasuk)).inDays;
      return HasilPemesanan(kode: 'AIR-MOCK01', jumlahMalam: malam, total: 0, status: 'dikonfirmasi');
    }
    final res = await _api.post('/pemesanan', body: {
      'penginapan_id': penginapanId,
      'tanggal_masuk': tanggalMasuk,
      'tanggal_keluar': tanggalKeluar,
      'jumlah_tamu': jumlahTamu,
      'metode_pembayaran': metodePembayaran,
      'waktu_pembayaran': waktuPembayaran,
    });
    return HasilPemesanan.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// GET /api/pemesanan -> riwayat (halaman Perjalanan)
  Future<List<Pemesanan>> getRiwayat() async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return [];
    }
    final res = await _api.get('/pemesanan');
    return ((res['data'] ?? []) as List)
        .map((e) => Pemesanan.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
