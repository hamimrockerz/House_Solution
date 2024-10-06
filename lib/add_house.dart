import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'animate_button_add_house.dart'; // Ensure this path is correct
import 'owner_dashboard.dart';
// Ensure you have the correct import for OwnerDashboard
import 'loadingscreen.dart'; // Import your LoadingScreen widget

class AddHousePage extends StatefulWidget {
  const AddHousePage({super.key});

  @override
  _AddHousePageState createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    _houseNoController.dispose();
    _roadController.dispose();
    _sectionController.dispose();
    _blockController.dispose();
    _areaController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  // Function to fetch owner information from Firebase Realtime Database
  void _fetchOwnerInformation(String contact) async {
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No owner found with this contact number.'),
          ),
        );
      }
    } catch (e) {
      print("Error fetching owner information: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch owner information.'),
        ),
      );
    }
  }

  // Function to save house data
  // Function to save house data
  void _saveHouse() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen(), // Use your LoadingScreen widget here
      );

      String contact = _contactController.text.trim();

      // Prepare the house data to be saved
      Map<String, dynamic> houseData = {
        'name': _nameController.text.trim(),
        'houseNo': _houseNoController.text.trim(),
        'road': _roadController.text.trim(),
        'section': _sectionController.text.trim(),
        'block': _blockController.text.trim(),
        'area': _areaController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
      };

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref();

        // Query to check for existing houses with the same details for the same contact
        Query query = ref.child('Houses/$contact').orderByChild('houseNo').equalTo(houseData['houseNo']);

        // Listen for the data once
        DatabaseEvent event = await query.once();
        DataSnapshot snapshot = event.snapshot;

        // Check if there are any existing entries with the same house number
        if (snapshot.value != null) {
          Map<dynamic, dynamic> existingHouses = snapshot.value as Map<dynamic, dynamic>;

          // Iterate over existing houses to check for duplicates
          bool isDuplicate = existingHouses.values.any((value) =>
          value['road'] == houseData['road'] &&
              value['section'] == houseData['section'] &&
              value['block'] == houseData['block'] &&
              value['area'] == houseData['area'] &&
              value['zipCode'] == houseData['zipCode']
          );

          if (isDuplicate) {
            Navigator.pop(context); // Close the loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This house entry already exists for this contact.'),
              ),
            );
            return; // Exit the function early to prevent saving
          }
        }

        // Create a unique key for the new house entry
        String houseKey = ref.child('Houses/$contact').push().key ?? '';

        // Save the house data under the unique key
        await ref.child('Houses/$contact/$houseKey').set(houseData);

        // Close the loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('House details saved successfully!'),
          ),
        );

        // Wait for 4 seconds before navigating back


        // Navigate back to OwnerDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OwnerDashboard()), // Replace with your actual dashboard page
        );

      } catch (e) {
        Navigator.pop(context); // Close the loading dialog on error
        print("Error saving house information: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save house details.'),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: suffixIcon,
            ),
            enabled: enabled,
            validator: validator,
            style: const TextStyle(color: Colors.white), // Text color
            onFieldSubmitted: (value) {
              if (label == "Contact") {
                _fetchOwnerInformation(value);
              }
            },
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
        title: const Text('Add House', style: TextStyle(fontSize: 22)), // Center title
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
                      _fetchOwnerInformation(_contactController.text.trim());
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
                _buildTextField(
                  controller: _houseNoController,
                  label: 'House No',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter House No.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _roadController,
                  label: 'Road',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Road.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _sectionController,
                  label: 'Section',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Section.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _blockController,
                  label: 'Block',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Block.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _areaController,
                  label: 'Area',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Area.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
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
                Center(
                  child: AnimatedButton(
                    onPressed: _saveHouse,
                    text: "Save House",
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
