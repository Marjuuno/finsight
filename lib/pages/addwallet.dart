import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  // 1. Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  // 2. Firebase Instances (Correctly initialized)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // 3. Proper disposal of controllers (Correct)
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  Future<void> _addWallet() async {
    final String name = nameController.text.trim();
    final String balanceText = balanceController.text.trim();
    final User? user = _auth.currentUser;

    // --- Authentication Check ---
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a wallet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Input Validation ---
    if (name.isEmpty || balanceText.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a wallet name and initial amount.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Attempt to parse balance and validate it's non-negative
    final double? balance = double.tryParse(balanceText);
    if (balance == null || balance < 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Initial amount must be a valid non-negative number.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- 🔑 DUPLICATION CHECK ADDED HERE ---
    try {
      // Query the user's wallets subcollection for a document where 'name' equals the input name
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .where('name', isEqualTo: name)
          .limit(1) // We only need to find one match to confirm duplication
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // A wallet with this name already exists
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wallet name "$name" already exists. Please choose a different name.'),
            backgroundColor: Colors.orange,
          ),
        );
        return; // Stop the function execution
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error checking for duplicate wallet name.'),
          backgroundColor: Colors.red,
        ),
      );
      // Optional: Log the error
      // print("Duplication check error: $e");
      return;
    }
    // --- 🔑 END DUPLICATION CHECK ---

    // Use a loading state or context check before proceeding
    if (!mounted) return;

    try {
      // --- 4. Firestore Write Operation ---
      // Adds a new document to the user's dedicated 'wallets' subcollection with a random ID.
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .add({
        'name': name,
        'balance': balance, // This is the initial balance of the wallet
        'created_at': FieldValue.serverTimestamp(),
      });

      // After successful write, show success message and navigate
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallet "$name" successfully created with ₱${balance.toStringAsFixed(2)}.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to HomePage and remove AddWalletPage from stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      // --- Error Handling ---
      if (!mounted) return;
      String errorMessage = 'Failed to add wallet. Please check your network or permissions.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      // Optional: print the full error to the console for debugging
      // print("Firestore Error during creation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9DDB9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create New Wallet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF558B6E),
                ),
              ),
              const SizedBox(height: 30),
              // 


              Image.asset(
                'assets/images/logo/piggybank.png',
                height: 200,
              ),
              const SizedBox(height: 30),
              const Text(
                'Give your new wallet a name and starting amount.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF558B6E),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Wallet Name (e.g., Cash, Bank A, Savings)',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Initial Balance (₱)',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF558B6E),
                        side: const BorderSide(color: Color(0xFF558B6E)),
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
                      onPressed: _addWallet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF558B6E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Create Wallet',
                        style: TextStyle(fontSize: 16),
                      ),
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