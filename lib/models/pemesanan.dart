import '../core/helpers.dart';
import 'penginapan.dart';

/// Satu baris riwayat pemesanan (GET /api/pemesanan) -> halaman Perjalanan
class Pemesanan {
  final int id;
  final String kode;
  final String tanggalMasuk; // "YYYY-MM-DD"
  final String tanggalKeluar;
  final int jumlahMalam;
  final int jumlahTamu;
  final int total;
  final String metodePembayaran;
  final String waktuPembayaran;
  final String status;
  final int penginapanId;
  final String judul;
  final String lokasi;
  final String gambar;

  Pemesanan({
    required this.id,
    required this.kode,
    required this.tanggalMasuk,
    required this.tanggalKeluar,
    required this.jumlahMalam,
    required this.jumlahTamu,
    required this.total,
    required this.metodePembayaran,
    required this.waktuPembayaran,
    required this.status,
    required this.penginapanId,
    required this.judul,
    required this.lokasi,
    required this.gambar,
  });

  factory Pemesanan.fromJson(Map<String, dynamic> json) => Pemesanan(
        id: toInt(json['id']),
        kode: (json['kode_pemesanan'] ?? '').toString(),
        tanggalMasuk: (json['tanggal_masuk'] ?? '').toString(),
        tanggalKeluar: (json['tanggal_keluar'] ?? '').toString(),
        jumlahMalam: toInt(json['jumlah_malam']),
        jumlahTamu: toInt(json['jumlah_tamu'], 1),
        total: toInt(json['total']),
        metodePembayaran: (json['metode_pembayaran'] ?? '').toString(),
        waktuPembayaran: (json['waktu_pembayaran'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        penginapanId: toInt(json['penginapan_id']),
        judul: (json['judul'] ?? '').toString(),
        lokasi: (json['lokasi'] ?? '').toString(),
        gambar: (json['gambar'] ?? '').toString(),
      );

  /// Objek Penginapan ringan, untuk membuka Detail Kamar dari riwayat.
  /// Detail Kamar tetap mengambil data lengkap lewat id.
  Penginapan get penginapan => Penginapan(
        id: penginapanId,
        judul: judul,
        lokasi: lokasi,
        hargaPerMalam: jumlahMalam > 0 ? total ~/ jumlahMalam : 0,
        rating: 0,
        gambar: gambar,
      );
}

/// Hasil POST /api/pemesanan
class HasilPemesanan {
  final String kode;
  final int jumlahMalam;
  final int total;
  final String status;

  HasilPemesanan({
    required this.kode,
    required this.jumlahMalam,
    required this.total,
    required this.status,
  });

  factory HasilPemesanan.fromJson(Map<String, dynamic> json) => HasilPemesanan(
        kode: (json['kode_pemesanan'] ?? '').toString(),
        jumlahMalam: toInt(json['jumlah_malam']),
        total: toInt(json['total']),
        status: (json['status'] ?? '').toString(),
      );
}
