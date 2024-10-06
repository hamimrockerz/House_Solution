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
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<Map<String, dynamic>> _houseList = []; // This will hold the house numbers and details
  String? _selectedHouseKey; // This will hold the selected house's Firebase key

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
    _sectionController.dispose();
    _blockController.dispose();
    _areaController.dispose();
    _zipCodeController.dispose();
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
              'road': entry.value['road'],
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
      _blockController.text = selectedHouse['block'] ?? '';
      _sectionController.text = selectedHouse['section'] ?? '';
      _areaController.text = selectedHouse['area'] ?? ''; // Populate area
      _zipCodeController.text = selectedHouse['zipCode'] ?? ''; // Populate zip code
    });
  }

  // Function to save flat data
  void _saveFlat() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen(), // Use your LoadingScreen widget here
      );

      String contact = _contactController.text.trim();

      // Prepare the flat data to be saved
      Map<String, dynamic> flatData = {
        'name': _nameController.text.trim(),
        'flatNo': _flatNoController.text.trim(),
        'road': _roadController.text.trim(),
        'section': _sectionController.text.trim(),
        'block': _blockController.text.trim(),
        'area': _areaController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
        'house': _selectedHouseKey, // Save selected house's Firebase key
      };

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref();

        // Create a unique key for the new flat entry
        String flatKey = ref.child('Flats/$contact').push().key ?? '';

        // Save the flat data under the unique key
        await ref.child('Flats/$contact/$flatKey').set(flatData);

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
          MaterialPageRoute(builder: (context) => const OwnerDashboard()), // Replace with your actual dashboard page
        );

      } catch (e) {
        Navigator.pop(context); // Close the loading dialog on error
        print("Error saving flat information: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save flat details.'),
          ),
        );
      }
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
              labelStyle: const TextStyle(color: Colors.white), // Label color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), // Border color and width
              ),
              filled: true,
              fillColor: Colors.black54, // Background color of text field
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              suffixIcon: suffixIcon, // Optional suffix icon
            ),
            style: const TextStyle(color: Colors.white), // Text color
            enabled: enabled,
            validator: validator,
          ),
        ),
      ),
    );
  }

  // Build house dropdown
  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: DropdownButtonFormField<String>(
            value: _selectedHouseKey,
            items: _houseList.map<DropdownMenuItem<String>>((house) {
              return DropdownMenuItem<String>(
                value: house['key'], // Firebase key as value
                child: Text(
                  house['houseNo'].toString(), // Display the house number in dropdown
                  style: const TextStyle(color: Colors.black), // Dropdown text color
                ),
              );
            }).toList(),
            onChanged: _onHouseSelected,
            decoration: InputDecoration(
              labelText: 'Select a house',
              filled: true,
              fillColor: Colors.black38,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
              ),
              labelStyle: const TextStyle(color: Colors.white), // Label color
            ),
            validator: (value) => value == null ? 'Please select a house' : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background color
      appBar: AppBar(
        title: const Text('Add Flat', style: TextStyle(fontSize: 22)), // Center title
        centerTitle: true, // Center title in AppBar
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(17.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact',
                  keyboardType: TextInputType.phone,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _fetchOwnerAndHouses(_contactController.text.trim());
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Please enter a valid Contact (11 digits).';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Name.';
                    }
                    return null;
                  },
                ),
                // House and Road in the same row
                Row(
                  children: [
                    Expanded(child: _buildDropdown()), // House dropdown
                    const SizedBox(width: 10), // Spacing between fields
                    Expanded(
                      child: _buildTextField(
                        controller: _roadController,
                        label: 'Road',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Road.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                // Section and Block in the same row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _sectionController,
                        label: 'Section',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Section.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10), // Spacing between fields
                    Expanded(
                      child: _buildTextField(
                        controller: _blockController,
                        label: 'Block',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Block.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                // Area and Zip Code in the same row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _areaController,
                        label: 'Area',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Area.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10), // Spacing between fields
                    Expanded(
                      child: _buildTextField(
                        controller: _zipCodeController,
                        label: 'Zip Code',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(r'^\d{4}$').hasMatch(value)) {
                            return 'Please enter a valid Zip Code (4 digits).';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  controller: _flatNoController,
                  label: 'Flat No',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Flat No.';
                    }
                    return null;
                  },
                ),
                Center(
                  child: AnimatedButton(
                    onPressed: _saveFlat,
                    text: "Save Flat",
                    buttonColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
