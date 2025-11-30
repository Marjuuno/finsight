import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'addwallet.dart';
import 'addexpenses.dart';
import 'adduser.dart';
import 'expenses.dart';
import 'settings.dart';
import 'sharedbudget.dart';

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
  double totalIncome = 0.0;
  double totalSpending = 0.0;
  double totalBalance = 0.0;

  List<Map<String, dynamic>> expenses = [];

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

  Future<void> _fetchData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ---------- Fetch wallets ----------
      QuerySnapshot walletsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .get();

      double sumIncome = 0.0;
      for (var doc in walletsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        sumIncome += (data['balance'] ?? 0).toDouble();
      }

      // ---------- Fetch expenses ----------
      QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      double sumSpending = 0.0;
      List<Map<String, dynamic>> fetchedExpenses = [];

      for (var doc in expensesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double amount = (data['amount'] ?? 0).toDouble();

        // Only consider as expense (we can filter by type if your Firestore has it)
        sumSpending += amount;

        // Add to activity
        fetchedExpenses.add({
          'category': data['category'] ?? 'Unknown',
          'amount': amount,
          'date': data['date'] != null
              ? (data['date'] is Timestamp
                  ? (data['date'] as Timestamp).toDate()
                  : DateTime.tryParse(data['date'].toString()) ?? DateTime.now())
              : DateTime.now(),
        });
      }

      setState(() {
        totalIncome = sumIncome;
        totalSpending = sumSpending;
        totalBalance = totalIncome - totalSpending;
        expenses = fetchedExpenses.take(4).toList(); // Show only 4 recent
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year % 100}";
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.favorite_border;
      case 'transportation':
        return Icons.directions_car_filled_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'subscription':
        return Icons.calendar_month_outlined;
      case 'groceries':
        return Icons.shopping_basket_outlined;
      case 'food':
        return Icons.fastfood_outlined;
      case 'daily':
        return Icons.local_mall_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'house':
        return Icons.home_outlined;
      case 'clothing':
        return Icons.checkroom_outlined;
      case 'self-care':
        return Icons.spa_outlined;
      case 'bills':
        return Icons.receipt_long_outlined;
      default:
        return Icons.receipt_long_outlined;
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
                    // -------- Header --------
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
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.notifications_none, size: 28),
                        ],
                      ),
                    ),

                    // -------- Insight --------
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
                                          fontWeight: FontWeight.bold)),
                                  const TextSpan(
                                      text: " into",
                                      style: TextStyle(fontSize: 22, color: Colors.black)),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                      text: "every ", style: TextStyle(fontSize: 22, color: Colors.black)),
                                  TextSpan(
                                      text: "PESO",
                                      style: TextStyle(
                                          fontSize: 28,
                                          color: const Color(0xFF0E8A41),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // -------- Status --------
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                            StatusItem(
                              icon: Icons.wallet,
                              label: "Spending",
                              amount: "-₱${totalSpending.toStringAsFixed(2)}",
                              color: Colors.red,
                            ),
                            StatusItem(
                              icon: Icons.attach_money,
                              label: "Income",
                              amount: "₱${totalIncome.toStringAsFixed(2)}",
                              color: Colors.green,
                            ),
                            StatusItem(
                              icon: Icons.savings,
                              label: "Balance",
                              amount: "₱${totalBalance.toStringAsFixed(2)}",
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // -------- Activity --------
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        child: expenses.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  "No expenses recorded.",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Column(
                                children: expenses.map((expense) {
                                  return ActivityItem(
                                    icon: _getIconForCategory(expense['category']),
                                    title: expense['category'],
                                    date: _formatDate(expense['date']),
                                    amount: "-₱${expense['amount'].toStringAsFixed(2)}",
                                  );
                                }).toList(),
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

  // ---------------- PopUp ----------------
  Widget _buildAddMenuOverlay(BuildContext context) {
    return Positioned(
      bottom: 250,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 230,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: _popUpGreen,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
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
            if (text == 'Add Wallet') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWalletPage()));
            } else if (text == 'Add User') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddUserPage()));
            } else if (text == 'Add Expenses') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpensePage()));
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

  // ---------------- Bottom Nav ----------------
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
        }
      },
      child: Icon(icon, color: isCurrent ? Colors.white : Colors.white70, size: 32),
    );
  }
}

// ---------------- Status Item ----------------
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

// ---------------- Activity Item ----------------
class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;

  const ActivityItem({super.key, required this.icon, required this.title, required this.date, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey.shade200, child: Icon(icon, color: Colors.black87)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(date, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          Text(amount, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
