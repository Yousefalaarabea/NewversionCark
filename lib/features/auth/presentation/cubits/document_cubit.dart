import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/text_manager.dart';
import '../widgets/profile_custom_widgets/document_upload_flow.dart';
import 'document_state.dart';


class DocumentCubit extends Cubit<DocumentState> {
  DocumentCubit() : super(DocumentInitial());
  File? selectedFile;

  void uploadDocument(DocumentType type, File file) async {
    emit(DocumentLoading(state.documents));
    try {
      final updatedDocs = Map<DocumentType, File?>.from(state.documents);
      updatedDocs[type] = file;

      // Simulate upload delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Emit success with localized message
      emit(DocumentSuccess(updatedDocs, message: TextManager.uploadSuccess.tr()));
    } catch (e) {
      emit(DocumentFailure(state.documents, TextManager.uploadFailed.tr()));
    }
  }

  void removeDocument(DocumentType type) async {
    emit(DocumentLoading(state.documents));
    try {
      final updatedDocs = Map<DocumentType, File?>.from(state.documents);
      updatedDocs[type] = null;

      await Future.delayed(const Duration(milliseconds: 200));

      // Emit success with localized message
      emit(DocumentSuccess(updatedDocs, message: TextManager.removeSuccess.tr()));
    } catch (e) {
      emit(DocumentFailure(state.documents, e.toString()));
    }
  }


  void resetDocuments() {
    emit(DocumentInitial());
  }

  void pickImage(File file) {
    selectedFile = file;
    emit(DocumentTempSelected(state.documents)); // new state if needed
  }

  void clearSelectedFile() {
    selectedFile = null;
  }
} 