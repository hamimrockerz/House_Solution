import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color buttonColor; // Add a member variable for buttonColor

  const AnimatedButton({
    required this.onPressed,
    required this.text,
    required this.buttonColor, // Marking as required
    super.key,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 26.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.buttonColor, width: 2), // Use buttonColor
          boxShadow: [
            BoxShadow(
              color: widget.buttonColor.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ButtonBorderPainter(_animation.value, widget.buttonColor), // Pass buttonColor
                    );
                  },
                ),
              ),
              Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.buttonColor, // Use buttonColor
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

class _ButtonBorderPainter extends CustomPainter {
  final double progress;
  final Color buttonColor; // Add a member variable for buttonColor

  _ButtonBorderPainter(this.progress, this.buttonColor); // Add buttonColor to the constructor

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = buttonColor // Use buttonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double width = size.width;
    final double height = size.height;

    const double borderWidth = 2;
    final double animatedWidth = width * progress;

    paint.shader = const LinearGradient(
      colors: [Colors.greenAccent, Colors.transparent],
      stops: [0.0, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, animatedWidth, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
