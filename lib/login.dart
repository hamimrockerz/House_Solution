import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:house_solution/theme/theme.dart';
import 'package:house_solution/widgets/custom_scaffold.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create-account.dart';
import 'ForgotPasswordPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formSignInKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool rememberPassword = false;
  late String contact;
  late String password;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loginUser() async {
    contact = _contactController.text.trim();
    password = _passwordController.text.trim();

    if (_formSignInKey.currentState!.validate()) {
      try {
        DatabaseEvent ownerEvent = await _database
            .child('owner_information')
            .orderByChild('contact')
            .equalTo(contact)
            .once();

        DatabaseEvent renterEvent = await _database
            .child('renter_information')
            .orderByChild('contact')
            .equalTo(contact)
            .once();

        bool ownerSuccess = false;
        bool renterSuccess = false;

        if (ownerEvent.snapshot.exists) {
          Map<dynamic, dynamic>? owners = ownerEvent.snapshot.value as Map<dynamic, dynamic>?;

          if (owners != null) {
            owners.forEach((key, value) {
              if (value['password'] == password) {
                ownerSuccess = true;
              }
            });
          }
        }

        if (renterEvent.snapshot.exists) {
          Map<dynamic, dynamic>? renters = renterEvent.snapshot.value as Map<dynamic, dynamic>?;

          if (renters != null) {
            renters.forEach((key, value) {
              if (value['password'] == password) {
                renterSuccess = true;
              }
            });
          }
        }

        if (ownerSuccess) {
          _handleSuccessfulLogin('/owner_dashboard');
        } else if (renterSuccess) {
          _handleSuccessfulLogin('/renter_dashboard');
        } else {
          _showLoginError();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging in: $e')),
        );
      }
    }
  }

  Future<void> _handleSuccessfulLogin(String route) async {
    if (rememberPassword) {
      _saveCredentials(contact, password);
    }
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushNamed(context, route);
  }

  void _showLoginError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid contact or password')),
    );
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
      if (savedTimestamp != null && (currentTimestamp - savedTimestamp) <= 12 * 60 * 60 * 1000) {
        _contactController.text = savedContact;
        _passwordController.text = savedPassword;
        setState(() {
          rememberPassword = true;
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
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 22.0),
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 28.0),
                      TextFormField(
                        controller: _contactController,
                        maxLength: 11, // Set maximum length to 11
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact';
                          } else if (value.length != 11) {
                            return 'Contact must be 11 digits';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Only allow digits
                        ],
                        decoration: InputDecoration(
                          label: const Text('Contact'),
                          hintText: 'Please Enter Your Contact Number',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          counterText: '', // Hide character count
                        ),
                      ),
                      const SizedBox(height: 28.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Your Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black26,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          counterText: '', // Hide character count
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Text(
                              'Forget password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loginUser,
                          child: const Text('Sign in'),
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Text(
                              'Sign in with',
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Logo(Logos.facebook_f),
                          Logo(Logos.whatsapp),
                          Logo(Logos.google),
                          Logo(Logos.apple),
                        ],
                      ),
                      const SizedBox(height: 28.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 16.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (e) => const CreateAccountPage()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
