import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GarageRentDetailsPage extends StatefulWidget {
  const GarageRentDetailsPage({super.key});

  @override
  _GarageRentDetailsPageState createState() => _GarageRentDetailsPageState();
}

class _GarageRentDetailsPageState extends State<GarageRentDetailsPage> {
  final List<String> _houses = ['House 1', 'House 2', 'House 3'];
  final List<String> _floors = ['1A', '1B', '2A', '2B', '3A', '3B', '4A', '4B', '5A', '5B', '6A', '6B'];
  final List<String> _carTypes = ['Sedan', 'SUV', 'Hatchback', 'Truck', 'Van', 'Motorcycle'];
  final List<String> _professions = ['Engineer', 'Doctor', 'Teacher', 'Lawyer', 'Artist', 'Student'];

  String _selectedHouse = 'House 1';
  String _selectedFloor = '1A';
  String? _selectedCarType;
  String? _selectedProfession;

  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carOwnerNameController = TextEditingController();
  final TextEditingController _carNumberPlateController = TextEditingController();

  bool _isLoading = false;

  void _submitForm() async {
    if (!_allFieldsFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save user data into Firebase
      DatabaseReference garageRentRef = FirebaseDatabase.instance.ref().child('garagerent_collect');

      // Example data structure to save into Firebase
      Map<String, dynamic> rentData = {
        'house': _selectedHouse,
        'floor': _selectedFloor,
        'rentAmount': _rentAmountController.text,
        'phone': _phoneController.text,
        'carType': _selectedCarType,
        'carNumberPlate': _carNumberPlateController.text,
        'profession': _selectedProfession,
        'carOwnerName': _carOwnerNameController.text,
      };

      // Save rent data
      await garageRentRef.push().set(rentData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rent data saved successfully')));

      // Clear form after successful submission
      _clearForm();

    } catch (e) {
      // Handle any errors that occur during data saving
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save rent data')));
      print('Error saving rent data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _allFieldsFilled() {
    return _selectedHouse.isNotEmpty &&
        _selectedFloor.isNotEmpty &&
        _rentAmountController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _carOwnerNameController.text.isNotEmpty &&
        _carNumberPlateController.text.isNotEmpty &&
        _selectedCarType != null &&
        _selectedProfession != null;
  }

  void _clearForm() {
    setState(() {
      _selectedHouse = 'House 1';
      _selectedFloor = '1A';
      _selectedCarType = null;
      _selectedProfession = null;
      _rentAmountController.clear();
      _phoneController.clear();
      _carOwnerNameController.clear();
      _carNumberPlateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage Rent Details'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
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
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'House',
                ),
              ),
              DropdownButtonFormField<String>(
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
              TextFormField(
                controller: _carOwnerNameController,
                decoration: const InputDecoration(
                  labelText: 'Car Owner Name',
                ),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _rentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Rent Amount',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _carNumberPlateController,
                decoration: const InputDecoration(
                  labelText: 'Car Number Plate',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCarType,
                items: _carTypes.map((carType) {
                  return DropdownMenuItem<String>(
                    value: carType,
                    child: Text(carType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCarType = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Car Type',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedProfession,
                items: _professions.map((profession) {
                  return DropdownMenuItem<String>(
                    value: profession,
                    child: Text(profession),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProfession = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Profession',
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
