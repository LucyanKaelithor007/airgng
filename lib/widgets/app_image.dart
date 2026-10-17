import 'package:flutter/material.dart';

import '../core/app_config.dart';

/// Widget gambar universal. Otomatis memilih sumber gambar:
///  - "assets/images/x.jpg"  -> gambar dari folder assets (laptop sendiri)
///  - "https://..."          -> URL penuh
///  - "rumah1.jpg"           -> nama file dari backend (AppConfig.imageBaseUrl + nama)
/// Jika gambar tidak ditemukan, tampil kotak abu-abu (tidak crash).
class AppImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  const AppImage(
    this.path, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  Widget get _placeholder => Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, color: Colors.grey.shade500),
      );

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return _placeholder;

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _placeholder,
      );
    }

    final url = path.startsWith('http') ? path : '${AppConfig.imageBaseUrl}$path';
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => _placeholder,
    );
  }
}
