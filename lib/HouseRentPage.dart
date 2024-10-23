import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HouseRentPage extends StatefulWidget {
  const HouseRentPage({super.key});

  @override
  _HouseRentPageState createState() => _HouseRentPageState();
}

class _HouseRentPageState extends State<HouseRentPage> {
  String _userName = 'User'; // Default user name
  String? _profileImageUrl; // Variable to hold the profile image URL

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user name when the page initializes
    _loadProfileImage(); // Fetch the profile image URL when the page initializes
  }

  Future<void> _fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(
        'name'); // Fetch the name from SharedPreferences

    if (name != null) {
      setState(() {
        _userName = name; // Update the user name
      });
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString(
          'profileImage'); // Fetch the profile image URL from SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context), // Add the drawer here
      appBar: AppBar(
        title: const Text(
          'House Rent',
          style: TextStyle(
            color: Colors
                .lightBlue, fontWeight: FontWeight.bold // Change the title color to amberAccent or any preferred color
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(
            0xFF40444B), // Keep the dark background for the AppBar
      ),
      body: Container(
        color: const Color(0xFF2C2F33),
        // Set the background color to match the dark background of the image
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildRentButton(context, 'House Rent Collect', Icons.money_off,
                '/house_rent_collect'),
            const SizedBox(height: 20), // Add space between buttons
            _buildRentButton(
                context, 'House Rent Update', Icons.edit, '/house_rent_update'),
            const SizedBox(height: 20), // Add space between buttons
            _buildRentButton(
                context, 'House Rent History', Icons.history, '/rent_history'),
          ],
        ),
      ),
    );
  }

  Widget _buildRentButton(BuildContext context, String title, IconData icon,
      String route) {
    return Card(
      color: const Color(0xFF40444B),
      // Dark color to match the button background from the image
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        highlightColor: Colors.blueAccent.withOpacity(0.3),
        // Highlight color for button press animation
        splashColor: Colors.amberAccent.withOpacity(0.5),
        // Ripple effect color
        child: Container(
          height: 80, // Set a fixed height for uniformity
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              // Adjusted icon size and color
              const SizedBox(width: 10),
              // Space between icon and text
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .white, // White text to contrast with the dark background
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Drawer widget with central picture and navigation options
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(
          0xFF2C2F33),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(_profileImageUrl!),
                  onBackgroundImageError: (_, __) => const Icon(Icons.error),
                )
                    : const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                      'assets/default_avatar.png'), // Placeholder image
                ),
                const SizedBox(height: 10),
                Text(
                  'Hello, $_userName', // Display the fetched user name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text(
                'Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text('Exit', style: TextStyle(color: Colors.white)),
            onTap: () async {
              // Close the drawer first
              Navigator.of(context).pop();

              // Show the exit confirmation dialog
              await _showExitConfirmationDialog(context);
            },
          ),
        ],
      ), // Dark background color for the drawer
    );
  }

// Exit confirmation dialog
  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF40444B),
          // Dark background for the dialog
          title: const Text(
              'Exit Confirmation', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to exit?',
              style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text(
                  'Cancel', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog and stay on page
              },
            ),
            TextButton(
              child: const Text(
                  'Exit', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                    '/login'); // Navigate to login page
              },
            ),
          ],
        );
      },
    );
  }
}