import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:house_solution/theme/theme.dart';
import 'package:house_solution/widgets/custom_scaffold.dart';
import 'package:firebase_database/firebase_database.dart';

import 'login.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String? _selectedRole;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool agreePersonalData = false;

  void _saveUserData() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String contact = _contactController.text.trim();
    String password = _passwordController.text.trim();

    // Validation logic
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please Select a Role (Owner/Renter)')),
      );
      return;
    }

    try {
      String collection = _selectedRole == 'Owner' ? 'owner_information' : 'renter_information';

      await _database.child(collection).push().set({
        'name': name,
        'email': email,
        'contact': contact,
        'password': password,
        'role': _selectedRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account Created Successfully')),
      );

      // Clear the fields
      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
      _passwordController.clear();
      _selectedRole = null;

      Navigator.pop(context); // Go back to login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        hint: 'Enter your name',
                        icon: Icons.person,
                        maxLength: 26,
                        isAlphabetic: true,
                      ),
                      const SizedBox(height: 25.0),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.email,
                        maxLength: 20,
                      ),
                      const SizedBox(height: 25.0),

                      // Contact
                      _buildTextField(
                        controller: _contactController,
                        label: 'Contact',
                        hint: 'Enter your contact number',
                        icon: Icons.phone,
                        maxLength: 11,
                        isNumeric: true,
                      ),
                      const SizedBox(height: 25.0),

                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock,
                        obscureText: true,
                        maxLength: 20,
                      ),
                      const SizedBox(height: 20.0),

                      // Role Selection as a TextField-like Dropdown
                      _buildRoleDropdown(),
                      const SizedBox(height: 30.0),

                      // Agree to processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'I agree to the processing of personal data',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && agreePersonalData) {
                              _saveUserData(); // Call to save user data
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please agree to the processing of personal data')),
                              );
                            }
                          },
                          child: const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Sign Up Divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Text(
                              'Sign up with',
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold,),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30.0),

                      // Sign Up Social Media Logos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Logo(Logos.facebook_f),
                          Logo(Logos.whatsapp),
                          Logo(Logos.google),
                          Logo(Logos.apple),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 16.5, // Increase the font size here
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                                fontSize: 17.0, // Match the font size for consistency
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    int maxLength = 100, // Default maxLength for generic use
    bool isNumeric = false, // Indicates if the field should only accept numeric input
    bool isAlphabetic = false, // Indicates if the field should only accept alphabetic input
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      inputFormatters: [
        if (isNumeric) FilteringTextInputFormatter.digitsOnly, // Allow only digits
        if (isAlphabetic) FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')), // Allow only letters and spaces
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (isAlphabetic && !RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
          return 'Please enter only alphabetic characters';
        }
        if (isNumeric && !RegExp(r'^\d+$').hasMatch(value)) {
          return 'Please enter only numeric characters';
        }
        return null;
      },
      decoration: InputDecoration(
        label: Text(label),
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        counterText: '', // Hide the counter text
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0), // Add padding for consistent sizing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select Role'),
          value: _selectedRole,
          items: <String>['Owner', 'Renter']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(value == 'Owner' ? Icons.house : Icons.apartment), // Change icon based on role
                  const SizedBox(width: 10), // Spacing between icon and text
                  Text(value),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue;
            });
          },
        ),
      ),
    );
  }
}
