import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MarketPulseApp());
}

class MarketPulseApp extends StatelessWidget {
  const MarketPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Pulse',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 공통 스타일
class AppStyles {
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 20.0;
  static const borderRadius = 10.0;

  static const Color primary = Color(0xFF8A6FA0);
  static const Color naver = Color(0xFF03C75A);
  static const Color kakao = Color(0xFFFEE500);

  static InputDecoration input(String text) {
    return InputDecoration(
      hintText: text,
      filled: true,
      fillColor: const Color(0xFFFDF4F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFE9E0EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFCFB8D7)),
      ),
    );
  }
}
