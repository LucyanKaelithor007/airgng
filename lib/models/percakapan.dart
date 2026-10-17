import '../core/helpers.dart';

/// Satu percakapan dengan tuan rumah di halaman Pesan.
class Percakapan {
  final int id;
  final String namaTuanRumah;
  final String pesanTerakhir;
  final String waktu; // sudah diformat dari backend, mis. "12 Okt"
  final String foto;
  final bool belumDibaca;

  Percakapan({
    required this.id,
    required this.namaTuanRumah,
    required this.pesanTerakhir,
    required this.waktu,
    this.foto = '',
    this.belumDibaca = false,
  });

  factory Percakapan.fromJson(Map<String, dynamic> json) => Percakapan(
        id: toInt(json['id']),
        namaTuanRumah: (json['nama_tuan_rumah'] ?? '').toString(),
        pesanTerakhir: (json['pesan_terakhir'] ?? '').toString(),
        waktu: (json['waktu'] ?? '').toString(),
        foto: (json['foto'] ?? '').toString(),
        belumDibaca: toBool(json['belum_dibaca']),
      );
}
