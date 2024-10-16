import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
import 'package:shared_preferences/shared_preferences.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  String _userName = 'User'; // Default user name
  String _userContact = ''; // Variable to hold the user contact
  List<String> _matchedUniqueIds = []; // To hold unique IDs from the contacts

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Fetch user info when the page initializes
  }

  Future<void> _fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name'); // Fetch the name from SharedPreferences
    final contact = prefs.getString('contact'); // Fetch the contact from SharedPreferences

    if (name != null) {
      setState(() {
        _userName = name; // Update the user name
      });
    }

    if (contact != null) {
      setState(() {
        _userContact = contact; // Update the user contact
      });
      await _fetchContacts(contact); // Fetch contacts from the database
    }
  }

  Future<void> _fetchContacts(String contact) async {
    final databaseReference = FirebaseDatabase.instance.ref();

    try {
      // Get all contacts from the Users node
      final contactsSnapshot = await databaseReference.child('Users').once();

      if (contactsSnapshot.snapshot.exists) { // Check if data exists
        Map<dynamic, dynamic> users = contactsSnapshot.snapshot.value as Map<dynamic, dynamic>;

        // Iterate over each user
        users.forEach((userId, userContacts) {
          if (userContacts['contacts'] != null) {
            Map<dynamic, dynamic> contacts = userContacts['contacts'];

            // Check if any contact matches the fetched user contact
            contacts.forEach((contactId, contactData) {
              // Assuming each contact has a field that can be compared
              // For example, if contactData contains a 'contact' field
              if (contactData['contact'] == contact) {
                setState(() {
                  _matchedUniqueIds.add(contactId); // Add the matching contact ID
                });
              }
            });
          }
        });

        // Remove duplicates if any
        _matchedUniqueIds = _matchedUniqueIds.toSet().toList();
      }
    } catch (e) {
      print('Error fetching contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch the column
          children: [
            // Card to display user info
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Name: $_userName',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue), // Change color for emphasis
                    ),
                    const SizedBox(height: 10), // Space between name and contact
                    Text(
                      'User Contact: $_userContact',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Space after the card

            // Display matched unique IDs
            if (_matchedUniqueIds.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _matchedUniqueIds.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Unique ID: ${_matchedUniqueIds[index]}'),
                    );
                  },
                ),
              )
            else
              const Text(
                'No matching contacts found.',
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
