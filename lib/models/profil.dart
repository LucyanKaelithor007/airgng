import '../core/helpers.dart';

/// Data akun untuk halaman Profil (GET /api/profil)
class Profil {
  final int id;
  final String kontak;
  final String email;
  final String namaDepan;
  final String namaBelakang;
  final String tanggalLahir;

  Profil({
    required this.id,
    required this.kontak,
    required this.email,
    required this.namaDepan,
    required this.namaBelakang,
    required this.tanggalLahir,
  });

  String get namaLengkap => '$namaDepan $namaBelakang'.trim();

  /// Huruf awal untuk avatar bulat ("A" untuk Ardana)
  String get inisial => namaDepan.isEmpty ? '?' : namaDepan[0].toUpperCase();

  factory Profil.fromJson(Map<String, dynamic> json) => Profil(
        id: toInt(json['id']),
        kontak: (json['kontak'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        namaDepan: (json['nama_depan'] ?? '').toString(),
        namaBelakang: (json['nama_belakang'] ?? '').toString(),
        tanggalLahir: (json['tanggal_lahir'] ?? '').toString(),
      );
}
