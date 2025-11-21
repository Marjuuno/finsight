import 'package:finsight/pages/homepage.dart';
import 'package:finsight/pages/sharedbudget.dart';
import 'package:finsight/pages/expenses.dart'; // Import the new ExpensesPage
import 'package:flutter/material.dart';

// Theme colors
const Color _primaryGreen = Color(0xFF0D532E);
const Color _accentGreen = Color(0xFF94A780);
const Color _buttonColor = Color(0xFFC8E6C9);
const Color _centerButtonColor = Colors.orange;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SETTINGS', // Title case from image
          style: TextStyle(
            color: _primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 2, // Added letter spacing to match the image
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SETTINGS LIST ITEMS ---
              _buildSettingsListTile(
                context: context,
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () => print('Navigate to Profile'),
              ),
              _buildSettingsListTile(
                context: context,
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () => print('Navigate to Notifications'),
              ),
              _buildSettingsListTile(
                context: context,
                icon: Icons.work_outline, // Changed to match image icon
                title: 'Linked Wallets',
                onTap: () => print('Navigate to Linked Wallets'),
              ),
              _buildSettingsListTile(
                context: context,
                icon: Icons.people_outline,
                title: 'Roles',
                onTap: () => print('Navigate to Roles'),
              ),
              _buildSettingsListTile(
                context: context,
                icon: Icons.settings, // Cog icon from image
                title: 'App Preferences',
                onTap: () => print('Navigate to App Preferences'),
              ),

              const SizedBox(height: 60), // Increased spacing before button

              // --- SIGN OUT BUTTON ---
              ElevatedButton(
                onPressed: () => print('Sign Out Tapped'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  foregroundColor: _primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: _primaryGreen,
                      width: 2,
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),

      // ----------------- CONSISTENT BOTTOM NAV BAR -----------------
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Helper widget for a clean, reusable settings list item
  Widget _buildSettingsListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Adjusted padding to match image
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: _primaryGreen,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20, // Adjusted font size to match image
                  color: _primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Removed chevron_right icon as it's not present in the image
          ],
        ),
      ),
    );
  }
  
  // Consistent Bottom Navigation Bar helper
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _accentGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navBarItem(context, Icons.home, const HomePage()),
          _navBarItem(context, Icons.groups_2, const SharedBudget()),
          const CircleAvatar(
            radius: 28,
            backgroundColor: _centerButtonColor,
            child: Icon(Icons.add, color: Colors.white, size: 34),
          ),
          _navBarItem(context, Icons.credit_card_outlined, const ExpensesPage()),
          // Highlight Settings icon since we are on the SettingsPage
          _navBarItem(context, Icons.settings, const SettingsPage(), isCurrent: true),
        ],
      ),
    );
  }

  Widget _navBarItem(BuildContext context, IconData icon, Widget targetPage, {bool isCurrent = false}) {
    return InkWell(
      onTap: () {
        // Use pushReplacement to switch main tabs without stacking history
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Icon(
        icon,
        color: isCurrent ? Colors.white : Colors.white70, 
        size: 32,
      ),
    );
  }
}