import 'package:flutter/material.dart';
import 'package:test_cark/core/utils/assets_manager.dart';

import '../../../auth/presentation/screens/login/login_screen.dart';

/// clean
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF05011F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF120A53).withOpacity(0.3),
                    BlendMode.modulate,
                  ),
                  child: Image.asset(AssetsManager.map,
                      //'assets/images/img/map2.png'
                      width: screenWidth),
                ),
                Column(
                  children: [
                    Text(
                      'CAR',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: screenWidth * 0.15,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.002),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.15),
                      child: Text(
                        'RENTAL',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
            Text(
              'NEED',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w200,
                fontSize: screenWidth * 0.08,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'A CAR ?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: screenWidth * 0.09,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Image.asset(
              AssetsManager.car,
              // 'assets/images/img/car.png',
              width: screenWidth * 0.5,
            ),
            SizedBox(height: screenHeight * 0.08),
            Container(
              width: screenWidth * 0.7,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(seconds: 1),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          LoginScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutQuad;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF120A53),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF120A53),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
