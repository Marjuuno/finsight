import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Color Definitions ---
const Color _accentGreen = Color(
  0xFF94A780,
); // Lighter green for grid background
const Color _darkGreen = Color(0xFF558B6E); // Darker green for borders/icons
const Color _lightBackground = Color(
  0xFFF0F5EE,
); // Background color for the category grid

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // --- Wallet State Variables ---
  List<DocumentSnapshot> _wallets = []; // List to hold fetched wallets
  String? _selectedWalletId; // ID of the currently selected wallet

  // --- Expense State Variables and Controllers ---
  String? _selectedCategory;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Hardcoded owner for simplicity
  final String _owner = "Owner";

  // --- Expense Categories (Corrected list) ---
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Health', 'icon': Icons.favorite_border},
    {'name': 'Transport', 'icon': Icons.directions_car_filled_outlined},
    {'name': 'Education', 'icon': Icons.school_outlined},
    {'name': 'Subscription', 'icon': Icons.calendar_month_outlined},
    {'name': 'Groceries', 'icon': Icons.shopping_basket_outlined},
    {'name': 'Food', 'icon': Icons.fastfood_outlined},
    {'name': 'Daily', 'icon': Icons.local_mall_outlined},
    {'name': 'Bills', 'icon': Icons.receipt_long_outlined},
    {'name': 'House', 'icon': Icons.home_outlined},
    {'name': 'Clothing', 'icon': Icons.checkroom_outlined},
    {'name': 'Self-Care', 'icon': Icons.spa_outlined},
    {'name': 'Others', 'icon': Icons.devices_other_sharp},
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateController.text = "${today.month}/${today.day}/${today.year}";
    _fetchWallets(); // Load wallets when the page initializes
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Firestore Data Fetching ---

  Future<void> _fetchWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    // Critical Check: Ensure the user is logged in before attempting Firestore access.
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User must be logged in to fetch wallets."),
          ),
        );
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .get();

      if (!mounted) return;
      setState(() {
        _wallets = snapshot.docs;
        // Automatically select the first wallet if none is selected
        if (_wallets.isNotEmpty) {
          if (_selectedWalletId == null ||
              !_wallets.any((doc) => doc.id == _selectedWalletId)) {
            _selectedWalletId = _wallets.first.id;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      // This is likely the PERMISSION_DENIED error if authentication fails.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching wallets: $e")));
    }
  }

  // --- Helper Widgets and Functions ---

  /// Builds a selectable category item for the grid.
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    bool isSelected = _selectedCategory == category['name'];

    // Determine the icon color based on selection
    final iconColor = isSelected ? _darkGreen : Colors.black87;

    // Determine the border and shadow based on selection
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      border: Border.all(
        color: isSelected ? _darkGreen : Colors.grey.shade200,
        width: isSelected ? 2 : 1,
      ),
      boxShadow: [
        if (isSelected)
          BoxShadow(
            color: _darkGreen.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        else
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
      ],
    );

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
            decoration: decoration,
            child: Icon(category['icon'], size: 28, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            category['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: iconColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// **FIXED:** Handles the date selection using a date picker, using the current controller date as the initial selection.
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      // Parse current date string (M/d/y) for initial date setting
      final parts = _dateController.text.split('/');
      // The date format is M/d/y, so indices are [0]=Month, [1]=Day, [2]=Year
      initialDate = DateTime(
          int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      // Fallback to today if parsing fails (e.g., if the field was empty or poorly formatted)
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
              style: TextButton.styleFrom(foregroundColor: _darkGreen),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Formats the selected date as M/d/y for the controller's text
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  // --- Wallet Selection Dropdown ---
  Widget _buildWalletSelectionField() {
    if (_wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _darkGreen, width: 2),
        ),
        child: const Text(
          'No Wallets Found. Please add one first.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Ensure a wallet is selected, defaulting to the first one if necessary
    final currentSelectedId = _selectedWalletId ?? _wallets.first.id;

    // Safely determine the selected wallet's name and balance for display in the collapsed field
    DocumentSnapshot selectedDoc;
    try {
      selectedDoc = _wallets.firstWhere((doc) => doc.id == currentSelectedId);
    } catch (e) {
      // Fallback to the first wallet if the currentSelectedId is somehow invalid
      selectedDoc = _wallets.first;
    }

    final selectedWalletName =
        selectedDoc.data() != null ? (selectedDoc['name'] as String? ?? 'Wallet') : 'Wallet';
    final selectedWalletBalance =
        selectedDoc.data() != null ? (selectedDoc['balance'] as num? ?? 0.0) : 0.0;
    
    // Combine name and balance for display
    final selectedWalletDisplay = '$selectedWalletName (₱${selectedWalletBalance.toStringAsFixed(2)})';


    return Container(
      padding: const EdgeInsets.only(left: 15, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _darkGreen, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentSelectedId,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          isExpanded: true,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          dropdownColor: Colors.white,

          // Dropdown Items list (Used for the expanded view)
          items: _wallets.map((walletDoc) {
            final name = walletDoc['name'] as String? ?? 'Wallet';
            final balance = walletDoc['balance'] as num? ?? 0.0;
            return DropdownMenuItem<String>(
              value: walletDoc.id,
              child: Text(
                '$name (₱${balance.toStringAsFixed(2)})',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),

          // On Changed handler
          onChanged: (String? newValue) {
            setState(() {
              _selectedWalletId = newValue;
            });
          },

          // **FIXED:** Selected Item Builder (Used for the collapsed display)
          selectedItemBuilder: (BuildContext context) {
            // Note: selectedItemBuilder list length must match the items list length
            return _wallets.map((walletDoc) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: _darkGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    // Display the combined name and balance only for the selected item
                    Text(
                      currentSelectedId == walletDoc.id
                          ? selectedWalletDisplay
                          : '', // Only show if it's the selected one
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // --- Amount Input (No changes) ---
  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Row(
        children: [
          const Text(
            'Amount:',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Expanded(
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
        ],
      ),
    );
  }

  /// The Date field (left side of the row - No changes).
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
              const Icon(
                Icons.calendar_month_outlined,
                color: _darkGreen,
                size: 20,
              ),
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

  /// The Owner field (right side of the row - No changes).
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

  /// The Notes field (No changes).
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

  // --- Expense Submission Logic (Updated to use Timestamp) ---

  Future<void> _addExpense() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      return;
    }

    // --- Input Validation ---
    if (_amountController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedWalletId == null) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please select a wallet, category, and enter an amount.",
            ),
          ),
        );
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Amount must be greater than zero.")),
        );
      return;
    }

    // --- Date Parsing (Required for Timestamp) ---
    DateTime expenseDate;
    try {
      final parts = _dateController.text.split('/');
      // The date format is M/d/y, so indices are [0]=Month, [1]=Day, [2]=Year
      expenseDate = DateTime(
          int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error: Could not parse the selected date.")),
        );
      return;
    }

    // Determine the wallet name for the transaction record
    String walletName = 'Unknown Wallet';
    try {
      // Use the current list of wallets in memory to find the name
      final selectedWallet = _wallets.firstWhere(
        (doc) => doc.id == _selectedWalletId,
      );
      walletName = selectedWallet['name'] as String? ?? 'Unknown Wallet';
    } catch (e) {
      // Fallback if the selected wallet is somehow not in the local list
    }

    // --- Firestore Transaction: Ensure both operations (save & update) succeed or fail together ---
    try {
      // 1. Define document references
      final firestore = FirebaseFirestore.instance;
      final userPath = firestore.collection('users').doc(user.uid);
      final transactionRef = userPath.collection('transactions').doc();
      final walletRef = userPath.collection('wallets').doc(_selectedWalletId);

      await firestore.runTransaction((transaction) async {
        // 2. Read the current wallet balance (Crucial for safety)
        final walletSnapshot = await transaction.get(walletRef);
        if (!walletSnapshot.exists) {
          throw Exception("Selected wallet does not exist!");
        }

        final currentBalance = (walletSnapshot.data()?['balance'] as num?) ?? 0;
        final newBalance = currentBalance - amount;

        // Optionally check for insufficient funds before deduction
        if (newBalance < 0) {
          throw Exception("Insufficient funds in the selected wallet.");
        }

        // 3. Update the wallet balance
        transaction.update(walletRef, {'balance': newBalance});

        // 4. Save the new expense transaction
        transaction.set(transactionRef, {
          'type': 'expense',
          'walletId': _selectedWalletId,
          'walletName': walletName,
          'category': _selectedCategory,
          'amount': amount,
          // FIX: Store the date as a Firestore Timestamp object
          'date': Timestamp.fromDate(expenseDate),
          'notes': _notesController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      // --- Success Feedback ---
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Expense of ₱${amount.toStringAsFixed(2)} recorded successfully! Wallet balance updated.",
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh wallets and pop the screen
      _fetchWallets();
      Navigator.pop(context);
    } catch (e) {
      // --- Failure Feedback ---
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: Failed to record expense. Details: ${e.toString().replaceAll('Exception: ', '')}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Main Build Method (No changes) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add Expense',
          style: TextStyle(
            color: _darkGreen,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Category Grid
              Container(
                height: MediaQuery.of(context).size.height * 0.38,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _lightBackground, // Use defined light background color
                  borderRadius: BorderRadius.circular(15),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder:
                      (context, index) => _buildCategoryItem(_categories[index]),
                ),
              ),

              const SizedBox(height: 20),

              // *** Wallet Selection Dropdown ***
              _buildWalletSelectionField(),

              const SizedBox(height: 15),

              // *** Amount Input ***
              _buildAmountInput(),

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
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
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
      ),
    );
  }
}