// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:house_solution/owner_dashboard.dart';
//
//
// class AddUserPage extends StatefulWidget {
//   const AddUserPage({Key? key}) : super(key: key);
//
//   @override
//   _AddUserPage createState() => AddUserPage();
// }
//
// class _CreateUserPageState extends State<AddUserPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final List<String> _houses = ['House 1', 'House 2', 'House 3'];
//   List<String> _floors = [];
//   List<DropdownMenuItem<String>> _houseDropdownItems = [];
//   List<DropdownMenuItem<String>> _floorDropdownItems = [];
//   String? _selectedHouse;
//   String? _selectedFloor;
//   String _password = '';
//   bool _showPassword = false;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _nidController = TextEditingController();
//   final TextEditingController _bcController = TextEditingController();
//   final TextEditingController _alternateContactController = TextEditingController();
//   final TextEditingController _alternateContactPersonController = TextEditingController();
//   final TextEditingController _rentAmountController = TextEditingController();
//   final TextEditingController _securityDepositController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeDropdowns();
//     _generateRandomPassword();
//   }
//
//   void _initializeDropdowns() {
//     _houseDropdownItems = _houses
//         .map((house) => DropdownMenuItem<String>(
//       value: house,
//       child: Text(house),
//     ))
//         .toList();
//
//     _selectedHouse = _houses.first;
//     _updateFloorList();
//   }
//
//   void _updateFloorList() {
//     setState(() {
//       if (_selectedHouse == 'House 1') {
//         _floors = ['1A', '1B', '2A', '2B'];
//       } else if (_selectedHouse == 'House 2') {
//         _floors = ['1A', '1B', '2A', '2B', '3A', '3B'];
//       } else if (_selectedHouse == 'House 3') {
//         _floors = ['1A', '1B', '2A', '2B', '3A', '3B', '4A'];
//       }
//
//       _floorDropdownItems = _floors
//           .map((floor) => DropdownMenuItem<String>(
//         value: floor,
//         child: Text(floor),
//       ))
//           .toList();
//
//       _selectedFloor = _floors.first;
//     });
//   }
//
//   void _generateRandomPassword() {
//     const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     const int passwordLength = 10;
//     setState(() {
//       _password = String.fromCharCodes(Iterable.generate(
//           passwordLength, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
//       _passwordController.text = _password;
//     });
//   }
//
//   bool _allFieldsFilled() {
//     return _nameController.text.isNotEmpty &&
//         _usernameController.text.isNotEmpty &&
//         _passwordController.text.isNotEmpty &&
//         _phoneController.text.isNotEmpty &&
//         (_nidController.text.isNotEmpty || _bcController.text.isNotEmpty) &&
//         _alternateContactController.text.isNotEmpty &&
//         _alternateContactPersonController.text.isNotEmpty &&
//         _rentAmountController.text.isNotEmpty &&
//         _securityDepositController.text.isNotEmpty &&
//         _selectedHouse != null &&
//         _selectedFloor != null;
//   }
//
//   bool _validatePhoneNumber(String value) {
//     return value.length == 11 && int.tryParse(value) != null;
//   }
//
//   bool _validateNIDorBC(String value) {
//     return value.length == 17 && int.tryParse(value) != null;
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//
//         },
//       );
//
//       Future.delayed(const Duration(seconds: 5), () {
//         DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('houses');
//
//         Map<String, dynamic> userData = {
//           'name': _nameController.text,
//           'username': _usernameController.text,
//           'password': _passwordController.text,
//           'phone': _phoneController.text,
//           'nid': _nidController.text,
//           'bc': _bcController.text,
//           'alternateContact': _alternateContactController.text,
//           'alternateContactPerson': _alternateContactPersonController.text,
//           'rentAmount': _rentAmountController.text,
//           'securityDeposit': _securityDepositController.text,
//           'house': _selectedHouse,
//           'floor': _selectedFloor,
//         };
//
//         usersRef.push().set(userData);
//
//         Navigator.of(context, rootNavigator: true).pop();
//
//         _showSuccessMessage();
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const OwnerDashboard()),
//         );
//       });
//     }
//   }
//
//   void _showSuccessMessage() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Success'),
//           content: const Text('User data saved successfully'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create User'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(32),
//             topRight: Radius.circular(32),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildDropdowns(),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _nameController,
//                     label: 'Name (Max 20 Characters)',
//                     maxLength: 20,
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please enter a name';
//                       }
//                       final bool validCharacters = RegExp(r'^[a-zA-Z ]+$').hasMatch(value);
//                       if (!validCharacters) {
//                         return 'Name should contain only alphabets';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _usernameController,
//                     label: 'Username (Max 20 Characters)',
//                     maxLength: 20,
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please enter a username';
//                       }
//                       final bool validCharacters = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);
//                       if (!validCharacters) {
//                         return 'Username should contain only alphabets and numbers';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildPasswordTextField(),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _phoneController,
//                     label: 'Phone Number',
//                     keyboardType: TextInputType.phone,
//                     maxLength: 11,
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please enter a phone number';
//                       }
//                       if (!_validatePhoneNumber(value)) {
//                         return 'Phone number should be 11 digits';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _nidController,
//                     label: 'NID (17 digits)',
//                     keyboardType: TextInputType.number,
//                     maxLength: 17,
//                     validator: (value) {
//                       if (value!.isEmpty && _bcController.text.isEmpty) {
//                         return 'Please enter either NID or BC';
//                       }
//                       if (value.isNotEmpty && !_validateNIDorBC(value)) {
//                         return 'NID should be 17 digits';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _bcController,
//                     label: 'BC (17 digits)',
//                     keyboardType: TextInputType.number,
//                     maxLength: 17,
//                     validator: (value) {
//                       if (value!.isEmpty && _nidController.text.isEmpty) {
//                         return 'Please enter either NID or BC';
//                       }
//                       if (value.isNotEmpty && !_validateNIDorBC(value)) {
//                         return 'BC should be 17 digits';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _alternateContactController,
//                     label: 'Alternate Contact Number',
//                     keyboardType: TextInputType.phone,
//                     maxLength: 11,
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please enter an alternate contact number';
//                       }
//                       if (!_validatePhoneNumber(value)) {
//                         return 'Alternate contact number should be 11 digits';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _alternateContactPersonController,
//                     label: 'Alternate Contact Person Details',
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please enter alternate contact person details';
//                       }
//                       final bool validCharacters = RegExp(r'^[a-zA-Z ]+$').hasMatch(value);
//                       if (!validCharacters) {
//                         return 'Alternate contact person details should contain only alphabets';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _rentAmountController,
//                     label: 'Rent Amount',
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please enter a rent amount';
//                       }
//                       if (double.tryParse(value) == null) {
//                         return 'Please enter a valid amount';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _securityDepositController,
//                     label: 'Security Deposit',
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please enter a security deposit amount';
//                       }
//                       if (double.tryParse(value) == null) {
//                         return 'Please enter a valid amount';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 32),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: _allFieldsFilled() ? _submitForm : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueAccent,
//                         minimumSize: const Size(200, 50),
//                       ),
//                       child: const Text(
//                         'Submit',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDropdowns() {
//     return Row(
//       children: [
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             value: _selectedHouse,
//             items: _houseDropdownItems,
//             onChanged: (value) {
//               setState(() {
//                 _selectedHouse = value;
//                 _updateFloorList();
//               });
//             },
//             decoration: InputDecoration(
//               labelText: 'Select House',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             value: _selectedFloor,
//             items: _floorDropdownItems,
//             onChanged: (value) {
//               setState(() {
//                 _selectedFloor = value;
//               });
//             },
//             decoration: InputDecoration(
//               labelText: 'Select Floor',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     TextInputType keyboardType = TextInputType.text,
//     int? maxLength,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//       ),
//       keyboardType: keyboardType,
//       maxLength: maxLength,
//       validator: validator,
//     );
//   }
//
//   Widget _buildPasswordTextField() {
//     return TextFormField(
//       controller: _passwordController,
//       obscureText: !_showPassword,
//       readOnly: true,
//       decoration: InputDecoration(
//         labelText: 'Password (Auto-Generated)',
//         suffixIcon: IconButton(
//           icon: Icon(
//             _showPassword ? Icons.visibility : Icons.visibility_off,
//           ),
//           onPressed: () {
//             setState(() {
//               _showPassword = !_showPassword;
//             });
//           },
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//       ),
//     );
//   }
// }
