import 'package:flutter/material.dart';

import '../core/app_config.dart'; // [BARU]
import '../core/app_theme.dart';
import '../models/penginapan.dart';
import '../routes.dart';
import '../services/api_client.dart'; // [BARU]
import '../services/favorit_service.dart';
import '../widgets/app_image.dart';

/// Favorit: kondisi kosong dan terisi sesuai referensi PDF halaman 4.
/// Tidak membuat route/format JSON baru; memakai model Penginapan existing.
class FavoritScreen extends StatefulWidget {
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  final FavoritService _service = FavoritService();
  List<Penginapan> _items = [];
  bool _loading = true;
  bool _mengedit = false;
  int? _sedangMenghapus;
  String? _error;
  int _nomorPermintaan = 0;

  @override
  void initState() {
    super.initState();
    FavoritService.perubahan.addListener(_saatFavoritBerubah);
    // [BARU] muat ulang otomatis saat pengguna login atau keluar
    ApiClient().tokenNotifier.addListener(_saatFavoritBerubah);
    _muatFavorit();
  }

  @override
  void dispose() {
    FavoritService.perubahan.removeListener(_saatFavoritBerubah);
    ApiClient().tokenNotifier.removeListener(_saatFavoritBerubah); // [BARU]
    super.dispose();
  }

  void _saatFavoritBerubah() {
    _muatFavorit(tampilkanLoading: false);
  }

  Future<void> _muatFavorit({bool tampilkanLoading = true}) async {
    final nomor = ++_nomorPermintaan;

    // [BARU] belum login -> tampilkan keadaan kosong (bukan pesan error)
    if (!AppConfig.useMock && ApiClient().token == null) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
        _error = null;
        _mengedit = false;
      });
      return;
    }

    if (tampilkanLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final hasil = await _service.getFavorit();
      if (!mounted || nomor != _nomorPermintaan) return;
      setState(() {
        _items = hasil;
        _loading = false;
        _error = null;
        if (_items.isEmpty) _mengedit = false;
      });
    } catch (e) {
      if (!mounted || nomor != _nomorPermintaan) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _hapusFavorit(Penginapan item) async {
    if (_sedangMenghapus != null) return;
    setState(() => _sedangMenghapus = item.id);
    try {
      await _service.setFavorit(item.id, false);
      if (!mounted) return;
      setState(() => _items.removeWhere((p) => p.id == item.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penginapan dihapus dari favorit')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus favorit: $e')),
      );
    } finally {
      if (mounted) setState(() => _sedangMenghapus = null);
    }
  }

  void _bukaDetail(Penginapan item) {
    _service.catatTerakhirDilihat(item);
    Navigator.pushNamed(context, AppRoutes.detailKamar, arguments: item);
  }

  void _bukaTerakhirDilihat() {
    final riwayat = _service.terakhirDilihat;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Terakhir dilihat',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (riwayat.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text('Belum ada penginapan yang Anda lihat.',
                      style: TextStyle(color: AppColors.textGrey)),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: riwayat.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (_, i) {
                      final item = riwayat[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AppImage(item.gambar, width: 58, height: 58),
                        ),
                        title: Text(item.judul, maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(item.lokasi),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _bukaDetail(item);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 25, 20, 17),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Daftar favorit',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 25,
                          letterSpacing: -0.6,
                          color: AppColors.text,
                        )),
                  ),
                  if (_items.isNotEmpty && !_loading)
                    TextButton(
                      onPressed: () => setState(() => _mengedit = !_mengedit),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.text,
                        backgroundColor: AppColors.surface,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(_mengedit ? 'Selesai' : 'Edit'),
                    ),
                ],
              ),
            ),
            Expanded(child: _konten()),
          ],
        ),
      ),
    );
  }

  Widget _konten() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined, size: 44,
                  color: AppColors.textGrey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => _muatFavorit(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, batas) {
      final kolom = (batas.maxWidth / 190).floor().clamp(2, 4).toInt();
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _muatFavorit(),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: kolom,
            crossAxisSpacing: 14,
            mainAxisSpacing: 23,
            childAspectRatio: 0.89,
          ),
          itemCount: _items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _KartuTerakhirDilihat(onTap: _bukaTerakhirDilihat);
            }
            final item = _items[index - 1];
            return _KartuFavorit(
              item: item,
              editMode: _mengedit,
              sedangMenghapus: _sedangMenghapus == item.id,
              onBuka: () => _bukaDetail(item),
              onHapus: () => _hapusFavorit(item),
            );
          },
        ),
      );
    });
  }
}

class _KartuTerakhirDilihat extends StatelessWidget {
  final VoidCallback onTap;
  const _KartuTerakhirDilihat({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF929292),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.history_rounded, color: Colors.white, size: 41),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Terakhir dilihat',
              maxLines: 1,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.text)),
        ],
      ),
    );
  }
}

class _KartuFavorit extends StatelessWidget {
  final Penginapan item;
  final bool editMode;
  final bool sedangMenghapus;
  final VoidCallback onBuka;
  final VoidCallback onHapus;

  const _KartuFavorit({
    required this.item,
    required this.editMode,
    required this.sedangMenghapus,
    required this.onBuka,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: editMode ? onHapus : onBuka,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AppImage(item.gambar),
                ),
                if (editMode)
                  Positioned(
                    right: 7,
                    top: 7,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: sedangMenghapus
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2,
                                  color: AppColors.primary))
                          : const Icon(Icons.close, size: 19,
                              color: AppColors.text),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(item.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700,
                  color: AppColors.text, fontSize: 13)),
          const SizedBox(height: 2),
          Text(item.lokasi,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5,
                  color: AppColors.textGrey)),
        ],
      ),
    );
  }
}