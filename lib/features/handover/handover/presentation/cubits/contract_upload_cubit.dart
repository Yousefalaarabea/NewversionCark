import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'contract_upload_state.dart';

class ContractUploadCubit extends Cubit<ContractUploadState> {
  ContractUploadCubit() : super(ContractUploadInitial());

  final ImagePicker _imagePicker = ImagePicker();
  String? _contractImagePath;

  String? get contractImagePath => _contractImagePath;

  Future<void> pickContractImage({ImageSource source = ImageSource.camera}) async {
    try {
      emit(ContractUploadLoading());
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        _contractImagePath = pickedFile.path;
        emit(ContractUploadSuccess(_contractImagePath!));
      } else {
        emit(ContractUploadFailure('No image selected'));
      }
    } catch (e) {
      emit(ContractUploadFailure('Failed to pick image: ${e.toString()}'));
    }
  }

  Future<void> pickContractImageFromGallery() async {
    await pickContractImage(source: ImageSource.gallery);
  }

  Future<void> takeContractImageFromCamera() async {
    await pickContractImage(source: ImageSource.camera);
  }

  void clearContractImage() {
    _contractImagePath = null;
    emit(ContractUploadInitial());
  }

  bool get hasContractImage => _contractImagePath != null;
} 