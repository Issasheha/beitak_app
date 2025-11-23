// lib/main.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); 
  runApp(const BeitakApp());
}

class BeitakApp extends StatelessWidget {
  const BeitakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'بيتك',
      theme: ThemeData(
        fontFamily: 'Cairo',
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.white,
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}