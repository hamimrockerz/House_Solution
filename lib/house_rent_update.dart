import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RentUpdatePage extends StatefulWidget {
  const RentUpdatePage({super.key});

  @override
  _RentUpdatePageState createState() => _RentUpdatePageState();
}

class _RentUpdatePageState extends State<RentUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _flatRentAmountController = TextEditingController();
  final TextEditingController _gasBillController = TextEditingController();
  final TextEditingController _waterBillController = TextEditingController();
  final TextEditingController _additionalBillController = TextEditingController();

  String? _selectedHouse;
  List<String> _selectedFlats = []; // Stores multiple selected flats
  List<String> _houseNumbers = [];
  List<String> _flatNumbers = [];
  List<String> _filteredFlatNumbers = [];
  bool _isSearchTriggered = false;


  String? _selectedRoad;    // Selected road
  String? _selectedBlock;   // Selected block
  String? _selectedSection;  // Selected section
  String? _selectedFlat;     // Selected flat

// Example function to set selected values (you should have your UI logic here)
  void _onSelectFlat(String house, String road, String block, String section, String flat) {
    setState(() {
      _selectedHouse = house;
      _selectedRoad = road;
      _selectedBlock = block;
      _selectedSection = section;
      _selectedFlat = flat;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadContactNumber(); // Load contact number when the page initializes
    _initializeFlatData(); // Fetch flats directly in initState
  }

  void _loadContactNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');

    if (storedContact != null) {
      await _fetchHouses(storedContact);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No contact number found. Please enter a contact number.'),
        ),
      );
    }
  }

  void _initializeFlatData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');

    if (storedContact != null) {
      await _fetchFlats(storedContact);
      setState(() {
        _selectedFlats = [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No contact number found. Please enter a contact number.'),
        ),
      );
    }
  }

  void _filterFlatsBasedOnHouse(String? selectedHouse) {
    if (selectedHouse != null) {
      List<String> selectedHouseParts = selectedHouse.split(', ');
      if (selectedHouseParts.length >= 4) {
        String housePrefix = selectedHouseParts.sublist(0, 4).join(', ');

        _filteredFlatNumbers = _flatNumbers.where((flat) {
          return flat.startsWith(housePrefix);
        }).toList();

        _selectedFlats = [];
      } else {
        _filteredFlatNumbers.clear();
        _selectedFlats = [];
      }
    } else {
      _filteredFlatNumbers.clear();
      _selectedFlats = [];
    }

    setState(() {});
  }

  Future<void> _fetchHouses(String contact) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child(
          'Flats/$contact');
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> flatsData = snapshot.value as Map<dynamic,
            dynamic>;
        Set<String> fetchedHouseNumbers = {};

        flatsData.forEach((key, value) {
          List<String> parts = key.split('_');
          if (parts.length >= 4) {
            String road = parts[2].replaceAll('%', '/');
            String house = parts[1].replaceAll('%', '/');
            String block = parts[3].replaceAll('%', '/');
            String section = parts[4].replaceAll('%', '/');

            String formattedHouse = "House:$road, Road:$house, Block:$block, Section:$section";
            fetchedHouseNumbers.add(formattedHouse);
          }
        });

        setState(() {
          _houseNumbers = fetchedHouseNumbers.toList();
          _selectedHouse = null;
        });
      } else {
        setState(() {
          _houseNumbers = [];
          _selectedHouse = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No house information found for the contact.')),
        );
      }
    } catch (e) {
      print("Error fetching houses: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch house information.')),
      );
    }
  }

  Future<void> _fetchFlats(String contact) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child(
          'Flats/$contact');
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> flatsData = snapshot.value as Map<dynamic,
            dynamic>;
        List<String> fetchedFlatNumbers = [];

        flatsData.forEach((key, value) {
          if (key.startsWith(contact)) {
            Map<dynamic, dynamic> subCollection = value as Map<dynamic,
                dynamic>;

            subCollection.forEach((subKey, subValue) {
              if (subKey.contains('_')) {
                List<String> parts = subKey.split('_');
                if (parts.length > 4) {
                  String flatId = parts.last.replaceAll('%', '/');
                  String houseId = parts[1].replaceAll('%', '/');
                  String roadId = parts[2].replaceAll('%', '/');
                  String blockId = parts[3].replaceAll('%', '/');
                  String sectionId = parts[4].replaceAll('%', '/');

                  String formattedFlat = "House:$roadId, Road:$houseId, Block:$blockId, Section:$sectionId, Flat:$flatId";
                  fetchedFlatNumbers.add(formattedFlat);
                }
              }
            });
          }
        });

        setState(() {
          _flatNumbers = fetchedFlatNumbers;
          _filteredFlatNumbers = List.from(_flatNumbers);
        });
      } else {
        setState(() {
          _flatNumbers = [];
          _filteredFlatNumbers = [];
          _selectedFlats = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No flat information found for the contact.')),
        );
      }
    } catch (e) {
      print("Error fetching flats: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch flat information.')),
      );
    }
  }

  void _fetchFlatDetails(String contact, String selectedHouseValue, String selectedFlatValue) async {
    // Format selectedHouse
    String selectedHouseFormatted = selectedHouseValue
        .replaceAll(RegExp(r'Road:|House:|Block:|Section:'), '') // Remove labels
        .replaceAll(',', '')  // Remove commas
        .replaceAll(' ', '_') // Replace spaces with underscores
        .replaceAll('___', '_') // Remove triple underscores if present
        .replaceAll('__', '_') // Remove double underscores if present
        .trim(); // Remove any leading/trailing spaces

    // Split formatted house components and rearrange them
    List<String> houseComponents = selectedHouseFormatted.split('_');

    // Construct the final formatted selectedHouse
    String selectedHouseFinal = "${contact}_${houseComponents[1]}_${houseComponents[0]}_${houseComponents[2]}_${houseComponents[3]}"; // e.g., "01837097070_2_14_A_11"

    // Format selectedFlat similarly
    String selectedFlatFormatted = selectedFlatValue
        .replaceAll(RegExp(r'Road:|House:|Block:|Section:|Flat:'), '') // Remove labels
        .replaceAll(',', '')  // Remove commas
        .replaceAll(' ', '_') // Replace spaces with underscores
        .replaceAll('___', '_') // Remove triple underscores if present
        .replaceAll('__', '_') // Remove double underscores if present
        .trim(); // Remove any leading/trailing spaces

    // Split formatted flat components and rearrange them
    List<String> flatComponents = selectedFlatFormatted.split('_');

    // Construct the final formatted selectedFlat
    String selectedFlatFinal = "${contact}_${flatComponents[1]}_${flatComponents[0]}_${flatComponents[2]}_${flatComponents[3]}_${flatComponents[4]}"; // e.g., "01837097070_2_14_A_11_1A"

    // Construct the flat path to fetch data
    String flatPath = "Flats/$contact/$selectedHouseFinal/$selectedFlatFinal"; // Path to the selected flat

    // Print debug information
    print("Fetching flat details from path: $flatPath");

    try {
      // Fetch data from Firebase
      DataSnapshot snapshot = await FirebaseDatabase.instance.ref(flatPath).get();

      if (snapshot.exists) {
        // Check if snapshot value is of the expected type
        Map<dynamic, dynamic>? flatData = snapshot.value as Map<dynamic, dynamic>?;

        if (flatData != null) {
          // Assign the values to the respective controllers
          _flatRentAmountController.text = flatData['rent']?.toString() ?? '';
          _gasBillController.text = flatData['gasBill']?.toString() ?? '';
          _waterBillController.text = flatData['waterBill']?.toString() ?? '';
          _additionalBillController.text = flatData['additionalBill']?.toString() ?? '';
        } else {
          // Handle case where flat data is null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Flat details not found.')),
          );
        }
      } else {
        // Handle the case where the flat does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flat details not found.')),
        );
      }
    } catch (e) {
      // Print more detailed error
      print('Error fetching flat details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch flat details.')),
      );
    }
  }




  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white70,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          suffixIcon: suffixIcon,
        ),
        enabled: enabled,
        validator: validator,
      ),
    );
  }

  void _updateRentDetails() {
    if (_formKey.currentState!.validate()) {
      print('Updating rent details for contact: ${_contactController.text}');
      print('Selected House: $_selectedHouse');
      print('Selected Flats: $_selectedFlats');
      print('Flat Rent Amount: ${_flatRentAmountController.text}');
      print('Gas Bill: ${_gasBillController.text}');
      print('Water Bill: ${_waterBillController.text}');
      print('Additional Bill: ${_additionalBillController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: const Text('Rent Update'),
        backgroundColor: Colors.blueAccent, // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Contact Number TextField
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    labelStyle: const TextStyle(color: Colors.white54),
                    fillColor: Colors.grey[800],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    suffixIcon:IconButton(
                      icon: const Icon(Icons.search, color: Colors.black87),
                      onPressed: () {
                        String contact = _contactController.text.trim();
                        String selectedHouse = _selectedHouse ?? ''; // Get selected house
                        String selectedFlat = _selectedFlats.isNotEmpty ? _selectedFlats.last : ''; // Get selected flat

                        // Validate that all fields are filled
                        if (contact.isNotEmpty && selectedHouse.isNotEmpty && selectedFlat.isNotEmpty) {
                          _fetchFlatDetails(contact, selectedHouse, selectedFlat);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields.')),
                          );
                        }
                      },
                    ),

                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a contact number';
                    }
                    return null;
                  },
                ),
              ),

              // House Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select House',
                    labelStyle: const TextStyle(color: Colors.white38),
                    fillColor: Colors.grey[800],
                    // Dropdown background color
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  value: _selectedHouse,
                  items: _houseNumbers.map((house) {
                    return DropdownMenuItem(
                      value: house,
                      child: Text(house,
                          style: const TextStyle(color: Colors.blueAccent)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedHouse = value;
                    });
                    _filterFlatsBasedOnHouse(value);
                  },
                ),
              ),

              // Flat Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select Flat',
                    labelStyle: const TextStyle(color: Colors.white54),
                    fillColor: Colors.grey[800],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text(
                        'Select a Flat',
                        style: TextStyle(color: Colors.white54),
                      ),
                      items: _filteredFlatNumbers.map((flat) {
                        return DropdownMenuItem<String>(
                          value: flat,
                          child: Text(flat, style: const TextStyle(color: Colors.lightBlueAccent)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value != null && !_selectedFlats.contains(value)) {
                            _selectedFlats.add(value);
                            _selectedFlat = value;  // Update selected flat value
                          }
                        });
                      },
                      isExpanded: true,
                      dropdownColor: Colors.grey[800],
                    ),
                  ),
                ),
              ),

// Display selected flat below the dropdown
              if (_selectedFlat != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Chip(
                    label: Text(
                      _selectedFlat!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blueAccent,
                    deleteIcon: const Icon(Icons.close, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        _selectedFlat = null;  // Clear selected flat
                        _selectedFlats.removeWhere((flat) => flat == _selectedFlat);
                      });
                    },
                  ),
                ),
              // Rent Amount TextField
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _flatRentAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Flat Rent Amount',
                    labelStyle: const TextStyle(color: Colors.white54),
                    fillColor: Colors.grey[800],
                    // Background color
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the flat rent amount';
                    }
                    return null;
                  },
                ),
              ),

              // Gas Bill TextField
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _gasBillController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Gas Bill',
                    labelStyle: const TextStyle(color: Colors.white54),
                    fillColor: Colors.grey[800],
                    // Background color
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the gas bill';
                    }
                    return null;
                  },
                ),
              ),

              // Water Bill TextField
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _waterBillController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Water Bill',
                    labelStyle: const TextStyle(color: Colors.white54),
                    fillColor: Colors.grey[800],
                    // Background color
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the water bill';
                    }
                    return null;
                  },
                ),
              ),

              // Additional Bill TextField
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _additionalBillController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Additional Bill',
                    labelStyle: const TextStyle(color: Colors.white54),
                    fillColor: Colors.grey[800],
                    // Background color
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter any additional bill';
                    }
                    return null;
                  },
                ),
              ),

              // Submit Button
              ElevatedButton(
                onPressed: _updateRentDetails,
                child: const Text('Update Rent Details'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
