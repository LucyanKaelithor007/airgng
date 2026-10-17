import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/profil.dart'; // [BARU]
import '../routes.dart'; // [BARU]
import '../services/api_client.dart'; // [BARU]
import '../services/profil_service.dart'; // [BARU]

// [DIHAPUS] import '../core/app_config.dart';
// [DIHAPUS] import '../data/mock_data.dart';

/// UI Profil mengikuti PDF referensi halaman 5.
/// Data nama diambil dari backend (GET /api/profil) bila pengguna sudah login.
/// Belum login: tampil "Pengguna Airgng" / "Tamu".
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // [BARU] alat pemanggil API dan penyimpan data akun
  final ProfilService _service = ProfilService();
  Profil? _profil;

  // [DIUBAH] sebelumnya: AppConfig.useMock ? MockData.namaProfilDemo : 'Pengguna Airgng'
  String _nama = 'Pengguna Airgng';

  // [BARU] dijalankan sekali saat halaman dibuat
  @override
  void initState() {
    super.initState();
    _muatProfil();
    // Muat ulang otomatis setiap pengguna login atau keluar
    ApiClient().tokenNotifier.addListener(_muatProfil);
  }

  // [BARU] wajib: lepas listener saat halaman ditutup
  @override
  void dispose() {
    ApiClient().tokenNotifier.removeListener(_muatProfil);
    super.dispose();
  }

  // [DIUBAH] ambil data akun dari backend
  Future<void> _muatProfil() async {
    if (ApiClient().token == null) {
      // belum login atau sudah keluar -> kembali ke tampilan tamu
      if (!mounted) return;
      setState(() {
        _profil = null;
        _nama = 'Pengguna Airgng';
      });
      return;
    }
    try {
      final p = await _service.getProfil();
      if (!mounted) return;
      setState(() {
        _profil = p;
        _nama = p.namaLengkap;
      });
    } catch (e) {
      // Gagal (mis. backend mati / token ditolak): nama tidak berubah.
      // Penyebabnya bisa dibaca di Debug Console.
      debugPrint('Gagal memuat profil: $e');
    }
  }

  // [BARU] ringkasan untuk menu "Lihat profil"
  String get _ringkasanProfil {
    final p = _profil;
    if (p == null) {
      return 'Anda belum masuk ke akun. Masuk untuk melihat data akun.';
    }
    final email = p.email.isEmpty ? '-' : p.email;
    final lahir = p.tanggalLahir.isEmpty ? '-' : p.tanggalLahir;
    return 'Kontak: ${p.kontak}\nEmail: $email\nTanggal lahir: $lahir';
  }

  void _pesanSingkat(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // [DIUBAH] sekarang menyimpan nama ke server (PUT /api/profil)
  Future<void> _editNama() async {
    final hasil = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => _EditNamaPage(namaAwal: _nama)),
    );
    if (hasil == null || !mounted) return;

    if (ApiClient().token == null) {
      setState(() => _nama = hasil);
      _pesanSingkat('Masuk ke akun terlebih dahulu agar nama tersimpan.');
      return;
    }

    // Pisahkan nama: kata pertama = nama depan, sisanya = nama belakang
    final bagian = hasil.split(' ');
    final depan = bagian.first;
    final belakang = bagian.skip(1).join(' ');

    try {
      final p = await _service.updateProfil(
        namaDepan: depan,
        namaBelakang: belakang,
        email: _profil?.email,
        tanggalLahir: _profil?.tanggalLahir,
      );
      if (!mounted) return;
      setState(() {
        _profil = p;
        _nama = p.namaLengkap;
      });
      _pesanSingkat('Nama berhasil disimpan.');
    } catch (e) {
      if (!mounted) return;
      _pesanSingkat(e.toString());
    }
  }

  void _detailMenu(
    String judul,
    String keterangan, {
    IconData icon = Icons.info_outline,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 31),
              const SizedBox(height: 15),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                keterangan,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.text,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [DIUBAH] sekarang benar-benar keluar: hapus token lalu kembali ke onboarding
  void _konfirmasiKeluar() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun'),
        content: const Text('Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ApiClient().token = null; // hapus token login
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.onboarding,
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(21, 15, 21, 32),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Notifikasi',
                  icon: const Icon(Icons.notifications_none_outlined),
                  onPressed: () => _pesanSingkat('Belum ada notifikasi.'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _kartuProfil(),
            const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: _KartuCepat(
                    judul: 'Perjalanan terdahulu',
                    icon: Icons.luggage_outlined,
                    warna: const Color(0xFFFFEFE8),
                    onTap: () => _detailMenu(
                      'Perjalanan terdahulu',
                      'Riwayat perjalanan akan tampil setelah data pemesanan '
                          'terhubung dengan akun pengguna.',
                      icon: Icons.luggage_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KartuCepat(
                    judul: 'Koneksi',
                    icon: Icons.groups_outlined,
                    warna: const Color(0xFFE9F3FD),
                    onTap: () => _detailMenu(
                      'Koneksi',
                      'Fitur koneksi dengan pengguna lain masih menunggu '
                          'implementasi dari tim.',
                      icon: Icons.groups_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            _kartuTuanRumah(),
            const SizedBox(height: 22),
            _menu('Pengaturan akun', Icons.settings_outlined, onTap: _editNama),
            _menu(
              'Dapatkan bantuan',
              Icons.help_outline,
              onTap: () => _detailMenu(
                'Dapatkan bantuan',
                'Butuh bantuan menggunakan Airgng? Hubungi tim pengembang '
                    'melalui kanal bantuan yang nanti ditentukan kelompok.',
                icon: Icons.help_outline,
              ),
            ),
            _menu(
              'Lihat profil',
              Icons.person_outline,
              // [DIUBAH] menampilkan data akun asli
              onTap: () => _detailMenu(
                _nama,
                _ringkasanProfil,
                icon: Icons.account_circle_outlined,
              ),
            ),
            _menu(
              'Privasi',
              Icons.shield_outlined,
              onTap: () => _detailMenu(
                'Privasi',
                'Pengaturan privasi akun membutuhkan penyimpanan dan '
                    'kontrak API yang akan disepakati oleh kelompok.',
                icon: Icons.shield_outlined,
              ),
            ),
            const Divider(height: 30, color: AppColors.border),
            _menu(
              'Rekomendasikan tuan rumah',
              Icons.campaign_outlined,
              onTap: () => _detailMenu(
                'Rekomendasikan tuan rumah',
                'Rekomendasi tuan rumah belum tersedia pada versi demo ini.',
                icon: Icons.campaign_outlined,
              ),
            ),
            _menu(
              'Temukan rekan tuan rumah',
              Icons.handshake_outlined,
              onTap: () => _detailMenu(
                'Temukan rekan tuan rumah',
                'Pencarian rekan tuan rumah belum tersedia pada versi demo ini.',
                icon: Icons.handshake_outlined,
              ),
            ),
            _menu(
              'Hukum',
              Icons.gavel_outlined,
              onTap: () => _detailMenu(
                'Hukum',
                'Informasi ketentuan dan kebijakan layanan Airgng '
                    'perlu disiapkan oleh tim sebelum dipublikasikan.',
                icon: Icons.gavel_outlined,
              ),
            ),
            _menu('Keluar', Icons.logout_outlined, onTap: _konfirmasiKeluar),
            const SizedBox(height: 12),
            const Text(
              'Airgng · Tampilan proyek pembelajaran',
              style: TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuProfil() {
    return Material(
      elevation: 2.5,
      shadowColor: Colors.black12,
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _detailMenu(
          _nama,
          _ringkasanProfil, // [DIUBAH] sebelumnya teks demo
          icon: Icons.account_circle_outlined,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 26),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFFDCEBFF),
                child: Text(
                  _nama.isEmpty ? '?' : _nama.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 25,
                    color: Color(0xFF1E5492),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _nama,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Tamu',
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kartuTuanRumah() {
    return Material(
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _detailMenu(
          'Menjadi Tuan Rumah',
          'Fitur pendaftaran sebagai tuan rumah membutuhkan alur '
              'dan backend tambahan yang belum disepakati tim.',
          icon: Icons.home_work_outlined,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menjadi Tuan Rumah',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Anda bisa meraih lebih banyak dengan membuka '
                      'pintu rumah untuk para tamu.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menu(String nama, IconData icon, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, size: 21, color: AppColors.text),
      title: Text(
        nama,
        style: const TextStyle(fontSize: 14.5, color: AppColors.text),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 19,
        color: AppColors.textGrey,
      ),
      onTap: onTap,
      minLeadingWidth: 25,
    );
  }
}

class _KartuCepat extends StatelessWidget {
  final String judul;
  final IconData icon;
  final Color warna;
  final VoidCallback onTap;

  const _KartuCepat({
    required this.judul,
    required this.icon,
    required this.warna,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.5,
      shadowColor: Colors.black12,
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 71,
                decoration: BoxDecoration(
                  color: warna,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.text, size: 35),
              ),
              const SizedBox(height: 11),
              Text(
                judul,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditNamaPage extends StatefulWidget {
  final String namaAwal;
  const _EditNamaPage({required this.namaAwal});

  @override
  State<_EditNamaPage> createState() => _EditNamaPageState();
}

class _EditNamaPageState extends State<_EditNamaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaAwal);
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan akun')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text(
              'Informasi pribadi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 9),
            // [DIUBAH] teks lama menyebut data belum tersimpan ke server
            const Text(
              'Nama ini akan disimpan ke akun Anda. '
              'Gunakan spasi untuk memisahkan nama depan dan belakang.',
              style: TextStyle(color: AppColors.textGrey, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _namaController,
              textCapitalization: TextCapitalization.words,
              maxLength: 70,
              decoration: const InputDecoration(
                labelText: 'Nama tampilan',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, _namaController.text.trim());
                }
              },
              child: const Text('Simpan nama'),
            ),
          ],
        ),
      ),
    );
  }
}
