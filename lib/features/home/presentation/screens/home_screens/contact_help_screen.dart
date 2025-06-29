import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactHelpScreen extends StatelessWidget {
  const ContactHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact & Help'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need Help?',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Q: How do I rent a car?\nA: Browse available cars, select your dates, and complete the booking process.\n\nQ: How do I contact support?\nA: Email support@cark.com or call 123-456-7890.\n\nQ: How do I become an owner?\nA: Tap the button below to add your car!',
                      style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              'Email: support@cark.com\nPhone: 123-456-7890',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
            ),

          ],
        ),
      ),
    );
  }
} 