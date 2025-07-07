part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

// Login States
class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final String message;
  LoginSuccess(this.message);
}

class LoginFailure extends AuthState {
  final String error;
  LoginFailure(this.error);
}

// Sign Up States
class SignUpLoading extends AuthState {}

class SignUpSuccess extends AuthState {
  final String message;
  SignUpSuccess(this.message);
}

class SignUpFailure extends AuthState {
  final String error;
  SignUpFailure(this.error);
}

// Image Uploading States
class UploadIdImageLoading extends AuthState {}

class UploadIdImageSuccess extends AuthState {
  UploadIdImageSuccess();
}

class UploadIdImageFailure extends AuthState {
  final String error;
  UploadIdImageFailure(this.error);
}

// Licence Image Uploading States
class UploadLicenceImageLoading extends AuthState {}

class UploadLicenceImageSuccess extends AuthState {
  UploadLicenceImageSuccess();
}

class UploadLicenceImageFailure extends AuthState {
  final String error;
  UploadLicenceImageFailure(this.error);
}

// Profile Image Uploading States

class UploadProfileScreenImageLoading extends AuthState {}

class UploadProfileScreenImageSuccess extends AuthState {
  UploadProfileScreenImageSuccess();
}

class UploadProfileScreenImageFailure extends AuthState {
  final String error;
  UploadProfileScreenImageFailure(this.error);
}

// Edit Profile States
class EditProfileLoading extends AuthState {}

class EditProfileSuccess extends AuthState {
  final String message;
  EditProfileSuccess(this.message);
}

class EditProfileFailure extends AuthState {
  final String error;
  EditProfileFailure(this.error);
}

// Update Profile States
class UpdateProfileLoading extends AuthState {}
class UpdateProfileSuccess extends AuthState {
  final String message;
  UpdateProfileSuccess(this.message);
}
class UpdateProfileFailure extends AuthState {
  final String message;
  UpdateProfileFailure(this.message);
}
