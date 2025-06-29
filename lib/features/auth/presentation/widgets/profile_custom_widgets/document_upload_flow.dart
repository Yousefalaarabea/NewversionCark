// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../home/presentation/screens/booking_screens/rental_search_screen.dart';
// import '../../screens/upload_documents/document_upload_screen.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../cubits/document_cubit.dart';
//
// enum DocumentType {
//   IDFront,
//   IDBack,
//   DriverLicense,
//   DrugsTest,
//   CriminalRecord,
//   DrivingViolations,
//   ProfilePhoto,
//   CarPhoto,
//   CarLicense,
//   VehicleViolations,
//   Insurance,
//   CarTest,
// }
//
// class DocumentUploadFlow extends StatefulWidget {
//   const DocumentUploadFlow({super.key});
//
//   @override
//   State<DocumentUploadFlow> createState() => _DocumentUploadFlowState();
// }
//
// class _DocumentUploadFlowState extends State<DocumentUploadFlow> {
//   // Only require ID front and back as mandatory
//   final List<DocumentType> _documentTypes = [
//     DocumentType.IDFront,
//     DocumentType.IDBack,
//     DocumentType.DriverLicense,
//     DocumentType.DrugsTest,
//     DocumentType.CriminalRecord,
//     DocumentType.DrivingViolations,
//     DocumentType.ProfilePhoto,
//     DocumentType.CarPhoto,
//     DocumentType.CarLicense,
//     DocumentType.VehicleViolations,
//     DocumentType.Insurance,
//     DocumentType.CarTest,
//   ];
//   int _currentIndex = 0;
//
//   void _handleNext(DocumentType type, File file) {
//     if (_currentIndex < _documentTypes.length - 1) {
//       setState(() {
//         _currentIndex++;
//       });
//     } else {
//       // All documents uploaded successfully
//       debugPrint('All documents uploaded (see cubit state)');
//       // Navigate or trigger submission logic
//     }
//   }
//
//   void _skipToRentalSearch(BuildContext context) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const RentalSearchScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentType = _documentTypes[_currentIndex];
//     final isFirstOptional = _currentIndex == 2;
//     return Scaffold(
//       body: Stack(
//         children: [
//           DocumentUploadScreen(
//             documentType: currentType,
//             onNext: _handleNext,
//           ),
//           if (isFirstOptional)
//             Positioned(
//               top: 40.h,
//               right: 24.w,
//               child: TextButton(
//                 onPressed: () => _skipToRentalSearch(context),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                   textStyle: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16.sp,
//                   ),
//                 ),
//                 child: const Text('Skip Now'),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'document_upload_flow_state.dart';
import '../../../../../features/home/presentation/model/car_model.dart';
import '../../../../../features/home/presentation/model/location_model.dart';

///DONE
enum DocumentType {
  idFront,
  idBack,
  driverLicense,
  drugsTest,
  criminalRecord,
  drivingViolations,
  profilePhoto,
  carPhoto,
  carLicense,
  vehicleViolations,
  insurance,
  carTest,
}

class DocumentUploadFlow extends StatefulWidget {
  final bool signupMode;
  const DocumentUploadFlow({super.key, this.signupMode = false});

  @override
  State<DocumentUploadFlow> createState() => DocumentUploadFlowState();
}

