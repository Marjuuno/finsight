import 'package:flutter/material.dart';

// Theme colors from the application
const Color _accentGreen = Color(0xFF94A780); // Light green for main sections
const Color _darkGreen = Color(0xFF558B6E);   // Dark green for buttons/header

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // Define the expense categories and their icons
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

  // Helper widget for a single category item
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

  // Function to show the date picker
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

  @override
  void initState() {
    super.initState();
    // Initialize date field with today's date
    final today = DateTime.now();
    _dateController.text = "${today.month}/${today.day}/${today.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Transparent app bar for a full-screen look
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
            // Header Section
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
                color: const Color(0xFFC9DDB9), // Lighter green for the category box
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
                  childAspectRatio: 0.75, // Adjusts height to fit text below icon
                ),
                itemBuilder: (context, index) {
                  return _buildCategoryItem(_categories[index]);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Wallet Selector (Placeholder)
            _buildInfoBox('WALLET 1', Icons.wallet_outlined),
            const SizedBox(height: 20),

            // Amount, Date, and Owner Row
            Row(
              children: [
                // Amount Input
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: _darkGreen),
                        const SizedBox(width: 8),
                        const Text('Amount', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: '₱',
                              items: const [
                                DropdownMenuItem(value: '₱', child: Text('₱')),
                                // Add other currency options if needed
                              ],
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                        // Actual text field for amount
                        const Expanded(
                          flex: 3,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date and Owner Fields
            Row(
              children: [
                // Date Picker
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: _buildInfoBox(
                      _dateController.text.isNotEmpty
                          ? _dateController.text
                          : 'mm/dd/yyyy',
                      Icons.calendar_month,
                      showBorder: true,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Owner
                Expanded(
                  child: _buildInfoBox('Owner', Icons.person_outline, showBorder: true),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notes Section
            Container(
              height: 120,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Notes',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons (Cancel and Add)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context), // Cancel
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
                    onPressed: () {
                      // Handle adding the expense logic here
                      print('Add Expense button pressed');
                      Navigator.pop(context); // Go back after adding
                    },
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

  // Helper widget for Wallet, Date, and Owner boxes
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
}