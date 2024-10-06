import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RentUpdatePage(),
    );
  }
}

class RentUpdatePage extends StatefulWidget {
  const RentUpdatePage({super.key});

  @override
  _RentUpdatePageState createState() => _RentUpdatePageState();
}

class _RentUpdatePageState extends State<RentUpdatePage> {
  final List<String> _houses = ['House 1', 'House 2', 'House 3'];
  final List<String> _floors = [
    '1A',
    '1B',
    '2A',
    '2B',
    '3A',
    '3B',
    '4A',
    '4B',
    '5A',
    '5B',
    '6A',
    '6B'
  ];
  List<DropdownMenuItem<String>> _houseDropdownItems = [];
  List<DropdownMenuItem<String>> _floorDropdownItems = [];
  String? _selectedHouse;
  String? _selectedFloor;

  final TextEditingController _flatRentAmountController = TextEditingController();
  final TextEditingController _gasBillController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _additionalController = TextEditingController();

  late DatabaseReference _rentRef;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rentRef = FirebaseDatabase.instance.ref().child('rent collection');
    _initializeDropdowns();
  }

  @override
  void dispose() {
    _flatRentAmountController.dispose();
    _gasBillController.dispose();
    _waterController.dispose();
    _serviceController.dispose();
    _additionalController.dispose();
    super.dispose();
  }

  void _initializeDropdowns() {
    _houseDropdownItems = _houses.map((house) => DropdownMenuItem<String>(
      value: house,
      child: Text(house),
    )).toList();

    _floorDropdownItems = _floors.map((floor) => DropdownMenuItem<String>(
      value: floor,
      child: Text(floor),
    )).toList();
  }

  void _fetchRentDetails() async {
    setState(() {
      _isLoading = true;
    });

    if (_selectedHouse != null && _selectedFloor != null) {
      try {
        DatabaseEvent event = await _rentRef.once();
        DataSnapshot snapshot = event.snapshot;
        Map<String, dynamic> allRentDetails =
        Map<String, dynamic>.from(snapshot.value as Map);

        bool found = false;
        allRentDetails.forEach((key, value) {
          Map<String, dynamic> rentDetails =
          Map<String, dynamic>.from(value);
          if (rentDetails['house'] == _selectedHouse &&
              rentDetails['floor'] == _selectedFloor) {
            setState(() {
              _flatRentAmountController.text =
                  rentDetails['flatRentAmount'].toString();
              _gasBillController.text = rentDetails['gasBill'].toString();
              _waterController.text = rentDetails['water'].toString();
              _serviceController.text = rentDetails['service'].toString();
              _additionalController.text =
                  rentDetails['additional'].toString();
            });
            found = true;
          }
        });

        if (!found && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No rent details found for selected house and floor')),
          );
        }
      } catch (error) {
        print('Error fetching rent details: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching rent details: $error')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a house and floor')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _updateRentDetails() async {
    setState(() {
      _isLoading = true;
    });

    if (_selectedHouse != null && _selectedFloor != null) {
      try {
        DatabaseEvent event = await _rentRef.once();
        DataSnapshot snapshot = event.snapshot;
        Map<String, dynamic> allRentDetails =
        Map<String, dynamic>.from(snapshot.value as Map);
        String? keyToUpdate;

        allRentDetails.forEach((key, value) {
          Map<String, dynamic> rentDetails =
          Map<String, dynamic>.from(value);
          if (rentDetails['house'] == _selectedHouse &&
              rentDetails['floor'] == _selectedFloor) {
            keyToUpdate = key;
          }
        });

        if (keyToUpdate != null) {
          Map<String, dynamic> updatedData = {
            'flatRentAmount': _flatRentAmountController.text,
            'gasBill': _gasBillController.text,
            'water': _waterController.text,
            'service': _serviceController.text,
            'additional': _additionalController.text,
            'house': _selectedHouse,
            'floor': _selectedFloor,
          };

          await _rentRef.child(keyToUpdate!).update(updatedData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rent details updated successfully')),
          );

          // Navigate back to DashboardPage after update
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No rent details found to update')),
          );
        }
      } catch (e) {
        print('Error updating rent details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating rent details: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _deleteRentDetails() async {
    setState(() {
      _isLoading = true;
    });

    if (_selectedHouse != null && _selectedFloor != null) {
      try {
        DatabaseEvent event = await _rentRef.once();
        DataSnapshot snapshot = event.snapshot;
        Map<String, dynamic> allRentDetails =
        Map<String, dynamic>.from(snapshot.value as Map);
        String? keyToDelete;

        allRentDetails.forEach((key, value) {
          Map<String, dynamic> rentDetails =
          Map<String, dynamic>.from(value);
          if (rentDetails['house'] == _selectedHouse &&
              rentDetails['floor'] == _selectedFloor) {
            keyToDelete = key;
          }
        });

        if (keyToDelete != null) {
          await _rentRef.child(keyToDelete!).remove();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rent details deleted successfully')),
          );

          // Clear input fields after deletion
          setState(() {
            _flatRentAmountController.clear();
            _gasBillController.clear();
            _waterController.clear();
            _serviceController.clear();
            _additionalController.clear();
          });

          // Navigate back to DashboardPage after deletion
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No rent details found to delete')),
          );
        }
      } catch (e) {
        print('Error deleting rent details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting rent details: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a house and floor')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Update'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading ? const SplashScreen() : _buildRentUpdateForm(),
    );
  }

  Widget _buildRentUpdateForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.blueAccent),
                    ),
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
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.blueAccent),
                    ),
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
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _fetchRentDetails,
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _flatRentAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Flat Rent Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gasBillController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Gas Bill',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _waterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Water',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _serviceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Service',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _additionalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Additional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _updateRentDetails,
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: _deleteRentDetails,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.repeat(reverse: true);

    Timer(
      const Duration(seconds: 5),
          () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const RentUpdatePage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                color: Colors.white,
              ),
              child: RotationTransition(
                turns: _animation,
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Please Wait a While',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}