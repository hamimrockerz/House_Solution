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

class RenterProfilePage extends StatefulWidget {
  const RenterProfilePage({super.key});

  @override
  State<RenterProfilePage> createState() => _RenterProfilePageState();
}

class _RenterProfilePageState extends State<RenterProfilePage> {
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
      DatabaseEvent renterEvent = await _database
          .child('renter_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      if (renterEvent.snapshot.exists) {
        Map<dynamic, dynamic>? renters = renterEvent.snapshot.value as Map<
            dynamic,
            dynamic>?;

        if (renters != null) {
          final renterData = renters.values.first;

          // Set the fetched values to the respective controllers
          _contactController.text = contact;
          _nameController.text = renterData['name'] ?? '';
          _emailController.text = renterData['email'] ?? '';
          _passwordController.text = renterData['password'] ?? '';
          _roleController.text = renterData['role'] ?? '';
          _presentAddressController.text = renterData['presentAddress'] ?? '';
          _permanentAddressController.text =
              renterData['permanentAddress'] ?? '';
          _nidController.text = renterData['nid'] ?? '';
          _altContactController.text = renterData['altContact'] ?? '';
          _selectedGender = renterData['gender'];
          _maritalStatus = renterData['maritalStatus'];

          // Load the profile image if it exists
          if (renterData['profileImage'] != null) {
            _imageFile = await _loadImage(renterData['profileImage']);
            // Call setState to update the UI after loading the image
            setState(() {});
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No renter information found for this contact.')),
        );
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
    final XFile? image = await _picker.pickImage(source: ImageSource
        .gallery); // You can use ImageSource.camera for the camera

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // Method to upload image to Firebase Storage and get the URL
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'profile_images/${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(image);

      // Listen to the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Uploading... ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
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

    // Fetch renter information and update if exists
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
    } else {
      // Create new renter entry if renter info does not exist
      String newRenterId = _database
          .child('renter_information')
          .push()
          .key!;
      await _database.child('renter_information').child(newRenterId).set({
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
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        // Only horizontal padding
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
              border: Border.all(color: const Color(0xFF64A6FF),
                  width: 2), // Border color and width
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Renter Profile',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile Image
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imageFile != null ? FileImage(
                            _imageFile!) : null,
                        child: _imageFile == null
                            ? const Icon(Icons.camera_alt, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: 'Name', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Contact
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(labelText: 'Contact Number',
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Password', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Role
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(
                        labelText: 'Role', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Present Address
                  TextFormField(
                    controller: _presentAddressController,
                    decoration: InputDecoration(labelText: 'Present Address',
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your present address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Permanent Address
                  TextFormField(
                    controller: _permanentAddressController,
                    decoration: InputDecoration(labelText: 'Permanent Address',
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your permanent address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // NID
                  TextFormField(
                    controller: _nidController,
                    decoration: InputDecoration(
                        labelText: 'NID', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your NID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Alternate Contact
                  TextFormField(
                    controller: _altContactController,
                    decoration: InputDecoration(labelText: 'Alternate Contact',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),

                  // Gender Selection
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    hint: const Text('Select Gender'),
                    items: <String>['Male', 'Female', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Marital Status Selection
                  DropdownButtonFormField<String>(
                    value: _maritalStatus,
                    hint: const Text('Select Marital Status'),
                    items: <String>['Single', 'Married', 'Divorced', 'Widowed']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _maritalStatus = newValue;
                      });
                    },
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
}