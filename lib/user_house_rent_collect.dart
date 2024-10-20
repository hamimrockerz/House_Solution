import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'animate_button_add_house.dart';
import 'owner_dashboard.dart'; // Ensure you have the correct import for OwnerDashboard
import 'loadingscreen.dart'; // Import your LoadingScreen widget
import 'package:intl/intl.dart'; // Add this line at the top with other imports
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

class UserHouseRentCollectPage extends StatefulWidget {
  const UserHouseRentCollectPage({super.key});

  @override
  _UserHouseRentCollectPageState createState() => _UserHouseRentCollectPageState();
}

class _UserHouseRentCollectPageState extends State<UserHouseRentCollectPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _flatRentAmountController = TextEditingController();
  final TextEditingController _rentedFlatController = TextEditingController();
  final TextEditingController _gasBillController = TextEditingController();
  final TextEditingController _electricityBillController = TextEditingController();
  final TextEditingController _additionalBillController = TextEditingController();
  final TextEditingController _waterBillController = TextEditingController();
  final TextEditingController _latePaymentFeeController = TextEditingController();
  List<String> flatOptions = []; // This will hold the list of available flat options
  String? selectedFlat; // This will hold the currently selected flat

  String? selectedMonth;
  String? selectedYear;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  double totalPayableAmount = 0.0;


  @override
  void initState() {
    super.initState();
    _flatRentAmountController.addListener(_updateTotal);
    _gasBillController.addListener(_updateTotal);
    _electricityBillController.addListener(_updateTotal);
    _additionalBillController.addListener(_updateTotal);
    _waterBillController.addListener(_updateTotal);
    _latePaymentFeeController.addListener(_updateTotal);

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
    selectedMonth = DateFormat('MM').format(DateTime.now()); // Current month
    selectedYear = DateFormat('yyyy').format(DateTime.now()); // Current year
    _updateLatePaymentFee(); // Set initial late payment fee
    _animationController.forward();

    _loadContactNumber(); // Load the stored contact when the page loads
    _autoSelectCurrentMonthYear(); // Auto-select the running month and year
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


  Future<void> _loadContactNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedContact = prefs.getString('contact');

    if (storedContact != null) {
      _contactController.text = storedContact;

      // Just call the function here without assigning or using it in an expression.
      _fetchOwnerInformation(storedContact);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contact number found. Please enter a contact number.')),
      );
    }
  }


  // Auto-select the current month and year
  void _autoSelectCurrentMonthYear() {
    DateTime now = DateTime.now();
    selectedMonth = now.month.toString(); // Set current month (1-12)
    selectedYear = now.year.toString(); // Set current year
  }
  void _onMonthOrYearChanged() {
    _updateLatePaymentFee(); // Call to update the late payment fee
  }

  void _onMonthChanged(String? month) {
    setState(() {
      selectedMonth = month;
    });
    _updateLatePaymentFee(); // Update late payment fee when month changes
  }

  void _onYearChanged(String? year) {
    setState(() {
      selectedYear = year;
    });
    _updateLatePaymentFee(); // Update late payment fee when year changes
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

      // Reference to the Users collection
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('Users');

      // Fetch user data
      DatabaseEvent event = await usersRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        bool found = false;
        String userName = '';
        String selectedFlat = '';

        // Traverse through Users collection
        Map<dynamic, dynamic> usersData = snapshot.value as Map<dynamic, dynamic>;

        for (var entry in usersData.entries) {
          var userValue = entry.value;

          // Search for the user contact and fetch selectedFlat
          if (userValue is Map) {
            userValue.forEach((subKey, subValue) {
              if (subValue is Map && subValue['contact'] == contact) {
                userName = subValue['name'] ?? 'No Name Found';
                selectedFlat = subValue['selectedFlat'] ?? 'No Flat Found';

                // Populate the name and flat fields
                _nameController.text = userName;
                _rentedFlatController.text = selectedFlat;

                found = true;
                return; // Break inner loop once found
              }
            });
          }

          if (found) break; // Break outer loop if user is found
        }

        if (!found) {
          // No user found with the specified contact
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found with this contact number.')),
          );
        } else {
          // Fetch flat details if the user is found
          await _fetchFlatDetails(selectedFlat); // Pass only the selectedFlat value
        }
      } else {
        // No data in Users collection
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user data found in the database.')),
        );
      }
    } catch (e) {
      print("Error fetching user information: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user information.')),
      );
    }
  }

// Function to fetch rent, gasBill, waterBill, additionalBill from Flats collection
  Future<void> _fetchFlatDetails(String selectedFlat) async {
    try {
      // Reference to the Flats collection
      DatabaseReference flatsRef = FirebaseDatabase.instance.ref().child('Flats');

      // Fetch all data in the Flats collection
      DatabaseEvent event = await flatsRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        bool flatFound = false;

        // Split selectedFlat into components
        List<String> components = selectedFlat.split(', ');
        String house = components.firstWhere((c) => c.startsWith('House:')).split(':')[1].trim();
        String road = components.firstWhere((c) => c.startsWith('Road:')).split(':')[1].trim();
        String block = components.firstWhere((c) => c.startsWith('Block:')).split(':')[1].trim();
        String section = components.firstWhere((c) => c.startsWith('Section:')).split(':')[1].trim();
        String flatNo = components.firstWhere((c) => c.startsWith('Flat:')).split(':')[1].trim(); // '1E'

        // Iterate through each contact's subcollection
        Map<dynamic, dynamic> flatsData = snapshot.value as Map<dynamic, dynamic>;
        for (var entry in flatsData.entries) {
          var flatSubCollection = entry.value;

          if (flatSubCollection is Map) {
            // Loop through the nested subcollections
            flatSubCollection.forEach((flatKeyLevel1, flatValueLevel1) {
              if (flatValueLevel1 is Map) {
                // Now loop through the deeply nested subcollection
                flatValueLevel1.forEach((nestedKey, nestedValue) {
                  // Match the nested values with the selected flat components
                  if (nestedValue['house'] == house &&
                      nestedValue['road'] == road &&
                      nestedValue['block'] == block &&
                      nestedValue['flatNo'] == flatNo) {

                    // If match found, fetch rent and other bills
                    String rent = nestedValue['rent']?.toString() ?? 'No Rent Found';
                    String gasBill = nestedValue['gasBill']?.toString() ?? 'No Gas Bill Found';
                    String waterBill = nestedValue['waterBill']?.toString() ?? 'No Water Bill Found';
                    String additionalBill = nestedValue['additionalBill']?.toString() ?? 'No Additional Bill Found';

                    // Populate the text fields with the fetched data
                    _flatRentAmountController.text = rent;
                    _gasBillController.text = gasBill;
                    _waterBillController.text = waterBill;
                    _additionalBillController.text = additionalBill;

                    flatFound = true; // Set flag to indicate flat was found
                    print("Flat details fetched successfully: Rent: $rent, Gas: $gasBill, Water: $waterBill, Additional: $additionalBill");
                    return; // Stop searching once the flat is found
                  }
                });
              }
            });
          }
        }

        if (!flatFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No matching flat details found.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No flat data found in the database.')),
        );
      }
    } catch (e) {
      print("Error fetching flat details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch flat details.')),
      );
    }
  }



  // Function to calculate the total payable amount
  void _updateTotal() {
    setState(() {
      totalPayableAmount = _calculateTotalPayableAmount();
    });
  }

  double _calculateTotalPayableAmount() {
    // Parse rent and bills from controllers
    double flatRentAmount = double.tryParse(_flatRentAmountController.text) ?? 0.0;
    double gasBill = double.tryParse(_gasBillController.text) ?? 0.0;
    double electricityBill = double.tryParse(_electricityBillController.text) ?? 0.0;
    double additionalBill = double.tryParse(_additionalBillController.text) ?? 0.0;
    double waterBill = double.tryParse(_waterBillController.text) ?? 0.0;

    // Read the late payment fee percentage from the controller and handle '%'
    String lateFeeText = _latePaymentFeeController.text.trim();
    double lateFeePercentage = 0.0;

    // Check if the text ends with '%' and parse accordingly
    if (lateFeeText.isNotEmpty && lateFeeText.endsWith('%')) {
      lateFeePercentage = double.tryParse(lateFeeText.substring(0, lateFeeText.length - 1)) ?? 0.0;
    } else {
      lateFeePercentage = double.tryParse(lateFeeText) ?? 0.0; // Handle non-percentage input
    }

    // Calculate total excluding late fee
    double totalExcludingLateFee = flatRentAmount + gasBill + electricityBill + additionalBill + waterBill;

    // Calculate late payment fee
    double latePaymentFee = totalExcludingLateFee * (lateFeePercentage / 100);

    // Calculate total payable amount
    return totalExcludingLateFee + latePaymentFee; // Return the total with late fee included
  }




  // Update this function in your state class
  void _updateLatePaymentFee() {
    if (selectedMonth != null && selectedYear != null) {
      DateTime currentDate = DateTime.now();
      DateTime selectedDate = DateTime(int.parse(selectedYear!), int.parse(selectedMonth!));

      // Check if the current date is after the 10th of the selected month
      if (currentDate.year == selectedDate.year &&
          currentDate.month == selectedDate.month &&
          currentDate.day > 10) {
        _latePaymentFeeController.text = '5%'; // Set late payment fee to 5%
      } else {
        _latePaymentFeeController.clear(); // Clear if before the 10th
      }

      // Ensure the cursor is positioned correctly at the end of the text
      _latePaymentFeeController.selection = TextSelection.fromPosition(
          TextPosition(offset: _latePaymentFeeController.text.length)
      );

      _updateTotal(); // Update the total whenever the late payment fee changes
    }
  }





  void _saveRentDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen(), // Use your LoadingScreen widget here
      );

      String contact = _contactController.text.trim();
      DateTime now = DateTime.now();
      String todayDate = now.toIso8601String(); // Get today's date in ISO format
      String currentMonth = now.month.toString(); // Get current month
      String currentYear = now.year.toString(); // Get current year
      String rentedFlat = _rentedFlatController.text.trim(); // Get the rented flat info

      // Use selectedMonth and selectedYear from your dropdowns
      String rentedMonth = selectedMonth != null
          ? DateFormat.MMMM().format(DateTime(0, int.parse(selectedMonth!))) // Convert to month name
          : ''; // Default value if selectedMonth is null
      String rentedYear = selectedYear ?? ''; // Ensure selectedYear is not null

      // Check if the rent data for this month and year already exists
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      DatabaseEvent event = await ref.child('Rent/$contact/$contact-$rentedMonth-$rentedYear').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Navigator.pop(context); // Close loading dialog if data exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rent is Already Paid For this Months and Year.'),
          ),
        );
        return; // Exit the method if data already exists
      }

      // Prepare the rent data to be saved
      Map<String, dynamic> rentData = {
        'name': _nameController.text.trim(),
        'contact': contact, // Save contact
        'rentedFlat': rentedFlat, // Save rented flat info
        'date': todayDate, // Save today's date
        'currentMonth': currentMonth, // Save current month
        'currentYear': currentYear, // Save current year
        'rentedMonth': rentedMonth, // Save rented month in string format
        'rentedYear': rentedYear, // Save rented year from dropdown
        'flatRentAmount': _flatRentAmountController.text.trim(),
        'gasBill': _gasBillController.text.trim(),
        'electricityBill': _electricityBillController.text.trim().isEmpty
            ? null // Set to null if empty
            : _electricityBillController.text.trim(), // Otherwise, use the entered value
        'additionalBill': _additionalBillController.text.trim(),
        'waterBill': _waterBillController.text.trim(),
        'latePaymentFee': _latePaymentFeeController.text.trim(),
        'totalPayableAmount': _calculateTotalPayableAmount(),
      };

      try {
        // Create a unique key for the new rent entry using rentedMonth and rentedYear
        String rentKey = '$contact-$rentedMonth-$rentedYear';

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
    required TextInputType keyboardType,
    Widget? suffixIcon,
    Function(String)? onChanged, // Add this line to include the onChanged parameter

    String? Function(String?)? validator,
    bool? enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white), // Keeping white label style
          filled: true,
          fillColor: Colors.black54, // Background color for the text field
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners for the border
            borderSide: const BorderSide(color: Colors.white, width: 2.0), // White border when not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), // Blue accent border when focused
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey, width: 2.0), // Grey border when disabled
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Rent Pay Page', style: TextStyle(fontSize: 22)),
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
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact',
                  keyboardType: TextInputType.phone,  // Ensure this argument is passed
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Please enter a valid Contact (11 digits).';
                    }
                    return null;
                  },
                  enabled: false,
                ),
                if (flatOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
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
                      value: selectedFlat,
                      items: flatOptions.map((flat) {
                        return DropdownMenuItem(
                          value: flat,
                          child: Text(flat, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFlat = value!;
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
                  keyboardType: TextInputType.text,  // Ensure keyboardType is passed
                  enabled: false,
                ),
                _buildTextField(
                  controller: _rentedFlatController,
                  label: 'Rented Flat',
                  keyboardType: TextInputType.text,  // Ensure keyboardType is passed
                  enabled: false,
                ),
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
                        enabled: false,
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
                        enabled: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: _additionalBillController,
                        label: 'Additional Bill',
                        keyboardType: TextInputType.number,
                        enabled: false,
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
                        enabled: false,
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
                          // Validate if the value is a valid percentage format (only numbers)
                          if (!RegExp(r'^\d*$').hasMatch(value)) {
                            return 'Please enter a valid percentage (e.g., 10).'; // Only numbers allowed
                          }
                          return null; // Return null if validation passes
                        },
                        enabled: false,
                        suffixIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '%', // Fixed '%' icon next to the field
                            style: TextStyle(color: Colors.grey), // Style for the percentage symbol
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _latePaymentFeeController.text = '';
                            return;
                          }

                          // Allow numeric input and manage percentage display
                          if (RegExp(r'^\d*$').hasMatch(value)) {
                            _latePaymentFeeController.text = '$value%';
                            _latePaymentFeeController.selection = TextSelection.fromPosition(TextPosition(offset: _latePaymentFeeController.text.length - 1));
                          } else if (value.endsWith('%')) {
                            _latePaymentFeeController.text = value.substring(0, value.length - 1);
                            _latePaymentFeeController.selection = TextSelection.fromPosition(TextPosition(offset: _latePaymentFeeController.text.length));
                          }

                          // Call to update the total amount whenever the late payment fee is changed
                          _updateTotal();
                        },

                      ),
                    ),

                  ],
                ),

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
                          value: selectedMonth,
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
                              selectedMonth = value;
                              _updateLatePaymentFee(); // Update late payment fee when month changes
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
                          value: selectedYear,
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
                              selectedYear = value;
                              _updateLatePaymentFee(); // Update late payment fee when year changes
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'Total Payable Amount: TK ${_calculateTotalPayableAmount().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),


                // Save button
                Center(
                  child: AnimatedButton(
                    onPressed: _saveRentDetails,
                    text: "Rent Collect",
                    buttonColor: Colors.blue,
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
