import 'package:flutter/material.dart';

// Theme colors
const Color _accentGreen = Color(0xFF94A780);
const Color _darkGreen = Color(0xFF558B6E);
const Color _contributorRed = Color(0xFFE57373); // Light red for Contributor
const Color _viewerBlue = Color(0xFF64B5F6);      // Light blue for Viewer

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  // Helper widget for the text input fields
  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Text inside the green box is white
            ),
          ),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Helper widget for the role buttons
  Widget _buildRoleButton(String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ElevatedButton(
          onPressed: () {
            // Handle role selection logic here
            print('Selected role: $label');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The image shows no app bar, but a title centered in the container
        // We'll use a standard app bar for navigation and set it transparent
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 350, // Match the width of the main content cards
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _accentGreen, // The main green container color
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
                    'Add User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Title color inside the container
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Name Input
                _buildInputField('NAME', 'Enter Name'),

                // Email Input
                _buildInputField('EMAIL', 'Enter Email'),

                // Contact Number Input
                _buildInputField('CONTACT NUMBER', 'Enter Contact Number'),

                // Role Selection
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'ROLE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildRoleButton('Owner', _darkGreen),
                    _buildRoleButton('Contributor', _contributorRed),
                    _buildRoleButton('Viewer', _viewerBlue),
                  ],
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
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
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
                        onPressed: () {
                          // Handle adding the user logic here
                          print('Add User button pressed');
                          Navigator.pop(context); // Go back after adding
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkGreen, // Dark green
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
      ),
      // Keep the custom bottom navigation bar for consistency
      bottomNavigationBar: Container(height: 70, color: Colors.transparent), // Placeholder to avoid overlapping the pop-up logic
    );
  }
}