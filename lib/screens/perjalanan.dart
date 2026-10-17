import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class PerjalananScreen extends StatelessWidget {
  /// Dari MainShell: berpindah kembali ke tab Jelajahi.
  final VoidCallback onMulaiSekarang;

  const PerjalananScreen({super.key, required this.onMulaiSekarang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFE8F3),
      body: Stack(
        children: [
          // Latar mirip peta (tanpa package tambahan)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFCFE8F3), Color(0xFFE6F1E4)],
                ),
              ),
              child: Align(
                alignment: const Alignment(0, -0.6),
                child: Icon(
                  Icons.public,
                  size: 180,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _lembarBawah(context),
          ),
        ],
      ),
    );
  }

  Widget _lembarBawah(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.luggage,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const Positioned(
                right: 4,
                top: 4,
                child: Icon(
                  Icons.favorite,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Rencanakan perjalanan\nAnda berikutnya',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Setelah Anda memesan perjalanan, pengalaman, atau layanan, '
            'kembalilah ke sini untuk melihat detailnya, menjelajahi peta, '
            'dan menyimpan tempat-tempat yang ingin dikunjungi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onMulaiSekarang,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Mulai sekarang',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
