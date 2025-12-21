// lib/main.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/routes/app_router.dart'; // فيه goRouterProvider
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(
    const ProviderScope(
      child: BeitakApp(),
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
