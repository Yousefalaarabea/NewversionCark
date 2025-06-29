import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../../../home/presentation/screens/booking_screens/rental_search_screen.dart';
import '../../screens/upload_documents/document_upload_screen.dart';
import 'document_upload_flow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth_cubit.dart';
import 'package:test_cark/config/routes/screens_name.dart';

///DONE
class DocumentUploadFlowState extends State<DocumentUploadFlow> {
  late final List<DocumentType> _documentTypes;
  int _currentIndex = 0;
  final Map<DocumentType, File?> _uploadedDocs = {for (var type in DocumentType.values) type: null};

  @override
  void initState() {
    super.initState();
    final isSignup = widget.signupMode;
    if (isSignup) {
      // Signup: ID docs first, then rest (optional)
      final idDocs = [DocumentType.idFront, DocumentType.idBack];
      final restDocs = List<DocumentType>.from(DocumentType.values.where((type) => type != DocumentType.idFront && type != DocumentType.idBack));
      _documentTypes = List<DocumentType>.from(idDocs)..addAll(restDocs);
    } else {
      // Booking: Require all except ID (assumed already uploaded)
      _documentTypes = List<DocumentType>.from(DocumentType.values.where((type) => type != DocumentType.idFront && type != DocumentType.idBack));
    }
  }

  void _handleNext(DocumentType type, File file) {
    setState(() {
      _uploadedDocs[type] = file;
      if (_currentIndex < _documentTypes.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _skipToApp() {
    // Go to main app after signup
    Navigator.pushReplacementNamed(context, ScreensName.rentalSearchScreen);
  }

  bool get _allDocumentsUploaded => _documentTypes.every((type) => _uploadedDocs[type] != null);

  void _bookNow() {
    if (_allDocumentsUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed!')),
      );
      // TODO: Trigger actual booking logic here
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload all required documents.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = widget.signupMode;
    final currentType = _documentTypes[_currentIndex];
    final bool isLastStep = _currentIndex == _documentTypes.length - 1;
    final bool showSkip = isSignup && _currentIndex >= 2; // Show skip from doc 3

    return Scaffold(
      body: Stack(
        children: [
          DocumentUploadScreen(
            documentType: currentType,
            onNext: _handleNext,
          ),
          if (showSkip)
            Positioned(
              top: 40.h,
              right: 24.w,
              child: TextButton(
                onPressed: _skipToApp,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                child: Text(TextManager.skipNow.tr()),
              ),
            ),
          if (!isSignup && isLastStep)
            Positioned(
              bottom: 40.h,
              left: 24.w,
              right: 24.w,
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _allDocumentsUploaded ? _bookNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
