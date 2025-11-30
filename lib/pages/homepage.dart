import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'addwallet.dart';
import 'addexpenses.dart';
import 'adduser.dart';
import 'expenses.dart';
import 'settings.dart';
import 'sharedbudget.dart';

// Theme colors
const Color _accentGreen = Color(0xFF94A780);
const Color _centerButtonColor = Colors.orange;
const Color _popUpGreen = Color(0xFF558B6E);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showAddMenu = false;
  double totalBalance = 0.0; // <-- dynamic balance

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  void _toggleAddMenu() {
    setState(() {
      _showAddMenu = !_showAddMenu;
    });
  }

  /// Fetch wallets and calculate total balance
  Future<void> _fetchBalance() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      QuerySnapshot walletsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .get();

      double sum = 0.0;
      for (var doc in walletsSnapshot.docs) {
        sum += (doc['balance'] ?? 0).toDouble();
      }

      setState(() {
        totalBalance = sum;
      });
    } catch (e) {
      print('Error fetching balance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showAddMenu) _toggleAddMenu();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Stack(
          children: [
            SafeArea(
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

                    // ----------------- INSIGHT CARD -----------------
                    Center(
                      child: Container(
                        width: 330,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "INSIGHT ",
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Color(0xFFE0A20C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " into",
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "every ",
                                    style: TextStyle(fontSize: 22, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: "PESO",
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: const Color(0xFF0E8A41),
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
                          children: [
                            const StatusItem(
                              icon: Icons.wallet,
                              label: "Spending",
                              amount: "-₱10,000",
                              color: Colors.red,
                            ),
                            const StatusItem(
                              icon: Icons.attach_money,
                              label: "Income",
                              amount: "₱15,000",
                              color: Colors.green,
                            ),
                            StatusItem(
                              icon: Icons.savings,
                              label: "Balance",
                              amount: "₱${totalBalance.toStringAsFixed(2)}", // <-- dynamic balance
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
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
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

            if (_showAddMenu) _buildAddMenuOverlay(context),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  /// Pop-Up Menu Widget, positioned above the Navigation Bar
  Widget _buildAddMenuOverlay(BuildContext context) {
    // The Positioned widget places the menu in the Stack
    return Positioned(
      // 70 (NavBar height) + ~30 (margin/padding) = 100
      bottom: 250, 
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 230, // Adjust width to fit the pop-up look
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

            if (text == 'Add Wallet') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWalletPage()),
              );
            } else if (text == 'Add User') {
              // New logic for Add User
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUserPage()),
              );
            } else if (text == 'Add Expenses') {
              // New logic for Add Expenses
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpensePage()),
              );
            } else {
              // Handle other actions like 'Add User' or 'Add Expenses'
              print('$text clicked!');
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

  /// Bottom Navigation Bar implementation (mostly reused from your code)
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
          // Interactive Center Button
          InkWell(
            onTap: _toggleAddMenu, // Toggles the pop-up menu
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

  // Nav Bar Item helper function
  Widget _navBarItem(BuildContext context, IconData icon, Widget targetPage, {bool isCurrent = false}) {
    return InkWell(
      onTap: () {
        // Prevent navigating if the current page is already selected or if we're tapping the 'Add' button placeholder
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

// ----------------- STATUS WIDGET (Reused) -----------------
class StatusItem extends StatelessWidget {
// ... (StatusItem code remains the same)
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

// ----------------- ACTIVITY ITEM (Reused) -----------------
class ActivityItem extends StatelessWidget {
// ... (ActivityItem code remains the same)
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