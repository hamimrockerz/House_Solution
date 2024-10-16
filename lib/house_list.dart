import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HouseListPage extends StatefulWidget {
  @override
  _HouseListPageState createState() => _HouseListPageState();
}

class _HouseListPageState extends State<HouseListPage> {
  List<Map<String, String>> _houses = [];
  bool _isLoading = true;
  String? _storedContact;

  @override
  void initState() {
    super.initState();
    _fetchStoredContact();
  }

  Future<void> _fetchStoredContact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storedContact = prefs.getString('contact');

    if (_storedContact != null) {
      _fetchHouses();
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stored contact found.')),
      );
    }
  }

  Future<void> _fetchHouses() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      DataSnapshot snapshot = await ref.child('Houses/$_storedContact').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> housesData = snapshot.value as Map<dynamic, dynamic>;

        _houses = housesData.entries.map((entry) {
          return {
            'houseNo': 'House: ${entry.value['houseNo']}', // Format houseNo
            'road': entry.value['road'] as String,
            'block': entry.value['block'] as String,
            'section': entry.value['section'] as String,
            'area': entry.value['area'] as String,
            'zipCode': entry.value['zipCode'] as String,
          };
        }).toList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No houses found for this contact.')),
        );
      }
    } catch (e) {
      print("Error fetching houses: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch houses.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House List'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of cards in a row
            crossAxisSpacing: 8.0, // Spacing between cards
            mainAxisSpacing: 8.0, // Spacing between rows
            childAspectRatio: 0.75, // Adjust to fit your card aspect ratio
          ),
          itemCount: _houses.length,
          itemBuilder: (context, index) {
            return FlipCard(
              houseDetails: _houses[index],
            );
          },
        ),
      ),
    );
  }

}

class FlipCard extends StatefulWidget {
  final Map<String, String> houseDetails;

  FlipCard({required this.houseDetails});

  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _toggleCard({bool flipToBack = false}) {
    if (flipToBack) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFlipped = flipToBack;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _toggleCard(flipToBack: true), // Show back side on hover
      onExit: (_) => _toggleCard(flipToBack: false), // Show front side on exit
      child: GestureDetector(
        onTap: () => _toggleCard(flipToBack: !_isFlipped), // Toggle on tap
        child: Container(
          width: 190,
          height: 254,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.lightGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Front side
              AnimatedOpacity(
                opacity: _isFlipped ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFC1C1).withOpacity(0.7),
                        const Color(0xFFFFA5A5).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.house,
                          size: 40,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.houseDetails['houseNo']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Click for Details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Back side
              AnimatedOpacity(
                opacity: _isFlipped ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.8),
                        Colors.blueAccent.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Details:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Road: ${widget.houseDetails['road']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Block: ${widget.houseDetails['block']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Section: ${widget.houseDetails['section']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Area: ${widget.houseDetails['area']}',
                            style: const TextStyle(color: Colors.white),
                          ),

                          Text(
                            'Zip Code: ${widget.houseDetails['zipCode']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
