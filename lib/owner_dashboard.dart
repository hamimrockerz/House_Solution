import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  _OwnerDashboardState createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _ownerName;
  String _greeting = ''; // Variable for greeting message
  String _ownerImageUrl = ''; // Variable to hold the image URL

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticInOut,
      ),
    );

    // Start animations
    _controller.forward();

    // Fetch owner details and set greeting message
    _fetchOwnerDetails();
  }

  Future<void> _fetchOwnerDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final contact = prefs.getString('contact');

    if (contact != null) {
      DatabaseEvent ownerEvent = await _database
          .child('owner_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      if (ownerEvent.snapshot.exists) {
        Map<dynamic, dynamic>? owners =
        ownerEvent.snapshot.value as Map<dynamic, dynamic>?;

        if (owners != null) {
          final ownerData = owners.values.first;

          setState(() {
            _ownerName = ownerData['name'];
            _greeting = _getGreeting(); // Set the greeting here
            _ownerImageUrl = ownerData['imageUrl'] ?? ''; // Fetch the image URL
          });

          // Store additional details in SharedPreferences
          await prefs.setString('email', ownerData['email'] ?? '');
          await prefs.setString('password', ownerData['password'] ?? '');
          await prefs.setString('role', ownerData['role'] ?? '');
        }
      }
    } else {
      // If contact is null, set a default greeting
      setState(() {
        _greeting = _getGreeting();
      });
    }
  }

  // Greeting method that includes "Good Evening"
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else if (hour >= 18 && hour < 24) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context), // Add the drawer here
      appBar: AppBar(
        title: Text(
          _greeting, // Always show the greeting message
          style: const TextStyle(fontSize: 22),
        ),
        centerTitle: true, // Center the title
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 5),
          const SizedBox(height: 10), // Additional spacing
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildAnimatedButton(context, 'House List', Icons.format_list_bulleted, '/house_list'),
                  _buildAnimatedButton(context, 'Add House', Icons.home, '/add_house'),
                  _buildAnimatedButton(context, 'Add Flat', Icons.apartment, '/add_flat'),
                  _buildAnimatedButton(context, 'House Rent', Icons.attach_money, '/house_rent'),
                  _buildAnimatedButton(context, 'Garage Rent', Icons.attach_money, '/garage_rent'), // Updated to navigate to HouseRentPage
// Updated to navigate to HouseRentPage
                  _buildAnimatedButton(context, 'Add User', Icons.person_add, '/add_user'),
                  _buildAnimatedButton(context, 'All Users', Icons.people, '/all_users'),
                  _buildAnimatedButton(context, 'Flat Status Change', Icons.swap_horiz, '/flat_status_change'),
                  // Removed Garage Rent Buttons
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer widget with central picture and navigation options
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _ownerImageUrl.isNotEmpty
                      ? NetworkImage(_ownerImageUrl)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  'Hello, ${_ownerName ?? 'Owner'}', // Keep this as it is
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Exit'),
            onTap: () async {
              // Close the drawer first
              Navigator.of(context).pop();

              // Show the exit confirmation dialog
              await _showExitConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Exit confirmation dialog with animation
  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticInOut,
          ),
          child: AlertDialog(
            title: const Text('Exit Confirmation'),
            content: const Text('Are you sure you want to exit?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog and stay on dashboard
                },
              ),
              TextButton(
                child: const Text('Exit'),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login page
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton(BuildContext context, String title, IconData icon, String route) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          _controller.reverse().then((_) {
            Navigator.pushNamed(context, route)
                .then((_) => _controller.forward());
          });
        },
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
