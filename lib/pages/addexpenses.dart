import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Color Definitions ---
const Color _accentGreen = Color(0xFF94A780);
const Color _darkGreen = Color(0xFF558B6E);
const Color _lightBackground = Color(0xFFF0F5EE);

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // --- Wallet State ---
  List<DocumentSnapshot> _wallets = [];
  String? _selectedWalletId;

  // --- Expense State ---
  String? _selectedCategory;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final String _owner = "Owner";

  // --- Categories ---
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
    _fetchWallets();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ===== Helpers to read walletName in a backwards-compatible way =====
  String _docWalletName(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    // Prefer canonical 'walletName', fallback to legacy 'name', then to doc id
    return (data['walletName'] as String?) ??
        (data['name'] as String?) ??
        'Wallet';
  }

  double _docBalance(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final bal = data['balance'];
    if (bal is num) return bal.toDouble();
    if (bal is String) return double.tryParse(bal) ?? 0.0;
    return 0.0;
  }

  double _parseAmount(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  // --- Fetch Wallets ---
  Future<void> _fetchWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('wallets')
              .get();

      if (!mounted) return;

      setState(() {
        _wallets = snapshot.docs;

        if (_wallets.isNotEmpty) {
          // Auto-select first wallet if none selected or previous id missing
          if (_selectedWalletId == null ||
              !_wallets.any((doc) => doc.id == _selectedWalletId)) {
            _selectedWalletId = _wallets.first.id;
          }
        } else {
          _selectedWalletId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching wallets: $e")));
    }
  }

  // --- Category Tile ---
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    bool isSelected = _selectedCategory == category['name'];
    final iconColor = isSelected ? _darkGreen : Colors.black87;

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
                  color:
                      isSelected
                          ? _darkGreen.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: isSelected ? 5 : 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
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

  // --- Date Picker ---
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      final parts = _dateController.text.split('/');
      initialDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (_) {
      initialDate = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _darkGreen,
              onSurface: Colors.black,
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

  // --- Wallet Selection Dropdown ---
  Widget _buildWalletSelectionField() {
    if (_wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
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

    final currentSelectedId = _selectedWalletId ?? _wallets.first.id;

    // Safely get selected doc (no throw)
    DocumentSnapshot selectedDoc;

    if (_wallets.any((w) => w.id == currentSelectedId)) {
      selectedDoc = _wallets.firstWhere((doc) => doc.id == currentSelectedId);
    } else {
      selectedDoc = _wallets.first; // fallback
      _selectedWalletId = selectedDoc.id; // keep state consistent
    }

    final selectedWalletName = _docWalletName(selectedDoc);
    final selectedWalletBalance = _docBalance(selectedDoc);

    final selectedWalletDisplay =
        "$selectedWalletName (₱${selectedWalletBalance.toStringAsFixed(2)})";

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
          items:
              _wallets.map((walletDoc) {
                final name = _docWalletName(walletDoc);
                final balance = _docBalance(walletDoc);
                return DropdownMenuItem(
                  value: walletDoc.id,
                  child: Text("$name (₱${balance.toStringAsFixed(2)})"),
                );
              }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedWalletId = value;
            });
          },
          selectedItemBuilder: (context) {
            // Show only the selected wallet text for the collapsed view
            return _wallets.map((walletDoc) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: _darkGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedWalletId == walletDoc.id
                          ? selectedWalletDisplay
                          : "",
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

  // --- Amount Input ---
  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          const Text(
            'Amount:',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '₱ 0.00',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Date Field ---
  Widget _buildDateField() {
    return Expanded(
      child: InkWell(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: _darkGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _dateController.text,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Owner Field ---
  Widget _buildOwnerField() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: _darkGreen),
            const SizedBox(width: 8),
            Expanded(child: Text(_owner, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }

  // --- Notes Field ---
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
        ),
      ),
    );
  }

  // --- Add Expense ---
  Future<void> _addExpense() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      return;
    }

    if (_amountController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedWalletId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a wallet, category, and enter an amount.",
          ),
        ),
      );
      return;
    }

    // parse amount safely
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    if (amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Amount must be greater than zero.")),
      );
      return;
    }

    // parse date
    DateTime expenseDate;
    try {
      final parts = _dateController.text.split('/');
      expenseDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid date format.")));
      return;
    }

    // Find selected wallet doc (safe)
    DocumentSnapshot? selectedWalletDoc;

    if (_wallets.any((doc) => doc.id == _selectedWalletId)) {
      selectedWalletDoc = _wallets.firstWhere(
        (doc) => doc.id == _selectedWalletId,
      );
    } else {
      selectedWalletDoc = null;
    }

    if (selectedWalletDoc == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected wallet no longer exists.")),
      );
      await _fetchWallets();
      return;
    }

    final walletName = _docWalletName(selectedWalletDoc);

    try {
      final firestore = FirebaseFirestore.instance;
      final userPath = firestore.collection('users').doc(user.uid);
      final transactionRef = userPath.collection('transactions').doc();
      final walletRef = userPath.collection('wallets').doc(_selectedWalletId);

      await firestore.runTransaction((transaction) async {
        final walletSnapshot = await transaction.get(walletRef);

        if (!walletSnapshot.exists) throw Exception("Wallet not found.");

        final currentBalance = _parseAmount(walletSnapshot.data()?['balance']);
        final newBalance = currentBalance - amount;

        if (newBalance < 0) {
          throw Exception("Insufficient funds.");
        }

        transaction.update(walletRef, {'balance': newBalance});

        transaction.set(transactionRef, {
          'type': 'expense',
          'walletId': _selectedWalletId,
          'walletName': walletName,
          'category': _selectedCategory,
          'amount': amount,
          'date': Timestamp.fromDate(expenseDate),
          'notes': _notesController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Expense of ₱${amount.toStringAsFixed(2)} recorded. Wallet balance updated.",
          ),
        ),
      );

      // refresh wallets & pop
      await _fetchWallets();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final msg =
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding expense: $msg")));
    }
  }

  // --- UI Build ---
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
              // Category Grid
              Container(
                height: MediaQuery.of(context).size.height * 0.38,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _lightBackground,
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
                      (context, i) => _buildCategoryItem(_categories[i]),
                ),
              ),

              const SizedBox(height: 20),
              _buildWalletSelectionField(),
              const SizedBox(height: 15),
              _buildAmountInput(),
              const SizedBox(height: 15),

              Row(
                children: [
                  _buildDateField(),
                  const SizedBox(width: 15),
                  _buildOwnerField(),
                ],
              ),

              const SizedBox(height: 15),
              _buildNotesField(),

              const SizedBox(height: 20),

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
                      child: const Text('Cancel'),
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
                      child: const Text('Add'),
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
