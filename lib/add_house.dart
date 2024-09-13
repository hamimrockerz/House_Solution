import 'package:flutter/material.dart';
import 'animate_button_add_house.dart'; // Ensure this path is correct

class AddHousePage extends StatefulWidget {
  const AddHousePage({super.key});

  @override
  _AddHousePageState createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ownerIdController = TextEditingController();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _houseIdController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

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
    _ownerIdController.dispose();
    _houseNameController.dispose();
    _houseIdController.dispose();
    _houseNoController.dispose();
    _roadController.dispose();
    _sectionController.dispose();
    _blockController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _saveHouse() async {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          child: SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      await Future.delayed(Duration(seconds: 3));

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('House details saved successfully!'),
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    required String? Function(String?) validator,
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
            maxLength: maxLength,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Background color shade
      appBar: AppBar(
        title: const Text('Add House'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _ownerIdController,
                  label: 'Owner ID',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{1,6}$').hasMatch(value)) {
                      return 'Please enter a valid Owner ID (up to 6 digits).';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _houseNameController,
                  label: 'House Name',
                  maxLength: 12,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z\s]{1,12}$').hasMatch(value)) {
                      return 'Please enter a valid House Name (up to 12 characters, letters only).';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _houseIdController,
                  label: 'House ID',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{1,6}$').hasMatch(value)) {
                      return 'Please enter a valid House ID (up to 6 digits).';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _houseNoController,
                  label: 'House No.',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{1,4}$').hasMatch(value)) {
                      return 'Please enter a valid House No. (up to 4 digits).';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _roadController,
                  label: 'Road',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{1,4}$').hasMatch(value)) {
                      return 'Please enter a valid Road (up to 4 digits).';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _sectionController,
                  label: 'Section',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{1,4}$').hasMatch(value)) {
                      return 'Please enter a valid Section (up to 4 digits).';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _blockController,
                  label: 'Block',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{1,4}$').hasMatch(value)) {
                      return 'Please enter a valid Block (up to 4 digits).';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact Information',
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Please enter a valid Contact Information (11 digits).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: AnimatedButton(
                    onPressed: _saveHouse,
                    text: 'Click Here To Save...',
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
