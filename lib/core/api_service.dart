import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;


  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
   ///     baseUrl: 'https://cark-f3fjembga0f6btek.uaenorth-01.azurewebsites.net/api/',
        baseUrl: 'https://tight-probe-galaxy-criteria.trycloudflare.com/api/',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // ✅ إضافة Pretty Dio Logger
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      compact: true,
      maxWidth: 90,
    ));

    // _dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) async {
    //     final prefs = await SharedPreferences.getInstance();
    //     final token = prefs.getString('access_token');
    //
    //     if (token != null) {
    //       options.headers['Authorization'] = 'Bearer $token';
    //     }
    //
    //     return handler.next(options);
    //   },
    //   onError: (error, handler) {
    //     // تقدر تعالج هنا مثلاً لو حصل Unauthorized
    //     return handler.next(error);
    //   },
    //   onResponse: (response, handler) {
    //     return handler.next(response);
    //   },
    // ));
  }


  Future<Response> postWithToken(String endpoint, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patchWithToken(String endpoint, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteWithToken(String endpoint, String token) async {
    final dio = Dio();
    final response = await dio.delete(
      '${_dio.options.baseUrl}$endpoint',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    return response;
  }

  Future<Response> getWithToken(String endpoint, String token) async {
    final dio = Dio();
    final response = await dio.get(
      '${_dio.options.baseUrl}$endpoint',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    return response;
  }

  // Get with admin token for operations that need admin privileges
  Future<Response> getWithAdminToken(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    String? adminToken = prefs.getString('admin_access_token');
    
    if (adminToken == null) {
      throw Exception('Admin token not found. Please login as admin first.');
    }
    
    try {
      final dio = Dio();
      final response = await dio.get(
        '${_dio.options.baseUrl}$endpoint',
        options: Options(
          headers: {
            'Authorization': 'Bearer $adminToken',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      // If token is expired, try to refresh it
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('Admin token expired, attempting to refresh...');
        // Note: You might want to implement token refresh logic here
        // For now, we'll just rethrow the error
      }
      rethrow;
    }
  }

  // Post with admin token for operations that need admin privileges
  Future<Response> postWithAdminToken(String endpoint, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final adminToken = prefs.getString('admin_access_token');
    
    if (adminToken == null) {
      throw Exception('Admin token not found. Please login as admin first.');
    }
    
    final dio = Dio();
    final response = await dio.post(
      '${_dio.options.baseUrl}$endpoint',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  }

  // Patch with admin token for operations that need admin privileges
  Future<Response> patchWithAdminToken(String endpoint, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final adminToken = prefs.getString('admin_access_token');
    
    if (adminToken == null) {
      throw Exception('Admin token not found. Please login as admin first.');
    }
    
    final dio = Dio();
    final response = await dio.patch(
      '${_dio.options.baseUrl}$endpoint',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  }

  // Future<void> assignRoleOwner(int userId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final adminToken = prefs.getString('admin_access_token');
  //     if (adminToken == null) {
  //       print("❌ Admin token not found. Cannot assign owner role.");
  //       return;
  //     }
  //
  //     // Get current roles (you may want to GET user-role/ to check if already has Owner)
  //     final rolesResponse = await ApiService().getWithAdminToken("user-roles/");
  //     final List roles = rolesResponse.data;
  //
  //     final hasOwnerRole = roles.any((role) =>
  //     role['user'] == userId && role['role'] == 2);
  //
  //     final isRenterOnly = roles.any((role) =>
  //     role['user'] == userId && role['role'] == 1) &&
  //         !hasOwnerRole;
  //
  //     if (isRenterOnly) {
  //       final response = await ApiService().postWithAdminToken("user-roles/", {
  //         "user": userId,
  //         "role": 2, // Owner
  //       });
  //
  //       if (response.statusCode == 201 || response.statusCode == 200) {
  //         print("✅ Owner role assigned to user $userId");
  //       } else {
  //         print("❌ Failed to assign Owner role. Status: ${response.statusCode}");
  //       }
  //     } else {
  //       print("ℹ️ User already has Owner role or is not just a Renter.");
  //     }
  //   } catch (e) {
  //     print("❌ Error assigning Owner role: $e");
  //   }
  // }
  //
  // Future<void> assignRoleDriver(int userId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final adminToken = prefs.getString('admin_access_token');
  //     if (adminToken == null) {
  //       print("❌ Admin token not found. Cannot assign driver role.");
  //       return;
  //     }
  //
  //     final response = await ApiService().postWithAdminToken("user-roles/", {
  //       "user": userId,
  //       "role": 3, // Driver
  //     });
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       print("✅ Driver role assigned to user $userId");
  //     } else {
  //       print("❌ Failed to assign Driver role. Status: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Error assigning Driver role: $e");
  //   }
  // }

  // Delete with admin token for operations that need admin privileges
  Future<Response> deleteWithAdminToken(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final adminToken = prefs.getString('admin_access_token');
    
    if (adminToken == null) {
      throw Exception('Admin token not found. Please login as admin first.');
    }
    
    final dio = Dio();
    final response = await dio.delete(
      '${_dio.options.baseUrl}$endpoint',
      options: Options(
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Accept': 'application/json',
        },
      ),
    );
    return response;
  }

  // Refresh admin token
  Future<String?> refreshAdminToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminRefreshToken = prefs.getString('admin_refresh_token');
      
      if (adminRefreshToken == null) {
        print('No admin refresh token found');
        return null;
      }
      
      final response = await _dio.post(
        'token/refresh/',
        data: {
          'refresh': adminRefreshToken,
        },
      );
      
      if (response.statusCode == 200) {
        final newAdminAccessToken = response.data['access'];
        await prefs.setString('admin_access_token', newAdminAccessToken);
        print('Admin token refreshed successfully');
        return newAdminAccessToken;
      }
    } catch (e) {
      print('Error refreshing admin token: $e');
    }
    return null;
  }

  // Ensure admin token is valid, refresh if needed
  Future<String?> ensureAdminTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    String? adminToken = prefs.getString('admin_access_token');
    
    if (adminToken == null) {
      print('No admin token found, attempting admin login...');
      // You might want to trigger admin login here
      return null;
    }
    
    // For now, we'll assume the token is valid
    // In a real implementation, you might want to validate the token
    return adminToken;
  }

  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Login method
  Future<Response> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        'token/',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
