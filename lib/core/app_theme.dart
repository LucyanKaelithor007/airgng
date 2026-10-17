import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE31C5F); // merah muda khas Airbnb
  static const Color text = Color(0xFF222222);
  static const Color textGrey = Color(0xFF717171);
  static const Color border = Color(0xFFDDDDDD);
  static const Color surface = Color(0xFFF7F7F7);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
      );
}
