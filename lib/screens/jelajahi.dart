import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/jelajahi_data.dart';
import '../models/penginapan.dart';
import '../routes.dart';
import '../services/favorit_service.dart';
import '../services/jelajahi_service.dart';
import '../services/api_client.dart';
import '../widgets/app_image.dart';
import '../widgets/penginapan_card.dart';
import 'login_daftar.dart';

/// Halaman Jelajahi (halaman utama).
/// Alur: Onboarding -> Jelajahi (popup Login/Daftar muncul 1 detik kemudian,
/// dikerjakan Dini) -> klik kartu -> Detail Kamar (dikerjakan Herdina).
class JelajahiScreen extends StatefulWidget {
  const JelajahiScreen({super.key});

  @override
  State<JelajahiScreen> createState() => _JelajahiScreenState();
}

class _JelajahiScreenState extends State<JelajahiScreen> {
  final JelajahiService _service = JelajahiService();
  final FavoritService _favoritService = FavoritService();

  static bool _popupLoginSudahMuncul = false;

  void _jadwalkanPopupLogin() {
    if (_popupLoginSudahMuncul || ApiClient().token != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _tungguLaluTampilkan());
  }

  Future<void> _tungguLaluTampilkan() async {
    // Tunggu sampai halaman ini benar-benar tampil (onboarding sudah selesai)
    while (mounted && !(ModalRoute.of(context)?.isCurrent ?? false)) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted || _popupLoginSudahMuncul) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted || _popupLoginSudahMuncul) return;

    _popupLoginSudahMuncul = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LoginDaftarModal(),
    );
  }

  static const List<(String, IconData)> _kategori = [
    ('Semua', Icons.search),
    ('Homes', Icons.home_work_outlined),
    ('Experiences', Icons.place_outlined),
    ('Services', Icons.room_service_outlined),
  ];

  JelajahiData? _data;
  bool _loading = true;
  String? _error;
  int _kategoriAktif = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _jadwalkanPopupLogin();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getJelajahi();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorit(Penginapan item) async {
    final baru = !item.isFavorit;
    setState(() => item.isFavorit = baru); // optimistic update
    try {
      await _favoritService.setFavorit(item.id, baru);
    } catch (e) {
      if (!mounted) return;
      setState(() => item.isFavorit = !baru); // batalkan jika gagal
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _bukaDetail(Penginapan item) {
    Navigator.pushNamed(context, AppRoutes.detailKamar, arguments: item)
      ..then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  _buildBody(),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,
                    child: Center(child: _InfoHarga()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEDEDED), Colors.white],
        ),
      ),
      child: Column(
        children: [
          // Kolom pencarian
          GestureDetector(
            onTap: () {
              // TODO: halaman pencarian (opsional)
            },
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 18, color: AppColors.text),
                  SizedBox(width: 8),
                  Text(
                    'Mulai pencarian',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Kategori
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kategori.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final aktif = i == _kategoriAktif;
                return GestureDetector(
                  // TODO: filter data berdasarkan kategori (kirim ?kategori= ke API)
                  onTap: () => setState(() => _kategoriAktif = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: aktif ? const Color(0xFFEBEBEB) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: aktif ? AppColors.text : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_kategori[i].$2, size: 16, color: AppColors.text),
                        const SizedBox(width: 6),
                        Text(
                          _kategori[i].$1,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40, color: AppColors.textGrey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: _load,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _data!;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 0, 90),
        children: [
          for (final seksi in data.seksi) ...[
            _SeksiHeader(
              judul: seksi.judul,
              onTap: () {
                // TODO: halaman daftar lengkap per kota
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16),
                itemCount: seksi.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final item = seksi.items[i];
                  return PenginapanCard(
                    item: item,
                    onTap: () => _bukaDetail(item),
                    onFavoritTap: () => _toggleFavorit(item),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (data.layanan.isNotEmpty) ...[
            const _SeksiHeader(judul: 'Temukan layanan di dekat Anda'),
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: data.layanan.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _LayananItem(layanan: data.layanan[i]),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (data.destinasi.isNotEmpty) ...[
            const _SeksiHeader(judul: 'Destinasi untuk Anda'),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: data.destinasi.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _DestinasiItem(destinasi: data.destinasi[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SeksiHeader extends StatelessWidget {
  final String judul;
  final VoidCallback? onTap;
  const _SeksiHeader({required this.judul, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                judul,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward, size: 18, color: AppColors.text),
          ],
        ),
      ),
    );
  }
}

class _LayananItem extends StatelessWidget {
  final Layanan layanan;
  const _LayananItem({required this.layanan});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AppImage(layanan.gambar, width: 76, height: 76),
          ),
          const SizedBox(height: 6),
          Text(
            layanan.nama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppColors.text),
          ),
        ],
      ),
    );
  }
}

class _DestinasiItem extends StatelessWidget {
  final Destinasi destinasi;
  const _DestinasiItem({required this.destinasi});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppImage(destinasi.gambar, width: 100, height: 76),
          ),
          const SizedBox(height: 6),
          Text(
            destinasi.nama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          Text(
            destinasi.deskripsi,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _InfoHarga extends StatelessWidget {
  const _InfoHarga();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sell, size: 15, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'Harga sudah mencakup semua biaya',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
