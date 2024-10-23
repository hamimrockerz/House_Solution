import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'animate_button_add_house.dart';
import 'owner_dashboard.dart'; // Ensure you have the correct import for OwnerDashboard
import 'loadingscreen.dart'; // Import your LoadingScreen widget
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _presentAddressController = TextEditingController();
  final TextEditingController _permanentAddressController = TextEditingController();

  bool _isSearchTriggered = false;
  String? _selectedHouse;
  List<String> _houseNumbers = [];

  String? _selectedFlat; // To hold the selected flat
  List<String> _flatNumbers = []; // List to hold fetched flat numbers

  List<String> _filteredFlatNumbers = []; // Flats that match the selected house


  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadContactNumber(); // Load contact number when the page initializes
    _initializeFlatData(); // Fetch flats directly in initState

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
    _statusController.dispose();
    _emailController.dispose();
    _presentAddressController.dispose();
    _permanentAddressController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  void _loadContactNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');

    if (storedContact != null) {
      // Fetch houses using the locally stored contact
      await _fetchHouses(storedContact);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No contact number found. Please enter a contact number.'),
        ),
      );
    }
  }

  void _initializeFlatData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');

    if (storedContact != null) {
      await _fetchFlats(storedContact); // Call fetch function directly
      // After fetching flats, ensure _selectedFlat remains null to show hint
      setState(() {
        _selectedFlat = null; // Ensures the dropdown shows hint text initially
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No contact number found. Please enter a contact number.'),
        ),
      );
    }
  }

  void _filterFlatsBasedOnHouse(String? selectedHouse) {
    if (selectedHouse != null) {
      // Split the selected house parts into relevant components
      List<String> selectedHouseParts = selectedHouse.split(', ');
      if (selectedHouseParts.length >= 4) {
        // Create the prefix to match
        String housePrefix = selectedHouseParts.sublist(0, 4).join(', '); // Get House, Road, Block, and Section

        // Filter the flat numbers based on the selected house prefix
        _filteredFlatNumbers = _flatNumbers.where((flat) {
          // Check if the flat starts with the house prefix
          return flat.startsWith(housePrefix);
        }).toList();

        // If matches are found, set the selected flat to the first match
        _selectedFlat = _filteredFlatNumbers.isNotEmpty ? null : null; // Ensure selected flat is null until user selects
      } else {
        _filteredFlatNumbers.clear();
        _selectedFlat = null; // Keep selected flat as null
      }
    } else {
      _filteredFlatNumbers.clear();
      _selectedFlat = null; // Keep selected flat as null
    }

    // Update the state to refresh the UI
    setState(() {});
  }


  Future<void> _fetchHouses(String contact) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('Flats/$contact');
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> flatsData = snapshot.value as Map<dynamic, dynamic>;
        Set<String> fetchedHouseNumbers = {};

        flatsData.forEach((key, value) {
          List<String> parts = key.split('_');
          if (parts.length >= 4) {
            // Replace % with /
            String road = parts[2].replaceAll('%', '/'); // Replace % in Road
            String house = parts[1].replaceAll('%', '/'); // Replace % in House
            String block = parts[3].replaceAll('%', '/'); // Replace % in Block
            String section = parts[4].replaceAll('%', '/'); // Replace % in Section

            // Corrected the order here: Road, House, Block, Section
            String formattedHouse = "House:$road, Road:$house, Block:$block, Section:$section";
            fetchedHouseNumbers.add(formattedHouse);
          }
        });

        setState(() {
          _houseNumbers = fetchedHouseNumbers.toList(); // Store formatted house numbers
        });
      } else {
        setState(() {
          _houseNumbers = [];
          _selectedHouse = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No house information found for the contact.')),
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
      // Reference to the Firebase path where flat data is stored for the given contact
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('Flats/$contact');
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> flatsData = snapshot.value as Map<dynamic, dynamic>;
        List<String> fetchedFlatNumbers = [];

        // Iterate through each flat's data
        flatsData.forEach((key, value) {
          if (key.startsWith(contact)) {
            Map<dynamic, dynamic> subCollection = value as Map<dynamic, dynamic>;

            // Iterate through each flat in the sub-collection
            subCollection.forEach((subKey, subValue) {
              if (subKey.contains('_')) {
                List<String> parts = subKey.split('_');
                if (parts.length > 4) { // Ensure there are enough parts for house and flat information
                  String flatId = parts.last.replaceAll('%', '/');
                  String houseId = parts[1].replaceAll('%', '/');
                  String roadId = parts[2].replaceAll('%', '/');
                  String blockId = parts[3].replaceAll('%', '/');
                  String sectionId = parts[4].replaceAll('%', '/');

                  // Format the flat information
                  String formattedFlat = "House:$roadId, Road:$houseId, Block:$blockId, Section:$sectionId, Flat:$flatId";
                  fetchedFlatNumbers.add(formattedFlat); // Add the formatted flat to the list
                }
              }
            });
          }
        });

        setState(() {
          _flatNumbers = fetchedFlatNumbers; // Store all fetched flat numbers
          _filteredFlatNumbers = List.from(_flatNumbers); // Initialize filtered flats
          _selectedFlat = _filteredFlatNumbers.isNotEmpty ? _filteredFlatNumbers[0] : null; // Set default selection
        });
      } else {
        setState(() {
          _flatNumbers = [];
          _filteredFlatNumbers = [];
          _selectedFlat = null; // Reset selected flat
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No flat information found for the contact.')),
        );
      }
    } catch (e) {
      print("Error fetching flats: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch flat information.')),
      );
    }
  }



  // Function to fetch user information from Firebase Realtime Database
  void _fetchUserInformation(String contact) async {
    try {
      // Check if the contact number is empty
      if (contact.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a contact number.'),
          ),
        );
        return;
      }

      // Fetch user information from Firebase
      DatabaseReference ref = FirebaseDatabase.instance.ref().child(
          'renter_information');
      Query query = ref.orderByChild('contact').equalTo(contact);
      DatabaseEvent event = await query.once();

      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) { // Check if snapshot has data
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic,
            dynamic>;

        // Assuming there could be multiple users with the same contact number
        // Get the first user if there are multiple matches
        var firstUser = userData.values.first;

        // Debugging logs
        print("Fetched User Data: $firstUser");

        setState(() {
          _nameController.text =
              firstUser['name'] ?? ''; // Populate the name field
          _statusController.text =
              firstUser['maritalStatus'] ?? ''; // Populate the status field
          _emailController.text =
              firstUser['email'] ?? ''; // Populate the email field
          _presentAddressController.text = firstUser['presentAddress'] ??
              ''; // Populate the present address field
          _permanentAddressController.text = firstUser['permanentAddress'] ??
              ''; // Populate the permanent address field
          _nidController.text =
              firstUser['nid'] ?? ''; // Populate the NID field
        });
      } else {
        // Show this message only if the user has actively searched
        if (_isSearchTriggered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user found with this contact number.'),
            ),
          );
        }
      }
    } catch (e) {
      print("Error fetching user information: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch user information.'),
        ),
      );
    }
  }

// Call this method when the search button is pressed
  void _onSearchPressed() {
    // Mark that the search has been triggered
    _isSearchTriggered = true;

    // Call the fetch user information method
    _fetchUserInformation(_contactController.text.trim());
  }


  // Function to save user data
  void _saveUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen(), // Use your LoadingScreen widget here
      );

      String contact = _contactController.text.trim(); // This is the contact to be used as the document ID

      // Fetch the locally stored contact from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedContact = prefs.getString('contact'); // This is the locally stored contact

      if (storedContact == null) {
        Navigator.pop(context); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No stored contact found. Please check the contact information.'),
          ),
        );
        return; // Exit early if no stored contact is found
      }

      DateTime now = DateTime.now();
      String rentedMonth = '${DateFormat('MMMM').format(now)}-${now.year}'; // Declare rentedMonth and assign it a formatted value

      // Prepare the user data to be saved
      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'status': _statusController.text.trim(),
        'email': _emailController.text.trim(),
        'presentAddress': _presentAddressController.text.trim(),
        'permanentAddress': _permanentAddressController.text.trim(),
        'nid': _nidController.text.trim(), // Add NID field
        'selectedHouse': _selectedHouse ?? '', // Keep as is, will format later
        'selectedFlat': _selectedFlat ?? '',   // Keep as is, will format later
        'contact': contact,                // Save the contact number
        'flatstatus': 'Occupied',          // Save flatstatus as 'Occupied'
        'rentedMonth': rentedMonth,        // Use rentedMonth variable
      };

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref();

        // Check if the user already exists under this contact number
        DataSnapshot snapshot = await ref.child('Users/$storedContact/$contact').get();

        if (snapshot.exists) {
          // User already exists, show an error message
          Navigator.pop(context); // Close the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This user entry already exists for this contact.'),
            ),
          );
          return; // Exit the function early to prevent saving
        }

        // Save the user data under the unique contact as ID in the subcollection
        await ref.child('Users/$storedContact/$contact').set(userData);

        // Extract and format selectedHouse and selectedFlat (code remains unchanged)
        String selectedHouseValue = _selectedHouse?.trim() ?? '';
        String selectedFlatValue = _selectedFlat?.trim() ?? '';

        // Format selectedHouse
        String selectedHouseFormatted = selectedHouseValue
            .replaceAll(RegExp(r'Road:|House:|Block:|Section:'), '')
            .replaceAll(',', '')
            .replaceAll(' ', '_')
            .replaceAll('___', '_')
            .replaceAll('__', '_')
            .trim();

        List<String> houseComponents = selectedHouseFormatted.split('_');

        selectedHouseFormatted = "${storedContact}_${houseComponents[1]}_${houseComponents[0]}_${houseComponents[2]}_${houseComponents[3]}";

        // Format selectedFlat similarly
        String selectedFlatFormatted = selectedFlatValue
            .replaceAll(RegExp(r'Road:|House:|Block:|Section:|Flat:'), '')
            .replaceAll(',', '')
            .replaceAll(' ', '_')
            .replaceAll('___', '_')
            .replaceAll('__', '_')
            .trim();

        List<String> flatComponents = selectedFlatFormatted.split('_');

        selectedFlatFormatted = "${storedContact}_${flatComponents[1]}_${flatComponents[0]}_${flatComponents[2]}_${flatComponents[3]}_${flatComponents[4]}";

        // Update the flat status and vacantMonth at the specified path
        await ref
            .child('Flats/$storedContact/$selectedHouseFormatted/$selectedFlatFormatted')
            .update({
          'flatstatus': 'Occupied',
          'vacantMonth': '', // Set vacantMonth to null when occupied
        });

        // Close the loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User details are updated successfully!'),
          ),
        );

        // Navigate back to OwnerDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OwnerDashboard()), // Replace with your actual dashboard page
        );
      } catch (e) {
        Navigator.pop(context); // Close the loading dialog on error
        print("Error saving user information: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save user details and update flat status.'),
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
              labelStyle: const TextStyle(color: Colors.white),
              // Label color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent,
                    width: 2.0), // Border color and width
              ),
              filled: true,
              fillColor: Colors.black54,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              suffixIcon: suffixIcon,
            ),
            enabled: enabled,
            validator: validator,
            style: const TextStyle(color: Colors.white),
            // Text color
            onFieldSubmitted: (value) {
              if (label == "Contact") {
                _fetchUserInformation(value);
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
        title: const Text(
          'Add User',
          style: TextStyle(fontSize: 22),
        ), // Center title
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
                      _fetchUserInformation(_contactController.text.trim());
                    },
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Please enter a valid Contact (11 digits).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Added spacing
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _statusController,
                        label: 'Status',
                        enabled: false, // Make Status field non-editable
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Status cannot be empty.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Added spacing
                _buildTextField(
                  controller: _nidController,
                  label: 'NID',
                  enabled: false, // Make NID field non-editable
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[0-9]{10,17}$').hasMatch(value)) {
                      return 'Please enter a valid NID Number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Added spacing
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  enabled: false, // Make Email field non-editable
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Added spacing
                _buildTextField(
                  controller: _presentAddressController,
                  label: 'Present Address',
                  enabled: false, // Make Present Address field non-editable
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Present Address cannot be empty.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Added spacing
                _buildTextField(
                  controller: _permanentAddressController,
                  label: 'Permanent Address',
                  enabled: false, // Make Permanent Address field non-editable
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Permanent Address cannot be empty.';
                    }
                    return null;
                  },
                ),


                // House Dropdown
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonFormField<String>(
                          value: _selectedHouse, // Selected house, initially null
                          items: _houseNumbers.map((displayValue) {
                            return DropdownMenuItem<String>(
                              value: displayValue,
                              child: Text(
                                displayValue,
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedHouse = value; // Update the selected house
                              _filterFlatsBasedOnHouse(value); // Filter flats based on selected house
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select House',
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
                            filled: true,
                            fillColor: Colors.blueGrey,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5),
                            ),
                          ),
                          hint: const Text(
                            "Select a house, road, block, and section", // Hint text when no selection is made
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          dropdownColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          isExpanded: true, // Ensures the dropdown takes the full width
                        ),
                      ),
                    ),
                  ],
                ),



                const SizedBox(height: 20), // Adjust the height as needed
// Flat Dropdown
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonFormField<String>(
                          value: _selectedFlat, // Current selected flat value
                          items: _filteredFlatNumbers.map((displayValue) {
                            return DropdownMenuItem<String>(
                              value: displayValue,
                              child: Text(
                                displayValue,
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFlat = value; // Update the selected flat when changed
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Flat',
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
                            filled: true,
                            fillColor: Colors.blueGrey,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5),
                            ),
                          ),
                          hint: const Text(
                            "Select a flat", // This will show when _selectedFlat is null
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          dropdownColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          isExpanded: true, // Ensures the dropdown takes the full width
                        ),
                      ),
                    ),
                  ],
                ),




                const SizedBox(height: 20), // Added spacing before button
                Center(
                    child: AnimatedButton(
                    onPressed: _saveUser,
                    text: "Save User Details",
                    buttonColor: Colors.blue,
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