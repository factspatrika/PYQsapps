import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'data/repositories/caching_service.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.light;
  }

  Future<void> loadTheme() async {
    final box = Hive.box('settingsBox');
    final isDark = box.get('dark_mode_enabled', defaultValue: false);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(bool isDark) async {
    final box = Hive.box('settingsBox');
    await box.put('dark_mode_enabled', isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

  await Hive.initFlutter();
  await CachingService.init();

  // Sync subjects, topics, and mocks from local assets before rendering UI
  await CachingService.syncAppStructure();

  runApp(
    const ProviderScope(
      child: PYQApp(),
    ),
  );
}

class PYQApp extends ConsumerWidget {
  const PYQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // Load theme from Hive on first build
    if (themeMode == ThemeMode.light) {
      Future.microtask(() => ref.read(themeModeProvider.notifier).loadTheme());
    }
    return MaterialApp(
      title: 'Railway PYQ App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }
}