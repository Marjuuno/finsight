import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _accentGreen = Color(0xFF94A780);
const Color _darkGreen = Color(0xFF558B6E);

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Health', 'icon': Icons.favorite_border},
    {'name': 'Transportation', 'icon': Icons.directions_car_filled_outlined},
    {'name': 'Education', 'icon': Icons.school_outlined},
    {'name': 'Subscription', 'icon': Icons.calendar_month_outlined},
    {'name': 'Groceries', 'icon': Icons.shopping_basket_outlined},
    {'name': 'Food', 'icon': Icons.fastfood_outlined},
    {'name': 'Daily', 'icon': Icons.local_mall_outlined},
    {'name': 'Entertainment', 'icon': Icons.movie_outlined},
    {'name': 'House', 'icon': Icons.home_outlined},
    {'name': 'Clothing', 'icon': Icons.checkroom_outlined},
    {'name': 'Self-Care', 'icon': Icons.spa_outlined},
    {'name': 'Bills', 'icon': Icons.receipt_long_outlined},
  ];

  String? _selectedCategory;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  // Hardcoded owner to avoid dropdown issues
  final String _owner = "Owner";

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateController.text = "${today.month}/${today.day}/${today.year}";
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    bool isSelected = _selectedCategory == category['name'];
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category['name'];
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(
                color: isSelected ? _darkGreen : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _darkGreen.withOpacity(0.3),
                        blurRadius: 5,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              category['icon'],
              size: 30,
              color: isSelected ? _darkGreen : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category['name'],
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? _darkGreen : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> _addExpense() async {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    double amount = double.tryParse(_amountController.text) ?? 0;

    // Add expense to Firestore
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

    // Update wallet balance
    QuerySnapshot walletsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .where('owner', isEqualTo: _owner)
        .get();

    if (walletsSnapshot.docs.isNotEmpty) {
      var walletDoc = walletsSnapshot.docs.first;
      double currentBalance = (walletDoc['balance'] ?? 0).toDouble();
      await walletDoc.reference.update({'balance': currentBalance - amount});
    }

    // Show popup/snackbar after successfully adding expense
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You added ₱$amount successfully!"),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context); // Return to previous page
  }

  Widget _buildInfoBox(String text, IconData icon, {bool showBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: showBorder ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.black87)),
          Icon(icon, color: _darkGreen),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _darkGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  'ADD EXPENSE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Grid
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFC9DDB9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) =>
                    _buildCategoryItem(_categories[index]),
              ),
            ),
            const SizedBox(height: 20),

            // Owner (hardcoded)
            _buildInfoBox(_owner, Icons.person_outline, showBorder: true),
            const SizedBox(height: 20),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date picker
            InkWell(
              onTap: () => _selectDate(context),
              child: _buildInfoBox(_dateController.text, Icons.calendar_month,
                  showBorder: true),
            ),
            const SizedBox(height: 20),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Buttons
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
