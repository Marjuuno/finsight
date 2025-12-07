import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';
import 'addwallet.dart';
import 'adduser.dart';
import 'addexpenses.dart';
import 'expenses.dart';
import 'settings.dart';

const Color _centerButtonColor = Colors.orange;

class SharedBudget extends StatefulWidget {
  const SharedBudget({super.key});

  @override
  State<SharedBudget> createState() => _SharedBudgetState();
}

class _SharedBudgetState extends State<SharedBudget> {
  bool _showAddMenu = false;

  void _toggleAddMenu() {
    if (!mounted) return;
    setState(() => _showAddMenu = !_showAddMenu);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showAddMenu) _toggleAddMenu();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SizedBox(width: 40),
                          Text(
                            "SHARED  BUDGET",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC79205),
                            ),
                          ),
                          Icon(Icons.notifications_none, size: 28),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FETCH GROUPS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection("groups")
                                .where(
                                  "membersEmails",
                                  arrayContains:
                                      FirebaseAuth.instance.currentUser!.email,
                                )
                                .snapshots(),

                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                child: Text(
                                  "No Groups Found",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children:
                                snapshot.data!.docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  final String groupName =
                                      data["name"] ?? "Unnamed Group";
                                  final double budget =
                                      (data["initialBudget"] ?? 0).toDouble();
                                  final List members = data["members"] ?? [];

                                  final admin = members.firstWhere(
                                    (m) => m["role"] == "Admin",
                                    orElse: () => {"email": "Unknown"},
                                  );

                                  final String adminEmail = admin["email"];

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20,
                                    ), // <--- ADD SPACING HERE
                                    child: SharedBudgetCard(
                                      groupId: doc.id,
                                      groupName: groupName,
                                      budget: budget,
                                      members:
                                          members
                                              .map((m) => m["email"])
                                              .toList(),
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // ADD MENU OVERLAY
            if (_showAddMenu) _buildAddMenuOverlay(context),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  // ADD POPUP MENU
  Widget _buildAddMenuOverlay(BuildContext context) {
    return Positioned(
      bottom: 185,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 230,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF387E5A),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _popupButton('Add Wallet', const AddWalletPage()),
              _popupButton('Add User', const AddGroupPage()),
              _popupButton('Add Expenses', const AddExpensePage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popupButton(String text, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _toggleAddMenu();
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // BOTTOM NAV BAR
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
          _navItem(context, Icons.home, const HomePage()),
          _navItem(context, Icons.groups_2, null, isCurrent: true),

          InkWell(
            onTap: _toggleAddMenu,
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: _centerButtonColor,
              child: Icon(Icons.add, color: Colors.white, size: 34),
            ),
          ),
          _navItem(context, Icons.credit_card_outlined, const ExpensesPage()),
          _navItem(context, Icons.settings, const SettingsPage()),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    Widget? page, {
    bool isCurrent = false,
  }) {
    return InkWell(
      onTap: () {
        if (!isCurrent && page != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
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

// SHARED BUDGET CARD
class SharedBudgetCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final double budget;
  final List members;

  const SharedBudgetCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.budget,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                groupName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF0E8A41)),
                ),
                child: const Text(
                  "View",
                  style: TextStyle(
                    color: Color(0xFF0E8A41),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // BUDGET SUMMARY
          Text("Total Budget: ₱$budget"),
          const SizedBox(height: 4),
          const Text("Spent: ₱0"),
          const SizedBox(height: 4),
          Text("Remaining: ₱$budget"),

          const SizedBox(height: 16),

          // MEMBERS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children:
                    members.take(3).map((email) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: CircleAvatar(
                          radius: 18,
                          child: Text(
                            email.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              // ADD USER BUTTON
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E8A41),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "+ Add User",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
