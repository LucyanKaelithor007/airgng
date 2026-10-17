import 'penginapan.dart';

/// Satu baris horizontal, mis. "Penginapan di Malang"
class SeksiPenginapan {
  final String judul;
  final List<Penginapan> items;
  SeksiPenginapan({required this.judul, required this.items});

  factory SeksiPenginapan.fromJson(Map<String, dynamic> json) => SeksiPenginapan(
        judul: (json['judul'] ?? '').toString(),
        items: ((json['items'] ?? []) as List)
            .map((e) => Penginapan.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Layanan {
  final String nama;
  final String gambar;
  Layanan({required this.nama, required this.gambar});

  factory Layanan.fromJson(Map<String, dynamic> json) => Layanan(
        nama: (json['nama'] ?? '').toString(),
        gambar: (json['gambar'] ?? '').toString(),
      );
}

class Destinasi {
  final String nama;
  final String deskripsi;
  final String gambar;
  Destinasi({required this.nama, required this.deskripsi, required this.gambar});

  factory Destinasi.fromJson(Map<String, dynamic> json) => Destinasi(
        nama: (json['nama'] ?? '').toString(),
        deskripsi: (json['deskripsi'] ?? '').toString(),
        gambar: (json['gambar'] ?? '').toString(),
      );
}

/// Seluruh data yang dibutuhkan halaman Jelajahi dalam satu response.
class JelajahiData {
  final List<SeksiPenginapan> seksi;
  final List<Layanan> layanan;
  final List<Destinasi> destinasi;

  JelajahiData({
    required this.seksi,
    required this.layanan,
    required this.destinasi,
  });

  factory JelajahiData.fromJson(Map<String, dynamic> json) => JelajahiData(
        seksi: ((json['seksi'] ?? []) as List)
            .map((e) => SeksiPenginapan.fromJson(e as Map<String, dynamic>))
            .toList(),
        layanan: ((json['layanan'] ?? []) as List)
            .map((e) => Layanan.fromJson(e as Map<String, dynamic>))
            .toList(),
        destinasi: ((json['destinasi'] ?? []) as List)
            .map((e) => Destinasi.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
