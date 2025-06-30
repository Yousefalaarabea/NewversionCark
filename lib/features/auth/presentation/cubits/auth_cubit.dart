import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_service.dart';
import '../../../../core/services/notification_service.dart';
import '../models/user_model.dart';
import 'auth_cubit.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    // Load user data when cubit is created
    loadUserData();
  }

  final ImagePicker imagePicker = ImagePicker();
  final NotificationService _notificationService = NotificationService();
  UserModel? userModel;
  String idImagePath = '';
  String licenceImagePath = '';
  String profileImage = '';

  File? frontIdImage;
  File? backIdImage;

  // Save user data to SharedPreferences
  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'id': user.id,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'email': user.email,
      'phone_number': user.phoneNumber,
      'national_id': user.national_id,
      'role': user.role,
      'fcm_token': user.fcmToken,
    };
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      userModel = UserModel.fromJson(userData);
    }
  }

  // Save FCM token for current user
  Future<void> saveFcmToken() async {
    if (userModel != null) {
      try {
        final fcmToken = await _notificationService.getFcmToken();
        if (fcmToken != null) {
          // Update user model with FCM token
          userModel = userModel!.copyWith(fcmToken: fcmToken);
          
          // Save to SharedPreferences
          await _saveUserData(userModel!);
          
          // Save to Firestore
          await _notificationService.saveFcmTokenToUser(userModel!.id, fcmToken);
          
          print('FCM token saved for user: ${userModel!.id}');
        } else {
          print('Failed to get FCM token for user: ${userModel!.id}');
        }
      } catch (e) {
        print('Error saving FCM token: $e');
        // Don't throw the error to avoid crashing the app
      }
    } else {
      print('User model is null, cannot save FCM token');
    }
  }

  // Enhanced FCM token saving with retry mechanism
  Future<void> saveFcmTokenWithRetry({int maxRetries = 3}) async {
    if (userModel == null) {
      print('User model is null, cannot save FCM token');
      return;
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final fcmToken = await _notificationService.getFcmToken();
        if (fcmToken != null) {
          // Update user model with FCM token
          userModel = userModel!.copyWith(fcmToken: fcmToken);
          
          // Save to SharedPreferences
          await _saveUserData(userModel!);
          
          // Save to Firestore
          await _notificationService.saveFcmTokenToUser(userModel!.id, fcmToken);
          
          print('FCM token saved successfully for user: ${userModel!.id} (attempt $attempt)');
          return; // Success, exit the retry loop
        } else {
          print('Failed to get FCM token for user: ${userModel!.id} (attempt $attempt)');
        }
      } catch (e) {
        print('Error saving FCM token (attempt $attempt): $e');
        if (attempt == maxRetries) {
          print('Failed to save FCM token after $maxRetries attempts');
        } else {
          // Wait before retrying
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      emit(LoginLoading());
      final response =  await ApiService().post("login/", {
        "email" : email,
        "password" : password
      });
      final data = response.data;

      // final userData = data['user']; // أو response.data مباشرة
      // final token = data['token'];

      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);

      // Map to UserModel (بعد ما تضيف fromJson تحت)
      //userModel = UserModel.fromJson(userData);
      //userModel = UserModel.fromJson(response["data"]);

      // Save FCM token after successful login
      await saveFcmToken();

      emit(LoginSuccess("Congrats"));
    }
    catch(error)
    {
      if (error is DioError && error.response != null && error.response?.data is Map<String, dynamic>) {
        emit(LoginFailure(jsonEncode(error.response?.data)));
      } else {
        emit(LoginFailure(error.toString()));
      }
    }
  }

  // Future<void> signup(String firstname, String lastname, String email,
  //     String phone, String password, String id) async {
  //   emit(SignUpLoading());
  //   await Future.delayed(const Duration(seconds: 5), () {
  //     emit(SignUpSuccess("Signup successfully"));
  //   });
  // }

  Future<void> signup(String firstname, String lastname, String email,
    //   String phone, String password, String id) async {
    // emit(SignUpLoading());
    // await Future.delayed(const Duration(seconds: 2));
    // log("firstname: $firstname, lastname: $lastname, email: $email, phone: $phone, password: $password , id : $id");
    // emit(SignUpSuccess("Signup successful"));
   String phone, String password,String national_id) async {
    try {
      emit(SignUpLoading());
      final response = await ApiService().post("register/", {
        "first_name": firstname,
        "last_name": lastname,
        "email": email,
        "phone_number": phone,
        "password": password,
        "national_id": national_id,
      });
      final data = response.data;

      // تأكد إذا كان السيرفر بيرجع التوكن أو بيانات المستخدم
      if (response.statusCode == 201) {

        userModel = UserModel.fromJson(data); //  خزّن بيانات المستخدم
        
        // Save user data to SharedPreferences
        await _saveUserData(userModel!);

        try {
          await login(email: email, password: password);

          // 🟢 إرسال الـ role بعد ما بقى معانا التوكن
          final roleResponse = await ApiService().postWithToken("user-roles/", {
            "user": userModel!.id,
            "role": 1,
          });
          // final roleResponse = await ApiService().post("user-roles/", {
          //   "user": userModel!.id,
          //   "role": 1,
          // });

          if (roleResponse.statusCode == 201 || roleResponse.statusCode == 200) {
            print("User role assigned successfully");
          } else {
            print("Unexpected status while assigning role: ${roleResponse.statusCode}");
          }
        } catch (e) {
          print("Error assigning user role: $e");
        }

        // Save FCM token after successful signup
        await saveFcmToken();

        // هنا ممكن تبدأ عملية رفع الصور بعد نجاح التسجيل
        // await uploadIdImage(...)
        // await uploadLicenceImage(...)

        await Future.delayed(const Duration(seconds: 2));
        emit(SignUpSuccess("Signup successful"));
      }
    } catch (error) {
      if (error is DioError && error.response != null && error.response?.data is Map<String, dynamic>) {
        emit(SignUpFailure(jsonEncode(error.response?.data)));
      } else {
        emit(SignUpFailure(error.toString()));
      }
    }
    log("firstname: $firstname, lastname: $lastname, email: $email, phone: $phone, password: $password , id : $national_id");

    //log("firstname: $firstname, lastname: $lastname, email: $email, phone: $phone, password: $password");
  }

  Future<void> uploadIdImage({required bool isFront}) async {
    emit(UploadIdImageLoading());
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (isFront) {
        frontIdImage = File(pickedFile.path);
      } else {
        backIdImage = File(pickedFile.path);
      }
      emit(UploadIdImageSuccess());
    } else {
      emit(UploadIdImageFailure("No image selected"));
    }
  }

  Future<void> uploadLicenceImage() async {
    emit(UploadLicenceImageLoading());
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      licenceImagePath = pickedFile.path;
      emit(UploadLicenceImageSuccess());
    } else {
      if (licenceImagePath.isEmpty) {
        emit(UploadLicenceImageFailure("No image selected"));
      } else {
        emit(UploadLicenceImageSuccess());
      }
    }
  }

  Future<void> editProfile(
      {required String firstname,
      required String lastname,
      required String email,
      required String phoneNumber,
      required String national_id}) async {
    emit(EditProfileLoading());
    await Future.delayed(const Duration(seconds: 2), () async {
      userModel = UserModel(
        id: userModel?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: firstname,
        lastName: lastname,
        email: email,
        phoneNumber: phoneNumber,
        national_id: national_id,
        role: userModel?.role ?? 'renter',
      );
      
      // Save updated user data to SharedPreferences
      await _saveUserData(userModel!);
      
      emit(EditProfileSuccess("Profile updated successfully"));
    });
  }

  Future<void> uploadProfileImage() async {
    emit(UploadProfileScreenImageLoading());
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      profileImage = pickedFile.path;
      emit(UploadProfileScreenImageSuccess());
    } else {
      if (profileImage.isEmpty) {
        emit(UploadProfileScreenImageFailure("No image selected"));
      } else {
        emit(UploadProfileScreenImageSuccess());
      }
    }
  }

  // Toggle user role between renter and owner
  void toggleRole() {
    // This is a simple implementation - you might want to store role in UserModel
    // For now, we'll just emit a state change
    emit(AuthInitial());
  }

  // Switch to owner mode and navigate to add car
  Future<void> switchToOwner() async {
    if (userModel != null) {
      // Update user role to owner
      userModel = userModel!.copyWith(role: 'owner');
      
      // Save updated user data to SharedPreferences
      await _saveUserData(userModel!);
      
      emit(AuthInitial());
    }
  }

  // Switch back to renter mode
  Future<void> switchToRenter() async {
    if (userModel != null) {
      // Update user role to renter
      userModel = userModel!.copyWith(role: 'renter');
      
      // Save updated user data to SharedPreferences
      await _saveUserData(userModel!);
      
      emit(AuthInitial());
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    userModel = null;
    emit(AuthInitial());
  }


  Future<int?> fetchLatestUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null) {
        print('No access token found');
        return null;
      }

      final userId = userModel?.id;
      if (userId == null) {
        print('No user ID available');
        return null;
      }

      final response = await ApiService().getWithToken(
        'user-roles/',
        accessToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> rolesList = response.data;

        // Filter user roles by current user
        final userRoles = rolesList
            .where((role) => role['user'] == userId)
            .toList();

        if (userRoles.isNotEmpty) {
          final latest = userRoles.last;
          print('Latest role for user $userId is ${latest['role']}');
          return latest['role'];
        } else {
          print('No role found for user $userId');
          return null;
        }
      } else {
        print('Error fetching roles: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in fetchLatestUserRole: $e');
      return null;
    }
  }



}


//
// Future<int?> fetchLatestUserRole() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');
//
//     final response = await ApiService().getWithToken(
//       "user-roles/",
//       token: accessToken,
//     );
//
//     if (response.statusCode == 200 && response.data is List) {
//       final roles = response.data;
//       if (roles.isNotEmpty) {
//         roles.sort((a, b) => b['id'].compareTo(a['id'])); // Sort by latest
//         return roles.first['role'];
//       }
//     }
//   } catch (e) {
//     print("Error fetching role: $e");
//   }
//
//   return null; // default fallback
// }
