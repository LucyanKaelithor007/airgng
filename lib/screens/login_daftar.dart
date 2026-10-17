import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/auth_service.dart';

class LoginDaftarModal extends StatefulWidget {
  const LoginDaftarModal({super.key});

  @override
  State<LoginDaftarModal> createState() => _LoginDaftarModalState();
}

class _LoginDaftarModalState extends State<LoginDaftarModal> {
  int _step = 1; // Step 1: Input kontak (email/no telp), Step 2: Form Buat Akun
  final TextEditingController _kontakController = TextEditingController();
  final TextEditingController _namaDepanController = TextEditingController();
  final TextEditingController _namaBelakangController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _kontakController.dispose();
    _namaDepanController.dispose();
    _namaBelakangController.dispose();
    _tanggalLahirController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // [BARU] Dipakai tombol "Lanjutkan" dan tombol Google/Apple.
  // Akun sudah ada -> langsung masuk. Belum ada -> tampilkan form Buat akun.
  Future<void> _lanjutDenganKontak(String kontak) async {
    final k = kontak.trim();
    if (k.isEmpty || _isLoading) return;
    _kontakController.text = k;

    setState(() => _isLoading = true);
    try {
      final terdaftar = await _authService.kontakTerdaftar(k);
      if (!mounted) return;

      if (terdaftar) {
        // Akun sudah ada: masuk langsung tanpa mengisi data lagi
        await _authService.loginOrRegister(kontak: k);
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('Berhasil masuk!')),
        );
      } else {
        // Akun baru: isi email otomatis bila kontak berupa email
        if (k.contains('@') && _emailController.text.isEmpty) {
          _emailController.text = k;
        }
        setState(() => _step = 2);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submitData() async {
    setState(() => _isLoading = true);
    try {
      await _authService.loginOrRegister(
        kontak: _kontakController.text,
        namaDepan: _namaDepanController.text,
        namaBelakang: _namaBelakangController.text,
        tanggalLahir: _tanggalLahirController.text,
        email: _emailController.text, // [BARU] email ikut dikirim
      );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context); // Tutup modal setelah sukses
        messenger.showSnackBar(
          const SnackBar(content: Text('Berhasil masuk / mendaftar akun!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar dengan tombol Close (X) dan Tombol Back jika di step > 1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_step > 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => setState(() => _step--),
                  )
                else
                  const SizedBox(width: 40),
                Text(
                  _step == 1 ? 'Masuk atau daftar' : 'Buat akun Anda',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.text),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // KONTEN STEP 1: Masuk atau Daftar (Nomor Telepon / Email / Social)
            if (_step == 1) ...[
              const Text(
                'Selamat datang di Airgng',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _kontakController,
                decoration: InputDecoration(
                  labelText: 'Nomor telepon atau email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // [DIUBAH] sebelumnya langsung setState(() => _step = 2)
                  onPressed: _isLoading
                      ? null
                      : () => _lanjutDenganKontak(_kontakController.text),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lanjutkan',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'atau',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 16),
              // [DIUBAH] dua kotak ikon berdampingan tanpa teks (seperti Airbnb asli)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _KotakSosial(
                    tooltip: 'Lanjutkan dengan Google',
                    ikon: Image.asset(
                      'assets/images/logo_google.png',
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.g_mobiledata,
                        size: 28,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () => _lanjutDenganKontak('google_user@gmail.com'),
                  ),
                  const SizedBox(width: 16),
                  _KotakSosial(
                    tooltip: 'Lanjutkan dengan Apple',
                    ikon: const Icon(Icons.apple, size: 26, color: Colors.black),
                    onPressed: () => _lanjutDenganKontak('apple_user@icloud.com'),
                  ),
                ],
              ),
            ]
            // KONTEN STEP 2: Form Buat Akun Anda
            else ...[
              const Text(
                'Informasi ini diperlukan agar dapat memesan atau menerima tamu.',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _namaDepanController,
                decoration: InputDecoration(
                  labelText: 'Nama depan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _namaBelakangController,
                decoration: InputDecoration(
                  labelText: 'Nama belakang',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tanggalLahirController,
                decoration: InputDecoration(
                  labelText: 'Tanggal lahir (YYYY-MM-DD)',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitData,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Setuju dan lanjutkan',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// [DIGANTI] sebelumnya _TombolSosial (tombol lebar dengan teks)
/// Kotak kecil berisi ikon saja untuk Google/Apple.
class _KotakSosial extends StatelessWidget {
  final Widget ikon;
  final String tooltip;
  final VoidCallback onPressed;

  const _KotakSosial({
    required this.ikon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 64,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(width: 26, height: 26, child: ikon),
        ),
      ),
    );
  }
}