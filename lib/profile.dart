import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:house_solution/theme/theme.dart'; // Ensure this has the necessary light theme colors
import 'package:house_solution/widgets/custom_scaffold.dart';
import 'package:image_picker/image_picker.dart'; // For selecting images
import 'dart:io'; // For handling image files
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'animate_button_add_house.dart'; // Your custom button widget
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _presentAddressController = TextEditingController();
  final TextEditingController _permanentAddressController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _altContactController = TextEditingController();

  // Variables for gender and marital status selection
  String? _selectedGender;
  String? _maritalStatus;

  bool isLoading = true;
  File? _imageFile; // Holds selected image

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load profile data on init
  }

  // Method to load profile data from SharedPreferences and Firebase
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contact = prefs.getString('contact');

    if (contact != null) {
      DatabaseEvent ownerEvent = await _database
          .child('owner_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      if (ownerEvent.snapshot.exists) {
        Map<dynamic, dynamic>? owners = ownerEvent.snapshot.value as Map<dynamic, dynamic>?;

        if (owners != null) {
          final ownerData = owners.values.first;

          // Set the fetched values to the respective controllers
          _contactController.text = contact;
          _nameController.text = ownerData['name'] ?? '';
          _emailController.text = ownerData['email'] ?? '';
          _passwordController.text = ownerData['password'] ?? '';
          _roleController.text = ownerData['role'] ?? '';
          _presentAddressController.text = ownerData['presentAddress'] ?? '';
          _permanentAddressController.text = ownerData['permanentAddress'] ?? '';
          _nidController.text = ownerData['nid'] ?? '';
          _altContactController.text = ownerData['altContact'] ?? '';
          _selectedGender = ownerData['gender'];
          _maritalStatus = ownerData['maritalStatus'];

          // Load the profile image if it exists
          if (ownerData['profileImage'] != null) {
            _imageFile = await _loadImage(ownerData['profileImage']);
            setState(() {});
          }
        }
      } else {
        // If owner information doesn't exist, check renter information
        DatabaseEvent renterEvent = await _database
            .child('renter_information')
            .orderByChild('contact')
            .equalTo(contact)
            .once();

        if (renterEvent.snapshot.exists) {
          Map<dynamic, dynamic>? renters = renterEvent.snapshot.value as Map<dynamic, dynamic>?;

          if (renters != null) {
            final renterData = renters.values.first;

            // Set the fetched values to the respective controllers
            _contactController.text = contact;
            _nameController.text = renterData['name'] ?? '';
            _emailController.text = renterData['email'] ?? '';
            _passwordController.text = renterData['password'] ?? '';
            _roleController.text = renterData['role'] ?? '';
            _presentAddressController.text = renterData['presentAddress'] ?? '';
            _permanentAddressController.text = renterData['permanentAddress'] ?? '';
            _nidController.text = renterData['nid'] ?? '';
            _altContactController.text = renterData['altContact'] ?? '';
            _selectedGender = renterData['gender'];
            _maritalStatus = renterData['maritalStatus'];

            // Load the profile image if it exists
            if (renterData['profileImage'] != null) {
              _imageFile = await _loadImage(renterData['profileImage']);
              setState(() {});
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No information found for this contact.')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stored contact number found.')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }



  // Method to load image from URL
// Method to load image from URL
  Future<File?> _loadImage(String imageUrl) async {
    try {
      // Get the image from the URL
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Create a temporary file
        final Directory tempDir = await getTemporaryDirectory();
        final File tempFile = File('${tempDir.path}/profile_image.jpg');

        // Write the image bytes to the file
        await tempFile.writeAsBytes(response.bodyBytes);
        return tempFile;
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }


  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery); // You can use ImageSource.camera for the camera

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // Method to upload image to Firebase Storage and get the URL
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(image);

      // Listen to the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Uploading... ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  // Method to save the profile data to Firebase
  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contact = prefs.getString('contact');

    if (contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stored contact number found.')),
      );
      return;
    }

    String? imageUrl;

    // Upload the selected image if available
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    // Check for owner information first
    DatabaseEvent ownerEvent = await _database
        .child('owner_information')
        .orderByChild('contact')
        .equalTo(contact)
        .once();

    if (ownerEvent.snapshot.exists) {
      String ownerId = ownerEvent.snapshot.children.first.key!;
      await _database.child('owner_information').child(ownerId).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _roleController.text,
        'presentAddress': _presentAddressController.text,
        'permanentAddress': _permanentAddressController.text,
        'nid': _nidController.text,
        'altContact': _altContactController.text,
        'gender': _selectedGender,
        'maritalStatus': _maritalStatus,
        if (imageUrl != null) 'profileImage': imageUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner profile updated successfully!')),
      );
    } else {
      // Check renter information if owner doesn't exist
      DatabaseEvent renterEvent = await _database
          .child('renter_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      if (renterEvent.snapshot.exists) {
        String renterId = renterEvent.snapshot.children.first.key!;
        await _database.child('renter_information').child(renterId).update({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _roleController.text,
          'presentAddress': _presentAddressController.text,
          'permanentAddress': _permanentAddressController.text,
          'nid': _nidController.text,
          'altContact': _altContactController.text,
          'gender': _selectedGender,
          'maritalStatus': _maritalStatus,
          if (imageUrl != null) 'profileImage': imageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Renter profile updated successfully!')),
        );
      } else {
        // Create a new owner entry if neither owner nor renter info exists
        String newOwnerId = _database.child('owner_information').push().key!;
        await _database.child('owner_information').child(newOwnerId).set({
          'contact': contact,
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _roleController.text,
          'presentAddress': _presentAddressController.text,
          'permanentAddress': _permanentAddressController.text,
          'nid': _nidController.text,
          'altContact': _altContactController.text,
          'gender': _selectedGender,
          'maritalStatus': _maritalStatus,
          if (imageUrl != null) 'profileImage': imageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile created as owner!')),
        );
      }
    }
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
                    child: GestureDetector(
                      onTap: _pickImage, // Call the method on tap
                      child: CircleAvatar(
                        radius: 50, // Adjust the size as needed
                        backgroundColor: Colors.grey[300],
                        child: _imageFile == null
                            ? _loadProfileImage() // Load from Firebase if null
                            : ClipOval(
                          child: Image.file(
                            _imageFile!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
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
                    buttonColor: Colors.blue, // Button color
                    onPressed: () {
                      // Validate form before saving
                      if (_formKey.currentState!.validate()) {
                        _saveProfileData(); // Call save method
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

// Method to load the profile image from Firebase if _imageFile is null
  Widget _loadProfileImage() {
    return FutureBuilder<File?>(
      future: _loadImageFromFirebase(), // Load the image from Firebase
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading indicator while fetching
        } else if (snapshot.hasError) {
          return const Icon(Icons.error, size: 50, color: Colors.red);
        } else if (snapshot.hasData && snapshot.data != null) {
          return ClipOval(
            child: Image.file(
              snapshot.data!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return const Icon(
            Icons.photo_camera, // Icon to represent the photo
            size: 50,
            color: Colors.blue, // Icon color
          );
        }
      },
    );
  }

// Method to fetch the profile image from Firebase Storage
  Future<File?> _loadImageFromFirebase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contact = prefs.getString('contact');

    if (contact != null) {
      // Fetch owner information from Firebase
      DatabaseEvent ownerEvent = await _database
          .child('owner_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      // Check if owner exists
      if (ownerEvent.snapshot.exists) {
        Map<dynamic, dynamic>? owners = ownerEvent.snapshot.value as Map<dynamic, dynamic>?;

        if (owners != null) {
          final ownerData = owners.values.first;

          // Load the profile image if it exists for owner
          if (ownerData['profileImage'] != null) {
            String imageUrl = ownerData['profileImage'];
            return await _loadImage(imageUrl);
          }
        }
      } else {
        // If owner doesn't exist, check for renter information
        DatabaseEvent renterEvent = await _database
            .child('renter_information')
            .orderByChild('contact')
            .equalTo(contact)
            .once();

        // Check if renter exists
        if (renterEvent.snapshot.exists) {
          Map<dynamic, dynamic>? renters = renterEvent.snapshot.value as Map<dynamic, dynamic>?;

          if (renters != null) {
            final renterData = renters.values.first;

            // Load the profile image if it exists for renter
            if (renterData['profileImage'] != null) {
              String imageUrl = renterData['profileImage'];
              return await _loadImage(imageUrl);
            }
          }
        }
      }
    }

    return null; // Return null if no profile image found for either owner or renter
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
