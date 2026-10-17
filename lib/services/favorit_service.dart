import 'package:flutter/foundation.dart';

import '../core/app_config.dart';
import '../data/mock_data.dart';
import '../models/penginapan.dart';
import 'api_client.dart';

/// Dipakai bersama oleh Jelajahi, Detail Kamar, dan Favorit.
/// File ini MENIMPA favorit_service.dart lama. Sudah mencakup semua yang
/// dipakai favorit.dart: perubahan, catatTerakhirDilihat, terakhirDilihat.
class FavoritService {
  final ApiClient _api = ApiClient();

  /// Naik 1 setiap kali favorit berubah (tambah/hapus).
  /// Halaman Favorit mendengarkan ini untuk memuat ulang daftar.
  static final ValueNotifier<int> perubahan = ValueNotifier<int>(0);

  /// Penyimpanan sementara (hanya selama aplikasi berjalan)
  static final Set<int> _mockFavorit = {}; // dipakai saat useMock = true
  static final List<Penginapan> _terakhirDilihat = [];

  /// Daftar penginapan yang baru dibuka, terbaru di atas (maks. 20)
  List<Penginapan> get terakhirDilihat => List.unmodifiable(_terakhirDilihat);

  void catatTerakhirDilihat(Penginapan item) {
    _terakhirDilihat.removeWhere((p) => p.id == item.id);
    _terakhirDilihat.insert(0, item);
    if (_terakhirDilihat.length > 20) _terakhirDilihat.removeLast();
  }

  /// jadiFavorit=true  -> POST   /api/favorit  { "penginapan_id": 1 }
  /// jadiFavorit=false -> DELETE /api/favorit/1
  Future<void> setFavorit(int penginapanId, bool jadiFavorit) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (jadiFavorit) {
        _mockFavorit.add(penginapanId);
      } else {
        _mockFavorit.remove(penginapanId);
      }
    } else if (jadiFavorit) {
      await _api.post('/favorit', body: {'penginapan_id': penginapanId});
    } else {
      await _api.delete('/favorit/$penginapanId');
    }
    perubahan.value++; // beri tahu halaman Favorit
  }

  /// GET /api/favorit -> daftar favorit pengguna (butuh login)
  Future<List<Penginapan>> getFavorit() async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final semua = MockData.jelajahi().seksi.expand((s) => s.items);
      return semua.where((p) => _mockFavorit.contains(p.id)).map((p) {
        p.isFavorit = true;
        return p;
      }).toList();
    }
    final res = await _api.get('/favorit');
    return ((res['data'] ?? []) as List)
        .map((e) => Penginapan.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}