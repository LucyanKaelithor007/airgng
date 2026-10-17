import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../core/helpers.dart';
import '../models/penginapan.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../services/favorit_service.dart';
import '../widgets/app_image.dart';

class DetailKamarScreen extends StatefulWidget {
  /// Opsional. Kalau null, argumen diambil dari
  /// Navigator.pushNamed(..., arguments: penginapan).
  final Penginapan? penginapan;

  const DetailKamarScreen({super.key, this.penginapan});

  @override
  State<DetailKamarScreen> createState() => _DetailKamarScreenState();
}

class _DetailKamarScreenState extends State<DetailKamarScreen> {
  static const int _malam = 2;

  final _service = DetailKamarService();
  final _pageController = PageController();

  Penginapan? _penginapan;
  DetailKamar? _detail;
  bool _loading = true;
  String? _error;
  bool _favorit = false;
  int _halaman = 0;
  bool _siap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_siap) return;
    _siap = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    _penginapan = widget.penginapan ?? (arg is Penginapan ? arg : null);
    _muat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    final p = _penginapan;
    if (p == null) {
      setState(() {
        _loading = false;
        _error = 'Kamar tidak ditemukan.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await _service.getDetail(p);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _favorit = d.isFavorit;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _toggleFavorit() async {
    final d = _detail;
    if (d == null) return;
    final baru = !_favorit;
    setState(() => _favorit = baru);
    _penginapan?.isFavorit = baru;
    try {
      await FavoritService().setFavorit(d.id, baru);
    } catch (e) {
      if (!mounted) return;
      setState(() => _favorit = !baru);
      _penginapan?.isFavorit = !baru;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui favorit. Coba lagi.')),
      );
    }
  }

  void _pesan() {
    final p = _penginapan;
    if (p == null) return;
    Navigator.pushNamed(context, AppRoutes.pemesananKamar, arguments: p);
  }

  String _rentangTanggal() {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final a = DateTime.now().add(const Duration(days: 7));
    final b = a.add(const Duration(days: _malam));
    if (a.month == b.month) {
      return '${a.day}–${b.day} ${bulan[a.month - 1]}';
    }
    return '${a.day} ${bulan[a.month - 1]}–${b.day} ${bulan[b.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final d = _detail;
    if (_error != null || d == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.text),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error ?? 'Terjadi kesalahan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _muat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _galeri(d),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(d),
                const SizedBox(height: 20),
                const Divider(color: AppColors.border, height: 1),
                _host(d),
                if (d.sorotan.isNotEmpty) ...[
                  const Divider(color: AppColors.border, height: 1),
                  ...d.sorotan.map(_sorotanItem),
                ],
                const Divider(color: AppColors.border, height: 1),
                if (d.pilihanTamu) _ratingBesar(d),
                _ulasanJudul(d),
              ],
            ),
          ),
          _ulasanList(d),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _barBawah(d),
    );
  }

  // ---------- Galeri ----------

  Widget _galeri(DetailKamar d) {
    final atas = MediaQuery.of(context).padding.top;
    final total = d.galeri.isEmpty ? 1 : d.galeri.length;

    return SizedBox(
      height: 324,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              itemCount: total,
              onPageChanged: (i) => setState(() => _halaman = i),
              itemBuilder: (_, i) =>
                  AppImage(d.galeri.isEmpty ? '' : d.galeri[i]),
            ),
          ),
          // Sudut atas melengkung untuk bagian putih di bawah foto
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 24,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_halaman + 1}/$total',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          Positioned(
            top: atas + 8,
            left: 16,
            child: _tombolBulat(
              Icons.arrow_back,
              () => Navigator.maybePop(context),
            ),
          ),
          Positioned(
            top: atas + 8,
            right: 16,
            child: Row(
              children: [
                _tombolBulat(Icons.ios_share, () {}),
                const SizedBox(width: 8),
                _tombolBulat(
                  _favorit ? Icons.favorite : Icons.favorite_border,
                  _toggleFavorit,
                  warna: _favorit ? AppColors.primary : AppColors.text,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tombolBulat(IconData ikon, VoidCallback onTap, {Color? warna}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(ikon, size: 18, color: warna ?? AppColors.text),
        ),
      ),
    );
  }

  // ---------- Header ----------

  Widget _header(DetailKamar d) {
    return Column(
      children: [
        Text(
          d.judul,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          d.tipe,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
        Text(
          d.kapasitas,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statRating(d),
            if (d.pilihanTamu) _statPilihanTamu(),
            _statUlasan(d),
          ],
        ),
        if (d.pembatalanGratis) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Pembatalan gratis',
              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statRating(DetailKamar d) {
    return Column(
      children: [
        Text(
          formatRating(d.rating),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: List.generate(
            5,
            (_) => const Icon(Icons.star, size: 10, color: AppColors.text),
          ),
        ),
      ],
    );
  }

  Widget _statPilihanTamu() {
    return const Row(
      children: [
        Icon(Icons.eco, size: 28, color: AppColors.text),
        SizedBox(width: 4),
        Text(
          'Pilihan\ntamu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 4),
        Icon(Icons.eco, size: 28, color: AppColors.text),
      ],
    );
  }

  Widget _statUlasan(DetailKamar d) {
    return Column(
      children: [
        Text(
          '${d.jumlahUlasan}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Ulasan',
          style: TextStyle(fontSize: 11, color: AppColors.textGrey),
        ),
      ],
    );
  }

  // ---------- Host & sorotan ----------

  Widget _host(DetailKamar d) {
    final inisial = d.host.nama.replaceFirst('Tuan rumah:', '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surface,
            child: Text(
              inisial.isEmpty ? '?' : inisial[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.host.nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d.host.info,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sorotanItem(SorotanKamar s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.vpn_key_outlined, size: 26, color: AppColors.text),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.judul,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.deskripsi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Rating & ulasan ----------

  Widget _ratingBesar(DetailKamar d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 44, color: AppColors.text),
              const SizedBox(width: 8),
              Text(
                formatRating(d.rating),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.eco, size: 44, color: AppColors.text),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilihan tamu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Rumah ini menjadi favorit tamu berdasarkan penilaian, ulasan, '
            'dan keandalannya',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
        ],
      ),
    );
  }

  Widget _ulasanJudul(DetailKamar d) {
    return const Padding(
      padding: EdgeInsets.only(top: 8, bottom: 16),
      child: Text(
        'Ulasan tamu menyebutkan',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _ulasanList(DetailKamar d) {
    if (d.ulasan.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Belum ada ulasan.',
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: d.ulasan.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _kartuUlasan(d.ulasan[i]),
      ),
    );
  }

  Widget _kartuUlasan(UlasanKamar u) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surface,
                child: Text(
                  u.nama.isEmpty ? '?' : u.nama[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.nama,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      u.bergabung,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                u.rating.clamp(0, 5),
                (_) => const Icon(Icons.star, size: 10, color: AppColors.text),
              ),
              const SizedBox(width: 6),
              Text(
                '· ${u.tanggal}',
                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              u.isi,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Bar bawah ----------

  Widget _barBawah(DetailKamar d) {
    final total = d.hargaPerMalam * _malam;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRupiah(total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  'Untuk $_malam malam · ${_rentangTanggal()}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
                if (d.pembatalanGratis)
                  const Text(
                    '✓ Pembatalan gratis',
                    style: TextStyle(fontSize: 11, color: AppColors.text),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            height: 48,
            child: ElevatedButton(
              onPressed: _pesan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pesan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Model, mock, dan service Detail Kamar (digabung di satu file)
// ============================================================
String _bulanTahun(String iso) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final p = iso.split('-');
  final m = p.length < 2 ? 0 : (int.tryParse(p[1]) ?? 0);
  if (m < 1 || m > 12) return iso;
  return '${bulan[m - 1]} ${p[0]}';
}

class HostKamar {
  final String nama;
  final String info;

  const HostKamar({required this.nama, required this.info});

  factory HostKamar.fromJson(Map<String, dynamic> j) => HostKamar(
    nama: (j['nama'] ?? '').toString(),
    info: (j['info'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {'nama': nama, 'info': info};
}

class SorotanKamar {
  final String judul;
  final String deskripsi;

  const SorotanKamar({required this.judul, required this.deskripsi});

  factory SorotanKamar.fromJson(Map<String, dynamic> j) => SorotanKamar(
    judul: (j['judul'] ?? '').toString(),
    deskripsi: (j['deskripsi'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {'judul': judul, 'deskripsi': deskripsi};
}

class UlasanKamar {
  final String nama;
  final String bergabung;
  final int rating;
  final String tanggal;
  final String isi;

  const UlasanKamar({
    required this.nama,
    required this.bergabung,
    required this.rating,
    required this.tanggal,
    required this.isi,
  });

  factory UlasanKamar.fromJson(Map<String, dynamic> j) => UlasanKamar(
    nama: (j['nama'] ?? j['nama_pengulas'] ?? '').toString(),
    bergabung: (j['bergabung'] ?? '').toString(),
    rating: toInt(j['rating']),
    tanggal: _bulanTahun((j['tanggal'] ?? '').toString()),
    isi: (j['isi'] ?? j['komentar'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'bergabung': bergabung,
    'rating': rating,
    'tanggal': tanggal,
    'isi': isi,
  };
}

class DetailKamar {
  final int id;
  final String judul;
  final String lokasi;
  final String tipe; // mis. "Kamar di Bangkok, Silom, Thailand"
  final String kapasitas; // mis. "1 tempat tidur · Kamar mandi bersama"
  final int hargaPerMalam;
  final double rating;
  final int jumlahUlasan;
  final bool pilihanTamu;
  final bool isFavorit;
  final bool pembatalanGratis;
  final List<String> galeri;
  final HostKamar host;
  final List<SorotanKamar> sorotan;
  final List<UlasanKamar> ulasan;

  const DetailKamar({
    required this.id,
    required this.judul,
    required this.lokasi,
    required this.tipe,
    required this.kapasitas,
    required this.hargaPerMalam,
    required this.rating,
    required this.jumlahUlasan,
    required this.pilihanTamu,
    required this.isFavorit,
    required this.pembatalanGratis,
    required this.galeri,
    required this.host,
    required this.sorotan,
    required this.ulasan,
  });

  factory DetailKamar.fromJson(Map<String, dynamic> j) {
    List<T> daftar<T>(dynamic raw, T Function(Map<String, dynamic>) buat) {
      if (raw is! List) return <T>[];
      return raw
          .whereType<Map>()
          .map((e) => buat(Map<String, dynamic>.from(e)))
          .toList();
    }

    final rawGaleri = j['galeri'];
    final rawHost = j['host'];

    return DetailKamar(
      id: toInt(j['id']),
      judul: (j['judul'] ?? '').toString(),
      lokasi: (j['lokasi'] ?? '').toString(),
      tipe: '${j['tipe'] ?? 'Kamar'} di ${j['lokasi'] ?? ''}',
      kapasitas:
          (j['kapasitas'] ?? 'Maksimum ${toInt(j['kapasitas_tamu'], 4)} tamu')
              .toString(),
      hargaPerMalam: toInt(j['harga_per_malam']),
      rating: toDouble(j['rating']),
      jumlahUlasan: toInt(j['jumlah_ulasan']),
      pilihanTamu: toBool(j['pilihan_tamu']),
      isFavorit: toBool(j['is_favorit']),
      pembatalanGratis: j['pembatalan_gratis'] == null
          ? true
          : toBool(j['pembatalan_gratis']),
      galeri: rawGaleri is List
          ? rawGaleri.map((e) => e.toString()).toList()
          : <String>[],
      host: rawHost is Map
          ? HostKamar.fromJson(Map<String, dynamic>.from(rawHost))
          : HostKamar(
              nama: 'Tuan rumah: ${j['tuan_rumah'] ?? ''}',
              info: 'Tuan rumah di ${j['lokasi'] ?? ''}',
            ),
      sorotan: daftar(j['sorotan'], SorotanKamar.fromJson),
      ulasan: daftar(j['ulasan'], UlasanKamar.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'lokasi': lokasi,
    'tipe': tipe,
    'kapasitas': kapasitas,
    'harga_per_malam': hargaPerMalam,
    'rating': rating,
    'jumlah_ulasan': jumlahUlasan,
    'pilihan_tamu': pilihanTamu,
    'is_favorit': isFavorit,
    'pembatalan_gratis': pembatalanGratis,
    'galeri': galeri,
    'host': host.toJson(),
    'sorotan': sorotan.map((e) => e.toJson()).toList(),
    'ulasan': ulasan.map((e) => e.toJson()).toList(),
  };
}

/// Data dummy detail kamar. Dibuat dari objek Penginapan yang dikirim
/// dari Jelajahi supaya judul, harga, rating, dan gambar selalu sama.
/// Membaca lewat toJson() (key snake_case) agar tidak bergantung pada
/// nama properti Dart di class Penginapan.
DetailKamar mockDetailKamar(Penginapan p) {
  final j = p.toJson();
  final gambar = (j['gambar'] ?? '').toString();

  return DetailKamar(
    id: int.tryParse('${j['id']}') ?? 0,
    judul: (j['judul'] ?? '').toString(),
    lokasi: (j['lokasi'] ?? '').toString(),
    tipe: 'Kamar di ${j['lokasi'] ?? ''}',
    kapasitas: '1 tempat tidur · Kamar mandi bersama',
    hargaPerMalam:
        int.tryParse('${j['harga_per_malam']}') ??
        (double.tryParse('${j['harga_per_malam']}')?.round() ?? 0),
    rating: double.tryParse('${j['rating']}') ?? 0,
    jumlahUlasan: 367,
    pilihanTamu: j['pilihan_tamu'] == true || j['pilihan_tamu'] == 1,
    isFavorit: j['is_favorit'] == true || j['is_favorit'] == 1,
    pembatalanGratis: true,
    galeri: gambar.isEmpty ? <String>[] : <String>[gambar],
    host: const HostKamar(
      nama: 'Tuan rumah: Sutatt',
      info: 'Host Teladan · Tuan rumah selama 10 tahun',
    ),
    sorotan: const [
      SorotanKamar(
        judul: 'Pengalaman check-in sangat baik',
        deskripsi: 'Tamu terakhir memuji proses check-in yang mulus.',
      ),
      SorotanKamar(
        judul: 'Lokasi strategis',
        deskripsi: 'Dekat stasiun, pusat perbelanjaan, dan tempat makan.',
      ),
    ],
    ulasan: const [
      UlasanKamar(
        nama: 'Youta',
        bergabung: '7 bulan bergabung di Airbnb',
        rating: 5,
        tanggal: 'September 2026',
        isi:
            'Tuan rumahnya sangat ramah! Lokasinya juga bagus, dan aksesnya '
            'ke pusat perbelanjaan yang indah, stasiun BTS, dan dermaga juga '
            'bagus, jadi sangat menyenangkan!',
      ),
      UlasanKamar(
        nama: 'Rani',
        bergabung: '2 tahun bergabung di Airbnb',
        rating: 5,
        tanggal: 'Agustus 2026',
        isi:
            'Kamarnya bersih dan nyaman. Saya pasti akan menginap lagi di '
            'sini saat berkunjung ke kota ini.',
      ),
      UlasanKamar(
        nama: 'Bima',
        bergabung: '1 tahun bergabung di Airbnb',
        rating: 4,
        tanggal: 'Juli 2026',
        isi:
            'Secara keseluruhan bagus. Kamar mandi digunakan bersama, tapi '
            'tetap bersih dan terawat.',
      ),
    ],
  );
}

class DetailKamarService {
  /// GET /api/penginapan/:id  ->  {"data": {...DetailKamar...}}
  Future<DetailKamar> getDetail(Penginapan p) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return mockDetailKamar(p);
    }

    final id = p.toJson()['id'];
    // ASUMSI: ApiClient().get(path) mengembalikan isi "data" yang sudah
    // di-decode. Kalau signature ApiClient berbeda, cukup ubah baris ini.
    final res = await ApiClient().get('/penginapan/$id');
    return DetailKamar.fromJson(Map<String, dynamic>.from(res['data'] as Map));
  }
}
