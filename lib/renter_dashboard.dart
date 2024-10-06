import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RenterDashboard extends StatefulWidget {
  const RenterDashboard({super.key});

  @override
  _RenterDashboardState createState() => _RenterDashboardState();
}

class _RenterDashboardState extends State<RenterDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _renterName;
  String _greeting = 'Welcome'; // Default greeting

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

    // Fetch and display renter's name and other details
    _fetchRenterDetails();
  }

  Future<void> _fetchRenterDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final contact = prefs.getString('contact');

    if (contact != null) {
      DatabaseEvent renterEvent = await _database
          .child('renter_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      if (renterEvent.snapshot.exists) {
        Map<dynamic, dynamic>? renters = renterEvent.snapshot.value as Map<dynamic, dynamic>?;

        if (renters != null) {
          final renterData = renters.values.first;

          setState(() {
            _renterName = renterData['name'];
            _greeting = _getGreeting(); // Set the greeting based on the time
          });

          // Store additional details in SharedPreferences
          await prefs.setString('email', renterData['email'] ?? '');
          await prefs.setString('password', renterData['password'] ?? '');
          await prefs.setString('role', renterData['role'] ?? '');
        }
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else if (hour >= 18 && hour < 24) {
      return 'Good Evening';
    } else {
      return 'Good Night'; // This is for midnight to 6 AM
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
      body: Stack(
        children: [
          Column(
            children: [
              // Welcome section with renter's name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.greenAccent, Colors.lightGreenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Center( // Center widget added here
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                        children: [
                          Text(
                            '$_greeting', // Greeting text
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Welcome, ${_renterName ?? 'Renter'}', // Welcome text with renter name
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Renter Dashboard',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Animated button grid
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      _buildAnimatedButton(context, 'Available Houses', Icons.house, '/available_houses'),
                      _buildAnimatedButton(context, 'My Profile', Icons.account_circle, '/my_profile'),
                      _buildAnimatedButton(context, 'Payment History', Icons.payment, '/payment_history'),
                      _buildAnimatedButton(context, 'Rent Agreements', Icons.document_scanner, '/rent_agreements'),
                      _buildAnimatedButton(context, 'Contact Landlord', Icons.contact_mail, '/contact_landlord'),
                      _buildAnimatedButton(context, 'Feedback', Icons.feedback, '/feedback'),
                      _buildAnimatedButton(context, 'Report Issue', Icons.report, '/report_issue'),
                      _buildAnimatedButton(context, 'Exit', Icons.exit_to_app, '/exit'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Enlarged Notification button positioned in the top-right
          Positioned(
            top: 60,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white, size: 32),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context, String title, IconData icon, String route) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          _controller.reverse().then((_) {
            Navigator.pushNamed(context, route).then((_) => _controller.forward());
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
              Icon(icon, size: 60, color: Colors.greenAccent),
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
