import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../../../home/presentation/widgets/search_widgets/camera_preview_box.dart';
import '../../widgets/documents/document_stepper.dart';
import '../../widgets/documents/dotted_instruction_box.dart';
import '../../widgets/profile_custom_widgets/document_upload_flow.dart';
import '../../cubits/document_cubit.dart';
import '../../cubits/document_state.dart';

///DONE
class DocumentUploadScreen extends StatefulWidget {
  final DocumentType documentType;
  final void Function(DocumentType, File) onNext;

  const DocumentUploadScreen({
    super.key,
    required this.documentType,
    required this.onNext,
  });

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  @override
  void didUpdateWidget(covariant DocumentUploadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentType != widget.documentType) {
      context.read<DocumentCubit>().clearSelectedFile();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final file = File(picked.path);
      context.read<DocumentCubit>().pickImage(file);
    }
  }

  void _uploadDocument(BuildContext context) {
    final selectedFile = context.read<DocumentCubit>().selectedFile;
    if (selectedFile != null) {
      context
          .read<DocumentCubit>()
          .uploadDocument(widget.documentType, selectedFile);
    }
  }

  String _getLabelForType(DocumentType type) {
    switch (type) {
      case DocumentType.idFront:
        return TextManager.idFront.tr();
      case DocumentType.idBack:
        return TextManager.idBack.tr();
      case DocumentType.driverLicense:
        return TextManager.driverLicense.tr();
      case DocumentType.drugsTest:
        return TextManager.drugsTest.tr();
      case DocumentType.criminalRecord:
        return TextManager.criminalRecord.tr();
      case DocumentType.drivingViolations:
        return TextManager.drivingViolations.tr();
      case DocumentType.profilePhoto:
        return TextManager.profilePhoto.tr();
      case DocumentType.carPhoto:
        return TextManager.carPhoto.tr();
      case DocumentType.carLicense:
        return TextManager.carLicense.tr();
      case DocumentType.vehicleViolations:
        return TextManager.vehicleViolations.tr();
      case DocumentType.insurance:
        return TextManager.insurance.tr();
      case DocumentType.carTest:
        return TextManager.carTest.tr();
    }
  }

  String _getInstructionsForType(DocumentType type) {
    switch (type) {
      case DocumentType.idFront:
        return TextManager.instructionIdFront.tr();
      case DocumentType.idBack:
        return TextManager.instructionIdBack.tr();
      case DocumentType.driverLicense:
        return TextManager.instructionDriverLicense.tr();
      case DocumentType.drugsTest:
        return TextManager.instructionDrugsTest.tr();
      case DocumentType.criminalRecord:
        return TextManager.instructionCriminalRecord.tr();
      case DocumentType.drivingViolations:
        return TextManager.instructionDrivingViolations.tr();
      case DocumentType.profilePhoto:
        return TextManager.instructionProfilePhoto.tr();
      case DocumentType.carPhoto:
        return TextManager.instructionCarPhoto.tr();
      case DocumentType.carLicense:
        return TextManager.instructionCarLicense.tr();
      case DocumentType.vehicleViolations:
        return TextManager.instructionVehicleViolations.tr();
      case DocumentType.insurance:
        return TextManager.instructionInsurance.tr();
      case DocumentType.carTest:
        return TextManager.instructionCarTest.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _getLabelForType(widget.documentType);
    final instructions = _getInstructionsForType(widget.documentType);
    final theme = Theme.of(context);
    final documentType = widget.documentType;

    return BlocConsumer<DocumentCubit, DocumentState>(
      listener: (context, state) {
        if (state is DocumentSuccess && state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );

          final uploadedFile = state.documents[documentType];
          // Go to the next step and pass the uploaded file
          if (uploadedFile != null) {
            widget.onNext(documentType, uploadedFile);
          }
        } else if (state is DocumentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },

      builder: (context, state) {
        final file = state.documents[documentType];
        final selectedFile = context.watch<DocumentCubit>().selectedFile;
        final isLoading = state is DocumentLoading;

        return Scaffold(
          backgroundColor: theme.colorScheme.onPrimary,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
            title: Text(
              label,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0.09.sh),

                  // Document Stepper
                  DocumentStepper(
                    totalSteps: DocumentType.values.length,
                    currentStep: DocumentType.values.indexOf(documentType),
                    theme: theme,
                  ),
                  SizedBox(height: 0.07.sh),

                  // Dotted Instruction Box
                  DottedInstructionBox(text: instructions, theme: theme),
                  SizedBox(height: 0.05.sh),

                  // Camera Preview Box
                  CameraPreviewBox(
                    onTap: isLoading ? () {} : _pickImage,
                    imageProvider: selectedFile != null
                        ? FileImage(selectedFile)
                        : (file != null
                            ? FileImage(file)
                            : const AssetImage(AssetsManager.camera)),
                  ),
                  SizedBox(height: 0.2.sh),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 0.07.sh,
                    child: ElevatedButton.icon(
                      icon: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Icon(Icons.upload,
                              color: theme.colorScheme.onPrimary),
                      label: Text(
                        isLoading
                            ? TextManager.uploading.tr()
                            : TextManager.uploadButton.tr(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: (!isLoading && selectedFile != null)
                          ? () => _uploadDocument(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 0.04.sh),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
