import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_service.dart';
import '../models/user_model.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    // Load user data when cubit is created
    print('AuthCubit initialized, loading user data...');
    // loadUserData();
    
    // Initialize admin login in background
    _initializeAdminLogin();
  }

  // Initialize admin login in background
  Future<void> _initializeAdminLogin() async {
    try {
      print('Initializing admin login in background...');
      await _performAdminLogin();
    } catch (e) {
      print('Error initializing admin login: $e');
    }
  }

  final ImagePicker imagePicker = ImagePicker();
  UserModel? userModel;
  String idImagePath = '';
  String licenceImagePath = '';
  String profileImage = '';

  File? frontIdImage;
  File? backIdImage;

  // Getter for userModel with null check
  UserModel? get currentUser => userModel;

  // Save user data to SharedPreferences
  Future<void> _saveUserData(UserModel user) async {
    try {
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
      final userDataString = jsonEncode(userData);
      await prefs.setString('user_data', userDataString);
      await prefs.setString('user_id', user.id.toString());
      print('User data saved to SharedPreferences: ${user.firstName} ${user.lastName}');
      print('Saved user data string: $userDataString');
    } catch (e) {
      print('Error saving user data to SharedPreferences: $e');
    }
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    try {
      print('Loading user data from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final accessToken = prefs.getString('access_token');
      
      if (userDataString != null) {
        print('User data string found: $userDataString');
        final userData = jsonDecode(userDataString);
        print('Decoded user data: $userData');
        userModel = UserModel.fromJson(userData);
        print('User data loaded successfully: ${userModel?.firstName} ${userModel?.lastName}');
        print('Loaded user ID: ${userModel?.id}');
        print('User model is null: ${userModel == null}');
      } else if (accessToken != null) {
        // If we have access token but no user data, try to fetch from server
        print('No user data in SharedPreferences, but access token found. Fetching from server...');
        try {
          final userResponse = await ApiService().getWithToken('user/profile/', accessToken);
          if (userResponse.statusCode == 200) {
            userModel = UserModel.fromJson(userResponse.data);
            await _saveUserData(userModel!);
            print('User data fetched from server and saved to SharedPreferences');
          } else {
            print('Failed to fetch user data from server: ${userResponse.statusCode}');
            userModel = null;
          }
        } catch (e) {
          print('Error fetching user data from server: $e');
          userModel = null;
        }
      } else {
        print('No user data or access token found in SharedPreferences');
        userModel = null;
      }
    } catch (e) {
      print('Error loading user data: $e');
      userModel = null;
    }
  }



  // Admin login for background operations
  Future<String?> _performAdminLogin() async {
    try {
      print('Performing background admin login...');
      final adminResponse = await ApiService().post("login/", {
        "email": "admin@gmail.com",
        "password": "admin123"
      });
      
      if (adminResponse.statusCode == 200) {
        final adminAccessToken = adminResponse.data['access'];
        final adminRefreshToken = adminResponse.data['refresh'];
        
        // Save admin tokens separately
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_access_token', adminAccessToken);
        await prefs.setString('admin_refresh_token', adminRefreshToken);
        
        print('Admin login successful, tokens saved');
        return adminAccessToken;
      }
    } catch (e) {
      print('Admin login failed: $e');
    }
    return null;
  }

  // Extract user ID from JWT token
  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1];
      // Add base64 padding if needed
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        case 0:
          break;
        default:
          return null; // Invalid base64
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final payloadMap = jsonDecode(decoded);
      return payloadMap['user_id']?.toString();
    } catch (e) {
      print('Error extracting user ID from token: $e');
      return null;
    }
  }

  // Refresh admin token if expired
  Future<String?> _refreshAdminToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminRefreshToken = prefs.getString('admin_refresh_token');
      
      if (adminRefreshToken != null) {
        print('Refreshing admin token...');
        final refreshResponse = await ApiService().post("token/refresh/", {
          "refresh": adminRefreshToken
        });
        
        if (refreshResponse.statusCode == 200) {
          final newAdminAccessToken = refreshResponse.data['access'];
          await prefs.setString('admin_access_token', newAdminAccessToken);
          print('Admin token refreshed successfully');
          return newAdminAccessToken;
        }
      }
    } catch (e) {
      print('Error refreshing admin token: $e');
    }
    
    // If refresh failed, try to login again
    return await _performAdminLogin();
  }

  Future<void> login({required String email, required String password}) async {
    try {
      emit(LoginLoading());
      
      // First, perform admin login in background to get admin token
      final adminToken = await _performAdminLogin();
      
      // Now perform user login
      final response = await ApiService().post("login/", {
        "email": email,
        "password": password
      });
      final data = response.data;

      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);

      // Use admin token to fetch user data from server
      if (adminToken != null) {
        try {
          print('Fetching user data using admin token...');
          // Extract user ID from the access token
          final userId = _extractUserIdFromToken(accessToken);
          
          if (userId != null) {
            print('Extracted user ID from token: $userId');
            // Try to get user data from users endpoint
            final userResponse = await ApiService().getWithAdminToken('users/$userId/');
            if (userResponse.statusCode == 200) {
              userModel = UserModel.fromJson(userResponse.data);
              // Save user data to SharedPreferences
              await _saveUserData(userModel!);
              print('Fetched user data from server using admin token and saved to SharedPreferences');
            } else {
              print('Failed to fetch user data with admin token, status: ${userResponse.statusCode}');
              // Create minimal user model with available data
              userModel = UserModel(
                id: userId,
                firstName: '',
                lastName: '',
                email: email,
                phoneNumber: '',
                national_id: '',
                role: 'renter',
              );
              await _saveUserData(userModel!);
              print('Created minimal user model due to server error');
            }
          } else {
            print('Could not extract user ID from token');
          }
        } catch (e) {
          print('Error fetching user data with admin token: $e');
        }
      } else {
        // If admin login failed, try with user token
        try {
          // Extract user ID from the access token
          final userId = _extractUserIdFromToken(accessToken);
          
          if (userId != null) {
            print('Extracted user ID from token: $userId');
            // Try to get user data from users endpoint
            final userResponse = await ApiService().getWithToken('users/$userId/', accessToken);
            if (userResponse.statusCode == 200) {
              userModel = UserModel.fromJson(userResponse.data);
              await _saveUserData(userModel!);
              print('Fetched user data from server using user token and saved to SharedPreferences');
            } else {
              print('Failed to fetch user data with user token, status: ${userResponse.statusCode}');
            }
          } else {
            print('Could not extract user ID from token');
          }
        } catch (e) {
          print('Error fetching user data with user token: $e');
        }
      }

      print('User logged in successfully: ${userModel!.firstName} ${userModel!.lastName}');
      print('User ID: ${userModel!.id}');
      print('User email: ${userModel!.email}');
      print('User model is null after login: ${userModel == null}');

      emit(LoginSuccess("Congrats"));
    } catch (error) {
      print('Login error: $error');
      emit(LoginFailure("Error"));
    }
  }


  Future<void> signup(String firstname, String lastname, String email,

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

        print('User signed up successfully: ${userModel!.firstName} ${userModel!.lastName}');
        print('User ID: ${userModel!.id}');
        print('User email: ${userModel!.email}');

        try {
          // Get tokens for the newly created user
          final loginResponse = await ApiService().post("login/", {
            "email": email,
            "password": password
          });
          
          final accessToken = loginResponse.data['access'];
          final refreshToken = loginResponse.data['refresh'];

          // Save tokens to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('refresh_token', refreshToken);

          // 🟢 إرسال الـ role بعد ما بقى معانا التوكن - استخدام admin token
          try {
            final roleResponse = await ApiService().postWithAdminToken("user-roles/", {
              "user": userModel!.id,
              "role": 1,
            });

            if (roleResponse.statusCode == 201 || roleResponse.statusCode == 200) {
              print("User role assigned successfully using admin token");
            } else {
              print("Unexpected status while assigning role: ${roleResponse.statusCode}");
            }
          } catch (e) {
            print("Error assigning user role with admin token: $e");
            // Fallback to user token
            try {
              final roleResponse = await ApiService().postWithToken("user-roles/", {
                "user": userModel!.id,
                "role": 1,
              });

              if (roleResponse.statusCode == 201 || roleResponse.statusCode == 200) {
                print("User role assigned successfully using user token");
              } else {
                print("Unexpected status while assigning role: ${roleResponse.statusCode}");
              }
            } catch (e2) {
              print("Error assigning user role with user token: $e2");
            }
          }
        } catch (e) {
          print("Error assigning user role: $e");
        }



        // هنا ممكن تبدأ عملية رفع الصور بعد نجاح التسجيل
        // await uploadIdImage(...)
        // await uploadLicenceImage(...)

        await Future.delayed(const Duration(seconds: 2));
        emit(SignUpSuccess("Signup successful"));
      }
    }catch(e){
      emit(SignUpFailure("Something went wrong. Please try again."));
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
      // userModel = userModel!.copyWith(role: 'owner');

      // Save updated user data to SharedPreferences
      await _saveUserData(userModel!);

      emit(AuthInitial());
    }
  }

  // Switch back to renter mode
  Future<void> switchToRenter() async {
    if (userModel != null) {
      // Update user role to renter
      // userModel = userModel!.copyWith(role: 'renter');

      // Save updated user data to SharedPreferences
      await _saveUserData(userModel!);

      emit(AuthInitial());
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('admin_access_token');
      await prefs.remove('admin_refresh_token');
      await prefs.remove('user_id');
      userModel = null;
      print('User logged out successfully (including admin tokens)');
      emit(AuthInitial());
    } catch (e) {
      print('Error during logout: $e');
      emit(AuthInitial());
    }
  }

  // Fetch user data from server and update SharedPreferences
  Future<void> fetchUserDataFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('admin_access_token');
      
      if (adminToken != null) {
        // Try with admin token first
        final userId = userModel!.id;
        try {
          print('Fetching user data from server using admin token...');
          final userResponse = await ApiService().getWithAdminToken('users/$userId');
          
          if (userResponse.statusCode == 200) {
            userModel = UserModel.fromJson(userResponse.data);
            await _saveUserData(userModel!);
            print('User data updated from server successfully using admin token');
            return;
          } else {
            print('Failed to fetch user data with admin token: ${userResponse.statusCode}');
          }
        } catch (e) {
          print('Error fetching user data with admin token: $e');
        }
      }
      
      // Fallback to user token if admin token fails
      final accessToken = prefs.getString('access_token');
      if (accessToken != null) {
        print('Fetching user data from server using user token...');
        final userResponse = await ApiService().getWithToken('user/profile/', accessToken);
        
        if (userResponse.statusCode == 200) {
          userModel = UserModel.fromJson(userResponse.data);
          await _saveUserData(userModel!);
          print('User data updated from server successfully using user token');
        } else {
          print('Failed to fetch user data with user token: ${userResponse.statusCode}');
        }
      } else {
        print('No access token available to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data from server: $e');
    }
  }


  Future<int?> fetchLatestUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('admin_access_token');
      final accessToken = prefs.getString('access_token');
      
      final userId = userModel?.id;
      if (userId == null) {
        print('No user ID available');
        return null;
      }

      // Try with admin token first
      if (adminToken != null) {
        try {
          final response = await ApiService().getWithAdminToken('user-roles/');

          if (response.statusCode == 200) {
            final List<dynamic> rolesList = response.data;

            // Filter user roles by current user
            final userRoles = rolesList
                .where((role) => role['user'] == userId)
                .toList();

            if (userRoles.isNotEmpty) {
              final latest = userRoles.last;
              print('Latest role for user $userId is ${latest['role']} (using admin token)');
              return latest['role'];
            } else {
              print('No role found for user $userId (using admin token)');
            }
          } else {
            print('Error fetching roles with admin token: ${response.statusCode}');
          }
        } catch (e) {
          print('Error fetching roles with admin token: $e');
        }
      }

      // Fallback to user token
      if (accessToken != null) {
        try {
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
              print('Latest role for user $userId is ${latest['role']} (using user token)');
              return latest['role'];
            } else {
              print('No role found for user $userId (using user token)');
            }
          } else {
            print('Error fetching roles with user token: ${response.statusCode}');
          }
        } catch (e) {
          print('Error fetching roles with user token: $e');
        }
      }

      print('No access token found');
      return null;
    } catch (e) {
      print('Error in fetchLatestUserRole: $e');
      return null;
    }
  }

}


