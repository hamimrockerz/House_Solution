import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User model class
class UserModel {
  final String id;
  final String name; // Add other fields as necessary
  final String selectedFlat; // New field for selected flat

  UserModel({
    required this.id,
    required this.name,
    required this.selectedFlat, // Initialize new field
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? 'Unknown', // Adjust based on your Firebase structure
      selectedFlat: data['selectedFlat'] ?? 'No flat selected', // Adjust based on your structure
    );
  }
}

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({Key? key}) : super(key: key);

  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  String? _storedContact;
  List<UserModel> _users = []; // List to hold user details
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoredContact();
  }

  Future<void> _fetchStoredContact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storedContact = prefs.getString('contact');

    if (_storedContact != null) {
      _fetchUserDetails(); // Fetch user details if the stored contact is found
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stored contact found.')),
      );
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      // Fetching the subcollection for the stored contact
      DataSnapshot snapshot = await ref.child('Users/$_storedContact').get();

      if (snapshot.exists) {
        // If the stored contact exists, extract user details
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
        _users = users.entries.map((entry) {
          // Create a UserModel from each entry
          return UserModel.fromMap(entry.value, entry.key);
        }).toList(); // Convert entries to UserModel objects

        setState(() {
          _isLoading = false; // Update loading state
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No users found for this contact.')),
        );
      }
    } catch (e) {
      print("Error fetching user details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user details.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Update loading state
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Users',
          style: TextStyle(
            fontSize: 24, // Increase title font size
            fontWeight: FontWeight.bold,
            color: Colors.lightGreenAccent,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        // Solid color for the AppBar
        elevation: 5,
        // Slight shadow for the AppBar
        automaticallyImplyLeading: false, // Remove back arrow button
      ),
      body: Container(
        color: Colors.blueGrey[100], // Light background color for the body
        padding: const EdgeInsets.all(16.0), // Padding around the body
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _users.isNotEmpty
            ? ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return Card(
              elevation: 6,
              // Moderate shadow for the card
              margin: const EdgeInsets.symmetric(vertical: 12),
              // Increased space around the card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Inner padding of the card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // Space between items
                      children: [
                        Expanded(
                          child: Text(
                            'Contact: ${user.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87, // Dark color for ID
                            ),
                            textAlign: TextAlign.left
                            ,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Space between User ID and Name
                        Expanded(
                          child: Text(
                            'Renter Name: ${user.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent, // Accent color for Name
                            ),
                            textAlign: TextAlign.end, // Align text to the end
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Space between rows
                    const Divider(), // Add a divider for separation
                    const SizedBox(height: 10), // Space after divider
                    Text(
                      'Rented Flat: ${user.selectedFlat}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black, fontWeight: FontWeight.bold, // Lighter color for flat
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : const Center(child: Text('No user details available.')),
      ),
    );
  }
}