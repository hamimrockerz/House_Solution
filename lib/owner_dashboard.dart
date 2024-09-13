import 'package:flutter/material.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  _OwnerDashboardState createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fade-in animation
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Scale animation for text transition
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticInOut,
      ),
    );

    // Start the animations
    _controller.forward();
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
              // Welcome heading section with transition animations
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
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
                    child: const Column(
                      children: [
                        Text(
                          'Welcome to',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Owner Dashboard',
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
              const SizedBox(height: 20),
              // Animated button grid
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
                      _buildAnimatedButton(context, 'Profile', Icons.account_circle, '/profile'), // Profile button added
                      _buildAnimatedButton(context, 'House Rent Collect', Icons.attach_money, '/house_rent_collect'),
                      _buildAnimatedButton(context, 'Garage Rent Collect', Icons.money, '/garage_rent_collect'),
                      _buildAnimatedButton(context, 'House Rent Update', Icons.update, '/house_rent_update'),
                      _buildAnimatedButton(context, 'Garage Rent Update', Icons.update, '/garage_rent_update'),
                      _buildAnimatedButton(context, 'House Rent Details', Icons.info, '/house_rent_details'),
                      _buildAnimatedButton(context, 'Garage Rent Details', Icons.garage, '/garage_rent_details'),
                      _buildAnimatedButton(context, 'House Rent History', Icons.history, '/rent_history'),
                      _buildAnimatedButton(context, 'Garage Rent History', Icons.history, '/garage_rent_history'),
                      _buildAnimatedButton(context, 'Add User', Icons.person_add, '/add_user'),
                      _buildAnimatedButton(context, 'All Users', Icons.people, '/all_users'),
                      _buildAnimatedButton(context, 'Flat Status Change', Icons.swap_horiz, '/flat_status_change'),
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
              icon: const Icon(Icons.notifications, color: Colors.white, size: 32),  // Enlarged notification icon
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
