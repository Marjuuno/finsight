import 'package:finsight/pages/addexpenses.dart';
import 'package:finsight/pages/adduser.dart';
import 'package:finsight/pages/addwallet.dart';
import 'package:finsight/pages/expenses.dart';
import 'package:finsight/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:finsight/pages/homepage.dart';
// Note: We keep the import for the current page (SharedBudget) as it may be navigated to from other pages.
// import 'package:finsight/pages/sharedbudget.dart'; 


// Theme colors (redefined for completeness)
const Color _accentGreen = Color(0xFF94A780);
const Color _centerButtonColor = Colors.orange;
const Color _popUpGreen = Color(0xFF558B6E); 


// Convert to StatefulWidget to manage the pop-up state
class SharedBudget extends StatefulWidget {
  const SharedBudget({super.key});

  @override
  State<SharedBudget> createState() => _SharedBudgetState();
}

class _SharedBudgetState extends State<SharedBudget> {
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
        backgroundColor: const Color(0xFFF7F7F7),

        // Use Stack to layer the main content and the pop-up menu
        body: Stack(
          children: [
            // 1. Main Content Area
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- TOP BAR ----------------
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          const Text(
                            "SHARED  BUDGET",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC79205),
                            ),
                          ),
                          const Icon(Icons.notifications_none, size: 28),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------- BUDGET CARDS ----------------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: const [
                          SharedBudgetCard(),
                          SizedBox(height: 20),
                          SharedBudgetCard(),
                          SizedBox(height: 20),
                          SharedBudgetCard(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // 2. Pop-Up Menu Overlay (only visible when _showAddMenu is true)
            if (_showAddMenu) _buildAddMenuOverlay(context),
          ],
        ),
        // ---------------- BOTTOM NAV BAR ----------------
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  // --- Start of Reused Pop-Up Logic ---

  /// Pop-Up Menu Widget, positioned above the Navigation Bar
  Widget _buildAddMenuOverlay(BuildContext context) {
    // The Positioned widget places the menu in the Stack
    return Positioned(
      // 70 (NavBar height) + ~30 (margin/padding) = 100
      bottom: 191, 
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 230, // Adjust width to fit the pop-up look
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: Color(0xFF387E5A),
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


  // Same bottom nav bar implementation used across all pages for consistency
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF387E5A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navBarItem(context, Icons.home, const HomePage()),
          _navBarItem(context, Icons.groups_2, const SharedBudget(), isCurrent: true),
          
          // The ADD button now uses the toggle function
          InkWell( 
            onTap: _toggleAddMenu,
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: _centerButtonColor,
              child: Icon(Icons.add, color: Colors.white, size: 34),
            ),
          ),
          
          _navBarItem(context, Icons.credit_card_outlined, const ExpensesPage()), 
          _navBarItem(context, Icons.settings, const SettingsPage()),
        ],
      ),
    );
  }

  Widget _navBarItem(BuildContext context, IconData icon, Widget targetPage, {bool isCurrent = false}) {
    return InkWell(
      onTap: () {
        // Use pushReplacement to prevent building up a huge navigation stack for main tabs
        if (!isCurrent) {
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

//
// ---------------- SHARED BUDGET CARD (Remains the same) ----------------
//
class SharedBudgetCard extends StatelessWidget {
  const SharedBudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Name + View Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Kevin Vega",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF0E8A41)),
                ),
                child: const Text(
                  "View",
                  style: TextStyle(
                    color: Color(0xFF0E8A41),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Budget Headers
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Budget", style: TextStyle(color: Colors.grey)),
              Text("Spent Budget", style: TextStyle(color: Colors.grey)),
              Text("Remaining Budget", style: TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 16),

          // Avatars & Add User
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _avatar("assets/user1.png"),
                  const SizedBox(width: 5),
                  _avatar("assets/user2.png"),
                  const SizedBox(width: 5),
                  _avatar("assets/user3.png"),
                  const SizedBox(width: 5),
                  const Text(
                    "+1",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Add User button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E8A41),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "+ Add User",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // avatar widget
  static Widget _avatar(String path) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: AssetImage(path),
    );
  }
}