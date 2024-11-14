import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHousePage extends StatefulWidget {
  const SearchHousePage({super.key});

  @override
  _SearchHousePageState createState() => _SearchHousePageState();
}

class _SearchHousePageState extends State<SearchHousePage> {
  String _userName = 'User'; // Default user name
  String? _profileImageUrl; // Variable to hold the profile image URL
  String? _selectedSortOption; // Variable to store the selected sort option
  String? _selectedLocationOption; // Variable to store the selected location option
  bool _showSortOptions = false; // Track the visibility of sort options
  bool _showLocationOptions = false; // Track the visibility of location options

  TextEditingController _divisionController = TextEditingController();
  TextEditingController _districtController = TextEditingController();
  TextEditingController _areaController = TextEditingController();

  // Options for sorting
  final List<String> _sortOptions = [
    'Newest',
    'Price (low to high)',
    'Price (high to low)',
  ];

  // Sample suggestions for locations (Division, District, Area)
  final List<String> _divisionSuggestions = [
    'Dhaka',
    'Chattogram (Chittagong)',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  final List<String> _areaSuggestions = [
    // Add all the area suggestions here
    'Adabor', 'Agargaon', 'Ajimpur', 'Aminbazar', 'Ashkona', // ... and so on
  ];

  final List<String> _districtSuggestions = [
    'Bagerhat',
    'Bandarban',
    'Brahmanbaria',
    'Chandpur',
    'Chattogram',
    'Chuadanga',
    'Cox\'s Bazar',
    'Dhaka',
    'Dinajpur',
    'Faridpur',
    'Feni',
    'Gaibandha',
    'Gazipur',
    'Gopalganj',
    'Habiganj',
    'Jamalkati',
    'Jamalpur',
    'Jashore',
    'Jhalokati',
    'Jhenaidah',
    'Joypurhat',
    'Khagrachari',
    'Khulna',
    'Kishoreganj',
    'Kurigram',
    'Kushtia',
    'Lakshmipur',
    'Lalmonirhat',
    'Madaripur',
    'Magura',
    'Manikganj',
    'Meherpur',
    'Moulvibazar',
    'Munshiganj',
    'Mymensingh',
    'Naogaon',
    'Narail',
    'Narsingdi',
    'Natore',
    'Netrokona',
    'Nilphamari',
    'Nawabganj',
    'Netrakona',
    'Pabna',
    'Panchagarh',
    'Patuakhali',
    'Pirojpur',
    'Rajbari',
    'Rajshahi',
    'Rangamati',
    'Rangpur',
    'Satkhira',
    'Shariatpur',
    'Sherpur',
    'Sirajganj',
    'Sunamganj',
    'Sylhet',
    'Tangail',
  ];


  List<String> _filteredDivisionSuggestions = [];
  List<String> _filteredDistrictSuggestions = [];
  List<String> _filteredAreaSuggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _loadProfileImage();
  }

  Future<void> _fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');

    if (name != null) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('profileImage');
    });
  }

  void _filterSuggestions() {
    setState(() {
      _filteredDivisionSuggestions = _divisionSuggestions
          .where((division) => division.toLowerCase().contains(_divisionController.text.toLowerCase()))
          .toList();

      _filteredDistrictSuggestions = _districtSuggestions // Modify this as needed
          .where((district) => district.toLowerCase().contains(_districtController.text.toLowerCase()))
          .toList();

      _filteredAreaSuggestions = _areaSuggestions
          .where((area) => area.toLowerCase().contains(_areaController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text(
          'Search House',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF40444B),
      ),
      body: Container(
        color: const Color(0xFF2C2F33),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildFilterButtons(), // Add filter buttons
            const SizedBox(height: 20), // Space below the filter buttons
            if (_showSortOptions) _buildSortOptions(), // Show sort options if toggled
            if (_showLocationOptions) _buildLocationOptions(), // Show location options if toggled
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSortByButton(), // Sort By button with dropdown
        _buildLocationButton(), // Location button with dropdown
        _buildFilterButton('Filter', Icons.filter_list),
      ],
    );
  }

  Widget _buildSortByButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showSortOptions = !_showSortOptions; // Toggle sort options visibility
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF40444B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              _selectedSortOption ?? 'Sort By',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Visibility(
      visible: _showSortOptions, // Show sort options based on visibility
      child: Container(
        padding: const EdgeInsets.all(10),
        color: const Color(0xFF40444B),
        child: Column(
          children: _sortOptions.map((option) {
            return ListTile(
              title: Text(option, style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _selectedSortOption = option; // Update selected option
                  _showSortOptions = false; // Hide sort options
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showLocationOptions = !_showLocationOptions; // Toggle location options visibility
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF40444B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              _selectedLocationOption ?? 'Location',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOptions() {
    return Visibility(
      visible: _showLocationOptions,
      child: Container(
        padding: const EdgeInsets.all(10),
        color: const Color(0xFF40444B),
        child: Column(
          children: [
            TextField(
              controller: _divisionController,
              decoration: const InputDecoration(
                hintText: 'Enter Division',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                _filterSuggestions(); // Call filter method
              },
            ),
            _buildSuggestionList(_filteredDivisionSuggestions, _divisionController),
            const SizedBox(height: 10),
            TextField(
              controller: _districtController,
              decoration: const InputDecoration(
                hintText: 'Enter District',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                _filterSuggestions(); // Call filter method
              },
            ),
            _buildSuggestionList(_filteredDistrictSuggestions, _districtController),
            const SizedBox(height: 10),
            TextField(
              controller: _areaController,
              decoration: const InputDecoration(
                hintText: 'Enter Area',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                _filterSuggestions(); // Call filter method
              },
            ),
            _buildSuggestionList(_filteredAreaSuggestions, _areaController),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle the input here
                String division = _divisionController.text;
                String district = _districtController.text;
                String area = _areaController.text;

                // Process the input as needed, e.g., storing or filtering
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // Create a widget for displaying the suggestion list
  Widget _buildSuggestionList(List<String> suggestions, TextEditingController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            suggestions[index],
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            controller.text = suggestions[index]; // Update text field with selected suggestion
            setState(() {
              _filteredDivisionSuggestions.clear();
              _filteredDistrictSuggestions.clear();
              _filteredAreaSuggestions.clear(); // Clear suggestions
            });
          },
        );
      },
    );
  }

  Widget _buildFilterButton(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Add filter button action here
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF40444B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2C2F33),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(_profileImageUrl!),
                  onBackgroundImageError: (_, __) => const Icon(Icons.error),
                )
                    : const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/default_avatar.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hello, $_userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text('Exit', style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.of(context).pop();
              await _showExitConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF40444B),
          title: const Text('Exit Confirmation', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to exit?', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Exit', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login page
              },
            ),
          ],
        );
      },
    );
  }
}
