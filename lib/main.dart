import 'package:ai_search/pages/home_page.dart';
import 'package:ai_search/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:admanager_web/admanager_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdManagerWeb.init();

  try {
    await dotenv.load(fileName: "assets/.env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.submitButton),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.copyWith(
            bodyMedium: const TextStyle(
              fontSize: 15,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
