import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    this.buttonText,
    required this.onTap,
    this.color,
    this.textColor,
  });

  final String? buttonText;
  final Widget onTap; // Made required
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (e) => onTap,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0), // Adjust vertical padding
        decoration: BoxDecoration(
          color: color ?? Colors.grey, // Default color if null
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
          ),
        ),
        constraints: const BoxConstraints(
          minHeight: 63.5, // Ensure minimum height for the button
        ),
        child: Text(
          buttonText ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.black, // Default text color if null
          ),
        ),
      ),
    );
  }
}
