import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'animate_button_add_house.dart';
import 'owner_dashboard.dart'; // Ensure you have the correct import for OwnerDashboard
import 'loadingscreen.dart'; // Import your LoadingScreen widget
import 'package:intl/intl.dart'; // Add this line at the top with other imports

class HouseRentCollectPage extends StatefulWidget {
  const HouseRentCollectPage({super.key});

  @override
  _HouseRentCollectPageState createState() => _HouseRentCollectPageState();
}

class _HouseRentCollectPageState extends State<HouseRentCollectPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
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
  String? selectedMonth;
  String? selectedYear;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  List<String> flatOptions = []; // List to store flat options
  String? selectedFlat; // To store the selected flat
  String? _flatRent;
  String? _gasBill;
  String? _waterBill; // Ensure you have these variables to hold the fetched values
  String? _additionalBill;

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
    _contactController.dispose();
    _nameController.dispose();
    _flatRentAmountController.dispose();
    _gasBillController.dispose();
    _electricityBillController.dispose();
    _additionalBillController.dispose();
    _waterBillController.dispose();
    _latePaymentFeeController.dispose();
    super.dispose();
  }

  // Function to fetch owner information from Firebase Realtime Database
  void _fetchOwnerInformation(String contact) async {
    try {
      if (contact.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a contact number.'),
          ),
        );
        return;
      }

      DatabaseReference ref = FirebaseDatabase.instance.ref().child('Flats');
      Query query = ref.orderByChild('contact').equalTo(contact);
      DatabaseEvent event = await query.once();

      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> flatData = snapshot.value as Map<dynamic, dynamic>;
        List<String> flatOptions = [];
        String? selectedFlat;

        for (var entry in flatData.entries) {
          var flatInfo = entry.value; // Get flat info from each entry

          if (flatInfo is Map<dynamic, dynamic>) {
            // Populate flat options with the flat numbers
            flatOptions.add(flatInfo['flatNo']); // Assuming flatNo is the key for flat number

            // For the first flat, populate the other fields
            if (selectedFlat == null) {
              selectedFlat = flatInfo['flatNo']; // Set the first flat as selected
              _nameController.text = flatInfo['name']; // Populate name field
              _flatRent = flatInfo['rent']; // Assuming you have a variable _flatRent
              _gasBill = flatInfo['gasBill']; // Assuming you have a variable _gasBill
              _waterBill = flatInfo['waterBill']; // Assuming you have a variable _waterBill
              _additionalBill = flatInfo['additionalBill']; // Assuming you have a variable _additionalBill
            }
          }
        }

        // Update the state with the new values
        setState(() {
          this.flatOptions = flatOptions; // Update dropdown options
          this.selectedFlat = selectedFlat; // Set the selected flat
          // Populate any additional UI elements as needed
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No owner found with this contact number.'),
          ),
        );
      }
    } catch (e) {
      print("Error fetching flat information: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch flat information.'),
        ),
      );
    }
  }


  // Function to calculate the total payable amount
  double _calculateTotalPayableAmount() {
    double flatRentAmount = double.tryParse(_flatRentAmountController.text) ?? 0.0;
    double gasBill = double.tryParse(_gasBillController.text) ?? 0.0;
    double electricityBill = double.tryParse(_electricityBillController.text) ?? 0.0;
    double additionalBill = double.tryParse(_additionalBillController.text) ?? 0.0;
    double waterBill = double.tryParse(_waterBillController.text) ?? 0.0;
    double latePaymentFee = double.tryParse(_latePaymentFeeController.text) ?? 0.0;

    return flatRentAmount + gasBill + electricityBill + additionalBill + waterBill + latePaymentFee;
  }

  // Function to save rent data
  void _saveRentDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen(), // Use your LoadingScreen widget here
      );

      String contact = _contactController.text.trim();

      // Prepare the rent data to be saved
      Map<String, dynamic> rentData = {
        'name': _nameController.text.trim(),
        'flatRentAmount': _flatRentAmountController.text.trim(),
        'gasBill': _gasBillController.text.trim(),
        'electricityBill': _electricityBillController.text.trim(),
        'additionalBill': _additionalBillController.text.trim(),
        'waterBill': _waterBillController.text.trim(),
        'latePaymentFee': _latePaymentFeeController.text.trim(),
        'totalPayableAmount': _calculateTotalPayableAmount(),
      };

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref();

        // Create a unique key for the new rent entry
        String rentKey = ref.child('Rent/$contact').push().key ?? '';

        // Save the rent data under the unique key
        await ref.child('Rent/$contact/$rentKey').set(rentData);

        // Close the loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rent details saved successfully!'),
          ),
        );

        // Navigate back to OwnerDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OwnerDashboard()), // Replace with your actual dashboard page
        );

      } catch (e) {
        Navigator.pop(context); // Close the loading dialog on error
        print("Error saving rent information: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save rent details.'),
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    Widget? suffixIcon,
    bool enabled = false, // Make all fields non-editable by default
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
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white), // Label color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), // Border color and width
              ),
              filled: true,
              fillColor: Colors.black54, // Background color of text field
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: suffixIcon,
            ),
            enabled: enabled,
            validator: validator,
            style: const TextStyle(color: Colors.white), // Text color
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background color
      appBar: AppBar(
        title: const Text('Collect Rent', style: TextStyle(fontSize: 22)), // Center title
        centerTitle: true, // Center title in AppBar
        automaticallyImplyLeading: false, // Remove back button
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
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact',
                  keyboardType: TextInputType.phone,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _fetchOwnerInformation(_contactController.text.trim());
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Please enter a valid Contact (11 digits).';
                    }
                    return null;
                  },
                  enabled: true, // Make the Contact field editable
                ),
                // Dropdown for selecting flat immediately after the contact field
                if (flatOptions.isNotEmpty) // Show only if there are flat options
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0), // Add some padding for spacing
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Flat',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                        filled: true,
                        fillColor: Colors.black54,
                      ),
                      value: selectedFlat, // Set the initial selected flat
                      items: flatOptions.map((flat) {
                        return DropdownMenuItem(
                          value: flat,
                          child: Text(
                            flat,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFlat = value; // Update the selected flat
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a flat.';
                        }
                        return null;
                      },
                    ),
                  ),
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Name.';
                    }
                    return null;
                  },
                  enabled: false, // Make the Name field non-editable
                ),
                // Row for Flat Rent Amount and other bills
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
                        enabled: false, // Make the Flat Rent Amount field non-editable
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
                        enabled: false, // Make the Gas Bill field non-editable
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _electricityBillController,
                        label: 'Electricity Bill',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an Electricity Bill.';
                          }
                          return null;
                        },
                        enabled: false, // Make the Electricity Bill field non-editable
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
                        enabled: false, // Make the Additional Bill field non-editable
                      ),
                    ),
                  ],
                ),
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
                        enabled: false, // Make the Water Bill field non-editable
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: _latePaymentFeeController,
                        label: 'Late Payment Fee (%)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Late Payment Fee.';
                          }
                          // Check if the value ends with % and is a valid number
                          if (!RegExp(r'^\d+%?$').hasMatch(value)) {
                            return 'Please enter a valid percentage (e.g., 10%).';
                          }
                          return null;
                        },
                        enabled: true, // Make the Late Payment Fee field editable
                      ),
                    ),
                  ],
                ),
                // Display total payable amount
                // Display total payable amount
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'Total Payable Amount: \$${_calculateTotalPayableAmount().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

// Dropdown for Month selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Month',
                            labelStyle: const TextStyle(color: Colors.green),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                            ),
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                          value: selectedMonth, // Set initial value
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: (index + 1).toString(),
                              child: Text(
                                DateFormat.MMMM().format(DateTime(0, index + 1)),
                                style: const TextStyle(color: Colors.blue),
                              ),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value; // Update the selected month
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Year',
                            labelStyle: const TextStyle(color: Colors.green),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                            ),
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                          value: selectedYear, // Set initial value
                          items: List.generate(50, (index) {
                            int year = DateTime.now().year + index;
                            return DropdownMenuItem(
                              value: year.toString(),
                              child: Text(
                                year.toString(),
                                style: const TextStyle(color: Colors.blue),
                              ),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value; // Update the selected year
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),


// Display today's date
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'Today\'s Date: ${DateFormat.yMMMd().format(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Save button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveRentDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button color
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Save Rent Details'),
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
