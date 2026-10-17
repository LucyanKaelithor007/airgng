import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/helpers.dart';
import '../models/penginapan.dart';
import 'app_image.dart';

/// Kartu penginapan (gambar, badge "Pilihan tamu", tombol love, harga, rating).
/// Dipakai di Jelajahi, dan bisa dipakai ulang di Favorit.
class PenginapanCard extends StatelessWidget {
  final Penginapan item;
  final VoidCallback onTap;
  final VoidCallback onFavoritTap;
  final double width;
  final int jumlahMalam;

  const PenginapanCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavoritTap,
    this.width = 165,
    this.jumlahMalam = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AppImage(item.gambar),
                  ),
                ),
                if (item.pilihanTamu)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Pilihan tamu',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onFavoritTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _HeartIcon(aktif: item.isFavorit),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${formatRupiah(item.hargaUntukMalam(jumlahMalam))} untuk $jumlahMalam malam',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: AppColors.text),
                const SizedBox(width: 2),
                Text(
                  formatRating(item.rating),
                  style: const TextStyle(fontSize: 12, color: AppColors.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartIcon extends StatelessWidget {
  final bool aktif;
  const _HeartIcon({required this.aktif});

  @override
  Widget build(BuildContext context) {
    if (aktif) {
      return const Icon(Icons.favorite, color: AppColors.primary, size: 24);
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.favorite, color: Colors.black.withAlpha(90), size: 24),
        const Icon(Icons.favorite_border, color: Colors.white, size: 24),
      ],
    );
  }
}
