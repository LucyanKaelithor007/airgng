import '../core/helpers.dart';

/// Model satu penginapan/kamar.
/// Nama key JSON dibuat snake_case agar sama dengan nama kolom MySQL.
class Penginapan {
  final int id;
  final String judul;
  final String lokasi;
  final int hargaPerMalam;
  final double rating;
  final bool pilihanTamu;

  /// Path asset ("assets/images/x.jpg"), URL penuh, atau nama file dari backend.
  final String gambar;
  bool isFavorit;

  Penginapan({
    required this.id,
    required this.judul,
    required this.lokasi,
    required this.hargaPerMalam,
    required this.rating,
    required this.gambar,
    this.pilihanTamu = false,
    this.isFavorit = false,
  });

  int hargaUntukMalam(int malam) => hargaPerMalam * malam;

  factory Penginapan.fromJson(Map<String, dynamic> json) => Penginapan(
        id: toInt(json['id']),
        judul: (json['judul'] ?? '').toString(),
        lokasi: (json['lokasi'] ?? '').toString(),
        hargaPerMalam: toInt(json['harga_per_malam']),
        rating: toDouble(json['rating']),
        pilihanTamu: toBool(json['pilihan_tamu']),
        gambar: (json['gambar'] ?? '').toString(),
        isFavorit: toBool(json['is_favorit']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'judul': judul,
        'lokasi': lokasi,
        'harga_per_malam': hargaPerMalam,
        'rating': rating,
        'pilihan_tamu': pilihanTamu,
        'gambar': gambar,
        'is_favorit': isFavorit,
      };
}
