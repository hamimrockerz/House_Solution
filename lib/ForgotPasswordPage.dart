import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for input formatters
import 'package:house_solution/widgets/theme_helper.dart';

import 'ForgotPasswordVerificationPage.dart';
import 'login.dart';
import 'widgets/header_widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double headerHeight = 300;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: headerHeight,
              child: HeaderWidget(headerHeight, true, Icons.phone_android), // Changed icon to phone
            ),
            SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Forgot Password?',
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                          SizedBox(height: 10),
                          Center( // Center the text
                            child: Text(
                              'Enter the contact number associated with your account.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),

                          ),


                          SizedBox(height: 10),
                          Text(
                            'We will call or text you a verification code to check your authenticity.',
                            style: TextStyle(
                              color: Colors.black38,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              keyboardType: TextInputType.number, // Only numeric input
                              maxLength: 11, // Maximum of 11 digits
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly // Allow only digits
                              ],
                              decoration: ThemeHelper()
                                  .textInputDecoration("Contact No.", "Enter your contact number")
                                  .copyWith(
                                counterText: '', // Hide the character count
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Contact number can't be empty";
                                } else if (val.length != 11) { // Check for exactly 11 digits
                                  return "Enter a valid contact number with 11 digits";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 25.0),
                          Container(
                            decoration: ThemeHelper().buttonBoxDecoration(context),
                            child: ElevatedButton(
                              style: ThemeHelper().buttonStyle(),
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                child: Text(
                                  "Send".toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const ForgotPasswordVerificationPage()),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Remember your password? ",
                                  style: TextStyle(fontSize: 16), // Increased text size
                                ),
                                TextSpan(
                                  text: 'Login',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const LoginPage()),
                                      );
                                    },
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18 // Increased text size
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
