import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopBrandsWidget extends StatelessWidget {
  const TopBrandsWidget(
      {super.key, required this.imagePath, required this.name});
// Done
  final String imagePath;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0.001.sw,
      ),

      // Top Brands Container
      child: Column(
        children: [
          // Brand Image
          ClipOval(
            child: Image.asset(
              imagePath,
              width: 0.2.sw,
              height: 0.1.sh,
              fit: BoxFit.scaleDown, // ensures the image fills and fits
            ),
          ),

          // SizedBox(height: 0.01.sh),
          Text(
            name,
            style: TextStyle(
              fontSize: 0.015.sh,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
