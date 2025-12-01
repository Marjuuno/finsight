import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'addwallet.dart';
import 'addexpenses.dart';
import 'adduser.dart';
import 'expenses.dart';
import 'settings.dart';
import 'sharedbudget.dart';

// Theme colors
const Color _centerButtonColor = Colors.orange;
const Color _primaryGreen = Color(0xFF0D532E);
const Color _activityCardColor = Color(0xFFF5F5F5); // Background for the Scaffold
const Color _cardWhite = Colors.white; // Background for the activity list

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showAddMenu = false;
  double totalIncome = 0.0;
  double totalSpending = 0.0;
  double totalBalance = 0.0;
  double totalTodaySpending = 0.0;
  List<Map<String, dynamic>> todayExpenses = [];
  List<Map<String, dynamic>> displayedExpenses = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _toggleAddMenu() {
    setState(() {
      _showAddMenu = !_showAddMenu;
    });
  }

  /// Fetch wallets and expenses
  Future<void> _fetchData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      double sumIncome = 0.0;
      double sumSpending = 0.0;
      double sumTodaySpending = 0.0;
      List<Map<String, dynamic>> fetchedTodayExpenses = [];
      List<Map<String, dynamic>> fetchedOlderExpenses = [];
      
      final DateTime now = DateTime.now();
      final String todayKey = DateFormat('yyyy-MM-dd').format(now);

      // Fetch wallets
      QuerySnapshot walletsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .get();

      for (var doc in walletsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        sumIncome += (data['balance'] ?? 0).toDouble();
      }

      // Fetch expenses (Sorted by date descending for recency)
      QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      for (var doc in expensesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double amount = 0.0;
        if (data.containsKey('amount')) {
          if (data['amount'] is num) {
            amount = data['amount'].toDouble();
          } else if (data['amount'] is String) {
            amount = double.tryParse(data['amount']) ?? 0.0;
          }
        }
        
        DateTime date = data['date'] != null
            ? (data['date'] is Timestamp
                ? (data['date'] as Timestamp).toDate()
                : DateTime.tryParse(data['date'].toString()) ?? DateTime.now())
            : DateTime.now();
            
        final expenseDateKey = DateFormat('yyyy-MM-dd').format(date);
        
        sumSpending += amount;

        Map<String, dynamic> expenseItem = {
          'category': data['category'] ?? 'Unknown',
          'amount': amount,
          // Normalize date to start of day
          'date': date.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0),
        };

        // Separate Today's expenses
        if (expenseDateKey == todayKey) {
            sumTodaySpending += amount;
            fetchedTodayExpenses.add(expenseItem);
        } else {
            fetchedOlderExpenses.add(expenseItem);
        }
      }

      // --- Logic to enforce Max 4 Items ---
      List<Map<String, dynamic>> combinedList = [];
      combinedList.addAll(fetchedTodayExpenses);
      
      // Calculate how many older items can be added (max 4 total)
      int remainingSlots = 4 - fetchedTodayExpenses.length;
      if (remainingSlots > 0) {
        combinedList.addAll(fetchedOlderExpenses.take(remainingSlots));
      }
      
      // If combinedList is empty, and there are older expenses, show the 4 most recent ones (if 0 today)
      if (fetchedTodayExpenses.isEmpty && fetchedOlderExpenses.isNotEmpty) {
        combinedList.addAll(fetchedOlderExpenses.take(4));
      }
      // ------------------------------------

      setState(() {
        totalIncome = sumIncome;
        totalSpending = sumSpending;
        totalBalance = totalIncome - sumSpending;
        totalTodaySpending = sumTodaySpending; 
        todayExpenses = fetchedTodayExpenses; 
        displayedExpenses = combinedList.take(4).toList(); // Ensure max 4 items are displayed
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String _formatDate(DateTime date) {
    // Format date as MM/dd/yy
    return DateFormat('MM/dd/yy').format(date);
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'health': return Icons.favorite_border;
      case 'transport': return Icons.directions_car_filled_outlined;
      case 'education': return Icons.school_outlined;
      case 'subscription': return Icons.calendar_month_outlined;
      case 'groceries': return Icons.shopping_basket_outlined;
      case 'food': return Icons.fastfood_outlined;
      case 'daily': return Icons.local_mall_outlined;
      case 'bills': return Icons.receipt_long_outlined;
      case 'house': return Icons.home_outlined;
      case 'clothing': return Icons.checkroom_outlined;
      case 'self-care': return Icons.spa_outlined;
      case 'others': return Icons.devices_other_sharp;
      default: return Icons.paste_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showAddMenu) _toggleAddMenu();
      },
      child: Scaffold(
        backgroundColor: _activityCardColor,
        body: Stack(
          children: [
            SafeArea(
              // 🎯 CHANGE 1: Removed SingleChildScrollView
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF387E5A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Hello, User!",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.notifications_none, size: 28),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Insight Card (UNCHANGED)
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Color.fromARGB(93, 0, 0, 0), blurRadius: 10)],
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(
                                    text: " into",
                                    style: TextStyle(fontSize: 22, color: Colors.black),
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
                                  const TextSpan(
                                    text: "PESO",
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: Color(0xFF0E8A41),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status Section (UNCHANGED)
                    const Text("Status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Color(0xFF387E5A),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            StatusItem(
                                icon: Icons.wallet,
                                label: "Spending",
                                amount: "-₱${totalSpending.toStringAsFixed(2)}",
                                color: Colors.red),
                            StatusItem(
                                icon: Icons.attach_money,
                                label: "Income",
                                amount: "₱${totalIncome.toStringAsFixed(2)}",
                                color: const Color.fromARGB(255, 7, 209, 14)),
                            StatusItem(
                                icon: Icons.savings,
                                label: "Balance",
                                amount: "₱${totalBalance.toStringAsFixed(2)}",
                                color: Colors.black87),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Activity Section Title
                    const Text("Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    // 🎯 CHANGE 2: Used Expanded to force the list to fill the remaining space
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardWhite,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Today Header with Total
                            if (todayExpenses.isNotEmpty || displayedExpenses.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Today",
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "-₱${totalTodaySpending.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // 2. Expenses List (Max 4 items enforced by displayedExpenses list)
                            if (displayedExpenses.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    "No expenses recorded yet.",
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else 
                              // Use Expanded and ListView.builder to fill the rest of the card space
                              // If there are more than ~4-5 items, the card will become internally scrollable.
                              Expanded( 
                                child: ListView.builder(
                                  // Removed NeverScrollableScrollPhysics to allow internal scrolling if content exceeds space
                                  shrinkWrap: true,
                                  itemCount: displayedExpenses.length,
                                  itemBuilder: (context, index) {
                                    final expense = displayedExpenses[index];
                                    final isToday = todayExpenses.contains(expense);
                                    
                                    return CustomActivityItem( 
                                      icon: _getIconForCategory(expense['category']),
                                      title: expense['category'],
                                      date: _formatDate(expense['date']),
                                      amount: "-₱${expense['amount'].toStringAsFixed(0)}",
                                      color: isToday ? Colors.red.shade400 : Colors.red.shade400, 
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // 🎯 CHANGE 3: Removed SizedBox(height: 100)
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

  // --- Utility Methods (UNCHANGED) ---

  Widget _buildAddMenuOverlay(BuildContext context) {
    return Positioned(
      bottom: 281,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 230,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: const Color(0xFF387E5A),
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
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _toggleAddMenu();
            Widget? targetPage; 

            if (text == 'Add Wallet') {
              targetPage = const AddWalletPage();
            } else if (text == 'Add User') {
              targetPage = const AddUserPage();
            } else if (text == 'Add Expenses') {
              targetPage = const AddExpensePage();
            }
            
            if (targetPage != null) {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => targetPage!),
              ).then((_) => _fetchData()); // Refresh data on return
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 1,
          ),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ),
      ),
    );
  }

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
          _navBarItem(context, Icons.home, const HomePage(), isCurrent: true),
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
          _navBarItem(context, Icons.settings, const SettingsPage()),
        ],
      ),
    );
  }

  Widget _navBarItem(BuildContext context, IconData icon, Widget targetPage, {bool isCurrent = false}) {
    return InkWell(
      onTap: () {
        if (!isCurrent) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => targetPage));
        } else {
          _fetchData(); 
        }
      },
      child: Icon(icon, color: isCurrent ? Colors.white : Colors.white70, size: 32),
    );
  }
}

// ----------------- STATUS ITEM (UNCHANGED) -----------------
class StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  const StatusItem({super.key, required this.icon, required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        const SizedBox(height: 6),
        Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

// ----------------- CUSTOM ACTIVITY ITEM (RESIZED) -----------------
class CustomActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final Color color;

  const CustomActivityItem({
    super.key, 
    required this.icon, 
    required this.title, 
    required this.date, 
    required this.amount, 
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icon Container size reduced
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, 
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, color: _primaryGreen, size: 24), // Icon size reduced
              ),
              const SizedBox(width: 12), // Reduced spacing
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)), // Smaller font
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)), // Smaller font
                ],
              ),
            ],
          ),
          Text(
            amount, 
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15) // Smaller font
          ),
        ],
      ),
    );
  }
}