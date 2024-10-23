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
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // Load the stored profile image
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

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl =
          prefs.getString('profileImage'); // Fetch the stored URL
    });
  }

  Future<void> _fetchOwnerDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final contact = prefs.getString('contact');

    if (contact != null) {
      // Fetch owner data
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
          });

          // Store additional details in SharedPreferences
          await prefs.setString('email', ownerData['email'] ?? '');
          await prefs.setString('password', ownerData['password'] ?? '');
          await prefs.setString('role', ownerData['role'] ?? '');

          // Fetch and store the profile image
          String profileImageUrl = ownerData['profileImage'] ??
              ''; // Assuming 'profileImage' is the field in your DB
          await prefs.setString('profileImage', profileImageUrl);
        }
      } else {
        // If owner doesn't exist, check for renter
        DatabaseEvent renterEvent = await _database
            .child('renter_information')
            .orderByChild('contact')
            .equalTo(contact)
            .once();

        if (renterEvent.snapshot.exists) {
          Map<dynamic, dynamic>? renters =
          renterEvent.snapshot.value as Map<dynamic, dynamic>?;

          if (renters != null) {
            final renterData = renters.values.first;

            setState(() {
              _ownerName = renterData['name'];
              _greeting = _getGreeting(); // Set the greeting here
            });

            // Store additional details in SharedPreferences
            await prefs.setString('email', renterData['email'] ?? '');
            await prefs.setString('password', renterData['password'] ?? '');
            await prefs.setString('role', renterData['role'] ?? '');

            // Fetch and store the profile image for renter
            String profileImageUrl = renterData['profileImage'] ??
                ''; // Assuming 'profileImage' is the field in your DB
            await prefs.setString('profileImage', profileImageUrl);
          }
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
    final hour = DateTime
        .now()
        .hour;

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
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(
          _greeting,
          style: const TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF33363A),
        // Match AppBar background color from image
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF2C2F33),
      // Match background color from image
      body: Column(
        children: [
          const SizedBox(height: 5),
          const SizedBox(height: 10),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0), // Adjust grid padding
                children: [
                  _buildAnimatedButton(context, 'House List', Icons.format_list_bulleted, '/house_list'),
                  _buildAnimatedButton(context, 'Add House', Icons.home, '/add_house'),
                  _buildAnimatedButton(context, 'Add Flat', Icons.apartment, '/add_flat'),
                  _buildAnimatedButton(context, 'House Rent', Icons.attach_money, '/house_rent'),
                  _buildAnimatedButton(context, 'Garage Rent', Icons.attach_money, '/garage_rent'),
                  _buildAnimatedButton(context, 'Add User', Icons.person_add, '/add_user'),
                  _buildAnimatedButton(context, 'All Users', Icons.people, '/all_users'),
                  _buildAnimatedButton(context, 'Flat Status Change', Icons.swap_horiz, '/flat_status_change'),
                ],
              ),

            ),
          ),
        ],
      ),
    );
  }

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
                  'Hello, $_ownerName', // Display the fetched user name
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
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Exit'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton(BuildContext context, String label, IconData icon, String route) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          margin: const EdgeInsets.all(8.0), // Margin for spacing
          width: 140, // Slightly increase button width
          height: 140, // Slightly increase button height
          decoration: BoxDecoration(
            color: const Color(0xFF33363A), // Button background color
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blue), // Increased icon size to 50
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16, // Increased font size to 16
                  fontWeight: FontWeight.bold, // Make font bold
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}