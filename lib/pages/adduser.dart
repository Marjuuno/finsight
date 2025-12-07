import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Theme colors
const Color _contributorRed = Color(0xFFE57373);
const Color _viewerBlue = Color(0xFF64B5F6);

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  // Text controllers
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController =
      TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController inviteEmailController = TextEditingController();

  // Member list
  List<Map<String, String>> invitedMembers = [];

  // Role for the next added member
  String selectedRole = "Contributor";

  bool isCreating = false;

  // Helper widget
  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Validate if email is registered
  Future<bool> _isRegisteredUser(String email) async {
    final query =
        await FirebaseFirestore.instance
            .collection("users")
            .where("email", isEqualTo: email)
            .limit(1)
            .get();

    return query.docs.isNotEmpty;
  }

  // Add member with validation
  Future<void> _addMember() async {
    final email = inviteEmailController.text.trim();
    if (email.isEmpty) return;

    // Prevent duplicates
    bool alreadyAdded = invitedMembers.any((m) => m["email"] == email);
    if (alreadyAdded) {
      _showMessage("This user is already added.");
      return;
    }

    // Check if email exists in 'users'
    bool exists = await _isRegisteredUser(email);
    if (!exists) {
      _showMessage("This email is not registered in the app.");
      return;
    }

    setState(() {
      invitedMembers.add({"email": email, "role": selectedRole});
      inviteEmailController.clear();
      selectedRole = "Contributor";
    });
  }

  // Display message
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Remove member
  void _removeMember(int index) {
    setState(() {
      invitedMembers.removeAt(index);
    });
  }

  Future<void> _createGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final groupName = groupNameController.text.trim();
    final description = groupDescriptionController.text.trim();
    final budgetText = budgetController.text.trim();

    if (groupName.isEmpty) {
      _showMessage("Group name is required.");
      return;
    }

    if (budgetText.isEmpty || double.tryParse(budgetText) == null) {
      _showMessage("Enter a valid budget amount.");
      return;
    }

    if (isCreating) return;

    setState(() => isCreating = true);

    try {
      double initialBudget = double.parse(budgetText);

      // Always add creator as Admin
      invitedMembers.insert(0, {"email": user.email!, "role": "Admin"});

      await FirebaseFirestore.instance.collection("groups").add({
        "name": groupName,
        "description": description,
        "initialBudget": initialBudget,

        // 🔥 THIS MUST MATCH YOUR RULES EXACTLY
        "creatorId": user.uid,

        "createdAt": FieldValue.serverTimestamp(),
        "members": invitedMembers,
        
        "membersEmails": invitedMembers.map((m) => m["email"]).toList(),

      });

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      _showMessage("Error creating group: $e");
    }

    if (!mounted) return;
    setState(() => isCreating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.transparent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF387E5A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Add Group',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Inputs
                _buildInputField(
                  "GROUP NAME",
                  "Enter Group Name",
                  groupNameController,
                ),
                _buildInputField(
                  "DESCRIPTION (OPTIONAL)",
                  "Write a short description...",
                  groupDescriptionController,
                ),
                _buildInputField(
                  "INITIAL BUDGET",
                  "Enter Amount (₱0.00)",
                  budgetController,
                  type: TextInputType.number,
                ),

                // Invite Members Label
                const Text(
                  "INVITE MEMBERS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                TextField(
                  controller: inviteEmailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Row: Role + Add Member
                Row(
                  children: [
                    // Role dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        items: const [
                          DropdownMenuItem(
                            value: "Contributor",
                            child: Text("Contributor"),
                          ),
                          DropdownMenuItem(
                            value: "Viewer",
                            child: Text("Viewer"),
                          ),
                        ],
                        onChanged:
                            (value) => setState(() => selectedRole = value!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Add button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addMember,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF387E5A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Add Member",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // LIST OF MEMBERS
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invitedMembers.length,
                  itemBuilder: (context, index) {
                    final member = invitedMembers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              member["email"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            member["role"]!,
                            style: TextStyle(
                              color:
                                  member["role"] == "Contributor"
                                      ? _contributorRed
                                      : _viewerBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _removeMember(index),
                            child: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Cancel / Create Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isCreating ? null : _createGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF387E5A),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(isCreating ? "Creating..." : "Create"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(height: 70, color: Colors.transparent),
    );
  }
}
