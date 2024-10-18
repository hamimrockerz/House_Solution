import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'animate_button_add_house.dart';

class FlatStatusChangePage extends StatefulWidget {
  const FlatStatusChangePage({super.key});

  @override
  State<FlatStatusChangePage> createState() => _FlatStatusChangePageState();
}

class _FlatStatusChangePageState extends State<FlatStatusChangePage> {
  final TextEditingController _contactController = TextEditingController();
  String? _flatStatus;
  String? _selectedStatus;
  String? _selectedMonth; // New variable for leaving month
  bool _showDropdown = false;

  // Fetch flat status from Firebase
  void _fetchFlatStatus() async {
    // Show loading screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');
    String contact = _contactController.text.trim();

    if (storedContact == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'No stored contact found. Please check the contact information.')),
      );
      return;
    }

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      DataSnapshot snapshot = await ref.child(
          'Users/$storedContact/$contact/flatstatus').get();

      if (snapshot.exists) {
        String flatStatus = snapshot.value.toString();
        Navigator.pop(context);
        setState(() {
          _flatStatus = flatStatus;
          _showDropdown = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Flat Status: $flatStatus')));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No flat status found for this contact.')));
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error fetching flat status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch flat status.')));
    }
  }

  // Function to store data to Firebase Storage
  Future<bool> _storeDataToStorage(Map<String, dynamic> userData,
      String contact) async {
    try {
      String jsonData = jsonEncode(userData);
      final String fileName = '$contact.json';

      // Upload the JSON data to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child(
          'UserData/$fileName');
      await storageRef.putString(jsonData, format: PutStringFormat.raw);

      print("Data successfully uploaded to Firebase Storage.");
      return true; // Return true if upload is successful
    } catch (e) {
      print("Error storing data in Firebase Storage: $e");
      return false; // Return false if upload fails
    }
  }

  // Function to hide user data and store it in Firebase Storage
  void _hideUserData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');
    String contact = _contactController.text.trim();

    if (storedContact == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No stored contact found.')));
      return;
    }

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();

      // Fetch user data to be hidden
      DataSnapshot userSnapshot = await ref.child(
          'Users/$storedContact/$contact').get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(
            userSnapshot.value as Map);

        // Store user data in Firebase Storage
        bool uploadSuccess = await _storeDataToStorage(userData, contact);
        if (uploadSuccess) {
          // Delete user data from Realtime Database after successful upload
          await ref.child('Users/$storedContact/$contact').remove();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User data hidden successfully!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to upload data to storage.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No user data found for this contact.')));
      }
    } catch (e) {
      print("Error hiding user information: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to hide user data: $e')));
    } finally {
      Navigator.pop(context); // Close loading dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      // Set your desired background color
      appBar: AppBar(
        title: const Text('Flat Status Change'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field with icon
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6), // Search field background color
                borderRadius: BorderRadius.circular(20), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 4.0), // Shadow position
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      // Text color
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        // Hint text color
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                      onSubmitted: (value) {
                        _fetchFlatStatus(); // Trigger fetch on Enter key press
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00796B), // Button color
                      borderRadius: BorderRadius.circular(
                          20), // Rounded corners
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      // Icon color
                      onPressed: _fetchFlatStatus, // Fetch flat status when search icon is clicked
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),

            // Show fetched flat status
            if (_flatStatus != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _flatStatus != null ? 1.0 : 0.0,
                    // Animates the opacity
                    duration: const Duration(seconds: 1),
                    // Duration of the animation
                    curve: Curves.easeIn,
                    // Animation curve
                    child: Text(
                      'Current Flat Status: $_flatStatus',
                      style: const TextStyle(
                        fontSize: 20, // Increased font size
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ),

            // Styled dropdown for selecting new flat status and leaving month
            if (_showDropdown) ...[
              // Row containing both dropdowns
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(
                            0xFFE6E6E6), // Dropdown background color
                      ),
                      child: DropdownButton<String>(
                        hint: const Text('Flat Status', style: TextStyle(
                            color: Colors.black)),
                        // Hint text color
                        value: _selectedStatus,
                        isExpanded: true,
                        underline: Container(),
                        icon: const Icon(
                            Icons.arrow_drop_down, color: Colors.black),
                        // Icon color
                        iconSize: 30,
                        dropdownColor: const Color(0xFFE6E6E6),
                        // Dropdown menu color
                        borderRadius: BorderRadius.circular(20),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        },
                        items: <String>['Vacant', 'Maintenance']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 16,
                                  color: Colors.black), // Item text color
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0), // Space between dropdowns
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(
                            0xFFE6E6E6), // Dropdown background color
                      ),
                      child: DropdownButton<String>(
                        hint: const Text('Leaving Month', style: TextStyle(
                            color: Colors.black)),
                        // Hint text color
                        value: _selectedMonth,
                        isExpanded: true,
                        underline: Container(),
                        icon: const Icon(
                            Icons.arrow_drop_down, color: Colors.black),
                        // Icon color
                        iconSize: 30,
                        dropdownColor: const Color(0xFFE6E6E6),
                        // Dropdown menu color
                        borderRadius: BorderRadius.circular(20),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMonth = newValue;
                          });
                        },
                        items: <String>[
                          'January', 'February', 'March', 'April',
                          'May', 'June', 'July', 'August',
                          'September', 'October', 'November', 'December'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 16,
                                  color: Colors.black), // Item text color
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0), // Space before the button

              // Centered button below the dropdowns
              Center(
                child: AnimatedButton(
                  onPressed: _fetchFlatStatus,
                  text: "Flat Status Change",
                  buttonColor: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}