import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Color Definitions ---
const Color _accentGreen = Color(0xFF94A780); // Lighter green for grid background
const Color _darkGreen = Color(0xFF558B6E); // Darker green for borders/icons

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // --- Expense Categories ---
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Health', 'icon': Icons.favorite_border},
    {'name': 'Transport', 'icon': Icons.directions_car_filled_outlined},
    {'name': 'Education', 'icon': Icons.school_outlined},
    {'name': 'Subscription', 'icon': Icons.calendar_month_outlined},
    {'name': 'Groceries', 'icon': Icons.shopping_basket_outlined},
    {'name': 'Food', 'icon': Icons.fastfood_outlined},
    {'name': 'Daily', 'icon': Icons.local_mall_outlined},
    {'name': 'Interest', 'icon': Icons.movie_outlined},
    {'name': 'House', 'icon': Icons.home_outlined},
    {'name': 'Clothing', 'icon': Icons.checkroom_outlined},
    {'name': 'Self-Care', 'icon': Icons.spa_outlined},
    {'name': 'Bills', 'icon': Icons.receipt_long_outlined},
  ];

  // --- State Variables and Controllers ---
  String? _selectedCategory;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  // Hardcoded owner for simplicity
  final String _owner = "Owner";

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateController.text = "${today.month}/${today.day}/${today.year}";
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Helper Widgets and Functions ---

  /// Builds a selectable category item for the grid.
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    bool isSelected = _selectedCategory == category['name'];
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category['name'];
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(
                color: isSelected ? _darkGreen : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              category['icon'],
              size: 28,
              color: isSelected ? _darkGreen : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? _darkGreen : Colors.black87,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the date selection using a date picker.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _darkGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _darkGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  /// Handles saving the expense to Firestore and updating the wallet balance.
  Future<void> _addExpense() async {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category and enter an amount.")),
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    double amount = double.tryParse(_amountController.text) ?? 0;

    // 1. Add expense to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .add({
      'owner': _owner,
      'category': _selectedCategory,
      'amount': amount,
      'date': _dateController.text,
      'notes': _notesController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Update wallet balance
    QuerySnapshot walletsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .where('owner', isEqualTo: _owner)
        .get();

    if (walletsSnapshot.docs.isNotEmpty) {
      var walletDoc = walletsSnapshot.docs.first;
      double currentBalance = (walletDoc['balance'] is num ? walletDoc['balance'] : 0).toDouble();
      await walletDoc.reference.update({'balance': currentBalance - amount});
    }

    // 3. Show confirmation and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You added ₱$amount to $_selectedCategory successfully!"),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  /// The main Wallet/Amount input box.
  Widget _buildAmountWalletInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _darkGreen, width: 2),
      ),
      child: Row(
        children: [
          // Icon
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.account_balance_wallet_outlined, color: _darkGreen, size: 32),
          ),

          // Placeholder Text
          const Text(
            'Amount',
            style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w500),
          ),

          const Spacer(),

          // Amount Input
          SizedBox(
            width: 100,
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: '₱ 0.00',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(fontSize: 18),
              ),
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),

          // Dropdown Arrow
          const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 24),
          ),
        ],
      ),
    );
  }

  /// The Date field (left side of the row).
  Widget _buildDateField() {
    return Expanded(
      child: InkWell(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: _darkGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _dateController.text,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The Owner field (right side of the row).
  Widget _buildOwnerField() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: _darkGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _owner,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The Notes field.
  Widget _buildNotesField() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _darkGreen, width: 1.5),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Notes',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _darkGreen,
          ),
        ),
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // *** CHANGE APPLIED HERE ***
        title: const Text(
          'Add Expense',
          style: TextStyle(
            color: _darkGreen, // Set color to _darkGreen
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Category Grid 
            Container(
              height: MediaQuery.of(context).size.height * 0.38, 
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5EE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) =>
                    _buildCategoryItem(_categories[index]),
              ),
            ),

            const SizedBox(height: 20), 

            // 2. Amount/Wallet Input
            _buildAmountWalletInput(),
            
            const SizedBox(height: 15),

            // 3. Date and Owner (Side-by-side)
            Row(
              children: [
                _buildDateField(),
                const SizedBox(width: 15),
                _buildOwnerField(),
              ],
            ),
            
            const SizedBox(height: 15),

            // 4. Notes Field
            _buildNotesField(),
            
            const SizedBox(height: 20),

            // 5. Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _darkGreen,
                      side: const BorderSide(color: _darkGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}