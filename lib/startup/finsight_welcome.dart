import 'package:finsight/startup/onboarding_screen.dart';
import 'package:flutter/material.dart';

class FinSightWelcomeScreen extends StatelessWidget {
  const FinSightWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                AppIconWidget(),
                SizedBox(height: 120.0),
                Text(
                  'FinSight',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Smart Expense & Savings Tracker',
                  style: TextStyle(
                    fontSize: 17.5,
                    color: Color.fromARGB(208, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 120.0),
                LetsBeginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppIconWidget extends StatelessWidget {
  const AppIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Image.asset('assets/images/logo/finsight.png'),
    );
  }
}

class LetsBeginButton extends StatelessWidget {
  const LetsBeginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 50,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF387E5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Let's Begin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
