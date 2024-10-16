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
        const SnackBar(content: Text('No stored contact found. Please check the contact information.')),
      );
      return;
    }

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      DataSnapshot snapshot = await ref.child('Users/$storedContact/$contact/flatstatus').get();

      if (snapshot.exists) {
        String flatStatus = snapshot.value.toString();
        Navigator.pop(context);
        setState(() {
          _flatStatus = flatStatus;
          _showDropdown = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flat Status: $flatStatus')));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No flat status found for this contact.')));
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error fetching flat status: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch flat status.')));
    }
  }

  // Function to store data to Firebase Storage
  // Function to store data to Firebase Storage
  Future<bool> _storeDataToStorage(Map<String, dynamic> userData, String contact) async {
    try {
      String jsonData = jsonEncode(userData);
      final String fileName = '$contact.json';

      // Upload the JSON data to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child('UserData/$fileName');
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No stored contact found.')));
      return;
    }

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();

      // Fetch user data to be hidden
      DataSnapshot userSnapshot = await ref.child('Users/$storedContact/$contact').get();

      if (userSnapshot.exists) {
        // Ensure proper casting from dynamic data
        Map<String, dynamic> userData = Map<String, dynamic>.from(userSnapshot.value as Map);

        // Store user data in Firebase Storage
        bool uploadSuccess = await _storeDataToStorage(userData, contact);
        if (uploadSuccess) {
          // Delete user data from Realtime Database after successful upload
          await ref.child('Users/$storedContact/$contact').remove();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User data hidden successfully!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload data to storage.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user data found for this contact.')));
      }
    } catch (e) {
      // Catch any errors during the entire process
      print("Error hiding user information: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to hide user data: $e')));
    } finally {
      Navigator.pop(context); // Close loading dialog
    }
  }



  // Function to hide user data and store it in Firebase Storage


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // TextField with search icon
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter 11-digit Number',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      onSubmitted: (value) {
                        _fetchFlatStatus(); // Trigger fetch on Enter key press
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _fetchFlatStatus, // Fetch flat status when search icon is clicked
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),

// Show fetched flatstatus
            if (_flatStatus != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _flatStatus != null ? 1.0 : 0.0, // Animates the opacity
                    duration: const Duration(seconds: 1), // Duration of the animation
                    curve: Curves.easeIn, // Animation curve
                    child: Text(
                      'Current Flat Status: $_flatStatus',
                      style: const TextStyle(
                        fontSize: 20,  // Increased font size
                        fontWeight: FontWeight.bold,  // Bold text
                      ),
                    ),
                  ),
                ),
              ),

            // Styled dropdown for selecting new flat status
            if (_showDropdown)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      hint: const Text('Select Flat Status'),
                      value: _selectedStatus,
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Button to hide user data and store it in Firebase Storage
                  Center(
    child: AnimatedButton(
    onPressed: _fetchFlatStatus,
    text: "Flat Status Change",
    buttonColor: Colors.blue,
    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
