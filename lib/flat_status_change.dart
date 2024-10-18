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
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();
  String? _selectedMonth; // New variable for leaving month

  String? _flatStatus;
  String? _selectedStatus; // To hold the selected status (Occupied/Vacant)
  bool _showDropdown = false;

  // Fetch flat status from Firebase
  void _fetchFlatStatus() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Retrieve stored contact from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedContact = prefs.getString('contact');
      String contact = _contactController.text.trim();

      if (storedContact == null) {
        Navigator.pop(context);
        _showSnackBar('No stored contact found. Please check the contact information.');
        return;
      }

      DatabaseReference ref = FirebaseDatabase.instance.ref();

      // Fetch user's data from Firebase under the stored contact
      DataSnapshot snapshot = await ref.child('Users/$storedContact/$contact').get();

      if (snapshot.exists) {
        // Extract flatStatus, selectedHouse, and selectedFlat
        String flatStatus = snapshot.child('flatstatus').value?.toString() ?? '';
        String selectedHouse = snapshot.child('selectedHouse').value?.toString() ?? '';
        String selectedFlat = snapshot.child('selectedFlat').value?.toString() ?? '';

        // Update UI and state with fetched values
        setState(() {
          _flatStatus = flatStatus;
          _houseController.text = selectedHouse;  // Memorize selected house
          _flatController.text = selectedFlat;    // Memorize selected flat
          _showDropdown = true;                   // Show dropdowns if needed
        });

        Navigator.pop(context);  // Dismiss the loading dialog
        _showSnackBar('Flat Status: $flatStatus');
      } else {
        Navigator.pop(context);
        _showSnackBar('No data found for this contact.');
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error fetching flat status: $e");
      _showSnackBar('Failed to fetch flat status.');
    }
  }

  // Helper function to show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Function to store data to Firebase Storage
  Future<bool> _storeDataToStorage(Map<String, dynamic> userData, String contact) async {
    try {
      String jsonData = jsonEncode(userData);
      final String fileName = '$contact.json';

      // Upload the JSON data to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child('UserData/$fileName');
      await storageRef.putString(jsonData, format: PutStringFormat.raw);

      print("Data successfully uploaded to Firebase Storage.");
      return true;  // Return true if upload is successful
    } catch (e) {
      print("Error storing data in Firebase Storage: $e");
      return false;  // Return false if upload fails
    }
  }

  // Function to hide user data and update the flat status in the Flats Collection
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
      _showSnackBar('No stored contact found.');
      return;
    }

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();

      // Fetch user data to be hidden
      DataSnapshot userSnapshot = await ref.child('Users/$storedContact/$contact').get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(userSnapshot.value as Map);

        // Store user data in Firebase Storage
        bool uploadSuccess = await _storeDataToStorage(userData, contact);
        if (uploadSuccess) {
          // Delete user data from Realtime Database after successful upload
          await ref.child('Users/$storedContact/$contact').remove();
          _showSnackBar('User data hidden successfully!');
        } else {
          _showSnackBar('Failed to upload data to storage.');
        }

        // Proceed to update flat status in Flats collection
        String selectedHouseValue = _houseController.text.trim();  // Get selected house value
        String selectedFlatValue = _flatController.text.trim();    // Get selected flat value

        // Format selectedHouse
        String selectedHouseFormatted = selectedHouseValue
            .replaceAll(RegExp(r'Road:|House:|Block:|Section:'), '')  // Remove labels
            .replaceAll(',', '')  // Remove commas
            .replaceAll(' ', '_')  // Replace spaces with underscores
            .replaceAll('___', '_')  // Remove triple underscores if present
            .replaceAll('__', '_')  // Remove double underscores if present
            .trim();  // Remove any leading/trailing spaces

        // Split and rearrange house components
        List<String> houseComponents = selectedHouseFormatted.split('_');
        selectedHouseFormatted = "${storedContact}_${houseComponents[1]}_${houseComponents[0]}_${houseComponents[2]}_${houseComponents[3]}";

        // Format selectedFlat similarly
        String selectedFlatFormatted = selectedFlatValue
            .replaceAll(RegExp(r'Road:|House:|Block:|Section:|Flat:'), '')  // Remove labels
            .replaceAll(',', '')  // Remove commas
            .replaceAll(' ', '_')  // Replace spaces with underscores
            .replaceAll('___', '_')  // Remove triple underscores if present
            .replaceAll('__', '_')  // Remove double underscores if present
            .trim();  // Remove any leading/trailing spaces

        // Split and rearrange flat components
        List<String> flatComponents = selectedFlatFormatted.split('_');
        selectedFlatFormatted = "${storedContact}_${flatComponents[1]}_${flatComponents[0]}_${flatComponents[2]}_${flatComponents[3]}_${flatComponents[4]}";

        // Update flat status in Flats collection based on selected status (Occupied/Vacant)
        String newFlatStatus = _selectedStatus ?? 'Occupied'; // Default to Occupied if no status is selected

        await ref
            .child('Flats/$storedContact/$selectedHouseFormatted/$selectedFlatFormatted')
            .update({'flatstatus': newFlatStatus});  // Update flat status to selected value

        _showSnackBar('Flat status updated to $newFlatStatus successfully!');
      } else {
        _showSnackBar('No user data found for this contact.');
      }
    } catch (e) {
      print("Error hiding user information: $e");
      _showSnackBar('Failed to hide user data: $e');
    } finally {
      Navigator.pop(context);  // Close loading dialog
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 4.0), // Shadow position
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
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeIn,
                    child: Text(
                      'Current Flat Status: $_flatStatus',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

            // Text fields for selected house and flat, only show if data has been fetched
            if (_flatStatus != null) ...[
              const SizedBox(height: 16.0),
              TextField(
                controller: _houseController,
                readOnly: true, // Make the TextField non-editable
                decoration: const InputDecoration(
                  labelText: 'Rented House',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Color(0xFFE6E6E6),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _flatController,
                readOnly: true, // Make the TextField non-editable
                decoration: const InputDecoration(
                  labelText: 'Rented Flat',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Color(0xFFE6E6E6),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),

              const SizedBox(height: 16.0),
            ],

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
                        value: _selectedStatus,
                        isExpanded: true,
                        underline: Container(),
                        icon: const Icon(
                            Icons.arrow_drop_down, color: Colors.black),
                        iconSize: 30,
                        dropdownColor: const Color(0xFFE6E6E6),
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
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
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
                        value: _selectedMonth,
                        isExpanded: true,
                        underline: Container(),
                        icon: const Icon(
                            Icons.arrow_drop_down, color: Colors.black),
                        iconSize: 30,
                        dropdownColor: const Color(0xFFE6E6E6),
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
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
                  // Replace the AnimatedButton's onPressed with _hideUserData
              Padding(
                padding: const EdgeInsets.only(top: 20.0), // Add space at the top
                child: Center(
                  child: AnimatedButton(
                    onPressed: _hideUserData, // Call _hideUserData instead of _fetchFlatStatus
                    text: "Flat Status Change",
                    buttonColor: Colors.blue,
                  ),
                ),
              ),


            ],
          ],
        ),
      ),
    );
  }
}