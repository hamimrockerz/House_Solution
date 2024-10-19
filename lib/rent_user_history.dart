import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animate_button_add_house.dart';

class UserRentHistoryPage extends StatefulWidget {
  const UserRentHistoryPage({super.key});

  @override
  _UserRentHistoryPageState createState() => _UserRentHistoryPageState();
}

class _UserRentHistoryPageState extends State<UserRentHistoryPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rentedDateController =
  TextEditingController(); // Added Rented Date Controller

  final TextEditingController _flatRentAmountController =
  TextEditingController();
  final TextEditingController _gasBillController = TextEditingController();
  final TextEditingController _electricityBillController =
  TextEditingController();
  final TextEditingController _additionalBillController =
  TextEditingController();
  final TextEditingController _waterBillController = TextEditingController();
  final TextEditingController _latePaymentFeeController =
  TextEditingController();
  final TextEditingController _totalPaidController = TextEditingController();
  double totalPayableAmount = 0.0; // Class-level variable

  String? selectedFlat;
  List<String> flatOptions = []; // Replace with your flat options

  // New variables for month and year selection
  String? selectedMonth;
  String? selectedYear;
  List<String> monthOptions = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  List<String> yearOptions = List.generate(
      30, (index) => (2024 + index).toString()); // Example: 2024 to 2015

  // Animation properties
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadContactNumber();
    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_controller);

    // Start the animation
    _controller.forward();

    // Fetch total paid amount from database
    double totalPayableAmount = 0.0; // New variable to hold the total payable amount
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadContactNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');

    if (storedContact != null) {
      _contactController.text = storedContact;
      await _fetchOwnerInformation(
          storedContact); // Fetch data right after loading contact
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'No contact number found. Please enter a contact number.')),
      );
    }
  }

  // Function to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    Widget? suffixIcon,
    bool enabled = false,
    VoidCallback? onFieldSubmitted, // Callback for field submission
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.black54,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          suffixIcon: suffixIcon,
        ),
        enabled: enabled,
        validator: validator,
        onFieldSubmitted: (value) {
          if (onFieldSubmitted != null) {
            onFieldSubmitted(); // Call the passed function
          }
        },
        style: const TextStyle(color: Colors.white),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Rent History Page', style: TextStyle(fontSize: 22)),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                // Row for Month and Year Dropdowns
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Rented Month',
                            labelStyle: const TextStyle(color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                            ),
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                          value: selectedMonth,
                          items: monthOptions.map((month) {
                            return DropdownMenuItem(
                              value: month,
                              child: Text(month, style: const TextStyle(color: Colors.blueAccent)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value;
                            });
                            // Automatically fetch data when month changes
                            if (selectedYear != null && value != null) {
                              _fetchOwnerInformation(_contactController.text.trim());
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a month.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Rented Year',
                          labelStyle: const TextStyle(color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.black54,
                        ),
                        value: selectedYear,
                        items: yearOptions.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year, style: const TextStyle(color: Colors.blueAccent)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                          });
                          // Automatically fetch data when year changes
                          if (selectedMonth != null && value != null) {
                            _fetchOwnerInformation(_contactController.text.trim());
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a year.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0), // Space before the contact field

                // Contact TextField
                _buildTextField(
                  controller: _contactController,
                  label: 'Enter The Renter Contact',
                  keyboardType: TextInputType.phone,
                  // Removed suffixIcon as requested
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Please enter a valid Contact (11 digits).';
                    }
                    return null; // Return null if validation passes
                  },
                  enabled: false, // Set enabled to false as requested
                  onFieldSubmitted: () {
                    String contact = _contactController.text.trim(); // Use the controller directly
                    if (contact.length == 11) {
                      _fetchOwnerInformation(contact);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid 11-digit contact.')),
                      );
                    }
                  },
                ),


                // Name and Rented Date in the same row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nameController,
                        label: 'Renter Name',
                        validator: (value) {
                          // No validation needed; just return null
                          return null; // Always valid, no message displayed
                        },
                        enabled: false, // Keep this disabled if you don't want the user to edit it
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: _rentedDateController,
                        label: 'Rented Date',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Rented Date.';
                          }
                          return null;
                        },
                        enabled: false,
                      ),
                    ),
                  ],
                ),

                // Flat Rent Amount and Gas Bill in the same row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _flatRentAmountController,
                        label: 'Flat Rent Amount',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Flat Rent Amount.';
                          }
                          return null;
                        },
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: _gasBillController,
                        label: 'Gas Bill',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Gas Bill.';
                          }
                          return null;
                        },
                        enabled: false,
                      ),
                    ),
                  ],
                ),

                // Electricity Bill and Additional Bill in the same row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _electricityBillController,
                        label: 'Electricity Bill',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Please enter the amount Electricity Bill.';
                            }
                          }
                          return null; // Return null to indicate no validation error
                        },
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: _additionalBillController,
                        label: 'Additional Bill',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an Additional Bill.';
                          }
                          return null;
                        },
                        enabled: false,
                      ),
                    ),
                  ],
                ),

                // Water Bill and Late Payment Fee in the same row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _waterBillController,
                        label: 'Water Bill',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Water Bill.';
                          }
                          return null;
                        },
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: _latePaymentFeeController,
                        label: 'Late Payment Fee',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Late Payment Fee.';
                          }
                          return null;
                        },
                        enabled: true,
                        suffixIcon: const Icon(Icons.percent, color: Colors
                            .white), // Add the percentage icon here
                      ),
                    ),

                  ],
                ),

                // Total Payable Amount
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20), // Add some space
                      Text(
                        'Rent Paid Amount: $totalPayableAmount',
                        // Use the variable directly
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: AnimatedButton(
                          onPressed: _printRentDetails,
                          // Call the function to save rent details
                          text: "Print Rent Slip",
                          // Button text
                          buttonColor: Colors.blue, // Button color
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _printRentDetails() {
    // Logic for printing rent details
    print("Rent details printed"); // Replace with actual printing logic
  }

  Future<void> _fetchOwnerInformation(String contact) async {
    if (selectedMonth != null && selectedYear != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String uniqueId = '$contact-$selectedMonth-$selectedYear';
      DatabaseReference ref = FirebaseDatabase.instance.ref();

      try {
        DatabaseEvent event = await ref.child('Rent/$contact/$uniqueId').once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists) {
          Map<String, dynamic> rentData = Map<String, dynamic>.from(
              snapshot.value as Map);

          // Set values in controllers
          _nameController.text = rentData['name'] ?? '';
          String originalDate = rentData['date'] ?? '';
          DateTime parsedDate = DateTime.parse(originalDate);
          String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
          _rentedDateController.text = formattedDate;
          _flatRentAmountController.text =
              rentData['flatRentAmount']?.toString() ?? '';
          _gasBillController.text = rentData['gasBill']?.toString() ?? '';
          _electricityBillController.text =
              rentData['electricityBill']?.toString() ?? '';
          _additionalBillController.text =
              rentData['additionalBill']?.toString() ?? '';
          _waterBillController.text = rentData['waterBill']?.toString() ?? '';
          _latePaymentFeeController.text =
              rentData['latePaymentFee']?.toString() ?? '';

          // Close loading dialog
          Navigator.pop(context);
          setState(() {}); // Update UI
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'No rent details found for this contact, month, and year.')));
        }
      } catch (e) {
        Navigator.pop(context);
        print("Error fetching rent information: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch rent details.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both month and year.')));
    }
  }
}