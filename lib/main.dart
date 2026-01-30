// lib/main.dart
// P1: Added GlobalErrorHandler for centralized error handling

import 'package:beitak_app/core/cache/prefs_cache.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/error/global_error_handler.dart';
import 'package:beitak_app/core/routes/app_router.dart';
import 'package:beitak_app/core/security/secure_token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ P1: Initialize global error handler first
  GlobalErrorHandler.init();

  // ✅ P1: Pre-warm SharedPreferences to avoid blocking I/O in routes
  await PrefsCache.init();

  // ✅ P0: Clean up stale/expired sessions on startup
  await SecureTokenStorage.migrateAndCleanup();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // ✅ P1: Run app in guarded zone to catch async errors
  GlobalErrorHandler.runGuarded(
    () => runApp(
      const ProviderScope(
        child: BeitakApp(),
      ),
    ),
  );
}

class BeitakApp extends ConsumerWidget {
  const BeitakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'بيتك',

      // ✅ مهم جداً لتفعيل Restoration عبر التطبيق
      restorationScopeId: 'app',

      theme: ThemeData(
        fontFamily: 'Cairo',
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.white,
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
