import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // Tampil 3 detik lalu pindah ke halaman utama (shell)
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.shell);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo.jpg',
          width: 140,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('GAGAL MUAT LOGO: $error');
            return const Icon(
              Icons.house_rounded,
              size: 100,
              color: AppColors.primary,
            );
          },
        ),
      ),
    );
  }
}
