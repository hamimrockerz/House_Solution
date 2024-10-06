import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HouseRentCollectPage extends StatefulWidget {
  const HouseRentCollectPage({super.key});

  @override
  _HouseRentCollectPageState createState() => _HouseRentCollectPageState();
}

class _HouseRentCollectPageState extends State<HouseRentCollectPage> {
  final List<String> _houses = ['House 1', 'House 2', 'House 3'];
  final List<String> _floors = [
    '1A', '1B', '2A', '2B', '3A', '3B', '4A', '4B', '5A', '5B', '6A', '6B'
  ];
  final List<int> _days = List.generate(31, (index) => index + 1);
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String? _selectedHouse;
  String? _selectedFloor;
  int? _selectedDay;
  String? _selectedMonth;
  int? _selectedYear;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _additionalController = TextEditingController();
  final TextEditingController _flatRentAmountController = TextEditingController();
  final TextEditingController _gasBillController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();

  bool _loading = false;

  late int _currentYear;
  late List<int> _years;

  @override
  void initState() {
    super.initState();
    _selectedHouse = _houses.first;
    _selectedFloor = _floors.first;
    _selectedDay = DateTime.now().day;
    _selectedMonth = _months[DateTime.now().month - 1];

    _currentYear = DateTime.now().year;
    _years = List.generate(11, (index) => _currentYear + index);
  }

  void _searchHouseAndFloor() async {
    DatabaseReference housesRef = FirebaseDatabase.instance.ref().child('houses');
    DatabaseReference rentCollectionRef = FirebaseDatabase.instance.ref().child('rent collection');

    try {
      // Query houses to find name and phone based on selected house and floor
      DatabaseEvent housesEvent = await housesRef
          .orderByChild('house')
          .equalTo(_selectedHouse)
          .once();
      DataSnapshot housesSnapshot = housesEvent.snapshot;
      if (housesSnapshot.value != null) {
        bool dataFound = false;
        (housesSnapshot.value as Map).forEach((key, value) {
          if (value['floor'] == _selectedFloor) {
            setState(() {
              _nameController.text = value['name'] ?? '';
              _phoneController.text = value['phone'] ?? '';
            });
            dataFound = true;
          }
        });
        if (!dataFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No data found for selected house and floor'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data found for selected house')),
        );
      }

      // Query rent collection to find additional, gas bill, etc. based on selected house and floor
      DatabaseEvent rentCollectionEvent = await rentCollectionRef
          .orderByChild('house')
          .equalTo(_selectedHouse)
          .once();
      DataSnapshot rentCollectionSnapshot = rentCollectionEvent.snapshot;
      if (rentCollectionSnapshot.value != null) {
        bool dataFound = false;
        (rentCollectionSnapshot.value as Map).forEach((key, value) {
          if (value['floor'] == _selectedFloor) {
            setState(() {
              _additionalController.text = value['additional'] ?? '';
              _flatRentAmountController.text = value['flatRentAmount'] ?? '';
              _gasBillController.text = value['gasBill'] ?? '';
              _serviceController.text = value['service'] ?? '';
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
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No rent data found for selected house')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching data. Please try again later.'),
        ),
      );
      print('Error fetching data: $e');
    }
  }

  Future<void> _submitRentDetails() async {
    setState(() {
      _loading = true;
    });

    // Simulating a delay of 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    DatabaseReference rentUserRef = FirebaseDatabase.instance.ref().child('rent user');

    try {
      await rentUserRef.push().set({
        'house': _selectedHouse,
        'floor': _selectedFloor,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'additional': _additionalController.text,
        'flatRentAmount': _flatRentAmountController.text,
        'gasBill': _gasBillController.text,
        'service': _serviceController.text,
        'day': _selectedDay,
        'month': _selectedMonth,
        'year': _selectedYear,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rent details submitted successfully'),
        ),
      );

      // Reset fields after submission
      setState(() {
        _nameController.clear();
        _phoneController.clear();
        _additionalController.clear();
        _flatRentAmountController.clear();
        _gasBillController.clear();
        _serviceController.clear();
        _loading = false;
      });

      // Navigate to dashboard or any other screen
      Navigator.pushReplacementNamed(context, '/dashboard');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting rent details. Please try again later.'),
        ),
      );
      print('Error submitting rent details: $e');
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Rent Collection'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
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
                          _selectedHouse = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'House',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
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
                          _selectedFloor = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Floor',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _searchHouseAndFloor,
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _additionalController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Additional',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _flatRentAmountController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Flat Rent Amount',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gasBillController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Gas Bill',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serviceController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Service',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedDay,
                      items: _days.map((day) {
                        return DropdownMenuItem<int>(
                          value: day,
                          child: Text(day.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDay = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Day',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
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
                          _selectedMonth = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Month',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      items: _years.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Year',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRentDetails,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    overlayColor: Colors.blue,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
