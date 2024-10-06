import 'package:flutter/material.dart';

import 'package:house_solution/theme/theme.dart';
import 'package:house_solution/widgets/custom_scaffold.dart';
import 'package:house_solution/widgets/welcome_button.dart';

import 'create-account.dart';
import 'login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome Back!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '\nEnter Personal Details To Your House Solution Account',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute evenly
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0), // Add spacing between buttons
                      child: WelcomeButton(
                        buttonText: 'Sign in',
                        onTap: LoginPage(),
                        color: Colors.transparent,
                        textColor: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: const CreateAccountPage(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
