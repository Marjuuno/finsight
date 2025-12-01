import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this package to your pubspec.yaml for date formatting

// Assuming these pages exist and were imported in the context of the previous request
import 'package:finsight/pages/settings.dart';
import 'package:finsight/pages/sharedbudget.dart';
import 'package:finsight/pages/homepage.dart';
import 'package:finsight/pages/addexpenses.dart';
import 'package:finsight/pages/adduser.dart';
import 'package:finsight/pages/addwallet.dart';

// Theme colors based on the images
const Color _primaryGreen = Color(0xFF0D532E);
const Color _accentGreen = Color(0xFF94A780); // Bottom Nav Bar background
const Color _centerButtonColor = Colors.orange;
const Color _expensesBackgroundColor = Color(0xFFE8F5E9);
const Color _popUpGreen = Color(0xFF558B6E); // Dark Green from the pop-up image
const Color _expenseHighlight = Colors.red;

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  bool _showAddMenu = false;
  
  // ------------------- FIREBASE DATA STATE -------------------
  List<Map<String, dynamic>> _allExpenses = []; // Store all fetched expenses
  List<Map<String, dynamic>> _filteredExpenses = []; // Store expenses for selected date
  bool isLoading = true;
  String? errorMessage;
  double _totalDayExpenses = 0.0;
  
  // New state for Calendar Functionality
  DateTime _selectedDate = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  Map<String, double> _dailyExpensesMap = {}; // Key: 'YYYY-MM-DD', Value: total expense
  // -------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _fetchExpenses(); 
  }

  void _toggleAddMenu() {
    setState(() {
      _showAddMenu = !_showAddMenu;
    });
  }

  // --- NEW: Function to handle date selection from the calendar ---
  void _selectDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    // Re-filter and update totals based on the new date
    _filterExpensesByDate();
  }

  // --- NEW: Function to filter expenses based on the selected date ---
  void _filterExpensesByDate() {
    final String selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    _filteredExpenses = _allExpenses.where((expense) {
      final expenseDate = expense['date'] as DateTime;
      final expenseDateString = DateFormat('yyyy-MM-dd').format(expenseDate);
      return expenseDateString == selectedDateString;
    }).toList();

    // Calculate total for the selected day
    _totalDayExpenses = _filteredExpenses.fold(0.0, (sum, item) => sum + (item['amount'] as double));

    setState(() {}); // Update the UI with filtered list and total
  }

  // --- UPDATED: Fetch all expenses and calculate daily totals ---
  Future<void> _fetchExpenses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      _dailyExpensesMap = {}; // Reset map
      _allExpenses = []; // Reset all expenses list
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'User not signed in.';
        });
        return;
      }

      QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses') 
          .orderBy('date', descending: true) 
          .get();

      List<Map<String, dynamic>> fetchedExpenses = [];
      Map<String, double> calculatedDailyExpenses = {};

      for (var doc in expensesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Safely extract amount and date
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

        // Accumulate daily total for the map
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        calculatedDailyExpenses[dateKey] = (calculatedDailyExpenses[dateKey] ?? 0.0) + amount;
        
        fetchedExpenses.add({
          'category': data['category'] ?? 'Unknown',
          'amount': amount,
          'user': data['userTag'] ?? 'Me', 
          'date': date.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0), // Normalize date
        });
      }

      setState(() {
        _allExpenses = fetchedExpenses;
        _dailyExpensesMap = calculatedDailyExpenses;
        isLoading = false;
      });

      // Filter and calculate total for the *currently selected* date after fetching all data
      _filterExpensesByDate(); 

    } catch (e) {
      print('Error fetching expenses: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load expenses.';
      });
    }
  }

  // Utility to map category names to icons 
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
        if (_showAddMenu) {
          _toggleAddMenu();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. Main Content Area
            SafeArea(
              child: Column(
                children: [
                  // ----------------- CALENDAR WIDGET -----------------
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CalendarWidget(
                      selectedDate: _selectedDate,
                      dailyTotals: _dailyExpensesMap,
                      onDateSelected: _selectDate, // Pass the callback
                      onMonthYearChanged: _fetchExpenses, // Fetch new data if month/year changes
                    ),
                  ),

                  // ----------------- EXPENSES LIST HEADER -----------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    color: _expensesBackgroundColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEE, MM/dd').format(_selectedDate), 
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryGreen),
                        ),
                        Text(
                          "Expenses: ₱${_totalDayExpenses.toStringAsFixed(2)}", 
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  
                  // ----------------- DYNAMIC EXPENSES LIST ITEMS -----------------
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchExpenses, // Allow refreshing the list
                      color: _primaryGreen,
                      child: _buildExpenseList(), // Uses filtered data
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. Pop-Up Menu Overlay
            if (_showAddMenu) _buildAddMenuOverlay(context),
          ],
        ),
        
        // ----------------- CONSISTENT BOTTOM NAV BAR -----------------
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildExpenseList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Error: $errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_filteredExpenses.isEmpty) {
      // Use a ListView to ensure RefreshIndicator works even when empty
      return ListView(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Text(
              "No expenses recorded for ${DateFormat('MM/dd').format(_selectedDate)}. Tap to select a different date.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = _filteredExpenses[index];
        return ExpenseItem(
          icon: _getIconForCategory(expense['category']), 
          title: expense['category'],
          user: expense['user'],
          amount: "-₱${expense['amount'].toStringAsFixed(2)}",
        );
      },
    );
  }

  // --- Reused Pop-Up and Navigation Logic ---

  Widget _buildAddMenuOverlay(BuildContext context) {
    return Positioned(
      bottom: 280, 
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 230,
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

  Widget _buildPopUpButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _toggleAddMenu(); 

            Widget targetPage;
            if (text == 'Add Wallet') {
              targetPage = const AddWalletPage();
            } else if (text == 'Add User') {
              targetPage = const AddUserPage();
            } else if (text == 'Add Expenses') {
              targetPage = const AddExpensePage();
            } else {
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            ).then((_) => _fetchExpenses()); // Refresh data when returning from add page
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
          _navBarItem(context, Icons.groups_2, const SharedBudget()),
          InkWell(
            onTap: _toggleAddMenu, 
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: _centerButtonColor,
              child: Icon(Icons.add, color: Colors.white, size: 34),
            ),
          ),
          _navBarItem(context, Icons.credit_card_outlined, const ExpensesPage(), isCurrent: true), 
          _navBarItem(context, Icons.settings, const SettingsPage()),
        ],
      ),
    );
  }

  Widget _navBarItem(BuildContext context, IconData icon, Widget targetPage, {bool isCurrent = false}) {
    return InkWell(
      onTap: () {
        if (!isCurrent) {
          // Use pushReplacement for navigation between main tabs
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

// ----------------- CALENDAR WIDGET (UPDATED FOR INTERACTIVITY) -----------------
class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, double> dailyTotals;
  final Function(DateTime) onDateSelected;
  final VoidCallback onMonthYearChanged;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.dailyTotals,
    required this.onDateSelected,
    required this.onMonthYearChanged,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _displayedMonth;
  late List<DateTime> _monthDays;
  late String _mostExpensiveDayKey;
  late String _leastExpensiveDayKey;

  @override
  void initState() {
    super.initState();
    _displayedMonth = widget.selectedDate.copyWith(day: 1);
    _calculateMonthDays();
    _calculateExpensiveDays();
  }

  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate days if selected month changes
    if (widget.selectedDate.month != oldWidget.selectedDate.month || 
        widget.selectedDate.year != oldWidget.selectedDate.year) {
      _displayedMonth = widget.selectedDate.copyWith(day: 1);
      _calculateMonthDays();
    }
    // Always recalculate expensive days when dailyTotals update
    if (widget.dailyTotals != oldWidget.dailyTotals) {
      _calculateExpensiveDays();
    }
  }

  void _calculateExpensiveDays() {
    if (widget.dailyTotals.isEmpty) {
      _mostExpensiveDayKey = '';
      _leastExpensiveDayKey = '';
      return;
    }

    double maxExpense = -1.0;
    double minExpense = double.maxFinite;
    String maxKey = '';
    String minKey = '';

    widget.dailyTotals.forEach((key, value) {
      // Only consider days in the currently displayed month
      if (key.startsWith(DateFormat('yyyy-MM').format(_displayedMonth))) {
        if (value > maxExpense) {
          maxExpense = value;
          maxKey = key;
        }
        if (value < minExpense) {
          minExpense = value;
          minKey = key;
        }
      }
    });

    _mostExpensiveDayKey = maxExpense > 0 ? maxKey : '';
    _leastExpensiveDayKey = minExpense != double.maxFinite ? minKey : '';
  }

  // Utility to generate a list of days for the currently displayed month
  void _calculateMonthDays() {
    final firstDayOfMonth = _displayedMonth;
    final lastDayOfMonth = DateTime(firstDayOfMonth.year, firstDayOfMonth.month + 1, 0);

    // Get the weekday of the first day (Monday=1, Sunday=7). Calendar starts on Sunday (index 0).
    int firstWeekday = firstDayOfMonth.weekday % 7; 

    List<DateTime> days = [];

    // Add padding days from the previous month
    for (int i = 0; i < firstWeekday; i++) {
      days.add(firstDayOfMonth.subtract(Duration(days: firstWeekday - i)));
    }

    // Add actual days of the month
    for (int i = 0; i < lastDayOfMonth.day; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)));
    }

    // Add padding days from the next month
    int remaining = 7 - (days.length % 7);
    if (remaining < 7) {
      for (int i = 0; i < remaining; i++) {
        days.add(lastDayOfMonth.add(Duration(days: i + 1)));
      }
    }
    _monthDays = days;
  }
  
  // Handlers for month/year navigation
  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
      _calculateMonthDays();
      widget.onMonthYearChanged(); // Trigger data fetch for new month
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
      _calculateMonthDays();
      widget.onMonthYearChanged(); // Trigger data fetch for new month
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: _primaryGreen),
                onPressed: _goToPreviousMonth,
              ),
              Row(
                children: [
                  _buildDropdown(DateFormat.MMM().format(_displayedMonth), 
                    [DateFormat.MMM().format(_displayedMonth)], 
                    onChanged: (val) { /* Placeholder for real dropdown */ },
                  ),
                  const SizedBox(width: 8),
                  _buildDropdown(DateFormat.y().format(_displayedMonth), 
                    [DateFormat.y().format(_displayedMonth)], 
                    onChanged: (val) { /* Placeholder for real dropdown */ },
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: _primaryGreen),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Su', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Mo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Tu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('We', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Th', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Fr', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Sa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          // Grid layout for dates
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _monthDays.length, 
            itemBuilder: (context, index) {
              final dayDate = _monthDays[index];
              final bool isCurrentMonth = dayDate.month == _displayedMonth.month;
              final bool isSelected = DateFormat('yyyy-MM-dd').format(dayDate) == DateFormat('yyyy-MM-dd').format(widget.selectedDate);
              final String dateKey = DateFormat('yyyy-MM-dd').format(dayDate);
              final bool hasExpense = widget.dailyTotals.containsKey(dateKey) && widget.dailyTotals[dateKey]! > 0;
              final bool isMostExpensive = dateKey == _mostExpensiveDayKey && hasExpense;
              final bool isLeastExpensive = dateKey == _leastExpensiveDayKey && hasExpense;

              Color dayTextColor = isCurrentMonth ? _primaryGreen : Colors.grey.shade400;
              if (isSelected) {
                dayTextColor = Colors.white;
              } else if (isMostExpensive) {
                 dayTextColor = Colors.red.shade800; // Most expensive day highlight
              } else if (isLeastExpensive) {
                 dayTextColor = _primaryGreen; // Least expensive day highlight
              }

              return InkWell(
                onTap: isCurrentMonth ? () => widget.onDateSelected(dayDate.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMostExpensive && !isSelected ? Colors.red.shade300 : Colors.transparent,
                      width: isMostExpensive && !isSelected ? 1.5 : 0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayDate.day.toString(),
                        style: TextStyle(
                          fontWeight: isSelected || hasExpense ? FontWeight.bold : FontWeight.normal,
                          color: dayTextColor,
                        ),
                      ),
                      if (hasExpense && !isSelected) // Show a dot for days with expenses
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isMostExpensive ? Colors.red : _primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, {required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: _primaryGreen),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontWeight: FontWeight.bold, color: _primaryGreen)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ----------------- EXPENSE ITEM WIDGET (Remains the same) -----------------
class ExpenseItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String user;
  final String amount;

  const ExpenseItem({
    super.key,
    required this.icon,
    required this.title,
    required this.user,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 36, color: _primaryGreen), // Icon from the image
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: _primaryGreen),
                ),
                Text(
                  user,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}