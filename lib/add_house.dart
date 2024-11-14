import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'animate_button_add_house.dart'; // Ensure this path is correct
import 'owner_dashboard.dart';
import 'loadingscreen.dart'; // Import your LoadingScreen widget
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _thanaController = TextEditingController();
  final TextEditingController _divisionController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();


  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<String> thanaSuggestions = [];
  List<String> areaSuggestions = [];
  List<String> zipCodeSuggestions = [];

  // States for unlocking fields
  bool isThanaEnabled = false;
  bool isAreaEnabled = false;
  bool isZipCodeEnabled = false;

  // Selected Division
  String? selectedDivision;

  final List<String> divisionSuggestions = [
    'Dhaka',
    'Chattogram (Chittagong)',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];
  final Map<String, List<String>> divisionToThanas = {
    'Dhaka': ['Dhanmondi', 'Uttara', 'Gulshan', 'Mirpur', 'Banani'],
    'Chattogram': ['Agrabad', 'Panchlaish', 'Kotwali', 'Halishahar', 'Chawkbazar'],
    'Khulna': ['Khalishpur', 'Sonadanga', 'Daulatpur', 'Rupsha'],
    'Rajshahi': ['Boalia', 'Motihar', 'Paba', 'Rajpara'],
    'Sylhet': ['Bandar Bazar', 'Zindabazar', 'Kumarpara', 'Amberkhana'],
    'Barishal': ['Kotwali', 'Bagerhat', 'Bakerganj', 'Banaripara'],
    'Rangpur': ['Gangachara', 'Kaunia', 'Badarganj', 'Pirganj'],
    'Mymensingh': ['Muktagacha', 'Trishal', 'Valuka', 'Nandail'],
  };

  final Map<String, List<String>> divisionToAreas = {
    'Dhaka': ['Mohammadpur', 'Bashundhara', 'Tejgaon', 'Shahbagh'],
    'Chattogram': ['Nasirabad', 'Jamalkhan', 'Hathazari', 'Sitakunda'],
    'Khulna': ['Khalishpur', 'Bagmara', 'Sonadanga', 'Daulatpur'],
    'Rajshahi': ['Uposhohor', 'Shiroil', 'Katakhali', 'Naohata'],
    'Sylhet': ['Bagbari', 'Zindabazar', 'Kumarpara', 'Amborkhana'],
    'Barishal': ['Charbaria', 'Jhalakathi', 'Mehendiganj', 'Gournadi'],
    'Rangpur': ['Pirgacha', 'Badarganj', 'Kaunia', 'Mithapukur'],
    'Mymensingh': ['Phulpur', 'Haluaghat', 'Nandail', 'Ishwarganj'],
  };

  final Map<String, List<String>> divisionToZipCodes = {
    'Dhaka': ['1207', '1216', '1229', '1230', '1231'],
    'Chattogram': ['4000', '4100', '4200', '4300', '4400'],
    'Khulna': ['9100', '9200', '9300', '9400'],
    'Rajshahi': ['6000', '6100', '6200', '6300'],
    'Sylhet': ['3100', '3200', '3300', '3400'],
    'Barishal': ['8200', '8300', '8400', '8500'],
    'Rangpur': ['5400', '5500', '5600', '5700'],
    'Mymensingh': ['2200', '2300', '2400', '2500'],
  };

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

    // Load stored contact when the page initializes
    _loadContactNumber();

    _contactController.addListener(() {
      String currentText = _contactController.text;
      String filteredText = currentText.replaceAll(
          RegExp(r'[^0-9]'), ''); // Remove non-numeric characters

      if (filteredText.length > 11) {
        filteredText = filteredText.substring(0, 11); // Limit to 11 digits
      }

      if (filteredText != currentText) {
        _contactController.value = TextEditingValue(
          text: filteredText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: filteredText.length), // Move cursor to the end
          ),
        );
      }
    });

    _houseNoController.addListener(() {
      String currentText = _houseNoController.text;

      // Limit to 4 characters (numbers and/or letters)
      if (currentText.length > 4) {
        _houseNoController.value = TextEditingValue(
          text: currentText.substring(0, 4),
          selection: TextSelection.fromPosition(
            TextPosition(offset: 4),
          ),
        );
      }
    });

    _roadController.addListener(() {
      String currentText = _roadController.text;

      // Allow only alphanumeric characters and limit to 3 characters
      String filteredText = currentText.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''); // Remove non-alphanumeric characters

      if (filteredText.length > 3) {
        filteredText = filteredText.substring(0, 3); // Limit to 3 characters
      }

      if (filteredText != currentText) {
        _roadController.value = TextEditingValue(
          text: filteredText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: filteredText.length),
          ),
        );
      }
    });


    _sectionController.addListener(() {
      String currentText = _sectionController.text;

      if (currentText.length > 2) {
        _sectionController.value = TextEditingValue(
          text: currentText.substring(0, 2),
          selection: TextSelection.fromPosition(
            TextPosition(offset: 2),
          ),
        );
      }
    });

    _blockController.addListener(() {
      if (_blockController.text.length > 2) {
        _blockController.text = _blockController.text.substring(0, 2);
        _blockController.selection = TextSelection.fromPosition(
          TextPosition(offset: _blockController.text.length),
        );
      }
    });
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
    _thanaController.dispose();
    _divisionController.dispose();

    super.dispose();
  }

  // Function to fetch owner information from Firebase Realtime Database
  void _loadContactNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');

    if (storedContact != null) {
      setState(() {
        _contactController.text = storedContact; // Populate contact field
      });

      // Call the method without 'await' as it returns void
      _fetchOwnerInformation(storedContact);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No contact number found. Please enter a contact number.'),
        ),
      );
    }
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

      DatabaseReference ref = FirebaseDatabase.instance.ref().child(
          'owner_information');
      Query query = ref.orderByChild('contact').equalTo(contact);
      DatabaseEvent event = await query.once();

      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> ownerData = snapshot.value as Map<dynamic,
            dynamic>;
        setState(() {
          _nameController.text = ownerData.values
              .first['name']; // Populate the name field with the first match
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
        builder: (context) =>
            LoadingScreen(), // Use your LoadingScreen widget here
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
        'thana': _thanaController.text.trim(), // Add this
        'division': _divisionController.text.trim(), // Add this
      };

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref();

        // Query to check for existing houses with the same details for the same contact
        Query query = ref.child('Houses/$contact')
            .orderByChild('houseNo')
            .equalTo(houseData['houseNo']);

        // Listen for the data once
        DatabaseEvent event = await query.once();
        DataSnapshot snapshot = event.snapshot;

        // Check if there are any existing entries with the same house number
        if (snapshot.value != null) {
          Map<dynamic, dynamic> existingHouses = snapshot.value as Map<
              dynamic,
              dynamic>;

          // Iterate over existing houses to check for duplicates
          // Check for duplicates with the added fields: Thana and Division
          bool isDuplicate = existingHouses.values.any((value) =>
          value['road'] == houseData['road'] &&
              value['section'] == houseData['section'] &&
              value['block'] == houseData['block'] &&
              value['area'] == houseData['area'] &&
              value['zipCode'] == houseData['zipCode'] &&
              value['thana'] == houseData['thana'] && // Add Thana to the check
              value['division'] ==
                  houseData['division'] // Add Division to the check
          );


          if (isDuplicate) {
            Navigator.pop(context); // Close the loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'This house entry already exists for this contact.'),
              ),
            );
            return; // Exit the function early to prevent saving
          }
        }

        // Create a unique key for the new house entry
        String houseKey = ref
            .child('Houses/$contact')
            .push()
            .key ?? '';

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
          MaterialPageRoute(builder: (
              context) => const OwnerDashboard()), // Replace with your actual dashboard page
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
    List<TextInputFormatter>? inputFormatters,
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
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
              ),
              filled: true,
              fillColor: Colors.black54,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: suffixIcon,
            ),
            enabled: enabled,
            validator: validator,
            style: const TextStyle(color: Colors.white),
            inputFormatters: inputFormatters,
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Add House', style: TextStyle(fontSize: 22)),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                // Row for House No and Road
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _houseNoController,
                        label: 'House No',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(
                              r'^\d{1,4}$').hasMatch(value)) {
                            return 'Please enter a valid House No (max 4 digits).';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _roadController,
                        label: 'Road',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(
                              r'^\d{1,3}$').hasMatch(value)) {
                            return 'Please enter a valid Road (max 3 digits).';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // House Nickname Field
                _buildTextField(
                  controller: _nicknameController,
                  label: 'House Nickname',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a House Nickname.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    // Division Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _divisionController.text.isEmpty ? null : _divisionController.text,
                        onChanged: (String? selectedDivision) {
                          setState(() {
                            _divisionController.text = selectedDivision ?? '';
                            // Dynamically update Thana, Area, and Zip Code suggestions
                            thanaSuggestions = divisionToThanas[selectedDivision ?? ''] ?? [];
                            areaSuggestions = divisionToAreas[selectedDivision ?? ''] ?? [];
                            zipCodeSuggestions = divisionToZipCodes[selectedDivision ?? ''] ?? [];
                            // Reset other fields when division changes
                            _thanaController.clear();
                            _areaController.clear();
                            _zipCodeController.clear();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Division',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.black54,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: divisionToThanas.keys.map<DropdownMenuItem<String>>((String division) {
                          return DropdownMenuItem<String>(
                            value: division,
                            child: Text(division, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a Division.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Thana Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _thanaController.text.isEmpty ? null : _thanaController.text,
                        onChanged: thanaSuggestions.isEmpty || _divisionController.text.isEmpty
                            ? null // Disable when no suggestions or Division is not selected
                            : (String? selectedThana) {
                          setState(() {
                            _thanaController.text = selectedThana ?? '';
                            // Dynamically update Area and Zip Code suggestions
                            areaSuggestions = divisionToAreas[_divisionController.text] ?? [];
                            zipCodeSuggestions = divisionToZipCodes[_divisionController.text] ?? [];
                            _areaController.clear();
                            _zipCodeController.clear();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Thana',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.black54,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: thanaSuggestions.map<DropdownMenuItem<String>>((String thana) {
                          return DropdownMenuItem<String>(
                            value: thana,
                            child: Text(thana, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a Thana.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

// Row for Area and Zip Code (using dropdowns)
                Row(
                  children: [
                    // Area Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _areaController.text.isEmpty ? null : _areaController.text,
                        onChanged: areaSuggestions.isEmpty || _thanaController.text.isEmpty
                            ? null // Disable when no suggestions or Thana is not selected
                            : (String? selectedArea) {
                          setState(() {
                            _areaController.text = selectedArea ?? '';
                            // Update Zip Code suggestions
                            zipCodeSuggestions = divisionToZipCodes[_divisionController.text] ?? [];
                            _zipCodeController.clear();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Area',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.black54,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: areaSuggestions.map<DropdownMenuItem<String>>((String area) {
                          return DropdownMenuItem<String>(
                            value: area,
                            child: Text(area, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an Area.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Zip Code Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _zipCodeController.text.isEmpty ? null : _zipCodeController.text,
                        onChanged: zipCodeSuggestions.isEmpty || _areaController.text.isEmpty
                            ? null // Disable when no suggestions or Area is not selected
                            : (String? selectedZipCode) {
                          setState(() {
                            _zipCodeController.text = selectedZipCode ?? '';
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Zip Code',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.black54,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: zipCodeSuggestions.map<DropdownMenuItem<String>>((String zip) {
                          return DropdownMenuItem<String>(
                            value: zip,
                            child: Text(zip, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a Zip Code.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 16),

                // Note Field
                _buildTextField(
                  controller: _noteController,
                  label: 'Note',
                  validator: (value) {
                    return null; // No validation for the Note field
                  },
                ),

                const SizedBox(height: 16),

                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      AnimatedButton(
                        onPressed: _saveHouse,
                        text: "Save House Details",
                        buttonColor: Colors.blue,
                      ),
                    ],
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