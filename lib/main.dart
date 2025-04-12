import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prospekt/auth_pages/login_screen.dart';
import 'package:prospekt/screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder(
        future: _checkAuthState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            print("Error checking auth state: ${snapshot.error}");
            return const SplashScreen(nextScreen: OnboardingScreen());
          } else {
            final User? user = snapshot.data as User?;
            // If user is already signed in, go directly to home screen
            if (user != null) {
              return const HomeScreen();
            }
            // Otherwise, start with the splash and onboarding flow
            return const SplashScreen(nextScreen: OnboardingScreen());
          }
        },
      ),
    );
  }

  // Separate method to check auth state with error handling
  Future<User?> _checkAuthState() async {
    try {
      return await FirebaseAuth.instance.authStateChanges().first;
    } catch (e) {
      print("Exception during auth state check: $e");
      // If there's a Pigeon/type cast error, return null instead of propagating the error
      if (e.toString().contains("Pigeon") ||
          e.toString().contains("is not a subtype")) {
        return null;
      }
      // For other errors, rethrow to be caught by the FutureBuilder's error handler
      rethrow;
    }
  }
}
