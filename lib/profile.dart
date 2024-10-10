import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:house_solution/theme/theme.dart'; // Ensure this has the necessary light theme colors
import 'package:house_solution/widgets/custom_scaffold.dart';
import 'animate_button_add_house.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _presentAddressController = TextEditingController();
  final TextEditingController _permanentAddressController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _altContactController = TextEditingController();

  String? _selectedGender; // No default selection
  String? _maritalStatus; // No default selection

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load stored data
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contact = prefs.getString('contact');

    if (contact != null) {
      // Fetch owner information from Firebase
      DatabaseEvent ownerEvent = await _database
          .child('owner_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      if (ownerEvent.snapshot.exists) {
        Map<dynamic, dynamic>? owners = ownerEvent.snapshot.value as Map<dynamic, dynamic>?;

        if (owners != null) {
          final ownerData = owners.values.first;

          // Set values to controllers
          _contactController.text = contact;
          _nameController.text = ownerData['name'] ?? '';
          _emailController.text = ownerData['email'] ?? '';
          _passwordController.text = ownerData['password'] ?? '';
          _roleController.text = ownerData['role'] ?? '';
          _presentAddressController.text = ownerData['presentAddress'] ?? '';
          _permanentAddressController.text = ownerData['permanentAddress'] ?? '';
          _nidController.text = ownerData['nid'] ?? '';
          _altContactController.text = ownerData['altContact'] ?? '';
          _selectedGender = ownerData['gender']; // Fetch selected gender
          _maritalStatus = ownerData['maritalStatus']; // Fetch marital status
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No owner information found for this contact.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stored contact number found.')),
      );
    }

    setState(() {
      isLoading = false; // Update loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Only horizontal padding
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView( // Allow scrolling
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFF4F7FB),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF85BFD7).withOpacity(0.9),
                  blurRadius: 30,
                  offset: const Offset(0, 30),
                  spreadRadius: -20,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Photo Icon at the Top Center
                  Center(
                    child: CircleAvatar(
                      radius: 50, // Adjust the size as needed
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.photo_camera, // Icon to represent the photo
                        size: 50,
                        color: Colors.blue, // Icon color
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Update your profile information.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _nameController, label: 'Name', hint: 'Enter your name', icon: Icons.person, maxLength: 26),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _emailController, label: 'Email', hint: 'Enter your email', icon: Icons.email, maxLength: 50),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _contactController, label: 'Contact Number', hint: 'Contact number', icon: Icons.phone, maxLength: 11, isNumeric: true),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _altContactController, label: 'Alternate Contact Number', hint: 'Alternate contact number', icon: Icons.phone_in_talk, maxLength: 11, isNumeric: true),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _passwordController, label: 'Password', hint: 'Enter your password', icon: Icons.lock, obscureText: true),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _roleController, label: 'Role', hint: 'Enter your role', icon: Icons.assignment_ind, isReadOnly: true), // Non-editable field
                  const SizedBox(height: 10),
                  _buildTextField(controller: _presentAddressController, label: 'Present Address', hint: 'Enter present address', icon: Icons.location_on),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _permanentAddressController, label: 'Permanent Address', hint: 'Enter permanent address', icon: Icons.home),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _nidController, label: 'NID Number', hint: 'Enter NID number', icon: Icons.credit_card, maxLength: 17, isNumeric: true),
                  const SizedBox(height: 20),
                  // Gender Dropdown
                  _buildDropdown(
                    label: 'Gender',
                    icon: Icons.wc,
                    value: _selectedGender, // Defaults to null
                    items: ['Male', 'Female', 'Other'],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value; // Updates state
                      });
                    },
                    hint: 'Select Gender',
                  ),
                  const SizedBox(height: 20),
                  // Marital Status Dropdown
                  _buildDropdown(
                    label: 'Marital Status',
                    icon: Icons.family_restroom,
                    value: _maritalStatus, // Defaults to null
                    items: ['Single', 'Married'],
                    onChanged: (value) {
                      setState(() {
                        _maritalStatus = value; // Updates state
                      });
                    },
                    hint: 'Select Status',
                  ),
                  const SizedBox(height: 30),
                  // Animated Button
                  AnimatedButton(
                    text: 'Update Information', // Required text argument
                    buttonColor: Colors.blue, // Required buttonColor argument
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Save data logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile saved successfully.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int? maxLength,
    bool isNumeric = false,
    bool isReadOnly = false,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      readOnly: isReadOnly,
      obscureText: obscureText,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: '', // This hides the length counter
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }


  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text(hint),
    );
  }
}
