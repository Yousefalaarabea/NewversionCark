import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../home/presentation/screens/booking_screens/rental_search_screen.dart';
import 'document_upload_screen.dart';
import '../../widgets/profile_custom_widgets/document_upload_flow.dart' show DocumentType;

class DocumentUploadFlow extends StatefulWidget {
  const DocumentUploadFlow({super.key});

  @override
  State<DocumentUploadFlow> createState() => _DocumentUploadFlowState();
}

class _DocumentUploadFlowState extends State<DocumentUploadFlow> {
  // Only require ID front and back as mandatory
  final List<DocumentType> _documentTypes = [
    DocumentType.idFront,
    DocumentType.idBack,
    DocumentType.driverLicense,
    DocumentType.drugsTest,
    DocumentType.criminalRecord,
    DocumentType.drivingViolations,
    DocumentType.profilePhoto,
    DocumentType.carPhoto,
    DocumentType.carLicense,
    DocumentType.vehicleViolations,
    DocumentType.insurance,
    DocumentType.carTest,
  ];
  int _currentIndex = 0;
  final Map<DocumentType, File> _uploadedDocuments = {};

  void _handleNext(DocumentType type, File file) {
    _uploadedDocuments[type] = file;
    if (_currentIndex < _documentTypes.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // All documents uploaded successfully
      debugPrint('All documents uploaded:');
      for (var entry in _uploadedDocuments.entries) {
        debugPrint('${entry.key.name}: ${entry.value.path}');
      }
      // Navigate or trigger submission logic
    }
  }

  void _skipToRentalSearch(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RentalSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentType = _documentTypes[_currentIndex];
    final isIDStep = _currentIndex == 0 || _currentIndex == 1;
    final isFirstOptional = _currentIndex == 2;

    return Scaffold(
      body: Stack(
        children: [
          DocumentUploadScreen(
            documentType: currentType,
            onNext: _handleNext,
          ),
          if (isFirstOptional)
            Positioned(
              top: 40.h,
              right: 24.w,
              child: TextButton(
                onPressed: () => _skipToRentalSearch(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                child: const Text('Skip Now'),
              ),
            ),
        ],
      ),
    );
  }
}
