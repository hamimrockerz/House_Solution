import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'animate_button_add_house.dart';
import 'owner_dashboard.dart'; // Ensure you have the correct import for OwnerDashboard
import 'loadingscreen.dart'; // Import your LoadingScreen widget
import 'package:shared_preferences/shared_preferences.dart';

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

  final TextEditingController _presentAddressController =
  TextEditingController();
  final TextEditingController _permanentAddressController =
  TextEditingController();
  bool _isSearchTriggered = false;



  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadContactNumber(); // Load contact number when the page initializes


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
      _fetchUserInformation(storedContact); // Fetch user info if contact is available
    } else {
      // Display a message if no contact is found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No contact number found. Please enter a contact number.'),
        ),
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
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('renter_information');
      Query query = ref.orderByChild('contact').equalTo(contact);
      DatabaseEvent event = await query.once();

      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) { // Check if snapshot has data
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

        // Assuming there could be multiple users with the same contact number
        // Get the first user if there are multiple matches
        var firstUser = userData.values.first;

        // Debugging logs
        print("Fetched User Data: $firstUser");

        setState(() {
          _nameController.text = firstUser['name'] ?? ''; // Populate the name field
          _statusController.text = firstUser['status'] ?? ''; // Populate the status field
          _emailController.text = firstUser['email'] ?? ''; // Populate the email field
          _presentAddressController.text = firstUser['presentAddress'] ?? ''; // Populate the present address field
          _permanentAddressController.text = firstUser['permanentAddress'] ?? ''; // Populate the permanent address field
          _nidController.text = firstUser['nid'] ?? ''; // Populate the NID field
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

      String contact = _contactController.text.trim();

      // Prepare the user data to be saved
      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'status': _statusController.text.trim(),
        'email': _emailController.text.trim(),
        'presentAddress': _presentAddressController.text.trim(),
        'permanentAddress': _permanentAddressController.text.trim(),

      };

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref();

        // Query to check for existing users with the same details for the same contact
        Query query = ref.child('Users/$contact').orderByChild('email').equalTo(userData['email']);

        // Listen for the data once
        DatabaseEvent event = await query.once();
        DataSnapshot snapshot = event.snapshot;

        // Check if there are any existing entries with the same email
        if (snapshot.value != null) {
          Map<dynamic, dynamic> existingUsers = snapshot.value as Map<dynamic, dynamic>;

          // Iterate over existing users to check for duplicates
          bool isDuplicate = existingUsers.values.any((value) =>
          value['contact'] == contact
          );

          if (isDuplicate) {
            Navigator.pop(context); // Close the loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This user entry already exists for this contact.'),
              ),
            );
            return; // Exit the function early to prevent saving
          }
        }

        // Create a unique key for the new user entry
        String userKey = ref.child('Users/$contact').push().key ?? '';

        // Save the user data under the unique key
        await ref.child('Users/$contact/$userKey').set(userData);

        // Close the loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User details saved successfully!'),
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
            content: Text('Failed to save user details.'),
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
              fillColor: Colors.black54,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: suffixIcon,
            ),
            enabled: enabled,
            validator: validator,
            style: const TextStyle(color: Colors.white), // Text color
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
        title: const Text('Add User', style: TextStyle(fontSize: 22)), // Center title
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
    if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
    return 'Please enter a valid Contact (11 digits).';
    }
    return null;
    },
    ),
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
    _buildTextField(
    controller: _nidController,
    label: 'NID',
    enabled: false, // Make NID field non-editable
    validator: (value) {
    if (value == null || value.isEmpty || !RegExp(r'^[0-9]{10,17}$').hasMatch(value)) {
    return 'Please enter a valid NID Number.';
    }
    return null;
    },
    ),
    _buildTextField(
    controller: _emailController,
    label: 'Email',
    enabled: false, // Make Email field non-editable
    validator: (value) {
    if (value == null || value.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Please enter a valid email address.';
    }
    return null;
    },
    ),
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
    // Row for Selected House and Selected Flat dropdowns


      Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Center(
    child: ElevatedButton(
    onPressed: _saveUser,
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent, // Background color
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    child: const Text('Save User', style: TextStyle(fontSize: 18)),
    ),
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