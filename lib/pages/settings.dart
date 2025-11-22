import 'package:finsight/login/signup/singin.dart';
import 'package:finsight/pages/homepage.dart';
import 'package:finsight/pages/sharedbudget.dart';
import 'package:finsight/pages/expenses.dart'; 
import 'package:flutter/material.dart';

// Assuming these pages exist and were imported in the context of the previous request
import 'package:finsight/pages/addexpenses.dart';
import 'package:finsight/pages/adduser.dart';
import 'package:finsight/pages/addwallet.dart';

// Theme colors
const Color _primaryGreen = Color(0xFF0D532E);
const Color _accentGreen = Color(0xFF94A780);
const Color _buttonColor = Color(0xFFC8E6C9);
const Color _centerButtonColor = Colors.orange;
const Color _popUpGreen = Color(0xFF558B6E); // Dark Green for pop-up

// Convert to StatefulWidget to manage the pop-up state
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State variable to control the visibility of the pop-up menu
  bool _showAddMenu = false;

  void _toggleAddMenu() {
    setState(() {
      _showAddMenu = !_showAddMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire screen in a GestureDetector to close the menu when tapping anywhere outside
    return GestureDetector(
      onTap: () {
        if (_showAddMenu) {
          _toggleAddMenu();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'SETTINGS',
            style: TextStyle(
              color: _primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // 1. Main Content Area
            SafeArea(
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
                      icon: Icons.work_outline,
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
                      icon: Icons.settings,
                      title: 'App Preferences',
                      onTap: () => print('Navigate to App Preferences'),
                    ),
        
                    const SizedBox(height: 60),
                    // --- SIGN OUT BUTTON ---
                    ElevatedButton(
                      onPressed: () {
                        // Close menu if open, then navigate
                        if (_showAddMenu) _toggleAddMenu();
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SigninPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor,
                        foregroundColor: _primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: _primaryGreen, width: 2),
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

            // 2. Pop-Up Menu Overlay (only visible when _showAddMenu is true)
            if (_showAddMenu) _buildAddMenuOverlay(context),
          ],
        ),
        // ----------------- CONSISTENT BOTTOM NAV BAR -----------------
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  // --- Start of Reused Pop-Up Logic ---

  /// Pop-Up Menu Widget, positioned above the Navigation Bar
  Widget _buildAddMenuOverlay(BuildContext context) {
    return Positioned(
      bottom: 31, 
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 230,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: _popUpGreen,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPopUpButton('Add Wallet'),
              _buildPopUpButton('Add User'),
              _buildPopUpButton('Add Expenses'),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper for the white buttons inside the pop-up menu
  Widget _buildPopUpButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _toggleAddMenu(); // Close the menu regardless of the action

            // Handle navigation based on the button text
            if (text == 'Add Wallet') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWalletPage()),
              );
            } else if (text == 'Add User') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUserPage()),
              );
            } else if (text == 'Add Expenses') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpensePage()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 1,
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // --- End of Reused Pop-Up Logic ---


  // Helper widget for a clean, reusable settings list item (copied from original)
  Widget _buildSettingsListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: _primaryGreen),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  color: _primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Consistent Bottom Navigation Bar helper (Updated to include _toggleAddMenu)
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
          // Interactive Center Button
          InkWell(
            onTap: _toggleAddMenu, // Toggles the pop-up menu
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: _centerButtonColor,
              child: Icon(Icons.add, color: Colors.white, size: 34),
            ),
          ),
          _navBarItem(
            context,
            Icons.credit_card_outlined,
            const ExpensesPage(),
          ),
          // Highlight Settings icon since we are on the SettingsPage
          _navBarItem(
            context,
            Icons.settings,
            const SettingsPage(),
            isCurrent: true,
          ),
        ],
      ),
    );
  }

  Widget _navBarItem(
    BuildContext context,
    IconData icon,
    Widget targetPage, {
    bool isCurrent = false,
  }) {
    return InkWell(
      onTap: () {
        // Prevent navigating if the current page is already selected
        if (!isCurrent) {
          // Close the add menu if it's open before navigating
          if (_showAddMenu) _toggleAddMenu();

          // Use pushReplacement to switch main tabs without stacking history
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        }
      },
      child: Icon(
        icon,
        color: isCurrent ? Colors.white : Colors.white70,
        size: 32,
      ),
    );
  }
}