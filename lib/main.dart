import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/image_carousel.dart';
import 'widgets/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const ImageCarousel(),
      },
      theme: ThemeData(
        primaryColor: const Color(0xFF1F2D5C),
        scaffoldBackgroundColor: const Color.fromARGB(255, 252, 232, 179),
        fontFamily: GoogleFonts.poppins().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2D5C),
          foregroundColor: Color(0xFFF2D68A),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF111A33)),
          bodyMedium: TextStyle(color: Color(0xFF111A33)),
          titleLarge: TextStyle(
            color: Color(0xFF1F2D5C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
