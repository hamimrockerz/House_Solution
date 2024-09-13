import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedStatus = 'Active';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // Add picture upload logic here
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Personal Details
            Expanded(
              child: ListView(
                children: [
                  _buildTextField('ID', 'Enter ID'),
                  _buildTextField('Name', 'Enter Name'),
                  _buildTextField('Contact', 'Enter Contact'),
                  _buildTextField('NID', 'Enter NID'),
                  _buildTextField('Email', 'Enter Email'),
                  _buildTextField('Password', 'Enter Password'),
                  _buildTextField('Present Address', 'Enter Present Address'),
                  _buildTextField('Permanent Address', 'Enter Permanent Address'),
                  const SizedBox(height: 20),
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: <String>['Active', 'Inactive'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Update Button
                  ElevatedButton(
                    onPressed: () {
                      // Add update logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
