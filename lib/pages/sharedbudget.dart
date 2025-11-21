import 'package:finsight/pages/expenses.dart';
import 'package:finsight/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:finsight/pages/homepage.dart';

// Theme colors
const Color _primaryGreen = Color(0xFF0D532E);
const Color _accentGreen = Color(0xFF94A780);
const Color _buttonColor = Color(0xFFC8E6C9);
const Color _centerButtonColor = Colors.orange;


class SharedBudget extends StatelessWidget {
  const SharedBudget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // ---------------- TOP BAR ----------------
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      "SHARED  BUDGET",
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

      // ---------------- BOTTOM NAV BAR ----------------
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}

  // Same bottom nav bar implementation used across all pages for consistency
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
          _navBarItem(context, Icons.groups_2, const SharedBudget(), isCurrent: true),
          const CircleAvatar(
            radius: 28,
            backgroundColor: _centerButtonColor,
            child: Icon(Icons.add, color: Colors.white, size: 34),
          ),
          // Highlight Expenses icon since we are on the ExpensesPage
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

//
// ---------------- SHARED BUDGET CARD ----------------
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
                "Aleisha Arindaeng",
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
