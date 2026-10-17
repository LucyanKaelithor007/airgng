import '../models/jelajahi_data.dart';
import '../models/penginapan.dart';
import '../models/percakapan.dart';

/// Data dummy sementara sebelum backend siap.
/// Taruh gambar milik kalian di assets/images/ dengan nama file di bawah ini
/// (atau ganti nama file di sini sesuai gambar kalian).
class MockData {
  static const String namaProfilDemo = 'Ardana';

  static String _img(String nama) => 'assets/images/$nama';

  static JelajahiData jelajahi() => JelajahiData(
    seksi: [
      SeksiPenginapan(
        judul: 'Penginapan di Malang',
        items: [
          Penginapan(
            id: 1,
            judul: 'Guesthouse di Malang City',
            lokasi: 'Malang',
            hargaPerMalam: 1284341,
            rating: 4.95,
            pilihanTamu: true,
            gambar: _img('penginapan_1.jpg'),
          ),
          Penginapan(
            id: 2,
            judul: 'Rumah di Lowokwaru',
            lokasi: 'Malang',
            hargaPerMalam: 1185624,
            rating: 5.0,
            pilihanTamu: true,
            gambar: _img('penginapan_2.jpg'),
          ),
        ],
      ),
      SeksiPenginapan(
        judul: 'Penginapan populer di Batu',
        items: [
          Penginapan(
            id: 3,
            judul: 'Rumah di Batu',
            lokasi: 'Batu',
            hargaPerMalam: 1800000,
            rating: 4.96,
            pilihanTamu: true,
            gambar: _img('penginapan_3.jpg'),
          ),
          Penginapan(
            id: 4,
            judul: 'Vila di Batu',
            lokasi: 'Batu',
            hargaPerMalam: 720000,
            rating: 4.97,
            pilihanTamu: true,
            gambar: _img('penginapan_4.jpg'),
          ),
        ],
      ),
      SeksiPenginapan(
        judul: 'Penginapan populer di Yogyakarta',
        items: [
          Penginapan(
            id: 5,
            judul: 'Rumah di Kecamatan Depok',
            lokasi: 'Yogyakarta',
            hargaPerMalam: 1751374,
            rating: 4.82,
            pilihanTamu: true,
            gambar: _img('penginapan_5.jpg'),
          ),
          Penginapan(
            id: 6,
            judul: 'Rumah di Wirobrajan',
            lokasi: 'Yogyakarta',
            hargaPerMalam: 922099,
            rating: 4.94,
            pilihanTamu: true,
            gambar: _img('penginapan_6.jpg'),
          ),
        ],
      ),
      SeksiPenginapan(
        judul: 'Penginapan populer di Surakarta',
        items: [
          Penginapan(
            id: 7,
            judul: 'Rumah di Banjarsari',
            lokasi: 'Surakarta',
            hargaPerMalam: 1389600,
            rating: 5.0,
            pilihanTamu: true,
            gambar: _img('penginapan_7.jpg'),
          ),
          Penginapan(
            id: 8,
            judul: 'Vila di Banjarsari',
            lokasi: 'Surakarta',
            hargaPerMalam: 1220000,
            rating: 4.97,
            pilihanTamu: true,
            gambar: _img('penginapan_8.jpg'),
          ),
        ],
      ),
    ],
    layanan: [
      Layanan(nama: 'Chef', gambar: _img('layanan_chef.jpg')),
      Layanan(nama: 'Pijat', gambar: _img('layanan_pijat.jpg')),
      Layanan(nama: 'Spa', gambar: _img('layanan_spa.jpg')),
    ],
    destinasi: [
      Destinasi(
        nama: 'Bangkok',
        deskripsi: 'Hiburan malam semarak',
        gambar: _img('destinasi_bangkok.jpg'),
      ),
      Destinasi(
        nama: 'Tokyo',
        deskripsi: 'Arsitektur memukau',
        gambar: _img('destinasi_tokyo.jpg'),
      ),
      Destinasi(
        nama: 'Kuala Lumpur',
        deskripsi: 'Untuk Menara Petronas',
        gambar: _img('destinasi_kualalumpur.jpg'),
      ),
    ],
  );

  /// Kosong = tampil seperti di aplikasi asli (belum ada percakapan).
  /// Isi list ini kalau ingin mencoba tampilan daftar percakapan.
  static List<Percakapan> percakapan() => [];
}
