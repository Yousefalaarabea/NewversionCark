import 'package:flutter/material.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/features/shared/presentation/screens/navigation_screen.dart';

import 'get_started_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _carAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Animation duration
    );

    // Define the car's movement animation
    _carAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start from the left
      end: const Offset(0.0, 0.0),    // Move to the center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,  // Smooth animation curve
    ));

    // Start the animation
    _controller.forward();

    // Navigate to the next screen after the animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Use PageRouteBuilder for custom animation
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(seconds: 1), // Set duration to 1 second
            // pageBuilder: (context, animation, secondaryAnimation) => MainNavigationScreen(),
            pageBuilder: (context, animation, secondaryAnimation) => const GetStartedScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Slide from right
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120A53), // Updated background color
      body: Stack(
        children: [
          // Car image (animated)
          AnimatedBuilder(
            animation: _carAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _carAnimation.value.dx * MediaQuery.of(context).size.width,
                  _carAnimation.value.dy * MediaQuery.of(context).size.height,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/img/car.png', // Path to your car image
                    width: 100, // Adjust the size of the car
                  ),
                ),
              );
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 290, // Adjust the distance from the bottom
            child: Center(
              child: Image.asset(
                'assets/images/img/text.png', // Path to your logo image
                width: 150, // Adjust the size of the logo
              ),
            ),
          ),
        ],
      ),
    );
  }
}