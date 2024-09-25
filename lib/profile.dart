import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  String _selectedRole = 'Owner'; // Default selection
  String _selectedStatus = 'Single'; // Default status selection

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _applicantIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _presentAddressController = TextEditingController();
  final TextEditingController _permanentAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveUserData() async {
    String applicantId = _applicantIdController.text.trim();
    String name = _nameController.text.trim();
    String contact = _contactController.text.trim();
    String nid = _nidController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String presentAddress = _presentAddressController.text.trim();
    String permanentAddress = _permanentAddressController.text.trim();

    // Validation logic
    if (!RegExp(r'^[a-zA-Z\s]{1,20}$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must contain only letters and be up to 20 characters')),
      );
      return;
    }

    if (!RegExp(r'^\d{11}$').hasMatch(contact)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact must be exactly 11 digits')),
      );
      return;
    }

    if (!RegExp(r'^\d{13}$').hasMatch(nid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NID must be exactly 13 digits')),
      );
      return;
    }

    if (email.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email must be up to 20 characters')),
      );
      return;
    }

    if (password.length > 32) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be up to 32 characters')),
      );
      return;
    }

    if (presentAddress.length > 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Present Address must be up to 40 characters')),
      );
      return;
    }

    if (permanentAddress.length > 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permanent Address must be up to 40 characters')),
      );
      return;
    }

    try {
      String collection = _selectedRole == 'Owner' ? 'owner_information' : 'renter_information';

      await _database.child(collection).push().set({
        'applicantId': applicantId,
        'name': name,
        'contact': contact,
        'nid': nid,
        'email': email,
        'password': password,
        'presentAddress': presentAddress,
        'permanentAddress': permanentAddress,
        'status': _selectedStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account Created Successfully')),
      );

      // Clear the fields
      _applicantIdController.clear();
      _nameController.clear();
      _contactController.clear();
      _nidController.clear();
      _emailController.clear();
      _passwordController.clear();
      _presentAddressController.clear();
      _permanentAddressController.clear();

      Navigator.pop(context); // Go back to login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.teal[700],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Create a New Account',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.teal[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Select Role',
                          filled: true,
                          fillColor: Colors.teal[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: ['Owner', 'Renter'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _applicantIdController,
                        label: 'Applicant ID',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        maxLength: 20,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _contactController,
                        label: 'Contact',
                        maxLength: 11,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _nidController,
                        label: 'NID',
                        maxLength: 13,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        maxLength: 20,
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordTextField(),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _presentAddressController,
                        label: 'Present Address',
                        maxLength: 40,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _permanentAddressController,
                        label: 'Permanent Address',
                        maxLength: 40,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Select Status',
                          filled: true,
                          fillColor: Colors.teal[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: ['Single', 'Married', 'Divorced'].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveUserData,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          backgroundColor: Colors.teal[700],
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Register'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate to login page
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.teal[700],
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Already have an account? Login here'),
                      ),
                    ],
                  ),
                ),
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
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.teal[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      maxLength: maxLength,
      keyboardType: keyboardType,
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      maxLength: 32,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.teal[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}
