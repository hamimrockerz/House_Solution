import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:house_solution/theme/theme.dart'; // Ensure this has the necessary light theme colors
import 'package:house_solution/widgets/custom_scaffold.dart';

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
    String? name = prefs.getString('name');
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    String? role = prefs.getString('role');

    if (contact != null) {
      // Set values to controllers
      _contactController.text = contact;
      _nameController.text = name ?? '';
      _emailController.text = email ?? '';
      _passwordController.text = password ?? '';
      _roleController.text = role ?? '';
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
        color: Colors.white, // Set white background
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Logic to upload picture
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.camera_alt, size: 40),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w900,
                  color: lightColorScheme.primary,
                ),
              ),
              const SizedBox(height: 40.0),
              Form(
                key: _formKey,
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Name',
                          hint: 'Enter your name',
                          icon: Icons.person,
                          maxLength: 26,
                        ),
                        const SizedBox(height: 25.0),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          icon: Icons.email,
                          maxLength: 50,
                        ),
                        const SizedBox(height: 25.0),
                        _buildTextField(
                          controller: _contactController,
                          label: 'Contact Number',
                          hint: 'Contact number',
                          icon: Icons.phone,
                          maxLength: 11,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 25.0),
                        _buildTextField(
                          controller: _altContactController,
                          label: 'Alternate Contact Number',
                          hint: 'Alternate contact number',
                          icon: Icons.phone_in_talk,
                          maxLength: 11,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 25.0),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        const SizedBox(height: 25.0),
                        _buildTextField(
                          controller: _roleController,
                          label: 'Role',
                          hint: 'Enter your role',
                          icon: Icons.assignment_ind,
                          isReadOnly: true, // Non-editable field
                        ),
                        const SizedBox(height: 25.0),
                        _buildTextField(
                          controller: _presentAddressController,
                          label: 'Present Address',
                          hint: 'Enter present address',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 25.0),
                        _buildTextField(
                          controller: _permanentAddressController,
                          label: 'Permanent Address',
                          hint: 'Enter permanent address',
                          icon: Icons.home,
                        ),
                        const SizedBox(height: 25.0),
                        _buildTextField(
                          controller: _nidController,
                          label: 'NID Number',
                          hint: 'Enter NID number',
                          icon: Icons.credit_card,
                          maxLength: 17,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 25.0),
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
                        const SizedBox(height: 25.0),
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
                        const SizedBox(height: 30.0),
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Save data logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile saved successfully.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade200, // Improved visibility
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          counterText: '', // This hides the character counter
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        readOnly: isReadOnly,
        obscureText: obscureText,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 16), // Set text style
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            hint: Text(hint),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
