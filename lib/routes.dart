import 'package:flutter/material.dart';

import 'models/penginapan.dart';
import 'screens/detail_kamar.dart';
import 'screens/main_shell.dart';
import 'screens/pemesanan_kamar.dart';
import 'screens/onboarding.dart';
import 'screens/login_daftar.dart';

/// Semua nama route + pembuatnya ada di sini.
/// Anggota lain yang menambah halaman baru (onboarding, login, dst.)
/// cukup menambah konstanta + satu case di [generate].
class AppRoutes {
  static const String shell = '/';
  static const String detailKamar = '/detail-kamar';
  static const String pemesananKamar = '/pemesanan-kamar';
  static const String onboarding = '/onboarding';
  static const String loginDaftar = '/login-daftar';
  // TODO (Dini): static const String onboarding = '/onboarding'; login = '/login';

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case detailKamar:
        final p = settings.arguments as Penginapan;
        return MaterialPageRoute(builder: (_) => DetailKamarScreen(penginapan: p));
      case pemesananKamar:
        final p = settings.arguments as Penginapan;
        return MaterialPageRoute(
            builder: (_) => BookingPage(penginapan: p));
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case loginDaftar:
        return MaterialPageRoute(builder: (_) => const LoginDaftarModal());
      case shell:
      default:
        return MaterialPageRoute(builder: (_) => const MainShell());
    }
  }
}
