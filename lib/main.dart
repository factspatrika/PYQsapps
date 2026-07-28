import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'data/repositories/caching_service.dart';
import 'data/repositories/notification_service.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box('settingsBox');
    final isDark = box.get('dark_mode_enabled', defaultValue: true) as bool;
    return isDark ? ThemeMode.dark : ThemeMode.light;
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

  // Force default Dark Mode for existing cached settings if v2 key missing
  final settingsBox = Hive.box('settingsBox');
  if (!settingsBox.containsKey('dark_mode_default_applied')) {
    await settingsBox.put('dark_mode_enabled', true);
    await settingsBox.put('dark_mode_default_applied', true);
  }

  // Initialize and schedule notifications
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await NotificationService.init();
    await NotificationService.scheduleDailyTenQuestionsNotification();
  }

  // Sync subjects, topics, and mocks from local assets before rendering UI
  await CachingService.syncAppStructure();
  await CachingService.syncAppConfig();

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
    final box = Hive.box('settingsBox');
    final bool onboardingCompleted = box.get('onboarding_v2_completed', defaultValue: false) as bool;

    return MaterialApp(
      title: 'Railways Science PYQs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: onboardingCompleted ? const DashboardScreen() : const OnboardingScreen(),
    );
  }
}