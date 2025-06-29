import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  String _feedbackType = 'General Feedback';
  final TextEditingController _commentController = TextEditingController();
  final List<String> _feedbackTypes = [
    'General Feedback',
    'Car Condition',
    'Owner/Renter Behavior',
    'Pickup/Drop-off Experience',
    'Payment/Deposit Issues',
    'App/Technical Issues',
  ];
  final _formKey = GlobalKey<FormState>();

  void _submitFeedback() {
    if (_formKey.currentState!.validate() && _rating > 0) {
      // TODO: Send feedback to backend or Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      Navigator.pop(context);
    } else if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rate your experience', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Row(
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(
                    _rating > index ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32.sp,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                )),
              ),
              SizedBox(height: 20.h),
              Text('Feedback Type', style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _feedbackType,
                items: _feedbackTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (val) => setState(() => _feedbackType = val!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 20.h),
              Text('Comments', style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _commentController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tell us about your experience...'
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your feedback.';
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  child: const Text('Submit Feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 