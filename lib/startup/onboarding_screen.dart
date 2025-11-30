import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 60.0, bottom: 40.0),
                    child: Text(
                      'Stay on Top of your Spending',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.8,
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/logo/wallet.png'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Text(
                      'Quickly log expenses and see\nwhere your money goes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.5,
                        height: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      // Mark onboarding as complete
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_complete', true);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const OnBoardingPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF387E5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
