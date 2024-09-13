import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create-account.dart'; // Import your create account page here

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loginUser() async {
    String contact = _contactController.text.trim();
    String password = _passwordController.text.trim();

    if (!RegExp(r'^[0-9]+$').hasMatch(contact)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid contact format. Only numbers are allowed.')),
      );
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9!@#$&*~]{1,20}$').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be alphanumeric or special characters, up to 20 characters')),
      );
      return;
    }

    try {
      // Check in owner_information collection
      DatabaseEvent ownerEvent = await _database
          .child('owner_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      // Check in renter_information collection
      DatabaseEvent renterEvent = await _database
          .child('renter_information')
          .orderByChild('contact')
          .equalTo(contact)
          .once();

      if (ownerEvent.snapshot.exists) {
        Map<dynamic, dynamic>? owners =
        ownerEvent.snapshot.value as Map<dynamic, dynamic>?;

        bool ownerFound = false;
        if (owners != null) {
          owners.forEach((key, value) {
            if (value['password'] == password) {
              ownerFound = true;
            }
          });
        }

        if (ownerFound) {
          if (_rememberMe) {
            _saveCredentials(contact, password);
          }
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushNamed(context, '/owner_dashboard'); // Redirect to Owner Dashboard
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid contact or password')),
          );
        }
      } else if (renterEvent.snapshot.exists) {
        Map<dynamic, dynamic>? renters =
        renterEvent.snapshot.value as Map<dynamic, dynamic>?;

        bool renterFound = false;
        if (renters != null) {
          renters.forEach((key, value) {
            if (value['password'] == password) {
              renterFound = true;
            }
          });
        }

        if (renterFound) {
          if (_rememberMe) {
            _saveCredentials(contact, password);
          }
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushNamed(context, '/renter_dashboard'); // Redirect to Renter Dashboard
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid contact or password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid contact or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in: $e')),
      );
    }
  }

  Future<void> _saveCredentials(String contact, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contact', contact);
    await prefs.setString('password', password);
    await prefs.setInt('timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedContact = prefs.getString('contact');
    final savedPassword = prefs.getString('password');
    final savedTimestamp = prefs.getInt('timestamp');

    if (savedContact != null && savedPassword != null) {
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      // Check if credentials are still valid (within 12 hours)
      if (savedTimestamp != null && (currentTimestamp - savedTimestamp) <= 12 * 60 * 60 * 1000) {
        _contactController.text = savedContact;
        _passwordController.text = savedPassword;
        setState(() {
          _rememberMe = true;
        });
      } else {
        await prefs.remove('contact');
        await prefs.remove('password');
        await prefs.remove('timestamp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe0e7ff), // Slightly lighter background color
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: 360, // Width adjusted for the content
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/Screenshot 2024-06-20 225354.png',
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _contactController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blueGrey[50],
                            hintText: 'Contact',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.black),
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blueGrey[50],
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text('Remember Me'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blueAccent, Colors.blue],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // Add space between buttons
                            TextButton(
                              onPressed: () {
                                // Handle forgot password functionality
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateAccountPage(), // Navigate to the Create Account Page
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text("Don't have an account? Create one"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
