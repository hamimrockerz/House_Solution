import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'owner_dashboard.dart'; // Import your dashboard page here

class HouseRentDetailsPage extends StatefulWidget {
  const HouseRentDetailsPage({Key? key}) : super(key: key);

  @override
  _HouseRentDetailsPageState createState() => _HouseRentDetailsPageState();
}

class _HouseRentDetailsPageState extends State<HouseRentDetailsPage> {
  final List<String> _houses = ['House 1', 'House 2', 'House 3'];
  final List<String> _floors = ['1A', '1B', '2A', '2B', '3A', '3B', '4A', '4B', '5A', '5B', '6A', '6B'];
  List<DropdownMenuItem<String>> _houseDropdownItems = [];
  List<DropdownMenuItem<String>> _floorDropdownItems = [];
  String? _selectedHouse;
  String? _selectedFloor;
  bool _isLoading = false;

  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _gasBillController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _additionalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDropdowns();
  }

  void _initializeDropdowns() {
    _houseDropdownItems = _houses
        .map((house) => DropdownMenuItem<String>(
      value: house,
      child: Text(house),
    ))
        .toList();

    _floorDropdownItems = _floors
        .map((floor) => DropdownMenuItem<String>(
      value: floor,
      child: Text(floor),
    ))
        .toList();

    // Initialize with default values
    _selectedHouse = _houses.first;
    _selectedFloor = _floors.first;
  }

  void _submitRentDetails() async {
    setState(() {
      _isLoading = true; // Start showing loading screen
    });

    DatabaseReference rentRef = FirebaseDatabase.instance.ref().child('house_rent_details');
    Map<String, dynamic> rentData = {
      'house': _selectedHouse,
      'floor': _selectedFloor,
      'rentAmount': _rentAmountController.text,
      'gasBill': _gasBillController.text,
      'water': _waterController.text,
      'service': _serviceController.text,
      'additional': _additionalController.text,
    };

    try {
      await rentRef.push().set(rentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rent details submitted successfully')),
      );

      // Clear input fields after submission
      _rentAmountController.clear();
      _gasBillController.clear();
      _waterController.clear();
      _serviceController.clear();
      _additionalController.clear();

      // Navigate to dashboard page (dashboard_page.dart)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OwnerDashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit rent details. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop showing loading screen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Rent Details'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedHouse,
                          items: _houseDropdownItems,
                          onChanged: (value) {
                            setState(() {
                              _selectedHouse = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'House',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFloor,
                          items: _floorDropdownItems,
                          onChanged: (value) {
                            setState(() {
                              _selectedFloor = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Floor',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rentAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Rent Amount',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gasBillController,
                    decoration: const InputDecoration(
                      labelText: 'Gas Bill',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _waterController,
                    decoration: const InputDecoration(
                      labelText: 'Water',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serviceController,
                    decoration: const InputDecoration(
                      labelText: 'Service',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _additionalController,
                    decoration: const InputDecoration(
                      labelText: 'Additional',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRentDetails,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
