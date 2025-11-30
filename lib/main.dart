import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'startup/finsight_welcome.dart';
import 'login/signup/singin.dart';
import 'pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // ⭐️ NEW: Optional parameter to override the onboarding check for testing
  final bool? onboardingCompleteOverride;

  const MyApp({super.key, this.onboardingCompleteOverride});

  // Function to check onboarding status, prioritizing the override
  Future<bool> checkOnboarding() async {
    // If the override is set, use it immediately
    if (onboardingCompleteOverride != null) {
      return onboardingCompleteOverride!;
    }
    
    // Otherwise, check SharedPreferences (normal runtime behavior)
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinSight',
      theme: ThemeData(primarySwatch: Colors.green),
      home: FutureBuilder<bool>(
        // FutureBuilder calls the modified checkOnboarding function
        future: checkOnboarding(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // Show loading screen while checking
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          bool onboardingComplete = snapshot.data ?? false;

          // Check if user is already logged in
          // Note: In a real test, you'd need to mock FirebaseAuth
          User? currentUser = FirebaseAuth.instance.currentUser;

          if (!onboardingComplete) {
            return const FinSightWelcomeScreen();
          } else {
            // If user exists, go to HomePage; otherwise SignIn
            return currentUser != null ? const HomePage() : const SigninPage();
          }
        },
      ),
    );
  }
}