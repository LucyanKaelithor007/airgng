import '../core/helpers.dart';
import 'penginapan.dart';

class Ulasan {
  final String namaPengulas;
  final int rating;
  final String komentar;
  final String tanggal; // "YYYY-MM-DD"

  Ulasan({
    required this.namaPengulas,
    required this.rating,
    required this.komentar,
    required this.tanggal,
  });

  factory Ulasan.fromJson(Map<String, dynamic> json) => Ulasan(
        namaPengulas: (json['nama_pengulas'] ?? '').toString(),
        rating: toInt(json['rating']),
        komentar: (json['komentar'] ?? '').toString(),
        tanggal: (json['tanggal'] ?? '').toString(),
      );
}

/// Data lengkap untuk halaman Detail Kamar (GET /api/penginapan/:id)
class DetailPenginapan {
  final Penginapan penginapan; // data dasar (judul, harga, rating, is_favorit, ...)
  final String tipe;
  final String deskripsi;
  final String tuanRumah;
  final int jumlahUlasan;
  final int kapasitasTamu;
  final List<String> galeri; // nama file / path gambar, tampilkan dengan AppImage
  final List<Ulasan> ulasan;

  DetailPenginapan({
    required this.penginapan,
    required this.tipe,
    required this.deskripsi,
    required this.tuanRumah,
    required this.jumlahUlasan,
    required this.kapasitasTamu,
    required this.galeri,
    required this.ulasan,
  });

  factory DetailPenginapan.fromJson(Map<String, dynamic> json) {
    final galeri = ((json['galeri'] ?? []) as List).map((e) => e.toString()).toList();
    final dasar = Penginapan.fromJson(json);
    return DetailPenginapan(
      penginapan: dasar,
      tipe: (json['tipe'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      tuanRumah: (json['tuan_rumah'] ?? '').toString(),
      jumlahUlasan: toInt(json['jumlah_ulasan']),
      kapasitasTamu: toInt(json['kapasitas_tamu'], 4),
      galeri: galeri.isEmpty ? [dasar.gambar] : galeri,
      ulasan: ((json['ulasan'] ?? []) as List)
          .map((e) => Ulasan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
