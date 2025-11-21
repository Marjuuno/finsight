import 'package:finsight/pages/secondstartup.dart';
import 'package:flutter/material.dart';

class FinSightWelcomeScreen extends StatelessWidget {
  const FinSightWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structure for the screen
    return const Scaffold(
      // Setting background to white, matching the image
      backgroundColor: Colors.white,
      body: SafeArea(
        // Centering all content vertically and horizontally
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              // Aligning children towards the center of the vertical axis
              mainAxisAlignment: MainAxisAlignment.center,
              // Allowing elements to take their natural width
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // 1. App Icon (Replicated with a Container and Icon)
                // The icon is a placeholder for a custom image/asset.
                // It uses a dark green background and a white target/money icon.
                AppIconWidget(),
                SizedBox(height: 120.0), // Spacing after the icon

                // 2. App Name - FinSight
                Text(
                  'FinSight',
                      style: TextStyle(
                        fontFamily: 'Georgia', // Approximation of the serif font
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
                SizedBox(height: 10.0), // Spacing between title and subtitle

                // 3. Subtitle - Smart Expense & Savings Tracker
                Text(
                  'Smart Expense & Savings Tracker',
                  style: TextStyle(
                    fontSize: 17.5,
                    color: Color.fromARGB(208, 0, 0, 0), // Lighter text color for the subtitle
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

// Custom Widget for the App Icon
class AppIconWidget extends StatelessWidget {
  const AppIconWidget({super.key});

  // Defining the primary green color from the image
  static const Color primaryGreen = Color(0xFF387E5A); 

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        // Using the identified green color
        color: Colors.white, 
        // Adding a slight border radius to match the image's rounded square
        borderRadius: BorderRadius.circular(18.0), 
        // Optional: slight shadow to give depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
        // Placeholder icon combining a target and a currency symbol
        child: Image.asset('assets/images/logo/finsight.png')
    );
  }
}

// Custom Widget for the "Let's Begin" Button
class LetsBeginButton extends StatelessWidget {
  const LetsBeginButton({super.key});

  // Defining the button's slightly muted green color from the image
  static const Color buttonGreen = Color(0xFF387E5A); 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Making the button wide but centered
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
          // Background color matching the button in the image
          backgroundColor: buttonGreen, 
          shape: RoundedRectangleBorder(
            // Matching the curved edges of the button
            borderRadius: BorderRadius.circular(10), 
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
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
