import 'package:finsight/pages/expenses.dart';
import 'package:finsight/pages/settings.dart';
import 'package:finsight/pages/sharedbudget.dart';
import 'package:flutter/material.dart';


// Theme colors
const Color _primaryGreen = Color(0xFF0D532E);
const Color _accentGreen = Color(0xFF94A780);
const Color _buttonColor = Color(0xFFC8E6C9);
const Color _centerButtonColor = Colors.orange;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------- HEADER -----------------
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CC9A0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Hello, User!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Icon(Icons.notifications_none, size: 28),
                  ],
                ),
              ),

// ----------------- INSIGHT CARD (FIXED) -----------------
              Center(
                child: Container(
                  width: 330,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Column( // Removed const here because of dynamic Text.rich
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // First line: "INSIGHT into"
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "INSIGHT ",
                              style: TextStyle(
                                fontSize: 28,
                                color: Color(0xFFE0A20C), // Golden color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: " into", // Space included for separation
                              style: TextStyle(
                                fontSize: 22, // Slightly smaller than INSIGHT
                                color: Colors.black, // Default text color
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Second line: "every PESO"
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "every ",
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: " PESO",
                              style: TextStyle(
                                fontSize: 28,
                                color: Color(0xFF0E8A41), // Green color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ----------------- STATUS -----------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Status",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Container(
                  width: 330,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAFBCA8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      StatusItem(
                        icon: Icons.wallet,
                        label: "Spending",
                        amount: "-₱10,000",
                        color: Colors.red,
                      ),
                      StatusItem(
                        icon: Icons.attach_money,
                        label: "Income",
                        amount: "₱15,000",
                        color: Colors.green,
                      ),
                      StatusItem(
                        icon: Icons.savings,
                        label: "Balance",
                        amount: "₱5,000",
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ----------------- ACTIVITY -----------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Activity",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Container(
                  width: 330,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: const Column(
                    children: [
                      ActivityItem(
                        icon: Icons.home,
                        title: "Home",
                        date: "10/08/25",
                        amount: "-₱1500",
                      ),
                      ActivityItem(
                        icon: Icons.fastfood,
                        title: "Food and Drinks",
                        date: "10/08/25",
                        amount: "-₱500",
                      ),
                      ActivityItem(
                        icon: Icons.cleaning_services,
                        title: "Personal Care",
                        date: "10/08/25",
                        amount: "-₱300",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
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
          _navBarItem(context, Icons.home, const HomePage(), isCurrent: true),
          _navBarItem(context, Icons.groups_2, const SharedBudget()),
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

// ----------------- STATUS WIDGET -----------------
class StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  const StatusItem({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        const SizedBox(height: 6),
        Text(
          amount,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

// ----------------- ACTIVITY ITEM -----------------
class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Icon(icon, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(date, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
