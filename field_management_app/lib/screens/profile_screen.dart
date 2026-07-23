// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/api_service.dart';
// import 'login_screen.dart';
// import 'edit_profile_screen.dart';
// import 'leave.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _userData;
//   String? _profileImagePath;
//   final ImagePicker _picker = ImagePicker();
//   String _userId = ''; // USER ID FOR DATA ISOLATION
//
//   // Dynamic stats data
//   int _monthlyTasksCompleted = 0;
//   int _avgTimePerVisit = 0;
//   int _targetCompletion = 0;
//   double _customerFeedback = 0.0;
//
//   static const Color primaryBlue = Color(0xFF0F3A68);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _loadStatistics();
//     _loadProfileImage();
//   }
//
//   Future<void> _loadProfileImage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final imagePath = prefs.getString('profile_image_path');
//       if (mounted && imagePath != null) {
//         setState(() {
//           _profileImagePath = imagePath;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading profile image: $e');
//     }
//   }
//
//   Future<void> _saveProfileImage(String path) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('profile_image_path', path);
//       if (mounted) {
//         setState(() {
//           _profileImagePath = path;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error saving profile image: $e');
//     }
//   }
//
//   Future<void> _showImageSourceDialog() async {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Choose Profile Photo',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt, color: primaryBlue),
//                 title: Text(
//                   'Take Photo',
//                   style: GoogleFonts.poppins(),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library, color: primaryBlue),
//                 title: Text(
//                   'Choose from Gallery',
//                   style: GoogleFonts.poppins(),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//               if (_profileImagePath != null)
//                 ListTile(
//                   leading: const Icon(Icons.delete, color: Colors.red),
//                   title: Text(
//                     'Remove Photo',
//                     style: GoogleFonts.poppins(color: Colors.red),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _removeProfileImage();
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: source,
//         maxWidth: 512,
//         maxHeight: 512,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         await _saveProfileImage(image.path);
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Profile photo updated successfully!',
//                 style: GoogleFonts.poppins(),
//               ),
//               backgroundColor: primaryBlue,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking image: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to update profile photo',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _removeProfileImage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('profile_image_path');
//       if (mounted) {
//         setState(() {
//           _profileImagePath = null;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Profile photo removed',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: primaryBlue,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error removing profile image: $e');
//     }
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userString = prefs.getString('user');
//
//       if (userString != null) {
//         final userData = jsonDecode(userString);
//         if (mounted) {
//           setState(() {
//             _userData = userData;
//             // Store user ID for data isolation
//             _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
//             _isLoading = false;
//           });
//         }
//         debugPrint('✅ User loaded in ProfileScreen: $_userId');
//       } else {
//         if (mounted) {
//           setState(() {
//             _userId = 'default';
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _userId = 'default';
//           _isLoading = false;
//         });
//       }
//       debugPrint('❌ Failed to load profile: $e');
//     }
//   }
//
//   Future<void> _loadStatistics() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // Use user-specific key
//       final String visitsKey = 'visits_$_userId';
//       final visitsString = prefs.getString(visitsKey);
//
//       if (visitsString == null || visitsString.isEmpty) {
//         if (mounted) {
//           setState(() {
//             _monthlyTasksCompleted = 0;
//             _avgTimePerVisit = 0;
//             _targetCompletion = 0;
//             _customerFeedback = 0.0;
//           });
//         }
//         return;
//       }
//
//       final List<dynamic> visitsJson = jsonDecode(visitsString);
//       final now = DateTime.now();
//
//       int completedThisMonth = 0;
//       int totalVisitTime = 0;
//       int visitCount = 0;
//       int totalTasksThisMonth = 0;
//
//       for (var visitJson in visitsJson) {
//         try {
//           final visitTime = DateTime.parse(visitJson['visitTime']);
//
//           if (visitTime.year == now.year && visitTime.month == now.month) {
//             totalTasksThisMonth++;
//
//             if (visitJson['status'] == 'completed' ||
//                 visitJson['status'] == 'successfully_met') {
//               completedThisMonth++;
//             }
//           }
//
//           if (visitJson['status'] == 'completed' ||
//               visitJson['status'] == 'successfully_met') {
//             totalVisitTime += 30;
//             visitCount++;
//           }
//         } catch (e) {
//           debugPrint('Error parsing visit: $e');
//           continue;
//         }
//       }
//
//       final totalTasks = visitsJson.length;
//       final completedTasks = visitsJson.where((v) =>
//       v['status'] == 'completed' || v['status'] == 'successfully_met'
//       ).length;
//
//       final targetPercentage = totalTasks > 0
//           ? ((completedTasks / totalTasks) * 100).round()
//           : 0;
//
//       final avgTime = visitCount > 0
//           ? (totalVisitTime / visitCount).round()
//           : 0;
//
//       final feedbackScore = 4.0 + (targetPercentage / 100 * 1.0);
//
//       if (mounted) {
//         setState(() {
//           _monthlyTasksCompleted = completedThisMonth;
//           _avgTimePerVisit = avgTime;
//           _targetCompletion = targetPercentage;
//           _customerFeedback = feedbackScore.clamp(0.0, 5.0);
//         });
//       }
//
//       debugPrint('✅ Stats loaded for user $_userId: Monthly=$completedThisMonth, Avg Time=$avgTime, Target=$targetPercentage%, Feedback=${feedbackScore.toStringAsFixed(1)}');
//     } catch (e) {
//       debugPrint('❌ Error loading statistics: $e');
//       if (mounted) {
//         setState(() {
//           _monthlyTasksCompleted = 0;
//           _avgTimePerVisit = 0;
//           _targetCompletion = 0;
//           _customerFeedback = 0.0;
//         });
//       }
//     }
//   }
//
//   Future<void> _logout() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(
//             'Logout',
//             style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//           ),
//           content: Text(
//             'Are you sure you want to logout?',
//             style: GoogleFonts.poppins(),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: Colors.grey),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//
//                 // IMPORTANT: Only clear authentication data, keep user-specific visits
//                 await prefs.remove('token');
//                 await prefs.remove('user');
//                 await prefs.remove('profile_image_path');
//                 // DO NOT use prefs.clear() as it removes all users' visits
//
//                 debugPrint('✅ User logged out: $_userId');
//
//                 if (mounted) {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => const LoginScreen()),
//                         (route) => false,
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryBlue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 'Logout',
//                 style: GoogleFonts.poppins(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _navigateToEditProfile() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditProfileScreen(userData: _userData ?? {}),
//       ),
//     );
//
//     if (result == true) {
//       await _loadUserData();
//       await _loadStatistics();
//     }
//   }
//
//   void _navigateToLeave() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ApplyLeaveScreen(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: primaryBlue,
//         body: const Center(
//           child: CircularProgressIndicator(color: Colors.white),
//         ),
//       );
//     }
//
//     final name = _userData?['name'] ?? 'User';
//     final email = _userData?['email'] ?? 'N/A';
//     final phone = _userData?['phone'] ?? 'N/A';
//     final employeeId = _userData?['employeeId'] ?? 'N/A';
//     final role = _userData?['role']?.toString().replaceAll('_', ' ') ?? 'Field Executive';
//     final zone = _userData?['zone'] ?? 'N/A';
//
//     final formattedRole = role.split(' ')
//         .map((word) => word.isNotEmpty
//         ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
//         : '')
//         .join(' ');
//
//     return Scaffold(
//       backgroundColor: primaryBlue,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header with profile photo
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: primaryBlue,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // Profile picture with edit button
//                   GestureDetector(
//                     onTap: _showImageSourceDialog,
//                     child: Stack(
//                       children: [
//                         Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white,
//                             border: Border.all(color: Colors.white, width: 3),
//                             image: _profileImagePath != null
//                                 ? DecorationImage(
//                               image: FileImage(File(_profileImagePath!)),
//                               fit: BoxFit.cover,
//                             )
//                                 : null,
//                           ),
//                           child: _profileImagePath == null
//                               ? Center(
//                             child: Text(
//                               name.isNotEmpty ? name[0].toUpperCase() : 'U',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 36,
//                                 fontWeight: FontWeight.bold,
//                                 color: primaryBlue,
//                               ),
//                             ),
//                           )
//                               : null,
//                         ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: const BoxDecoration(
//                               color: primaryBlue,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.camera_alt,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           name,
//                           style: GoogleFonts.poppins(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '$formattedRole - ${zone.split(',').last.trim()}',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Main content
//             Expanded(
//               child: Container(
//                 color: const Color(0xFFF8F9FA),
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       left: 20,
//                       right: 20,
//                       top: 20,
//                       bottom: 20,
//                     ),
//                     child: Column(
//                       children: [
//                         // Stats Grid
//                         GridView.count(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           crossAxisCount: 2,
//                           mainAxisSpacing: 15,
//                           crossAxisSpacing: 15,
//                           childAspectRatio: 1.35,
//                           children: [
//                             _buildStatCard(
//                               Icons.check_circle,
//                               '$_monthlyTasksCompleted',
//                               'Monthly Tasks\nCompleted',
//                               primaryBlue,
//                             ),
//                             _buildStatCard(
//                               Icons.access_time,
//                               '${_avgTimePerVisit}m',
//                               'Avg.Time per\nVisit',
//                               primaryBlue,
//                             ),
//                             _buildStatCard(
//                               Icons.flag,
//                               '$_targetCompletion%',
//                               'Target\nCompletion',
//                               primaryBlue,
//                             ),
//                             _buildStatCard(
//                               Icons.chat_bubble,
//                               _customerFeedback.toStringAsFixed(1),
//                               'Customer\nFeedback',
//                               primaryBlue,
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 30),
//
//                         // Basic Details
//                         Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(15),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Basic Details',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildCompactDetailCard(
//                                       Icons.badge,
//                                       'Employee ID',
//                                       employeeId.startsWith('#') ? employeeId : '#$employeeId',
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _buildCompactDetailCard(
//                                       Icons.phone,
//                                       'Phone Number',
//                                       phone.startsWith('+') ? phone : '+91 $phone',
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildCompactDetailCard(
//                                       Icons.email,
//                                       'Email',
//                                       email,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _buildCompactDetailCard(
//                                       Icons.location_on,
//                                       'Zone',
//                                       zone,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         // Menu Options
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(15),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               _buildMenuOption(
//                                 Icons.edit,
//                                 'Edit Profile',
//                                 _navigateToEditProfile,
//                               ),
//                               _buildMenuOption(
//                                 Icons.settings,
//                                 'Account Management',
//                                     () {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Account management coming soon!'),
//                                       backgroundColor: primaryBlue,
//                                     ),
//                                   );
//                                 },
//                               ),
//                               _buildMenuOption(
//                                 Icons.person_outline,
//                                 'Contact HR',
//                                     () {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Contact HR feature coming soon!'),
//                                       backgroundColor: primaryBlue,
//                                     ),
//                                   );
//                                 },
//                               ),
//                               _buildMenuOption(
//                                 Icons.calendar_today,
//                                 'Apply for Leave',
//                                 _navigateToLeave,
//                               ),
//                               _buildMenuOption(
//                                 Icons.logout,
//                                 'Log Out',
//                                 _logout,
//                                 color: Colors.red,
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               spreadRadius: 0,
//               blurRadius: 20,
//               offset: const Offset(0, -4),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: 3,
//           onTap: (index) {
//             if (index != 3) {
//               Navigator.pop(context);
//             }
//           },
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: primaryBlue,
//           unselectedItemColor: Colors.grey.shade400,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           selectedLabelStyle: GoogleFonts.poppins(
//             fontWeight: FontWeight.w600,
//             fontSize: 12,
//           ),
//           unselectedLabelStyle: GoogleFonts.poppins(
//             fontWeight: FontWeight.w500,
//             fontSize: 12,
//           ),
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.assignment_outlined),
//               activeIcon: Icon(Icons.assignment),
//               label: 'Task',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_month_outlined),
//               activeIcon: Icon(Icons.calendar_month),
//               label: 'Calendar',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatCard(IconData icon, String value, String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(22.5),
//             ),
//             child: Icon(icon, color: Colors.white, size: 22),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//               height: 1.2,
//             ),
//           ),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 13,
//               color: const Color(0xFF666666),
//               fontWeight: FontWeight.w500,
//               height: 1.3,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCompactDetailCard(IconData icon, String label, String value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F9FA),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: const Color(0xFF666666), size: 18),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: const Color(0xFF666666),
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap, {Color? color}) {
//     return ListTile(
//       leading: Icon(icon, color: color ?? const Color(0xFF666666)),
//       title: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           color: color ?? Colors.black,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       trailing: Icon(Icons.chevron_right, color: const Color(0xFF666666)),
//       onTap: onTap,
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'leave.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  String _userId = ''; // USER ID FOR DATA ISOLATION

  // Dynamic stats data
  int _monthlyTasksCompleted = 0;
  int _avgTimePerVisit = 0;
  int _targetCompletion = 0;
  double _customerFeedback = 0.0;

  static const Color primaryBlue = Color(0xFF0F3A68);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStatistics();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_path');
      if (mounted && imagePath != null) {
        setState(() {
          _profileImagePath = imagePath;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
    }
  }

  Future<void> _saveProfileImage(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', path);
      if (mounted) {
        setState(() {
          _profileImagePath = path;
        });
      }
    } catch (e) {
      debugPrint('Error saving profile image: $e');
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: primaryBlue),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: primaryBlue),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await _saveProfileImage(image.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile photo updated successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: primaryBlue,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile photo',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_path');
      if (mounted) {
        setState(() {
          _profileImagePath = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile photo removed',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: primaryBlue,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing profile image: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final userData = jsonDecode(userString);
        if (mounted) {
          setState(() {
            _userData = userData;
            // Store user ID for data isolation
            _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
            _isLoading = false;
          });
        }
        debugPrint('✅ User loaded in ProfileScreen: $_userId');
      } else {
        if (mounted) {
          setState(() {
            _userId = 'default';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userId = 'default';
          _isLoading = false;
        });
      }
      debugPrint('❌ Failed to load profile: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Use user-specific key
      final String visitsKey = 'visits_$_userId';
      final visitsString = prefs.getString(visitsKey);

      if (visitsString == null || visitsString.isEmpty) {
        if (mounted) {
          setState(() {
            _monthlyTasksCompleted = 0;
            _avgTimePerVisit = 0;
            _targetCompletion = 0;
            _customerFeedback = 0.0;
          });
        }
        return;
      }

      final List<dynamic> visitsJson = jsonDecode(visitsString);
      final now = DateTime.now();

      int completedThisMonth = 0;
      int totalVisitTime = 0;
      int visitCount = 0;
      int totalTasksThisMonth = 0;

      for (var visitJson in visitsJson) {
        try {
          final visitTime = DateTime.parse(visitJson['visitTime']);

          if (visitTime.year == now.year && visitTime.month == now.month) {
            totalTasksThisMonth++;

            if (visitJson['status'] == 'completed' ||
                visitJson['status'] == 'successfully_met') {
              completedThisMonth++;
            }
          }

          if (visitJson['status'] == 'completed' ||
              visitJson['status'] == 'successfully_met') {
            totalVisitTime += 30;
            visitCount++;
          }
        } catch (e) {
          debugPrint('Error parsing visit: $e');
          continue;
        }
      }

      final totalTasks = visitsJson.length;
      final completedTasks = visitsJson.where((v) =>
      v['status'] == 'completed' || v['status'] == 'successfully_met'
      ).length;

      final targetPercentage = totalTasks > 0
          ? ((completedTasks / totalTasks) * 100).round()
          : 0;

      final avgTime = visitCount > 0
          ? (totalVisitTime / visitCount).round()
          : 0;

      final feedbackScore = 4.0 + (targetPercentage / 100 * 1.0);

      if (mounted) {
        setState(() {
          _monthlyTasksCompleted = completedThisMonth;
          _avgTimePerVisit = avgTime;
          _targetCompletion = targetPercentage;
          _customerFeedback = feedbackScore.clamp(0.0, 5.0);
        });
      }

      debugPrint('✅ Stats loaded for user $_userId: Monthly=$completedThisMonth, Avg Time=$avgTime, Target=$targetPercentage%, Feedback=${feedbackScore.toStringAsFixed(1)}');
    } catch (e) {
      debugPrint('❌ Error loading statistics: $e');
      if (mounted) {
        setState(() {
          _monthlyTasksCompleted = 0;
          _avgTimePerVisit = 0;
          _targetCompletion = 0;
          _customerFeedback = 0.0;
        });
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                // IMPORTANT: Only clear authentication data, keep user-specific visits
                await prefs.remove('token');
                await prefs.remove('user');
                await prefs.remove('profile_image_path');
                // DO NOT use prefs.clear() as it removes all users' visits

                debugPrint('✅ User logged out: $_userId');

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: _userData ?? {}),
      ),
    );

    if (result == true) {
      await _loadUserData();
      await _loadStatistics();
    }
  }

  void _navigateToLeave() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ApplyLeaveScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: primaryBlue,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final name = _userData?['name'] ?? 'User';
    final email = _userData?['email'] ?? 'N/A';
    final phone = _userData?['phone'] ?? 'N/A';
    final employeeId = _userData?['employeeId'] ?? 'N/A';
    final role = _userData?['role']?.toString().replaceAll('_', ' ') ?? 'Field Executive';
    final zone = _userData?['zone'] ?? 'N/A';

    final formattedRole = role.split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Header with profile photo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Profile picture with edit button
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 3),
                            image: _profileImagePath != null
                                ? DecorationImage(
                              image: FileImage(File(_profileImagePath!)),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: _profileImagePath == null
                              ? Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$formattedRole - ${zone.split(',').last.trim()}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                color: const Color(0xFFF8F9FA),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [
                        // Stats Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 1.4,
                          children: [
                            _buildStatCard(
                              Icons.check_circle,
                              '$_monthlyTasksCompleted',
                              'Monthly Tasks\nCompleted',
                              primaryBlue,
                            ),
                            _buildStatCard(
                              Icons.access_time,
                              '${_avgTimePerVisit}m',
                              'Avg.Time per\nVisit',
                              primaryBlue,
                            ),
                            _buildStatCard(
                              Icons.flag,
                              '$_targetCompletion%',
                              'Target\nCompletion',
                              primaryBlue,
                            ),
                            _buildStatCard(
                              Icons.chat_bubble,
                              _customerFeedback.toStringAsFixed(1),
                              'Customer\nFeedback',
                              primaryBlue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Basic Details
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactDetailCard(
                                      Icons.badge,
                                      'Employee ID',
                                      employeeId.startsWith('#') ? employeeId : '#$employeeId',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildCompactDetailCard(
                                      Icons.phone,
                                      'Phone Number',
                                      phone.startsWith('+') ? phone : '+91 $phone',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactDetailCard(
                                      Icons.email,
                                      'Email',
                                      email,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildCompactDetailCard(
                                      Icons.location_on,
                                      'Zone',
                                      zone,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Menu Options
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuOption(
                                Icons.edit,
                                'Edit Profile',
                                _navigateToEditProfile,
                              ),
                              _buildMenuOption(
                                Icons.settings,
                                'Account Management',
                                    () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Account management coming soon!'),
                                      backgroundColor: primaryBlue,
                                    ),
                                  );
                                },
                              ),
                              _buildMenuOption(
                                Icons.person_outline,
                                'Contact HR',
                                    () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Contact HR feature coming soon!'),
                                      backgroundColor: primaryBlue,
                                    ),
                                  );
                                },
                              ),
                              _buildMenuOption(
                                Icons.calendar_today,
                                'Apply for Leave',
                                _navigateToLeave,
                              ),
                              _buildMenuOption(
                                Icons.logout,
                                'Log Out',
                                _logout,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            if (index != 3) {
              Navigator.pop(context);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryBlue,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Task',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF666666),
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetailCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF666666), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF666666)),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: color ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: const Color(0xFF666666)),
      onTap: onTap,
    );
  }
}