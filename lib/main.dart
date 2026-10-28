import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/storage/record_store.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await AppStorage.open();

  // Set system navigation & status bar style for clean light theme default
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(ProviderScope(
    overrides: [appStorageProvider.overrideWithValue(storage)],
    child: const KudiLensApp(),
  ));
}

class KudiLensApp extends StatelessWidget {
  const KudiLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kudi Lens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
