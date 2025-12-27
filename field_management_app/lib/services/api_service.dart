// // // // // // import 'dart:convert';
// // // // // // import 'package:http/http.dart' as http;
// // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // import '../utils/constants.dart';
// // // // // // import '../models/user.dart';
// // // // // // import '../models/task.dart';
// // // // // //
// // // // // // class ApiService {
// // // // // //   static const String baseUrl = AppStrings.baseUrl;
// // // // // //
// // // // // //   static Future<String?> _getToken() async {
// // // // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // //     return prefs.getString('token');
// // // // // //   }
// // // // // //
// // // // // //   static Future<Map<String, String>> _getHeaders() async {
// // // // // //     String? token = await _getToken();
// // // // // //     return {
// // // // // //       'Content-Type': 'application/json',
// // // // // //       if (token != null) 'Authorization': 'Bearer $token',
// // // // // //     };
// // // // // //   }
// // // // // //
// // // // // //   // Authentication
// // // // // //   static Future<Map<String, dynamic>> login(String userId, String password) async {
// // // // // //     final response = await http.post(
// // // // // //       Uri.parse('$baseUrl/auth/login'),
// // // // // //       headers: {'Content-Type': 'application/json'},
// // // // // //       body: jsonEncode({'userId': userId, 'password': password}),
// // // // // //     );
// // // // // //
// // // // // //     if (response.statusCode == 200) {
// // // // // //       return jsonDecode(response.body);
// // // // // //     } else {
// // // // // //       throw Exception('Login failed');
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // User Profile
// // // // // //   static Future<User> getUserProfile() async {
// // // // // //     final response = await http.get(
// // // // // //       Uri.parse('$baseUrl/users/profile'),
// // // // // //       headers: await _getHeaders(),
// // // // // //     );
// // // // // //
// // // // // //     if (response.statusCode == 200) {
// // // // // //       return User.fromJson(jsonDecode(response.body));
// // // // // //     } else {
// // // // // //       throw Exception('Failed to load profile');
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // Tasks
// // // // // //   static Future<List<Task>> getTasks() async {
// // // // // //     final response = await http.get(
// // // // // //       Uri.parse('$baseUrl/tasks'),
// // // // // //       headers: await _getHeaders(),
// // // // // //     );
// // // // // //
// // // // // //     if (response.statusCode == 200) {
// // // // // //       List<dynamic> tasksJson = jsonDecode(response.body);
// // // // // //       return tasksJson.map((json) => Task.fromJson(json)).toList();
// // // // // //     } else {
// // // // // //       throw Exception('Failed to load tasks');
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   static Future<void> updateTaskStatus(int taskId, String status, String? notes) async {
// // // // // //     final response = await http.put(
// // // // // //       Uri.parse('$baseUrl/tasks/$taskId/status'),
// // // // // //       headers: await _getHeaders(),
// // // // // //       body: jsonEncode({'status': status, 'notes': notes}),
// // // // // //     );
// // // // // //
// // // // // //     if (response.statusCode != 200) {
// // // // // //       throw Exception('Failed to update task');
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // Leave Application
// // // // // //   static Future<void> applyLeave(Map<String, dynamic> leaveData) async {
// // // // // //     final response = await http.post(
// // // // // //       Uri.parse('$baseUrl/leaves'),
// // // // // //       headers: await _getHeaders(),
// // // // // //       body: jsonEncode(leaveData),
// // // // // //     );
// // // // // //
// // // // // //     if (response.statusCode != 200) {
// // // // // //       throw Exception('Failed to apply leave');
// // // // // //     }
// // // // // //   }
// // // // // // }
// // // // //
// // // // //
// // // // // import 'dart:convert';
// // // // // import 'package:http/http.dart' as http;
// // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // //
// // // // // class ApiService {
// // // // //   static const String baseUrl = 'http://10.0.2.2:3000/api';
// // // // //   // For local development, use: http://10.0.2.2:3000/api (Android emulator)
// // // // //   // For physical device, use your computer's IP: http://192.168.1.xxx:3000/api
// // // // //
// // // // //   static Future<String?> getToken() async {
// // // // //     final prefs = await SharedPreferences.getInstance();
// // // // //     return prefs.getString('token');
// // // // //   }
// // // // //
// // // // //   static Future<Map<String, String>> getHeaders() async {
// // // // //     final token = await getToken();
// // // // //     return {
// // // // //       'Content-Type': 'application/json',
// // // // //       if (token != null) 'Authorization': 'Bearer $token',
// // // // //     };
// // // // //   }
// // // // //
// // // // //   static Future<Map<String, dynamic>> login(String userId, String password) async {
// // // // //     try {
// // // // //       final response = await http.post(
// // // // //         Uri.parse('$baseUrl/auth/login'),
// // // // //         headers: {'Content-Type': 'application/json'},
// // // // //         body: jsonEncode({
// // // // //           'userId': userId,
// // // // //           'password': password,
// // // // //         }),
// // // // //       );
// // // // //
// // // // //       return jsonDecode(response.body);
// // // // //     } catch (e) {
// // // // //       return {
// // // // //         'success': false,
// // // // //         'message': 'Network error: ${e.toString()}',
// // // // //       };
// // // // //     }
// // // // //   }
// // // // //
// // // // //   static Future<Map<String, dynamic>> getUserProfile() async {
// // // // //     try {
// // // // //       final headers = await getHeaders();
// // // // //       final response = await http.get(
// // // // //         Uri.parse('$baseUrl/users/profile'),
// // // // //         headers: headers,
// // // // //       );
// // // // //
// // // // //       return jsonDecode(response.body);
// // // // //     } catch (e) {
// // // // //       return {
// // // // //         'success': false,
// // // // //         'message': 'Network error: ${e.toString()}',
// // // // //       };
// // // // //     }
// // // // //   }
// // // // //
// // // // //   static Future<List<dynamic>> getTasks() async {
// // // // //     try {
// // // // //       final headers = await getHeaders();
// // // // //       final response = await http.get(
// // // // //         Uri.parse('$baseUrl/tasks'),
// // // // //         headers: headers,
// // // // //       );
// // // // //
// // // // //       if (response.statusCode == 200) {
// // // // //         return jsonDecode(response.body);
// // // // //       }
// // // // //       return [];
// // // // //     } catch (e) {
// // // // //       return [];
// // // // //     }
// // // // //   }
// // // // // }
// // // //
// // // // import 'dart:convert';
// // // // import 'package:http/http.dart' as http;
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // //
// // // // class ApiService {
// // // //   // For Android Emulator use: http://10.0.2.2:3000/api
// // // //   // For Physical Device use your computer's IP: http://192.168.248.81:3000/api
// // // //   static const String baseUrl = 'http://192.168.248.81:3000/api';
// // // //
// // // //   static Future<String?> getToken() async {
// // // //     final prefs = await SharedPreferences.getInstance();
// // // //     return prefs.getString('token');
// // // //   }
// // // //
// // // //   static Future<Map<String, String>> getHeaders() async {
// // // //     final token = await getToken();
// // // //     return {
// // // //       'Content-Type': 'application/json',
// // // //       if (token != null) 'Authorization': 'Bearer $token',
// // // //     };
// // // //   }
// // // //
// // // //   static Future<Map<String, dynamic>> login(String name, String userId, String password) async {
// // // //     try {
// // // //       final response = await http.post(
// // // //         Uri.parse('$baseUrl/auth/login'),
// // // //         headers: {'Content-Type': 'application/json'},
// // // //         body: jsonEncode({
// // // //           'name': name,
// // // //           'userId': userId,
// // // //           'password': password,
// // // //         }),
// // // //       );
// // // //
// // // //       return jsonDecode(response.body);
// // // //     } catch (e) {
// // // //       return {
// // // //         'success': false,
// // // //         'message': 'Network error: ${e.toString()}',
// // // //       };
// // // //     }
// // // //   }
// // // //
// // // //   static Future<Map<String, dynamic>> getUserProfile() async {
// // // //     try {
// // // //       final headers = await getHeaders();
// // // //       final response = await http.get(
// // // //         Uri.parse('$baseUrl/users/profile'),
// // // //         headers: headers,
// // // //       );
// // // //
// // // //       if (response.statusCode == 200) {
// // // //         return {
// // // //           'success': true,
// // // //           'data': jsonDecode(response.body),
// // // //         };
// // // //       } else {
// // // //         return {
// // // //           'success': false,
// // // //           'message': 'Failed to fetch profile',
// // // //         };
// // // //       }
// // // //     } catch (e) {
// // // //       return {
// // // //         'success': false,
// // // //         'message': 'Network error: ${e.toString()}',
// // // //       };
// // // //     }
// // // //   }
// // // //
// // // //   static Future<Map<String, dynamic>> getTasks() async {
// // // //     try {
// // // //       final headers = await getHeaders();
// // // //       final response = await http.get(
// // // //         Uri.parse('$baseUrl/tasks'),
// // // //         headers: headers,
// // // //       );
// // // //
// // // //       if (response.statusCode == 200) {
// // // //         return {
// // // //           'success': true,
// // // //           'data': jsonDecode(response.body),
// // // //         };
// // // //       } else {
// // // //         return {
// // // //           'success': false,
// // // //           'message': 'Failed to fetch tasks',
// // // //         };
// // // //       }
// // // //     } catch (e) {
// // // //       return {
// // // //         'success': false,
// // // //         'message': 'Network error: ${e.toString()}',
// // // //       };
// // // //     }
// // // //   }
// // // //
// // // //   static Future<Map<String, dynamic>> updateTaskStatus(int taskId, String status, String? notes) async {
// // // //     try {
// // // //       final headers = await getHeaders();
// // // //       final response = await http.put(
// // // //         Uri.parse('$baseUrl/tasks/$taskId/status'),
// // // //         headers: headers,
// // // //         body: jsonEncode({
// // // //           'status': status,
// // // //           'notes': notes,
// // // //         }),
// // // //       );
// // // //
// // // //       if (response.statusCode == 200) {
// // // //         return {
// // // //           'success': true,
// // // //           'data': jsonDecode(response.body),
// // // //         };
// // // //       } else {
// // // //         return {
// // // //           'success': false,
// // // //           'message': 'Failed to update task status',
// // // //         };
// // // //       }
// // // //     } catch (e) {
// // // //       return {
// // // //         'success': false,
// // // //         'message': 'Network error: ${e.toString()}',
// // // //       };
// // // //     }
// // // //   }
// // // //
// // // //   static Future<Map<String, dynamic>> applyLeave(Map<String, dynamic> leaveData) async {
// // // //     try {
// // // //       final headers = await getHeaders();
// // // //       final response = await http.post(
// // // //         Uri.parse('$baseUrl/leaves'),
// // // //         headers: headers,
// // // //         body: jsonEncode(leaveData),
// // // //       );
// // // //
// // // //       if (response.statusCode == 200) {
// // // //         return {
// // // //           'success': true,
// // // //           'data': jsonDecode(response.body),
// // // //         };
// // // //       } else {
// // // //         final data = jsonDecode(response.body);
// // // //         return {
// // // //           'success': false,
// // // //           'message': data['message'] ?? 'Failed to apply leave',
// // // //         };
// // // //       }
// // // //     } catch (e) {
// // // //       return {
// // // //         'success': false,
// // // //         'message': 'Network error: ${e.toString()}',
// // // //       };
// // // //     }
// // // //   }
// // // //
// // // //   static Future<Map<String, dynamic>> getLeaves() async {
// // // //     try {
// // // //       final headers = await getHeaders();
// // // //       final response = await http.get(
// // // //         Uri.parse('$baseUrl/leaves'),
// // // //         headers: headers,
// // // //       );
// // // //
// // // //       if (response.statusCode == 200) {
// // // //         return {
// // // //           'success': true,
// // // //           'data': jsonDecode(response.body),
// // // //         };
// // // //       } else {
// // // //         return {
// // // //           'success': false,
// // // //           'message': 'Failed to fetch leaves',
// // // //         };
// // // //       }
// // // //     } catch (e) {
// // // //       return {
// // // //         'success': false,
// // // //         'message': 'Network error: ${e.toString()}',
// // // //       };
// // // //     }
// // // //   }
// // // // }
// // // //
// // // //
// // //
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:http/http.dart' as http;
// // // import 'package:http_parser/http_parser.dart';
// // //
// // // class ApiService {
// // //   static const String baseUrl = 'http://YOUR_IP_ADDRESS:3000/api';
// // //
// // //   static Future<Map<String, dynamic>> login(
// // //       String name,
// // //       String userId,
// // //       String password,
// // //       ) async {
// // //     try {
// // //       final response = await http.post(
// // //         Uri.parse('$baseUrl/auth/login'),
// // //         headers: {'Content-Type': 'application/json'},
// // //         body: jsonEncode({
// // //           'name': name,
// // //           'userId': userId,
// // //           'password': password,
// // //         }),
// // //       );
// // //
// // //       return jsonDecode(response.body);
// // //     } catch (e) {
// // //       return {
// // //         'success': false,
// // //         'message': 'Network error: ${e.toString()}',
// // //       };
// // //     }
// // //   }
// // //
// // //   static Future<Map<String, dynamic>> signup({
// // //     required String name,
// // //     required String employeeId,
// // //     required String email,
// // //     required String phone,
// // //     required String zone,
// // //     required String role,
// // //     required String password,
// // //     File? profileImage,
// // //   }) async {
// // //     try {
// // //       var request = http.MultipartRequest(
// // //         'POST',
// // //         Uri.parse('$baseUrl/auth/signup'),
// // //       );
// // //
// // //       // Add text fields
// // //       request.fields['name'] = name;
// // //       request.fields['employeeId'] = employeeId;
// // //       request.fields['email'] = email;
// // //       request.fields['phone'] = phone;
// // //       request.fields['zone'] = zone;
// // //       request.fields['role'] = role;
// // //       request.fields['password'] = password;
// // //
// // //       // Add profile image if provided
// // //       if (profileImage != null) {
// // //         var stream = http.ByteStream(profileImage.openRead());
// // //         var length = await profileImage.length();
// // //         var multipartFile = http.MultipartFile(
// // //           'profileImage',
// // //           stream,
// // //           length,
// // //           filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
// // //           contentType: MediaType('image', 'jpeg'),
// // //         );
// // //         request.files.add(multipartFile);
// // //       }
// // //
// // //       var streamedResponse = await request.send();
// // //       var response = await http.Response.fromStream(streamedResponse);
// // //
// // //       return jsonDecode(response.body);
// // //     } catch (e) {
// // //       return {
// // //         'success': false,
// // //         'message': 'Network error: ${e.toString()}',
// // //       };
// // //     }
// // //   }
// // //
// // //   static Future<Map<String, dynamic>> getUserProfile(String token) async {
// // //     try {
// // //       final response = await http.get(
// // //         Uri.parse('$baseUrl/user/profile'),
// // //         headers: {
// // //           'Content-Type': 'application/json',
// // //           'Authorization': 'Bearer $token',
// // //         },
// // //       );
// // //
// // //       return jsonDecode(response.body);
// // //     } catch (e) {
// // //       return {
// // //         'success': false,
// // //         'message': 'Network error: ${e.toString()}',
// // //       };
// // //     }
// // //   }
// // // }
// //
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;
// // import 'package:http_parser/http_parser.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // class ApiService {
// //   // Update this URL to your backend URL or your IP address
// //   static const String baseUrl = 'http://YOUR_IP_ADDRESS:3000/api';
// //
// //   // Login method
// //   static Future<Map<String, dynamic>> login(
// //       String name,
// //       String userId,
// //       String password,
// //       ) async {
// //     try {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/auth/login'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode({
// //           'name': name,
// //           'userId': userId,
// //           'password': password,
// //         }),
// //       );
// //
// //       return jsonDecode(response.body);
// //     } catch (e) {
// //       return {
// //         'success': false,
// //         'message': 'Network error: ${e.toString()}',
// //       };
// //     }
// //   }
// //
// //   // Signup method
// //   static Future<Map<String, dynamic>> signup({
// //     required String name,
// //     required String employeeId,
// //     required String email,
// //     required String phone,
// //     required String zone,
// //     required String role,
// //     required String password,
// //     File? profileImage,
// //   }) async {
// //     try {
// //       var request = http.MultipartRequest(
// //         'POST',
// //         Uri.parse('$baseUrl/auth/signup'),
// //       );
// //
// //       // Add text fields
// //       request.fields['name'] = name;
// //       request.fields['employeeId'] = employeeId;
// //       request.fields['email'] = email;
// //       request.fields['phone'] = phone;
// //       request.fields['zone'] = zone;
// //       request.fields['role'] = role;
// //       request.fields['password'] = password;
// //
// //       // Add profile image if provided
// //       if (profileImage != null) {
// //         var stream = http.ByteStream(profileImage.openRead());
// //         var length = await profileImage.length();
// //         var multipartFile = http.MultipartFile(
// //           'profileImage',
// //           stream,
// //           length,
// //           filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
// //           contentType: MediaType('image', 'jpeg'),
// //         );
// //         request.files.add(multipartFile);
// //       }
// //
// //       var streamedResponse = await request.send();
// //       var response = await http.Response.fromStream(streamedResponse);
// //
// //       return jsonDecode(response.body);
// //     } catch (e) {
// //       return {
// //         'success': false,
// //         'message': 'Network error: ${e.toString()}',
// //       };
// //     }
// //   }
// //
// //   // Get user profile (with token from SharedPreferences)
// //   static Future<Map<String, dynamic>> getUserProfile() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token');
// //
// //       if (token == null) {
// //         return {
// //           'success': false,
// //           'message': 'No authentication token found',
// //         };
// //       }
// //
// //       final response = await http.get(
// //         Uri.parse('$baseUrl/user/profile'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $token',
// //         },
// //       );
// //
// //       return jsonDecode(response.body);
// //     } catch (e) {
// //       return {
// //         'success': false,
// //         'message': 'Network error: ${e.toString()}',
// //       };
// //     }
// //   }
// //
// //   // Get user profile with explicit token parameter
// //   static Future<Map<String, dynamic>> getUserProfileWithToken(String token) async {
// //     try {
// //       final response = await http.get(
// //         Uri.parse('$baseUrl/user/profile'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $token',
// //         },
// //       );
// //
// //       return jsonDecode(response.body);
// //     } catch (e) {
// //       return {
// //         'success': false,
// //         'message': 'Network error: ${e.toString()}',
// //       };
// //     }
// //   }
// //
// //   // Update user profile
// //   static Future<Map<String, dynamic>> updateProfile({
// //     required String name,
// //     required String email,
// //     required String phone,
// //   }) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token');
// //
// //       if (token == null) {
// //         return {
// //           'success': false,
// //           'message': 'No authentication token found',
// //         };
// //       }
// //
// //       final response = await http.put(
// //         Uri.parse('$baseUrl/user/profile'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $token',
// //         },
// //         body: jsonEncode({
// //           'name': name,
// //           'email': email,
// //           'phone': phone,
// //         }),
// //       );
// //
// //       return jsonDecode(response.body);
// //     } catch (e) {
// //       return {
// //         'success': false,
// //         'message': 'Network error: ${e.toString()}',
// //       };
// //     }
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ApiService {
//   // IMPORTANT: Update this URL based on your setup:
//   // For Android Emulator: use http://10.0.2.2:3000/api
//   // For Physical Device: use http://YOUR_COMPUTER_IP:3000/api (e.g., http://192.168.1.100:3000/api)
//   // For Production: use your actual server URL
//   static const String baseUrl = 'http://10.0.2.2:3000/api';
//
//   // Login method
//   static Future<Map<String, dynamic>> login(
//       String name,
//       String userId,
//       String password,
//       ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'name': name,
//           'userId': userId,
//           'password': password,
//         }),
//       );
//
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   // Signup method - Employee ID will be auto-generated by backend
//   static Future<Map<String, dynamic>> signup({
//     required String name,
//     required String email,
//     required String phone,
//     required String zone,
//     required String role,
//     required String password,
//     File? profileImage,
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/auth/signup'),
//       );
//
//       // Add text fields
//       request.fields['name'] = name;
//       request.fields['email'] = email;
//       request.fields['phone'] = phone;
//       request.fields['zone'] = zone;
//       request.fields['role'] = role;
//       request.fields['password'] = password;
//
//       // Add profile image if provided
//       if (profileImage != null) {
//         var stream = http.ByteStream(profileImage.openRead());
//         var length = await profileImage.length();
//         var multipartFile = http.MultipartFile(
//           'profileImage',
//           stream,
//           length,
//           filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
//           contentType: MediaType('image', 'jpeg'),
//         );
//         request.files.add(multipartFile);
//       }
//
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   // Get user profile (with token from SharedPreferences)
//   static Future<Map<String, dynamic>> getUserProfile() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         return {
//           'success': false,
//           'message': 'No authentication token found',
//         };
//       }
//
//       final response = await http.get(
//         Uri.parse('$baseUrl/user/profile'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   // Get user profile with explicit token parameter
//   static Future<Map<String, dynamic>> getUserProfileWithToken(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/user/profile'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   // Update user profile
//   static Future<Map<String, dynamic>> updateProfile({
//     required String name,
//     required String email,
//     required String phone,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         return {
//           'success': false,
//           'message': 'No authentication token found',
//         };
//       }
//
//       final response = await http.put(
//         Uri.parse('$baseUrl/user/profile'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'name': name,
//           'email': email,
//           'phone': phone,
//         }),
//       );
//
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   // Get tasks
//   static Future<Map<String, dynamic>> getTasks() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         return {
//           'success': false,
//           'message': 'No authentication token found',
//         };
//       }
//
//       final response = await http.get(
//         Uri.parse('$baseUrl/tasks'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'data': jsonDecode(response.body),
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'Failed to fetch tasks',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   // Update task status
//   static Future<Map<String, dynamic>> updateTaskStatus(
//       int taskId,
//       String status,
//       String? notes,
//       ) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         return {
//           'success': false,
//           'message': 'No authentication token found',
//         };
//       }
//
//       final response = await http.put(
//         Uri.parse('$baseUrl/tasks/$taskId/status'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'status': status,
//           'notes': notes,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'data': jsonDecode(response.body),
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'Failed to update task status',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   // Apply leave
//   static Future<Map<String, dynamic>> applyLeave(Map<String, dynamic> leaveData) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         return {
//           'success': false,
//           'message': 'No authentication token found',
//         };
//       }
//
//       final response = await http.post(
//         Uri.parse('$baseUrl/leaves'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(leaveData),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'success': true,
//           'data': jsonDecode(response.body),
//         };
//       } else {
//         final data = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message': data['message'] ?? 'Failed to apply leave',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   // Get leaves
//   static Future<Map<String, dynamic>> getLeaves() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         return {
//           'success': false,
//           'message': 'No authentication token found',
//         };
//       }
//
//       final response = await http.get(
//         Uri.parse('$baseUrl/leaves'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'data': jsonDecode(response.body),
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'Failed to fetch leaves',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IMPORTANT: Update this URL based on your setup:
  // For Android Emulator: use http://10.0.2.2:3000/api
  // For Physical Device: use http://YOUR_COMPUTER_IP:3000/api (e.g., http://192.168.1.100:3000/api)
  // For Production: use your actual server URL
  // static const String baseUrl = 'http://192.168.71.81:3000/api';
  static const String baseUrl = 'http://192.168.86.81:3000/api';

  // Login method
  static Future<Map<String, dynamic>> login(
      String name,
      String userId,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'userId': userId,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Signup method - Employee ID will be auto-generated by backend
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String zone,
    required String role,
    required String password,
    File? profileImage,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/signup'),
      );

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['zone'] = zone;
      request.fields['role'] = role;
      request.fields['password'] = password;

      // Add profile image if provided
      if (profileImage != null) {
        var stream = http.ByteStream(profileImage.openRead());
        var length = await profileImage.length();
        var multipartFile = http.MultipartFile(
          'profileImage',
          stream,
          length,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get user profile (with token from SharedPreferences)
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get user profile with explicit token parameter
  static Future<Map<String, dynamic>> getUserProfileWithToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update user profile - Enhanced with more fields
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update user profile - Full profile update (for edit profile screen)
  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': userData['name'],
          'email': userData['email'],
          'phone': userData['phone'],
          'zone': userData['zone'],
          'role': userData['role'],
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update profile with image
  static Future<Map<String, dynamic>> updateProfileWithImage({
    required String name,
    required String email,
    required String phone,
    required String zone,
    required String role,
    File? profileImage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/user/profile'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['zone'] = zone;
      request.fields['role'] = role;

      // Add profile image if provided
      if (profileImage != null) {
        var stream = http.ByteStream(profileImage.openRead());
        var length = await profileImage.length();
        var multipartFile = http.MultipartFile(
          'profileImage',
          stream,
          length,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get tasks
  static Future<Map<String, dynamic>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch tasks',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create task/visit
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create task',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update task status
  static Future<Map<String, dynamic>> updateTaskStatus(
      int taskId,
      String status,
      String? notes,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$taskId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update task status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Apply leave
  static Future<Map<String, dynamic>> applyLeave(Map<String, dynamic> leaveData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/leaves'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(leaveData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to apply leave',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get leaves
  static Future<Map<String, dynamic>> getLeaves() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/leaves'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch leaves',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get user statistics (for dashboard/profile)
  static Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch statistics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Submit client summary
  static Future<Map<String, dynamic>> submitClientSummary(Map<String, dynamic> summaryData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/client-summaries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(summaryData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit summary',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Submit expense
  static Future<Map<String, dynamic>> submitExpense(Map<String, dynamic> expenseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(expenseData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit expense',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get expenses
  static Future<Map<String, dynamic>> getExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch expenses',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': true,
          'message': 'Already logged out',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Clear local data regardless of server response
      await prefs.clear();

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Logged out successfully',
        };
      } else {
        return {
          'success': true,
          'message': 'Logged out locally',
        };
      }
    } catch (e) {
      // Clear local data even on error
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }
}