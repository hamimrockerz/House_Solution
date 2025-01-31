import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RenterDashboard extends StatefulWidget {
  const RenterDashboard({super.key});

  @override
  _RenterDashboardState createState() => _RenterDashboardState();
}

class _RenterDashboardState extends State<RenterDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _renterName;
  String _greeting = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();

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

    // Fetch renter details and set greeting message
    _fetchRenterDetails();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('profileImage');
    });
  }

  Future<void> _fetchRenterDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final contact = prefs.getString('contact');

    if (contact != null) {
      // Fetch renter data
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
            _renterName = renterData['name'];
            _greeting = _getGreeting();
          });

          // Store additional details in SharedPreferences
          await prefs.setString('email', renterData['email'] ?? '');
          await prefs.setString('password', renterData['password'] ?? '');
          await prefs.setString('role', renterData['role'] ?? '');

          // Fetch and store the profile image
          String profileImageUrl = renterData['profileImage'] ?? '';
          await prefs.setString('profileImage', profileImageUrl);
        }
      } else {
        // Handle case where renter doesn't exist
        setState(() {
          _greeting =
              _getGreeting(); // Set a default greeting if no renter found
        });
      }
    } else {
      setState(() {
        _greeting = _getGreeting(); // Set a default greeting if contact is null
      });
    }
  }

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
        backgroundColor: const Color(0xFF33363A), // AppBar background color
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
      // Scaffold background color
      body: Column(
        children: [
          const SizedBox(height: 5),
          const SizedBox(height: 10),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildAnimatedButton(
                      context, 'Favorites Houses', Icons.house, '/view_houses'),
                  _buildAnimatedButton(context, 'Rent History', Icons.history,
                      '/rent_user_history'),
                  _buildAnimatedButton(context, 'Rent Pay', Icons.attach_money,
                      '/user_house_rent_collect'),
                  _buildAnimatedButton(
                      context, 'Search House', Icons.search, '/search_house'),
                  _buildAnimatedButton(
                      context, 'Saved Search House', Icons.bookmark,
                      '/saved_search_house'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/messenger');
          },
          child: const Icon(Icons.chat),
          backgroundColor: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2C2F33), // Drawer background color
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
                  onBackgroundImageError: (_, __) => Icon(Icons.error),
                )
                    : const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hello, $_renterName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
              Navigator.of(context).pop();
              await _showExitConfirmationDialog(context);
            },
          ),
        ],
      ),
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
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton(BuildContext context, String title, IconData icon,
      String route) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          _controller.reverse().then((_) {
            Navigator.pushNamed(context, route).then((_) =>
                _controller.forward());
          });
        },
        child: Container(
          margin: const EdgeInsets.all(8.0),
          // Button margin
          width: 140,
          // Button width
          height: 140,
          // Button height
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
              Icon(icon, size: 50, color: Colors.blue), // Icon color and size
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Font size
                  fontWeight: FontWeight.bold, // Bold font
                  color: Colors.white, // Font color
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