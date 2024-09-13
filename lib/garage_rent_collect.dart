import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GarageRentCollectPage extends StatefulWidget {
  const GarageRentCollectPage({Key? key}) : super(key: key);

  @override
  _CarRentCollectPageState createState() => _CarRentCollectPageState();
}

class _CarRentCollectPageState extends State<GarageRentCollectPage> {
  final List<String> _houses = ['House 1', 'House 2', 'House 3'];
  final List<String> _floors = ['1A', '1B', '2A', '2B', '3A', '3B', '4A', '4B', '5A', '5B', '6A', '6B'];
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  late String _selectedHouse;
  late String _selectedFloor;
  late String _selectedDay;
  late String _selectedMonth;
  late String _selectedYear;
  late List<String> _years;

  final TextEditingController _carOwnerNameController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedHouse = _houses.first;
    _selectedFloor = _floors.first;
    _selectedDay = now.day.toString();
    _selectedMonth = _months[now.month - 1]; // Month name from _months list
    _selectedYear = now.year.toString();
    _years = List.generate(6, (index) => (now.year + index).toString());
    _clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Rent Collect'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Padding(
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
                    items: _houses.map((house) {
                      return DropdownMenuItem<String>(
                        value: house,
                        child: Text(house),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHouse = value!;
                        _selectedFloor = _floors.first;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'House',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFloor,
                    items: _floors.map((floor) {
                      return DropdownMenuItem<String>(
                        value: floor,
                        child: Text(floor),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFloor = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Floor',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _fetchData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _carOwnerNameController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Car Owner Name',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _carTypeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Car Type',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _professionController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Profession',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _rentAmountController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Rent Amount',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDay,
                    items: List.generate(31, (index) => (index + 1).toString()).map((day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Day',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    items: _months.map((month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Month',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedYear,
                    items: _years.map((year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Year',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _fetchData() {
    setState(() {
      _isLoading = true;
    });

    DatabaseReference garageRentRef = FirebaseDatabase.instance.ref().child('garagerent_collect');

    _clearFields();

    garageRentRef
        .orderByChild('house')
        .equalTo(_selectedHouse)
        .once()
        .then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<Object?, Object?> dataMap = event.snapshot.value as Map<Object?, Object?>;

        bool dataFound = false;

        dataMap.forEach((key, value) {
          Map<String, dynamic> data = Map<String, dynamic>.from(value as Map);

          if (data['floor'] == _selectedFloor) {
            setState(() {
              _carOwnerNameController.text = data['carOwnerName'] ?? '';
              _carTypeController.text = data['carType'] ?? '';
              _professionController.text = data['profession'] ?? '';
              _phoneController.text = data['phone'] ?? '';
              _rentAmountController.text = data['rentAmount'] ?? '';
              _isLoading = false; // Hide loading screen
            });
            dataFound = true;
          }
        });

        if (!dataFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No rent data found for selected house and floor'),
            ),
          );
          _isLoading = false; // Hide loading screen
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No data found for selected house and floor'),
          ),
        );
        _isLoading = false; // Hide loading screen
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching data. Please try again later.'),
        ),
      );
      print('Error fetching data: $error');
      _isLoading = false; // Hide loading screen
    });
  }

  void _clearFields() {
    setState(() {
      _carOwnerNameController.clear();
      _carTypeController.clear();
      _professionController.clear();
      _phoneController.clear();
      _rentAmountController.clear();
    });
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    DatabaseReference grentRef = FirebaseDatabase.instance.ref().child('grent');

    Map<String, dynamic> rentData = {
      'house': _selectedHouse,
      'floor': _selectedFloor,
      'carOwnerName': _carOwnerNameController.text,
      'carType': _carTypeController.text,
      'profession': _professionController.text,
      'phone': _phoneController.text,
      'rentAmount': _rentAmountController.text,
      'day': _selectedDay,
      'month': _selectedMonth,
      'year': _selectedYear,
    };

    try {
      await grentRef.push().set(rentData);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Rent data saved successfully'),
      ));

      // Simulate a delay for the loading splash screen effect
      await Future.delayed(Duration(seconds: 2));

      // Navigate back to dashboard after successful submission
      Navigator.of(context).pop(); // Close the current page
      Navigator.pushReplacementNamed(context, '/dashboard'); // Replace with your actual dashboard route
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to save rent data'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _carOwnerNameController.dispose();
    _carTypeController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    _rentAmountController.dispose();
    super.dispose();
  }
}
