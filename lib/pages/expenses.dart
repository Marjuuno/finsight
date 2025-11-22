import 'package:finsight/pages/settings.dart';
import 'package:finsight/pages/sharedbudget.dart';
import 'package:finsight/pages/homepage.dart';
import 'package:flutter/material.dart';

// Assuming these pages exist and were imported in the context of the previous request
import 'package:finsight/pages/addexpenses.dart';
import 'package:finsight/pages/adduser.dart';
import 'package:finsight/pages/addwallet.dart';

// Theme colors based on the images
const Color _primaryGreen = Color(0xFF0D532E);
const Color _accentGreen = Color(0xFF94A780); // Bottom Nav Bar background
const Color _centerButtonColor = Colors.orange;
const Color _expensesBackgroundColor = Color(0xFFE8F5E9);
const Color _popUpGreen = Color(0xFF558B6E); // Dark Green from the pop-up image

// Convert to StatefulWidget to manage the pop-up state
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  // State variable to control the visibility of the pop-up menu
  bool _showAddMenu = false;

  void _toggleAddMenu() {
    setState(() {
      _showAddMenu = !_showAddMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire screen in a GestureDetector to close the menu when tapping anywhere outside
    return GestureDetector(
      onTap: () {
        if (_showAddMenu) {
          _toggleAddMenu();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // Use Stack to layer the main content and the pop-up menu
        body: Stack(
          children: [
            // 1. Main Content Area
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ----------------- CALENDAR WIDGET -----------------
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CalendarWidget(),
                    ),

                    // ----------------- EXPENSES LIST HEADER -----------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      color: _expensesBackgroundColor,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Thurs, 11/20",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryGreen),
                          ),
                          Text(
                            "Expenses: ₱5,337",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    
                    // ----------------- EXPENSES LIST ITEMS -----------------
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          ExpenseItem(
                            icon: Icons.grid_view, title: "Entertainment", user: "Me", amount: "-₱500",
                          ),
                          ExpenseItem(
                            icon: Icons.fastfood_outlined, title: "Food", user: "Sister", amount: "-₱350",
                          ),
                          ExpenseItem(
                            icon: Icons.local_grocery_store_outlined, title: "Groceries", user: "Mother", amount: "-₱1,987",
                          ),
                          ExpenseItem(
                            icon: Icons.school_outlined, title: "Education", user: "Me", amount: "-₱1,500",
                          ),
                          ExpenseItem(
                            icon: Icons.favorite_border, title: "Health", user: "Father", amount: "-₱1,000",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 2. Pop-Up Menu Overlay (only visible when _showAddMenu is true)
            if (_showAddMenu) _buildAddMenuOverlay(context),
          ],
        ),
        
        // ----------------- CONSISTENT BOTTOM NAV BAR -----------------
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  // --- Start of Reused Pop-Up Logic ---

  /// Pop-Up Menu Widget, positioned above the Navigation Bar
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

            // Handle navigation based on the button text
            if (text == 'Add Wallet') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWalletPage()),
              );
            } else if (text == 'Add User') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUserPage()),
              );
            } else if (text == 'Add Expenses') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpensePage()),
              );
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

  // --- End of Reused Pop-Up Logic ---

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
          _navBarItem(context, Icons.home, const HomePage()),
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
          // Highlight Expenses icon since we are on the ExpensesPage
          _navBarItem(context, Icons.credit_card_outlined, const ExpensesPage(), isCurrent: true), 
          _navBarItem(context, Icons.settings, const SettingsPage()),
        ],
      ),
    );
  }

  Widget _navBarItem(BuildContext context, IconData icon, Widget targetPage, {bool isCurrent = false}) {
    return InkWell(
      onTap: () {
        // Use pushReplacement to prevent building up a huge navigation stack for main tabs
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

// ----------------- CALENDAR WIDGET (Remains the same) -----------------
class CalendarWidget extends StatelessWidget {
// ... (CalendarWidget code remains the same)
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left, color: Colors.grey),
              _buildDropdown("Nov", ['Jan', 'Feb', 'Mar', 'Nov']),
              _buildDropdown("2025", ['2023', '2024', '2025']),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Su', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Mo', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Tu', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('We', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Th', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Fr', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Sa', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          // Grid layout for dates (simplified for this example)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 30, // Example for 30 days
            itemBuilder: (context, index) {
              final day = index + 1;
              return Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontWeight: day == 20 ? FontWeight.bold : FontWeight.normal,
                    color: day == 20 ? _primaryGreen : Colors.black,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // Placeholder: Handle month/year change
          },
        ),
      ),
    );
  }
}

// ----------------- EXPENSE ITEM WIDGET (Remains the same) -----------------
class ExpenseItem extends StatelessWidget {
// ... (ExpenseItem code remains the same)
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