import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Color Definitions ---
const Color _darkGreen = Color(0xFF558B6E); 
const Color _primaryGreen = Color(0xFF0D532E); 
const Color _saveButtonColor = Color(0xFF4CAF50); 
const Color _fieldColor = Color(0xFF9EB59A); 

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // --- State to control the UI ---
  bool _isEditing = false; 

  // --- Controllers for Profile Fields ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController(); 
  
  final String _addressLabel = "Home Address";
  

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  // --- Data Loading Future (Initial Fetch) ---
  Future<void> _loadProfileData() async {
    if (_currentUser == null) return;

    // 1. Get Email from Firebase Auth (Read-only)
    _emailController.text = _currentUser!.email ?? 'N/A';
    
    // 2. Fetch all profile data from Firestore
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data()!;
        
        // Name is reliably fetched from the Firestore document
        _nameController.text = data['name'] ?? 'Name Not Set'; 
        
        _contactController.text = data['phone'] ?? ''; 
        _addressController.text = data['address'] ?? 'Add your address...';
        // Ensure income is loaded as String for TextEditingController
        _incomeController.text = data['income']?.toString() ?? '0'; 
      } else {
         // Fallback if the Firestore document doesn't exist
        _nameController.text = _currentUser!.displayName ?? 'Name Not Found'; 
      }
    } catch (e) {
      print("Error loading profile data: $e");
      // Set default text on failure
      _nameController.text = 'Error Loading Name';
      _contactController.text = 'Error Loading Contact';
      _addressController.text = 'Error Loading Address';
    }
  }

  // --- Logic for Button Action ---
  void _handleButtonPress() {
    if (_isEditing) {
      _saveProfileChanges();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  // --- FIXED SAVE LOGIC ---
  void _saveProfileChanges() async {
    if (_currentUser == null) return;

    // Capture the trimmed text fields before setting _isEditing=false
    final String newName = _nameController.text.trim();
    final String newContact = _contactController.text.trim();
    final String newAddress = _addressController.text.trim();
    final String newIncomeText = _incomeController.text.trim();


    try {
      // 1. Update Name in Firebase Auth (optional, for convenience)
      if (_currentUser!.displayName != newName) {
        await _currentUser!.updateDisplayName(newName);
      }
      
      // 2. Update all fields in Firestore
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).set(
        {
          'name': newName,
          'phone': newContact,
          'address': newAddress,
          // Convert string to double for storage
          'income': double.tryParse(newIncomeText) ?? 0.0,
          'email': _emailController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), 
      );

      // 3. Update Controllers and State only AFTER successful write to prevent fetch bug
      if (mounted) {
        setState(() {
          // Set controllers to the new saved values
          _nameController.text = newName;
          _contactController.text = newContact;
          _addressController.text = newAddress;
          _incomeController.text = newIncomeText;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Saved Successfully!")),
        );
      }
    } catch (e) {
      // If saving fails, show error and stay in editing mode
      if (mounted) {
        setState(() {
            _isEditing = true; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: ${e.toString()}")),
        );
      }
    }
  }

  // --- Helper Widgets ---

  /// Builds a themed text input field with professional styling.
  Widget _buildProfileInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    bool isEmail = false,
  }) {
    bool readOnly = !_isEditing || isEmail; 
    
    Color borderColor = _isEditing ? _darkGreen : Colors.grey.shade300;
    double borderWidth = _isEditing ? 1.5 : 1;
    
    if (isEmail) {
        borderColor = Colors.grey.shade200;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor, 
            width: borderWidth,
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
        child: Row(
          children: [
            // Icon in dark green
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, color: _darkGreen, size: 20),
            ),
            
            // Text Field
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                readOnly: readOnly,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: readOnly ? Colors.grey : _darkGreen, 
                    fontWeight: readOnly ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14,
                  ),
                  prefixText: prefixText,
                  prefixStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  fontSize: 16, 
                  color: readOnly ? Colors.grey.shade600 : Colors.black87, 
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds the Save/Edit button.
  Widget _buildActionButton() {
    String buttonText = _isEditing ? 'Save Changes' : 'Edit Profile';
    Color buttonColor = _isEditing ? _saveButtonColor : _darkGreen;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: ElevatedButton(
        onPressed: _handleButtonPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(
          buttonText, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            color: _primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      // Use FutureBuilder to handle loading state while fetching user data
      body: FutureBuilder<void>(
        // Use a unique Key to force FutureBuilder rebuild if needed, though 
        // setState in _saveProfileChanges handles the UI refresh.
        future: _loadProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _darkGreen));
          }
          if (snapshot.hasError || _currentUser == null) {
            return const Center(
              child: Text(
                'Failed to load profile. Please sign in again.', 
                style: TextStyle(color: Colors.red)
              ),
            );
          }

          // Data is loaded, display the scrollable content
          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. Avatar Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20, bottom: 40),
                  color: Colors.white, 
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(color: _darkGreen, width: 3),
                        ),
                        child: Icon(
                          Icons.person, 
                          color: _darkGreen, 
                          size: 60
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              print("Open image picker");
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: _darkGreen,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. Form Fields Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name (Editable, fetched from Firestore 'name')
                      _buildProfileInputField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),

                      // Email (Read-only, fetched from Auth)
                      _buildProfileInputField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isEmail: true, 
                      ),
                      
                      // Contact Number (Editable, fetched from Firestore 'phone')
                      _buildProfileInputField(
                        controller: _contactController,
                        label: 'Contact Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      // Address (Editable, fetched from Firestore 'address')
                      _buildProfileInputField(
                        controller: _addressController,
                        label: _addressLabel,
                        icon: Icons.location_on_outlined,
                      ),


                      // Total Income (Editable, fetched from Firestore 'income')
                      _buildProfileInputField(
                        controller: _incomeController,
                        label: 'Total Income (Monthly)',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        prefixText: '₱ ', 
                      ),

                      // Action Button (Edit / Save Changes)
                      _buildActionButton(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}