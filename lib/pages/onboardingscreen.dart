import 'package:finsight/login/signup/signUp.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the screen width for responsive padding
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08), // Dynamic horizontal padding
          child: Column(
            // Use spaceBetween to push the content and button apart
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // TOP CONTENT: Title, Image, and Description
              Column(
                children: <Widget>[
                  // Title Text: "Build Better Habits"
                  const Padding(
                    padding: EdgeInsets.only(top: 60.0, bottom: 85.0),
                    child: Text(
                      'Build Better Habits',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Georgia', // Approximation of the serif font
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.8,
                    color: Colors.transparent, // Transparent background
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/logo/piggybank.png')
                  ),

                  // Description Text
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Text(
                      'Set goals and watch your\nsavings grow automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.5,
                        height: 1.5, // Line spacing
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              // BOTTOM: Continue Button
              Padding(
                // Add some bottom padding to lift it slightly from the bottom edge
                padding: const EdgeInsets.only(bottom: 30.0),
                child: SizedBox(
                  width: double.infinity, // Full width button
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF387E5A), // Approximate green/sage color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
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