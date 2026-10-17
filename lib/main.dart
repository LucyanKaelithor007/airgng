import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'routes.dart';

void main() {
  runApp(const AirgngApp());
}

class AirgngApp extends StatelessWidget {
  const AirgngApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airgng',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // TODO (Dini): ganti initialRoute ke AppRoutes.onboarding setelah selesai
      initialRoute: AppRoutes.onboarding,
      onGenerateRoute: AppRoutes.generate,
    );
  }
}
