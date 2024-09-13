import 'package:flutter/material.dart';

class RenterDashboard extends StatelessWidget {
  const RenterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renter Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildDashboardButton(context, 'Add House', Icons.home, '/add_house'),
          _buildDashboardButton(context, 'Add Flat', Icons.apartment, '/add_flat'),
          _buildDashboardButton(context, 'House Rent Details', Icons.info, '/house_rent_details'),
          _buildDashboardButton(context, 'House Rent Collect', Icons.attach_money, '/house_rent_collect'),
          _buildDashboardButton(context, 'Rent History', Icons.history, '/rent_history'),
          _buildDashboardButton(context, 'Garage Rent Details', Icons.garage, '/garage_rent_details'),
          _buildDashboardButton(context, 'Garage Rent Collect', Icons.money, '/garage_rent_collect'),
          _buildDashboardButton(context, 'Garage Rent History', Icons.history, '/garage_rent_history'),
          _buildDashboardButton(context, 'Add User', Icons.person_add, '/add_user'),
          _buildDashboardButton(context, 'All Users', Icons.people, '/all_users'),
          _buildDashboardButton(context, 'Flat Status Change', Icons.swap_horiz, '/flat_status_change'),
          _buildDashboardButton(context, 'Exit', Icons.exit_to_app, '/exit'),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
