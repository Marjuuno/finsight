// File: settings_page.dart

import 'package:finsight/login/signup/singin.dart';
import 'package:finsight/pages/homepage.dart';
import 'package:finsight/pages/sharedbudget.dart';
import 'package:finsight/pages/expenses.dart';
import 'package:finsight/pages/addexpenses.dart';
import 'package:finsight/pages/adduser.dart';
import 'package:finsight/pages/addwallet.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Theme colors
const Color _primaryGreen = Color(0xFF0D532E);
const Color _accentGreen = Color(0xFF94A780);
const Color _buttonColor = Color(0xFFC8E6C9);
const Color _centerButtonColor = Colors.orange;
const Color _popUpGreen = Color(0xFF558B6E);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showAddMenu = false;

  void _toggleAddMenu() {
    setState(() {
      _showAddMenu = !_showAddMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showAddMenu) _toggleAddMenu();
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
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSettingsListTile(
                        context: context,
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () => print('Navigate to Profile')),
                    _buildSettingsListTile(
                        context: context,
                        icon: Icons.notifications_none,
                        title: 'Notifications',
                        onTap: () => print('Navigate to Notifications')),
                    _buildSettingsListTile(
                        context: context,
                        icon: Icons.work_outline,
                        title: 'Linked Wallets',
                        onTap: () => print('Navigate to Linked Wallets')),
                    _buildSettingsListTile(
                        context: context,
                        icon: Icons.people_outline,
                        title: 'Roles',
                        onTap: () => print('Navigate to Roles')),
                    _buildSettingsListTile(
                        context: context,
                        icon: Icons.settings,
                        title: 'App Preferences',
                        onTap: () => print('Navigate to App Preferences')),

                    const SizedBox(height: 60),

                    // Sign Out Button
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Firebase logout
                          await FirebaseAuth.instance.signOut();

                          // Close menu if open
                          if (_showAddMenu) _toggleAddMenu();

                          // Navigate to SignInPage and remove history
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SigninPage()),
                            (Route<dynamic> route) => false,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to sign out: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pop-up Add Menu
            if (_showAddMenu) _buildAddMenuOverlay(context),
          ],
        ),

        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  // Pop-Up Menu Overlay
  Widget _buildAddMenuOverlay(BuildContext context) {
    return Positioned(
      bottom: 31,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 230,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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

  Widget _buildPopUpButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _toggleAddMenu();
            if (text == 'Add Wallet') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddWalletPage()));
            } else if (text == 'Add User') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddUserPage()));
            } else if (text == 'Add Expenses') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddExpensePage()));
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

  Widget _buildSettingsListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 26, color: _primaryGreen),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 20, color: _primaryGreen, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          InkWell(
            onTap: _toggleAddMenu,
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: _centerButtonColor,
              child: Icon(Icons.add, color: Colors.white, size: 34),
            ),
          ),
          _navBarItem(context, Icons.credit_card_outlined, const ExpensesPage()),
          _navBarItem(context, Icons.settings, const SettingsPage(), isCurrent: true),
        ],
      ),
    );
  }

  Widget _navBarItem(BuildContext context, IconData icon, Widget targetPage,
      {bool isCurrent = false}) {
    return InkWell(
      onTap: () {
        if (!isCurrent) {
          if (_showAddMenu) _toggleAddMenu();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        }
      },
      child: Icon(icon, color: isCurrent ? Colors.white : Colors.white70, size: 32),
    );
  }
}
