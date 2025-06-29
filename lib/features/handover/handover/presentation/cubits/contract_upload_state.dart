part of 'contract_upload_cubit.dart';

@immutable
abstract class ContractUploadState {}

class ContractUploadInitial extends ContractUploadState {}

class ContractUploadLoading extends ContractUploadState {}

class ContractUploadSuccess extends ContractUploadState {
  final String imagePath;
  ContractUploadSuccess(this.imagePath);
}

class ContractUploadFailure extends ContractUploadState {
  final String error;
  ContractUploadFailure(this.error);
} 