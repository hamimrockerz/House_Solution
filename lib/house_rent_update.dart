import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'animate_button_add_house.dart';

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
  List<String> _selectedFlats = [];
  List<String> _houseNumbers = [];
  List<String> _flatNumbers = [];
  List<String> _filteredFlatNumbers = [];
  bool _isSearchTriggered = false;

  String? _selectedRoad;
  String? _selectedBlock;
  String? _selectedSection;
  String? _selectedFlat;

// Example function to set selected values (you should have your UI logic here)
  void _onSelectFlat(String? selectedFlat) {
    setState(() {
      _selectedFlat = selectedFlat;

      // Fetch flat details when both a house and flat are selected
      if (selectedFlat != null && _selectedHouse != null) {
        _fetchFlatDetails(
          _contactController.text.trim(),
          _selectedHouse!,
          selectedFlat,
        );
      }
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
      _contactController.text =
          storedContact; // Auto-populate the contact number
      await _fetchHouses(storedContact);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'No contact number found. Please enter a contact number.')),
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
        const SnackBar(content: Text(
            'No contact number found. Please enter a contact number.')),
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

  void _fetchFlatDetails(String contact, String selectedHouseValue,
      String selectedFlatValue) async {
    // Format selectedHouse
    String selectedHouseFormatted = selectedHouseValue
        .replaceAll(
        RegExp(r'Road:|House:|Block:|Section:'), '') // Remove labels
        .replaceAll(',', '') // Remove commas
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
        .replaceAll(
        RegExp(r'Road:|House:|Block:|Section:|Flat:'), '') // Remove labels
        .replaceAll(',', '') // Remove commas
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
      DataSnapshot snapshot = await FirebaseDatabase.instance.ref(flatPath)
          .get();

      if (snapshot.exists) {
        // Check if snapshot value is of the expected type
        Map<dynamic, dynamic>? flatData = snapshot.value as Map<dynamic,
            dynamic>?;

        if (flatData != null) {
          // Assign the values to the respective controllers
          _flatRentAmountController.text = flatData['rent']?.toString() ?? '';
          _gasBillController.text = flatData['gasBill']?.toString() ?? '';
          _waterBillController.text = flatData['waterBill']?.toString() ?? '';
          _additionalBillController.text =
              flatData['additionalBill']?.toString() ?? '';
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

  void _onSelectHouse(String? selectedHouse) {
    setState(() {
      _selectedHouse = selectedHouse;

      // Fetch flats based on the selected house
      _filterFlatsBasedOnHouse(selectedHouse);

      // Reset selected flat and clear details
      _selectedFlat = null;
    });
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

  void _updateRentDetails() async {
    if (_formKey.currentState!.validate()) {
      String contact = _contactController.text.trim();
      String selectedHouseValue = _selectedHouse ??
          ''; // Ensure selected house value is not null
      String selectedFlatValue = _selectedFlats.isNotEmpty
          ? _selectedFlats.last
          : ''; // Get the last selected flat

      // Format selectedHouse
      String selectedHouseFormatted = selectedHouseValue
          .replaceAll(
          RegExp(r'Road:|House:|Block:|Section:'), '') // Remove labels
          .replaceAll(',', '') // Remove commas
          .replaceAll(' ', '_') // Replace spaces with underscores
          .replaceAll('___', '_') // Remove triple underscores if present
          .replaceAll('__', '_') // Remove double underscores if present
          .trim(); // Remove any leading/trailing spaces

      // Split formatted house components and rearrange them
      List<String> houseComponents = selectedHouseFormatted.split('_');

      // Construct the final formatted selectedHouse
      String selectedHouseFinal = "${contact}_${houseComponents[1]}_${houseComponents[0]}_${houseComponents[2]}_${houseComponents[3]}"; // e.g., "01837097070_2_14_A_11"

      // Loop through selected flats
      for (String flat in _selectedFlats) {
        // Format selectedFlat similarly
        String selectedFlatFormatted = flat
            .replaceAll(
            RegExp(r'Road:|House:|Block:|Section:|Flat:'), '') // Remove labels
            .replaceAll(',', '') // Remove commas
            .replaceAll(' ', '_') // Replace spaces with underscores
            .replaceAll('___', '_') // Remove triple underscores if present
            .replaceAll('__', '_') // Remove double underscores if present
            .trim(); // Remove any leading/trailing spaces

        // Split formatted flat components and rearrange them
        List<String> flatComponents = selectedFlatFormatted.split('_');

        // Construct the final formatted selectedFlat
        String selectedFlatFinal = "${contact}_${flatComponents[1]}_${flatComponents[0]}_${flatComponents[2]}_${flatComponents[3]}_${flatComponents[4]}"; // e.g., "01837097070_2_14_A_11_1A"

        // Construct the flat path to update data
        String flatPath = "Flats/$contact/$selectedHouseFinal/$selectedFlatFinal"; // Path to the selected flat

        // Update flat details in Firebase
        try {
          await FirebaseDatabase.instance.ref(flatPath).update({
            'rent': double.tryParse(_flatRentAmountController.text) ??
                0.0,
            'gasBill': double.tryParse(_gasBillController.text) ?? 0.0,
            'waterBill': double.tryParse(_waterBillController.text) ?? 0.0,
            'additionalBill': double.tryParse(_additionalBillController.text) ??
                0.0,
          });

          print('Successfully updated flat: $flatPath');
        } catch (e) {
          print('Error updating flat $flatPath: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update flat details.')),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flat details updated successfully.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back arrow button
        title: const Center(
          child: Text(
            'Rent Update',
            textAlign: TextAlign.center, // Center align the title
          ),
        ),
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
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a contact number';
                    }
                    return null;
                  },
                  enabled: false,
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
                      child: Center(
                        child: Text(house,
                            style: const TextStyle(color: Colors.blueAccent)),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _onSelectHouse(
                        value); // Call the method for house selection
                  },
                ),
              ),


              // Custom Flat Selection
              // Custom Flat Selection
              // Custom Flat Selection
              // Select Flats Container
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Flats:", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () => _showFlatSelectionDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: Center(
                          child: Text(
                            _selectedFlats.isNotEmpty ? _selectedFlats.join(', ') : 'Select Flats',
                            style: TextStyle(
                              color: _selectedFlats.isNotEmpty ? Colors.green : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

// Display selected flats below the button
              if (_selectedFlats.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _selectedFlats.map((flat) {
                      return Chip(
                        label: Text(
                          flat,
                          style: const TextStyle(color: Colors.green),
                        ),
                        backgroundColor: Colors.blueAccent,
                        deleteIcon: const Icon(Icons.close, color: Colors.white),
                        onDeleted: () {
                          setState(() {
                            _selectedFlats.remove(flat); // Remove flat from selected list
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),


              // Rent Amount TextField
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _flatRentAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.lightGreen),
                  decoration: InputDecoration(
                    labelText: 'Flat Rent Amount',
                    labelStyle: const TextStyle(color: Colors.white54),
                    fillColor: Colors.grey[800],
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
              Center(
                child: AnimatedButton(
                  onPressed: _updateRentDetails,
                  text: "Update Flat Details",
                  buttonColor: Colors.blue,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

// Function to show flat selection dialog
  // Method to show the flat selection dialog
  void _showFlatSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Flats'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _filteredFlatNumbers.map((flat) {
                return GestureDetector(
                  onTap: () {
                    // Toggle selection of the flat
                    setState(() {
                      if (_selectedFlats.contains(flat)) {
                        _selectedFlats.remove(flat); // Deselect if already selected
                      } else {
                        _selectedFlats.add(flat); // Select if not already selected
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _selectedFlats.contains(flat),
                          onChanged: (value) {
                            // Toggle selection on checkbox change
                            setState(() {
                              if (value!) {
                                _selectedFlats.add(flat); // Select
                              } else {
                                _selectedFlats.remove(flat); // Deselect
                              }
                            });
                          },
                        ),
                        Flexible(
                          child: Text(
                            flat,
                            style: const TextStyle(color: Colors.blue),
                            maxLines: 2, // Allows wrapping into two lines
                            overflow: TextOverflow.ellipsis, // Adds '...' if text exceeds two lines
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Done', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                // Fetch flat details when the user clicks Done
                if (_selectedFlats.isNotEmpty && _selectedHouse != null) {
                  // Fetch details for each selected flat
                  for (String flat in _selectedFlats) {
                    _fetchFlatDetails(
                      _contactController.text.trim(),
                      _selectedHouse!,
                      flat,
                    );
                  }
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select at least one flat.')),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }
}