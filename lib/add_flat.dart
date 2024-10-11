import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'animate_button_add_house.dart'; // Ensure this path is correct
import 'owner_dashboard.dart'; // Ensure you have the correct import for OwnerDashboard
import 'loadingscreen.dart'; // Import your LoadingScreen widget

class AddFlatPage extends StatefulWidget {
  const AddFlatPage({super.key});

  @override
  _AddFlatPageState createState() => _AddFlatPageState();
}

class _AddFlatPageState extends State<AddFlatPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _flatNoController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController(); // Added houseNo controller
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _bedroomController = TextEditingController();
  final TextEditingController _washroomController = TextEditingController();
  final TextEditingController _kitchenController = TextEditingController();
  final TextEditingController _balconyController = TextEditingController();
  final TextEditingController _rentController = TextEditingController(); // New Flat Rent Amount field
  final TextEditingController _gasBillController = TextEditingController(); // New Gas Bill field
  final TextEditingController _waterBillController = TextEditingController(); // New Water Bill field
  final TextEditingController _additionalBillController = TextEditingController(); // New Additional Bill field

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<Map<String, dynamic>> _houseList = [];
  String? _selectedHouseKey;
  List<String> _flatSuggestions = []; // List to hold flat suggestions
  List<String> _selectedFlatNumbers = [];

  get houseNo_ => null;

  get road_ => null; // List to hold selected flat numbers

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contactController.dispose();
    _nameController.dispose();
    _flatNoController.dispose();
    _roadController.dispose();
    _houseNoController.dispose(); // Dispose house number controller
    _sectionController.dispose();
    _blockController.dispose();
    _areaController.dispose();
    _zipCodeController.dispose();
    _bedroomController.dispose();
    _washroomController.dispose();
    _kitchenController.dispose();
    _balconyController.dispose();
    _rentController.dispose();
    _gasBillController.dispose();
    _waterBillController.dispose();
    _additionalBillController.dispose();

    super.dispose();
  }

  // Function to fetch owner and house information from Firebase Realtime Database
  void _fetchOwnerAndHouses(String contact) async {
    try {
      if (contact.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a contact number.'),
          ),
        );
        return;
      }

      DatabaseReference ref = FirebaseDatabase.instance.ref().child('owner_information');
      Query query = ref.orderByChild('contact').equalTo(contact);
      DatabaseEvent event = await query.once();

      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> ownerData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _nameController.text = ownerData.values.first['name']; // Populate the name field with the first match
        });

        // Now fetch the house list associated with this contact
        _fetchHouseList(contact);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No owner found with this contact number.'),
          ),
        );
      }
    } catch (e) {
      print("Error fetching owner and house information: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch owner information.'),
        ),
      );
    }
  }

  // Function to fetch house list based on contact number
  void _fetchHouseList(String contact) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('Houses/$contact');
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> houseData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _houseList = houseData.entries.map((entry) {
            return {
              'key': entry.key, // Firebase key
              'houseNo': entry.value['houseNo'], // House number
              'road': entry.value['road'], // Road
              'block': entry.value['block'],
              'section': entry.value['section'],
              'area': entry.value['area'], // Area
              'zipCode': entry.value['zipCode'], // Zip Code
            };
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No houses found for this contact.'),
          ),
        );
      }
    } catch (e) {
      print("Error fetching house list: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch house list.'),
        ),
      );
    }
  }

  // Function to handle when a house is selected from the dropdown
  void _onHouseSelected(String? houseKey) {
    setState(() {
      _selectedHouseKey = houseKey;

      // Find the selected house's details and populate the respective fields
      Map<String, dynamic>? selectedHouse = _houseList.firstWhere(
            (house) => house['key'] == houseKey,
        orElse: () => {},
      );

      _roadController.text = selectedHouse['road'] ?? '';
      _houseNoController.text = selectedHouse['houseNo'] ?? ''; // Populate houseNo
      _blockController.text = selectedHouse['block'] ?? '';
      _sectionController.text = selectedHouse['section'] ?? '';
      _areaController.text = selectedHouse['area'] ?? ''; // Populate area
      _zipCodeController.text = selectedHouse['zipCode'] ?? ''; // Populate zip code
    });
  }

  void _saveFlat() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            LoadingScreen(), // Use your LoadingScreen widget here
      );

      String contact = _contactController.text.trim();
      String houseNo = ''; // Initialize houseNo
      String road = ''; // Initialize road
      String block = _blockController.text.trim(); // Get block value

      // Get the selected house details
      if (_selectedHouseKey != null) {
        // Find the selected house's details
        Map<String, dynamic>? selectedHouse = _houseList.firstWhere(
              (house) => house['key'] == _selectedHouseKey,
          orElse: () => {},
        );

        // Ensure that selectedHouse is not empty
        if (selectedHouse.isNotEmpty) {
          houseNo =
              selectedHouse['houseNo'] ?? ''; // Get houseNo from selected house
          road = selectedHouse['road'] ?? ''; // Get road from selected house
        } else {
          print("Selected house not found.");
          Navigator.pop(context);
          return; // Exit if no house is found
        }
      } else {
        print("No house selected.");
        Navigator.pop(context);
        return; // Exit if no house is selected
      }

      // Check if flat numbers are selected
      if (_selectedFlatNumbers.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one flat number.'),
          ),
        );
        return; // Exit if no flat number is selected
      }

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref();

        // Create a unique path for the subcollection using contact, road, house, and block
        String subCollectionPath = 'Flats/$contact/${contact}_${road}_${houseNo}_${block}';

        // Iterate through each selected flat number and save its data
        for (String flatNumber in _selectedFlatNumbers) {
          // Trim whitespace and create a unique ID for each flat
          String trimmedFlatNumber = flatNumber.trim();

          // Create a unique ID for the flat in the format: contact_house_road_block_flat
          String flatId = '${contact}_${houseNo}_${road}_${block}_$trimmedFlatNumber'; // Format: contact_house_road_block_flat

          // Prepare the flat data to be saved
          Map<String, dynamic> flatData = {
            'name': _nameController.text.trim(),
            'flatNo': trimmedFlatNumber,
            // Save the flat number correctly
            'road': road,
            // Use the road variable correctly
            'section': _sectionController.text.trim(),
            'block': block,
            // Save the block number
            'area': _areaController.text.trim(),
            'zipCode': _zipCodeController.text.trim(),
            'bedroom': _bedroomController.text.trim(),
            'washroom': _washroomController.text.trim(),
            'kitchen': _kitchenController.text.trim(),
            'balcony': _balconyController.text.trim(),
            'house': houseNo,
            // Save the house number
            'rent': _rentController.text.trim(),
            // New Rent field
            'gasBill': _gasBillController.text.trim(),
            // New Gas Bill field
            'waterBill': _waterBillController.text.trim(),
            // New Water Bill field
            'additionalBill': _additionalBillController.text.trim(),
            // New Additional Bill field
          };

          // Save the flat data under the constructed path
          await ref.child('$subCollectionPath/$flatId').set(flatData);
          print(
              "Saved flat data for: $flatId"); // Debug log for successful save
        }

        // Close the loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flat details saved successfully!'),
          ),
        );

        // Navigate back to OwnerDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (
              context) => const OwnerDashboard()), // Replace with your actual dashboard page
        );
      } catch (e) {
        Navigator.pop(context); // Close the loading dialog on error
        print("Error saving flat information: $e"); // Enhanced error logging
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save flat details.'),
          ),
        );
      }
    }
  }


  void _onFlatNoChanged(String value) {
    // Create a list of letters A to J
    List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    // Check if the input is a valid number (1, 2, etc.)
    if (value.isNotEmpty && int.tryParse(value) != null) {
      int flatNumber = int.parse(value); // Get the numeric part

      // Create flat numbers from '1A' to '1J', '2A' to '2J', etc.
      List<String> flatSuggestions = letters.map((
          letter) => '$flatNumber$letter').toList();

      setState(() {
        _flatSuggestions = flatSuggestions;
      });
    } else {
      setState(() {
        _flatSuggestions = []; // Clear suggestions if input is not valid
      });
    }
  }

  Widget _buildFlatSuggestions() {
    return Wrap(
      spacing: 8.0, // Space between items
      runSpacing: 8.0, // Space between rows
      children: _flatSuggestions.map((flatNo) {
        return GestureDetector(
          onTap: () {
            _toggleFlatSelection(flatNo); // Handle the tap
            _flatNoController.clear(); // Clear the text field after selection
            setState(() {
              _flatSuggestions.clear(); // Clear suggestions after selecting
            });
          },
          child: Chip(
            label: Text(flatNo), // Display the flat number
            backgroundColor: Colors.blueAccent, // Customize the chip style
            labelStyle: const TextStyle(color: Colors.white), // Text color
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedFlats() {
    return Wrap(
      spacing: 8.0,
      children: _selectedFlatNumbers.map((flatNo) {
        return Chip(
          label: Text(flatNo),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () => _toggleFlatSelection(flatNo),
          backgroundColor: Colors.lightBlue, // Customize the chip style
          labelStyle: const TextStyle(color: Colors.white),// Remove flat on delete
        );
      }).toList(),
    );
  }
  void _toggleFlatSelection(String flatNo) {
    setState(() {
      if (_selectedFlatNumbers.contains(flatNo)) {
        _selectedFlatNumbers.remove(flatNo);
      } else {
        _selectedFlatNumbers.add(flatNo);
      }
    });
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    Widget? suffixIcon,
    bool enabled = true,
    Function(String)? onChanged, // Add this line
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              suffixIcon: suffixIcon,
            ),
            style: const TextStyle(color: Colors.green),
            enabled: enabled,
            validator: validator,
            onChanged: onChanged, // Add this line
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2F33), // Dark background color
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Add Flat',
          textAlign: TextAlign.center, // Center the text
        ),
        centerTitle: true, // Center title in AppBar
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner Contact Field
              _buildTextField(
                controller: _contactController,
                label: 'Owner Contact',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact number';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.black38),
                  onPressed: () =>
                      _fetchOwnerAndHouses(_contactController.text.trim()),
                ),
              ),

              // Row: Owner Name and Select House Dropdown
              Row(
                children: [
                  Flexible(
                    flex: 1, // Decrease width for Owner Name
                    child: _buildTextField(
                      controller: _nameController,
                      label: 'Owner Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the name';
                        }
                        return null;
                      },
                      enabled: false, // Auto-filled
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 2, // Increase width for Select House
                    child: DropdownButtonFormField<String>(
                      value: _selectedHouseKey,
                      decoration: InputDecoration(
                        labelText: 'Select House',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                      ),
                      items: _houseList.map((house) {
                        return DropdownMenuItem<String>(
                          value: house['key'],
                          child: Text(
                            'House: ${house['houseNo']}, Road: ${house['road']}',
                            overflow: TextOverflow.ellipsis, // Handle long text
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: _onHouseSelected,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a house';
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),


              // Flat No Field
              _buildTextField(
                controller: _flatNoController,
                label: 'Flat No.',
                validator: (value) {
                  if (_selectedFlatNumbers.isEmpty) {
                    return 'Please select at least one flat number.';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _onFlatNoChanged(value); // Handle input changes
                  } else {
                    setState(() {
                      _flatSuggestions
                          .clear(); // Clear suggestions if input is empty
                    });
                  }
                },
              ),

              // Display suggestions and selected flats
              _buildFlatSuggestions(),
              _buildSelectedFlats(),

              // Row: Road, Block, and Section Fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _roadController,
                      label: 'Road',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the road';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _blockController,
                      label: 'Block',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the block';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _sectionController,
                      label: 'Section',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the section';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Row: Area and Zip Code Fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _areaController,
                      label: 'Area',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the area';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _zipCodeController,
                      label: 'Zip Code',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the zip code';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Row: Bedroom, Washroom, Kitchen, and Balcony Fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _bedroomController,
                      label: 'Room',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of rooms';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _washroomController,
                      label: 'Washrooms',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of washrooms';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _kitchenController,
                      label: 'Kitchens',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of kitchens';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _balconyController,
                      label: 'Balconies',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of balconies';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Row: Rent, Gas Bill Fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _rentController,
                      label: 'Flat Rent Amount',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the rent amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _gasBillController,
                      label: 'Gas Bill',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the gas bill';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Row: Water Bill and Additional Bill Fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _waterBillController,
                      label: 'Water Bill',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the water bill';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _additionalBillController,
                      label: 'Additional Bill',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter any additional bill';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Save Button
              Center(
                child: AnimatedButton(
                  onPressed: _saveFlat,
                  text: "Save Flat Details",
                  buttonColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}