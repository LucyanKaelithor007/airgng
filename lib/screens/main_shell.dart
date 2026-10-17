import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'favorit.dart';
import 'jelajahi.dart';
import 'perjalanan.dart';
import 'pesan.dart';
import 'profil.dart';

/// Kerangka utama dengan bottom navigation 5 tab:
/// Jelajahi | Favorit | Perjalanan | Pesan | Profil
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final List<int> _versi = [0, 0, 0, 0, 0];

  void _keJelajahi() => setState(() => _index = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const JelajahiScreen(),
          FavoritScreen(),
          PerjalananScreen(onMulaiSekarang: _keJelajahi),
          PesanScreen(onMulaiSekarang: _keJelajahi),
          ProfilScreen(),
          FavoritScreen(key: ValueKey('fav${_versi[1]}')),
          PerjalananScreen(key: ValueKey('trip${_versi[2]}'), onMulaiSekarang: _keJelajahi),
          PesanScreen(key: ValueKey('pesan${_versi[3]}'), onMulaiSekarang: _keJelajahi),
          ProfilScreen(key: ValueKey('profil${_versi[4]}')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() { _index = i; _versi[i]++; }),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        selectedFontSize: 10.5,
        unselectedFontSize: 10.5,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Jelajahi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.flight_outlined),
              activeIcon: Icon(Icons.flight),
              label: 'Perjalanan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Pesan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}
