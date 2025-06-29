import 'package:flutter/material.dart';

class CameraPreviewBox extends StatelessWidget {
  final VoidCallback onTap;
  final ImageProvider imageProvider;

  const CameraPreviewBox({
    super.key,
    required this.onTap,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight* 0.3,
        width:  double.maxFinite,
        margin: EdgeInsets.symmetric(vertical: screenHeight* 0.03),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
