import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'animate_button_add_house.dart'; // Ensure this path is correct
import 'owner_dashboard.dart';
// Ensure you have the correct import for OwnerDashboard
import 'loadingscreen.dart'; // Import your LoadingScreen widget
import 'package:flutter/services.dart';
class AddHousePage extends StatefulWidget {
  const AddHousePage({super.key});

  @override
  _AddHousePageState createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _thanaController = TextEditingController();
  final TextEditingController _divisionController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final List<String> zipCodeSuggestions = [
    "1000", "1207", "1209", "1212", "1213", "1216", "1230", "1340", "1400", "1420",
    "1430", "1500", "1520", "1540", "1600", "1610", "1620", "1700", "1711", "1750",
    "1800", "1810", "1820", "1900", "1940", "1960", "2300", "2330", "2336", "2400",
    "2430", "3000", "3030", "3100", "3170", "3200", "3210", "3300", "3310", "3400",
    "3420", "3450", "3500", "3510", "3520", "3600", "3610", "3640", "3700", "3720",
    "3730", "3800", "3860", "3870", "3900", "3930", "3940", "4000", "4100", "4203",
    "4204", "4216", "4300", "4320", "4340", "4400", "4460", "4500", "4530", "4580",
    "4600", "4620", "4700", "4750", "4760", "5000", "5030", "5100", "5150", "5200",
    "5230", "5300", "5310", "5400", "5440", "5500", "5530", "5600", "5630", "5700",
    "5740", "5800", "5840", "5850", "5900", "5940", "6000", "6270", "6300", "6320",
    "6400", "6430", "6500", "6540", "6600", "6620", "6700", "6730", "7000", "7010",
    "7030", "7100", "7120", "7200", "7220", "7300", "7320", "7340", "7400", "7430",
    "7450", "7500", "7510", "7520", "7600", "7620", "7630", "7700", "7710", "7730",
    "7800", "7830", "7850", "7900", "7920", "7930", "8000", "8020", "8030", "8200",
    "8220", "8300", "8340", "8400", "8430", "8500", "8540", "8600", "8650", "9000",
    "9240", "9260", "9300", "9310", "9350", "9400", "9440", "9450"
  ];
  final List<String> thanaSuggestions = [
    'Adabor',
    'Akkelpur',
    'Akhaura',
    'Alamdanga',
    'Amtali',
    'Araihazar',
    'Ashulia',
    'Ashuganj',
    'Atghoria',
    'Atrai',
    'Austagram',
    'Bagatipara',
    'Bagha',
    'Bagherpara',
    'Bahubal',
    'Bakerganj',
    'Bakshiganj',
    'Bandar',
    'Bandarban Sadar',
    'Bangshal',
    'Banaripara',
    'Bancharampur',
    'Baniachong',
    'Banani',
    'Banshkhali',
    'Baralekha',
    'Barguna Sadar',
    'Barhatta',
    'Barishal Kotwali',
    'Barura',
    'Basail',
    'Batiaghata',
    'Bauphal',
    'Beanibazar',
    'Begumganj',
    'Belabo',
    'Belkuchi',
    'Bera',
    'Betagi',
    'Bhaluka',
    'Bhandaria',
    'Bheramara',
    'Bholahat',
    'Bhola Sadar',
    'Bhuapur',
    'Bhurungamari',
    'Birol',
    'Birampur',
    'Birganj',
    'Birishiri',
    'Boalkhali',
    'Boalmari',
    'Bochaganj',
    'Boda',
    'Bogra Sadar',
    'Chakaria',
    'Chandina',
    'Chandpur Sadar',
    'Chapai Nawabganj Sadar',
    'Chhagalnaiya',
    'Chhatak',
    'Chitalmari',
    'Chuadanga Sadar',
    'Cox\'s Bazar Sadar',
    'Daganbhuiyan',
    'Daudkandi',
    'Debhata',
    'Debidwar',
    'Debiganj',
    'Delduar',
    'Derai',
    'Dhamoirhat',
    'Dhamrai',
    'Dhobaura',
    'Dhunat',
    'Dighalia',
    'Dimla',
    'Dinajpur Sadar',
    'Dirai',
    'Dohar',
    'Doulatpur (Khulna)',
    'Doulatpur (Kushtia)',
    'Doulatpur (Manikganj)',
    'Durgapur',
    'Faridganj',
    'Faridpur Sadar',
    'Fatullah',
    'Fenchuganj',
    'Gabtali',
    'Gaibandha Sadar',
    'Gaffargaon',
    'Gandaria',
    'Gangni',
    'Ghoraghat',
    'Ghatail',
    'Goalandaghat',
    'Golapganj',
    'Gomastapur',
    'Gopalganj Sadar',
    'Gopalpur',
    'Gosairhat',
    'Gowainghat',
    'Gournadi',
    'Gulshan',
    'Gurudaspur',
    'Habiganj Sadar',
    'Haimchar',
    'Haluaghat',
    'Harirampur',
    'Hathazari',
    'Hatiya',
    'Homna',
    'Hossainpur',
    'Ishwardi',
    'Islampur',
    'Itna',
    'Jaintiapur',
    'Jaldhaka',
    'Jamalpur Sadar',
    'Jessore Kotwali',
    'Jhalokathi Sadar',
    'Jhenaidah Sadar',
    'Joypurhat Sadar',
    'Kabirhat',
    'Kachua',
    'Kaharole',
    'Kalaroa',
    'Kaliganj (Gazipur)',
    'Kaliganj (Jhenidah)',
    'Kaliganj (Satkhira)',
    'Kalihati',
    'Kalkini',
    'Kamarkhanda',
    'Kamrangirchar',
    'Kanaighat',
    'Kansat',
    'Kaptai',
    'Karimganj',
    'Kashiani',
    'Kawkhali',
    'Kazipur',
    'Kendua',
    'Keraniganj',
    'Keshabpur',
    'Keshorhat',
    'Khagrachhari Sadar',
    'Khaliajuri',
    'Khalishpur',
    'Khan Jahan Ali',
    'Khanpur',
    'Khatunganj',
    'Khetlal',
    'Khoksa',
    'Kishoreganj Sadar',
    'Kishorganj (Nilphamari)',
    'Kochua (Chandpur)',
    'Kotchandpur',
    'Kotwali (Dhaka)',
    'Kotwali (Chattogram)',
    'Kotwali (Jessore)',
    'Kotwali (Khulna)',
    'Kotwali (Mymensingh)',
    'Kotwali (Rajshahi)',
    'Kotwali (Rangpur)',
    'Kotwali (Sylhet)',
    'Koyra',
    'Kulaura',
    'Kuliarchar',
    'Kumarkhali',
    'Kurigram Sadar',
    'Kushtia Sadar',
    'Kutubdia',
    'Laksham',
    'Lalmohan',
    'Lalmonirhat Sadar',
    'Lohagara (Chattogram)',
    'Lohagara (Narail)',
    'Lakhai',
    'Lalpur',
    'Madarganj',
    'Madaripur Sadar',
    'Madhabpur',
    'Madhukhali',
    'Madhupur',
    'Magura Sadar',
    'Mahadebpur',
    'Mahalchari',
    'Maheshkhali',
    'Maheshpur',
    'Maksudpur',
    'Manikganj Sadar',
    'Mathbaria',
    'Matlab Dakshin',
    'Matlab Uttar',
    'Matiranga',
    'Mithamoin',
    'Mirpur (Dhaka)',
    'Mirpur (Kushtia)',
    'Mirzaganj',
    'Mirzapur',
    'Mithapukur',
    'Mohadevpur',
    'Mohanganj',
    'Moheshkhali',
    'Moheshpur',
    'Moksedpur',
    'Mominpur',
    'Mongla',
    'Monirampur',
    'Moulvibazar Sadar',
    'Muladi',
    'Muksudpur',
    'Munshiganj Sadar',
    'Muradnagar',
    'Mymensingh Sadar',
    'Naikhongchhari',
    'Nageshwari',
    'Nagarpur',
    'Nalitabari',
    'Naldanga',
    'Nalchity',
    'Nandail',
    'Nangalkot',
    'Narail Sadar',
    'Narayanganj Sadar',
    'Narsingdi Sadar',
    'Nasirnagar',
    'Natore Sadar',
    'Nawabganj (Dhaka)',
    'Nawabganj (Dinajpur)',
    'Nawabganj (Rajshahi)',
    'Nesarabad',
    'Netrokona Sadar',
    'Nilphamari Sadar',
    'Noakhali Sadar',
    'Pabna Sadar',
    'Paharpur',
    'Panchagarh Sadar',
    'Panchbibi',
    'Pangsha',
    'Parbatipur',
    'Patgram',
    'Patharghata',
    'Patuakhali Sadar',
    'Phulbari (Dinajpur)',
    'Phulbari (Kurigram)',
    'Phultala',
    'Pirganj (Rangpur)',
    'Pirganj (Thakurgaon)',
    'Pirojpur Sadar',
    'Porsha',
    'Raiganj',
    'Raipura',
    'Rajarhat',
    'Rajbari Sadar',
    'Rajnagar',
    'Ramganj',
    'Rangamati Sadar',
    'Rangpur Sadar',
    'Ranishankoil',
    'Raozan',
    'Rasulpur',
    'Ruma',
    'Sadarghat',
    'Saghata',
    'Saidpur',
    'Sakhipur',
    'Sandwip',
    'Santhia',
    'Sariakandi',
    'Satkhira Sadar',
    'Savar',
    'Senbagh',
    'Setabganj',
    'Shahjadpur',
    'Shailkupa',
    'Shahrasti',
    'Shalikha',
    'Shalutia',
    'Shariakandi',
    'Sherpur Sadar',
    'Shibalaya',
    'Shibganj (Bogra)',
    'Shibganj (Chapainawabganj)',
    'Shibpur',
    'Singair',
    'Singra',
    'Sirajganj Sadar',
    'Sitakunda',
    'Sonagazi',
    'Sonargaon',
    'Sonatala',
    'Sreepur (Gazipur)',
    'Sreepur (Magura)',
    'Sreemangal',
    'Subarnachar',
    'Sujanagar',
    'Sullah',
    'Sunamganj Sadar',
    'Sylhet Kotwali',
    'Tahirpur',
    'Tangail Sadar',
    'Tarabo',
    'Taraganj',
    'Tarash',
    'Tarakanda',
    'Teknaf',
    'Tetulia',
    'Thakurgaon Sadar',
    'Titas',
    'Tongi',
    'Tungipara',
    'Ukhia',
    'Ulipur',
    'Ullapara',
    'Uzirpur',
  ];
  final List<String> divisionSuggestions = [
    'Dhaka',
    'Chattogram (Chittagong)',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];
  final List<String> areaSuggestions = [
    // Dhaka Division
    'Adabor', 'Agargaon', 'Ajimpur', 'Aminbazar', 'Ashkona', 'Azimpur', 'Badda', 'Bailey Road', 'Banani', 'Banasree',
    'Bangla Motor', 'Baridhara', 'Bashundhara', 'Begum Rokeya Sarani', 'Bijoynagar', 'Chawkbazar', 'Dakshin Khan',
    'Dania', 'Dhanmondi', 'Elephant Road', 'Eskaton', 'Farmgate', 'Gabtoli', 'Gulshan', 'Hazaribagh', 'Jatrabari',
    'Jurain', 'Kafrul', 'Kalabagan', 'Kallyanpur', 'Kamalapur', 'Kamal Ataturk Avenue', 'Kawran Bazar', 'Khilgaon',
    'Khilkhet', 'Lalbagh', 'Lalmatia', 'Malibagh', 'Matuail', 'Mazar Road', 'Merul Badda', 'Mirpur', 'Mohakhali',
    'Mohammadpur', 'Monipuripara', 'Mouchak', 'Motijheel', 'Mugdapara', 'Nadda', 'Nakhalpara', 'Nawabganj',
    'Nikunja', 'Pallabi', 'Panthapath', 'Puran Dhaka', 'Rampura', 'Rayer Bazar', 'Savar', 'Segunbagicha',
    'Shahbagh', 'Shantinagar', 'Shyamoli', 'Shonir Akhra', 'Siddheswari', 'Tejgaon', 'Tejturi Bazar', 'Uttara',
    'Wari', 'Zirabo',

    // Chattogram Division
    'Agrabad', 'Anwara', 'Bakalia', 'Bandar', 'Bashkhali', 'Chandgaon', 'Chawkbazar (Ctg)', 'Colonel Hat',
    'Cox\'s Bazar Sadar', 'Double Mooring', 'Feni Sadar', 'GEC Circle', 'Halishahar', 'Jhautola', 'Khulshi',
    'Lohagara', 'Mirsharai', 'Muradpur', 'Nasirabad', 'Pahartali', 'Panchlaish', 'Patenga', 'Rangamati Sadar',
    'Reazuddin Bazar', 'Riazuddin Bazar', 'Sitakunda', 'Tiger Pass',

    // Rajshahi Division
    'Bagha', 'Baneshwar', 'Boalia', 'Charghat', 'Chowbaria', 'Durgapur', 'Godagari', 'Kashiadanga', 'Katakhali',
    'Mohonpur', 'Naogaon Sadar', 'Natore Sadar', 'Puthia', 'Rajpara', 'Shah Makhdum', 'Tanore',

    // Khulna Division
    'Alaipur', 'Bagherpara', 'Bagerhat Sadar', 'Batiaghata', 'Dumuria', 'Fakirhat', 'Jessore Sadar', 'Khulna Sadar',
    'Kotchandpur', 'Kushtia Sadar', 'Manirampur', 'Mujgunni', 'Noapara', 'Phultala', 'Rupsha', 'Satkhira Sadar',
    'Shikarpur',

    // Barishal Division
    'Babuganj', 'Barishal Sadar', 'Bauphal', 'Charfesson', 'Gournadi', 'Hizla', 'Jhalokathi Sadar', 'Muladi',
    'Patuakhali Sadar', 'Taltoli',

    // Sylhet Division
    'Ambarkhana', 'Balaganj', 'Beanibazar', 'Biswanath', 'Chhatak', 'Golapganj', 'Hobiganj Sadar', 'Jaintiapur',
    'Kanaighat', 'Kulaura', 'Moulvibazar Sadar', 'Srimangal', 'Sunamganj Sadar', 'Sylhet Sadar', 'Zakiganj',

    // Rangpur Division
    'Badarganj', 'Baliadangi', 'Gangachara', 'Gobindaganj', 'Kurigram Sadar', 'Lalmonirhat Sadar', 'Mithapukur',
    'Nilphamari Sadar', 'Pirgachha', 'Pirgacha', 'Rangpur Sadar', 'Thakurgaon Sadar', 'Ulipur',

    // Mymensingh Division
    'Bhaluka', 'Dhobaura', 'Fulbaria', 'Gafargaon', 'Gouripur', 'Ishwarganj', 'Jamalpur Sadar', 'Mymensingh Sadar',
    'Muktagachha', 'Netrokona Sadar', 'Sherpur Sadar', 'Tarakanda'
  ];

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

    _contactController.addListener(() {
      String currentText = _contactController.text;
      String filteredText = currentText.replaceAll(RegExp(r'[^0-9]'), ''); // Remove non-numeric characters

      if (filteredText.length > 11) {
        filteredText = filteredText.substring(0, 11); // Limit to 11 digits
      }

      if (filteredText != currentText) {
        _contactController.value = TextEditingValue(
          text: filteredText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: filteredText.length), // Move cursor to the end
          ),
        );
      }
    });

    _houseNoController.addListener(() {
      String currentText = _houseNoController.text;

      // Limit to 3 characters
      if (currentText.length > 4) {
        // Update only if the length exceeds 3
        _houseNoController.value = TextEditingValue(
          text: currentText.substring(0, 4), // Keep only first 3 characters
          selection: TextSelection.fromPosition(
            const TextPosition(offset: 4), // Move cursor to the end
          ),
        );
      }
    });

    // Listener for Road to allow only numeric digits
    _roadController.addListener(() {
      String currentText = _roadController.text;
      String filteredText = currentText.replaceAll(RegExp(r'[^0-9]'), ''); // Remove non-numeric characters

      if (filteredText.length > 3) {
        filteredText = filteredText.substring(0, 3); // Limit to 3 digits
      }

      // Update only if the filtered text is different
      if (filteredText != currentText) {
        _roadController.value = TextEditingValue(
          text: filteredText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: filteredText.length), // Move cursor to the end
          ),
        );
      }
    });

    _sectionController.addListener(() {
      String currentText = _sectionController.text;

      // Limit to 2 digits
      if (currentText.length > 2) {
        // Update only if the length exceeds 2
        _sectionController.value = TextEditingValue(
          text: currentText.substring(0, 2), // Keep only the first 2 characters
          selection: TextSelection.fromPosition(
            TextPosition(offset: 2), // Move cursor to the end
          ),
        );
      }
    });

    _blockController.addListener(() {
      if (_blockController.text.length > 2) {
        _blockController.text = _blockController.text.substring(0, 2);
        _blockController.selection = TextSelection.fromPosition(
          TextPosition(offset: _blockController.text.length),
        );
      }
    });

  }


  @override
  void dispose() {
    _animationController.dispose();
    _contactController.dispose();
    _nameController.dispose();
    _houseNoController.dispose();
    _roadController.dispose();
    _sectionController.dispose();
    _blockController.dispose();
    _areaController.dispose();
    _zipCodeController.dispose();
    _thanaController.dispose();
    _divisionController.dispose();

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

      DatabaseReference ref = FirebaseDatabase.instance.ref().child('owner_information');
      Query query = ref.orderByChild('contact').equalTo(contact);
      DatabaseEvent event = await query.once();

      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> ownerData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _nameController.text = ownerData.values.first['name']; // Populate the name field with the first match
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No owner found with this contact number.'),
          ),
        );
      }
    } catch (e) {
      print("Error fetching owner information: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch owner information.'),
        ),
      );
    }
  }

  // Function to save house data
  // Function to save house data
  void _saveHouse() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen(), // Use your LoadingScreen widget here
      );

      String contact = _contactController.text.trim();

      // Prepare the house data to be saved
      Map<String, dynamic> houseData = {
        'name': _nameController.text.trim(),
        'houseNo': _houseNoController.text.trim(),
        'road': _roadController.text.trim(),
        'section': _sectionController.text.trim(),
        'block': _blockController.text.trim(),
        'area': _areaController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
        'thana': _thanaController.text.trim(),       // Add this
        'division': _divisionController.text.trim(), // Add this
      };

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref();

        // Query to check for existing houses with the same details for the same contact
        Query query = ref.child('Houses/$contact').orderByChild('houseNo').equalTo(houseData['houseNo']);

        // Listen for the data once
        DatabaseEvent event = await query.once();
        DataSnapshot snapshot = event.snapshot;

        // Check if there are any existing entries with the same house number
        if (snapshot.value != null) {
          Map<dynamic, dynamic> existingHouses = snapshot.value as Map<dynamic, dynamic>;

          // Iterate over existing houses to check for duplicates
          // Check for duplicates with the added fields: Thana and Division
          bool isDuplicate = existingHouses.values.any((value) =>
          value['road'] == houseData['road'] &&
              value['section'] == houseData['section'] &&
              value['block'] == houseData['block'] &&
              value['area'] == houseData['area'] &&
              value['zipCode'] == houseData['zipCode'] &&
              value['thana'] == houseData['thana'] &&         // Add Thana to the check
              value['division'] == houseData['division']      // Add Division to the check
          );


          if (isDuplicate) {
            Navigator.pop(context); // Close the loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This house entry already exists for this contact.'),
              ),
            );
            return; // Exit the function early to prevent saving
          }
        }

        // Create a unique key for the new house entry
        String houseKey = ref.child('Houses/$contact').push().key ?? '';

        // Save the house data under the unique key
        await ref.child('Houses/$contact/$houseKey').set(houseData);

        // Close the loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('House details saved successfully!'),
          ),
        );

        // Wait for 4 seconds before navigating back


        // Navigate back to OwnerDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OwnerDashboard()), // Replace with your actual dashboard page
        );

      } catch (e) {
        Navigator.pop(context); // Close the loading dialog on error
        print("Error saving house information: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save house details.'),
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
    List<TextInputFormatter>? inputFormatters, // Add inputFormatters parameter

    bool enabled = true,
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
            onFieldSubmitted: (value) {
              if (label == "Contact") {
                _fetchOwnerInformation(value);
              }
            },
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
        title: const Text('Add House', style: TextStyle(fontSize: 22)), // Center title
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
                      // Fetch owner information using the contact number
                      _fetchOwnerInformation(_contactController.text.trim());
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 11) {
                      return 'Please enter a valid Contact (11 digits).';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(11), // Limit to 11 digits
                  ],
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

                // Row for House No and Road
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _houseNoController,
                        label: 'House No',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(r'^\d{1,4}$').hasMatch(value)) {
                            return 'Please enter a valid House No (max 4 digits).';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16), // Add some spacing between the fields
                    Expanded(
                      child: _buildTextField(
                        controller: _roadController,
                        label: 'Road',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(r'^\d{1,3}$').hasMatch(value)) {
                            return 'Please enter a valid Road (max 3 digits).';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Row for Section and Block
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _sectionController,
                        label: 'Section',
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(r'^\d{1,2}$').hasMatch(value)) {
                            return 'Please enter a valid Section (max 2 digits).';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Allow only digits
                          LengthLimitingTextInputFormatter(2), // Limit to 2 digits
                        ],
                      ),
                    ),


                    const SizedBox(width: 16), // Add some spacing between the fields
                    Expanded(
                      child: _buildTextField(
                        controller: _blockController,
                        label: 'Block',
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length > 2) {
                            return 'Please enter a valid Block (max 2 characters).';
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2), // Limit to 2 characters
                        ],
                      ),
                    ),
                  ],
                ),


                Row(
                  children: [
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return thanaSuggestions.where((thana) =>
                              thana.toLowerCase().contains(textEditingValue.text.toLowerCase())); // Suggest matching thanas
                        },
                        onSelected: (String selection) {
                          _thanaController.text = selection; // Update the controller with the selected thana
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Thana',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                              ),
                              filled: true,
                              fillColor: Colors.black54,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a Thana.';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Colors.white),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')), // Allow only alphabetic characters and spaces
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16), // Add some spacing between the fields
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return divisionSuggestions.where((division) =>
                              division.toLowerCase().contains(textEditingValue.text.toLowerCase())); // Suggest matching divisions
                        },
                        onSelected: (String selection) {
                          _divisionController.text = selection; // Update the controller with the selected division
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Division',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                              ),
                              filled: true,
                              fillColor: Colors.black54,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a Division.';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Colors.white),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')), // Allow only alphabetic characters and spaces
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16), // Add some vertical space between rows

// Row for Area and Zip Code
                Row(
                  children: [
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return areaSuggestions.where((area) =>
                              area.toLowerCase().contains(textEditingValue.text.toLowerCase())); // Suggest matching areas
                        },
                        onSelected: (String selection) {
                          _areaController.text = selection; // Update the controller with the selected area
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Area',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                              ),
                              filled: true,
                              fillColor: Colors.black54,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an Area.';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Colors.white),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')), // Allow only alphabetic characters and spaces
                            ],
                          );
                        },
                      ),
                    ),


                    const SizedBox(width: 16), // Add some spacing between the fields
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return zipCodeSuggestions.where((zip) =>
                              zip.contains(textEditingValue.text)); // Suggest matching zip codes
                        },
                        onSelected: (String selection) {
                          _zipCodeController.text = selection; // Update the controller with the selected zip code
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                          return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              keyboardType: TextInputType.number, // Show numeric keyboard
                              decoration: InputDecoration(
                              labelText: 'Zip Code',
                              labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.black54,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(r'^\d{4}$').hasMatch(value)) {
                          return 'Please enter a valid Zip Code (4 digits).';
                          }
                          return null;
                          },
                          style: const TextStyle(color: Colors.white),
                          inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Allow only digits
                          LengthLimitingTextInputFormatter(4), // Limit to 4 digits
                          ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 16), // Add some vertical space above the button
                      AnimatedButton(
                        onPressed: _saveHouse,
                        text: "Save House Details",
                        buttonColor: Colors.blue,
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
}