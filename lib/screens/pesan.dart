import 'package:flutter/material.dart';

import '../core/app_config.dart'; // [BARU]
import '../core/app_theme.dart';
import '../models/percakapan.dart';
import '../services/api_client.dart'; // [BARU]
import '../services/pesan_service.dart';
import '../widgets/app_image.dart';

/// Halaman Pesan.
/// [onMulaiSekarang] dipanggil saat tombol "Mulai sekarang" ditekan
/// (MainShell mengarahkannya ke tab Jelajahi).
class PesanScreen extends StatefulWidget {
  final VoidCallback onMulaiSekarang;
  const PesanScreen({super.key, required this.onMulaiSekarang});

  @override
  State<PesanScreen> createState() => _PesanScreenState();
}

class _PesanScreenState extends State<PesanScreen> {
  final PesanService _service = PesanService();

  List<Percakapan> _percakapan = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    // [BARU] muat ulang otomatis saat pengguna login atau keluar
    ApiClient().tokenNotifier.addListener(_saatLoginBerubah);
  }

  // [BARU] wajib: lepas listener saat halaman ditutup
  @override
  void dispose() {
    ApiClient().tokenNotifier.removeListener(_saatLoginBerubah);
    super.dispose();
  }

  // [BARU]
  void _saatLoginBerubah() => _load(tampilkanLoading: false);

  // [DIUBAH] menangani keadaan belum login dan muat ulang tanpa kedip
  Future<void> _load({bool tampilkanLoading = true}) async {
    // Belum login -> tampilan kosong seperti aplikasi asli (bukan pesan error)
    if (!AppConfig.useMock && ApiClient().token == null) {
      if (!mounted) return;
      setState(() {
        _percakapan = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    if (tampilkanLoading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _service.getPercakapan();
      if (!mounted) return;
      setState(() {
        _percakapan = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildBody()),
            _buildPercakapanTerdahulu(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _BulatIcon(
                icon: Icons.search,
                onTap: () {
                  // TODO: cari percakapan
                },
              ),
              const SizedBox(width: 10),
              _BulatIcon(
                icon: Icons.settings_outlined,
                onTap: () {
                  // TODO: pengaturan pesan
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                'Pesan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.notifications_off_outlined,
                size: 18,
                color: AppColors.textGrey,
              ),
            ],
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
    if (_percakapan.isEmpty) return _buildKosong();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _percakapan.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 84),
        itemBuilder: (context, i) => _PercakapanTile(
          data: _percakapan[i],
          onTap: () {
            // TODO: buka halaman chat (kirim id percakapan)
          },
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _IlustrasiChat(),
            const SizedBox(height: 28),
            const Text(
              'Tidak ada yang perlu dilihat di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Rencanakan masa inap, pengalaman, atau layanan untuk terhubung dengan tuan rumah Anda di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: widget.onMulaiSekarang,
              child: const Text(
                'Mulai sekarang',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercakapanTerdahulu() {
    return InkWell(
      onTap: () {
        // TODO: halaman percakapan yang diarsipkan
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Percakapan terdahulu',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class _BulatIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BulatIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.text),
      ),
    );
  }
}

/// Ilustrasi dua gelembung chat (dibuat dari Icon, tanpa file gambar).
class _IlustrasiChat extends StatelessWidget {
  const _IlustrasiChat();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 110,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 84,
              color: Colors.grey.shade300,
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 76,
              color: Color(0xFF2AA6E8),
            ),
          ),
          const Positioned(
            right: 22,
            top: 26,
            child: Icon(Icons.menu, size: 28, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PercakapanTile extends StatelessWidget {
  final Percakapan data;
  final VoidCallback onTap;
  const _PercakapanTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: ClipOval(
        child: data.foto.isEmpty
            ? Container(
                width: 48,
                height: 48,
                color: const Color(0xFFDCEBFA),
                alignment: Alignment.center,
                child: Text(
                  data.namaTuanRumah.isEmpty
                      ? '?'
                      : data.namaTuanRumah[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B4FA8),
                  ),
                ),
              )
            : AppImage(data.foto, width: 48, height: 48),
      ),
      title: Text(
        data.namaTuanRumah,
        style: TextStyle(
          fontSize: 14,
          fontWeight: data.belumDibaca ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        data.pesanTerakhir,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12.5),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            data.waktu,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
          if (data.belumDibaca) ...[
            const SizedBox(height: 6),
            const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
          ],
        ],
      ),
    );
  }
}
