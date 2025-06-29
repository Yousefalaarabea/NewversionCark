import 'dart:io';
import '../widgets/profile_custom_widgets/document_upload_flow.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DocumentState {
  final Map<DocumentType, File?> documents;

  const DocumentState(this.documents);
}

class DocumentInitial extends DocumentState {
  DocumentInitial() : super({for (var type in DocumentType.values) type: null});
}

class DocumentLoading extends DocumentState {
  DocumentLoading(Map<DocumentType, File?> documents) : super(documents);
}

class DocumentSuccess extends DocumentState {
  final String message;

  DocumentSuccess(Map<DocumentType, File?> documents, {this.message = ""})
      : super(documents);
}

class DocumentFailure extends DocumentState {
  final String error;

  DocumentFailure(Map<DocumentType, File?> documents, this.error)
      : super(documents);
}

class DocumentTempSelected extends DocumentState {
  DocumentTempSelected(Map<DocumentType, File?> documents)
      : super(documents);
}
