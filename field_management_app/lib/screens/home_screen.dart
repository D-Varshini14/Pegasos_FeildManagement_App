// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:geolocator/geolocator.dart';
// import 'tasks_screen.dart';
// import 'calendar_screen.dart';
// import 'profile_screen.dart';
// import 'add_visit_screen.dart'; // ✅ Import the updated AddVisitScreen
// import 'client_summary_screen.dart' as summary;
//
// // Model class for Visit data
// class Visit {
//   final String clientName;
//   final String purpose;
//   final String location;
//   final String phoneNumber;
//   final DateTime visitTime;
//   final String status; // 'pending', 'completed', 'missed'
//   final String notes;
//
//   Visit({
//     required this.clientName,
//     required this.purpose,
//     required this.location,
//     required this.phoneNumber,
//     required this.visitTime,
//     this.status = 'pending',
//     this.notes = '',
//   });
//
//   // Convert Visit to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'clientName': clientName,
//       'purpose': purpose,
//       'location': location,
//       'phoneNumber': phoneNumber,
//       'visitTime': visitTime.toIso8601String(),
//       'status': status,
//       'notes': notes,
//     };
//   }
//
//   // Create Visit from JSON
//   factory Visit.fromJson(Map<String, dynamic> json) {
//     return Visit(
//       clientName: json['clientName'] ?? '',
//       purpose: json['purpose'] ?? '',
//       location: json['location'] ?? '',
//       phoneNumber: json['phoneNumber'] ?? '',
//       visitTime: DateTime.parse(json['visitTime']),
//       status: json['status'] ?? 'pending',
//       notes: json['notes'] ?? '',
//     );
//   }
//
//   // Create a copy of visit with updated status
//   Visit copyWith({String? status}) {
//     return Visit(
//       clientName: clientName,
//       purpose: purpose,
//       location: location,
//       phoneNumber: phoneNumber,
//       visitTime: visitTime,
//       status: status ?? this.status,
//       notes: notes,
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   List<Visit> _visits = [];
//   String _userName = '';
//   String _userId = ''; // USER ID FOR DATA ISOLATION
//   String _currentLocation = 'Loading...';
//   bool _isLoading = true;
//
//   // Professional blue color scheme
//   static const Color primaryBlue = Color(0xFF0F3A68);
//   static const Color lightBlue = Color(0xFF1565C0);
//   static const Color darkBlue = Color(0xFF0A2A4F);
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }
//
//   // Initialize all data
//   Future<void> _initializeData() async {
//     await _loadUserData(); // Load user data first to get userId
//     await _loadVisits(); // Then load visits using userId
//     await _getCurrentLocation();
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Load user data from SharedPreferences
//   Future<void> _loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userString = prefs.getString('user');
//
//       if (userString != null) {
//         final userData = jsonDecode(userString);
//         if (mounted) {
//           setState(() {
//             _userName = userData['name']?.split(' ')[0] ?? 'User';
//             // IMPORTANT: Store user ID for data isolation
//             _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
//           });
//         }
//         debugPrint('✅ User loaded: $_userName (ID: $_userId)');
//       } else {
//         if (mounted) {
//           setState(() {
//             _userName = 'Professional';
//             _userId = 'default';
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('❌ Error loading user data: $e');
//       if (mounted) {
//         setState(() {
//           _userName = 'Professional';
//           _userId = 'default';
//         });
//       }
//     }
//   }
//
//   // Load visits from SharedPreferences - USER SPECIFIC
//   Future<void> _loadVisits() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // Use user-specific key
//       final String visitsKey = 'visits_$_userId';
//       final visitsString = prefs.getString(visitsKey);
//
//       if (visitsString != null) {
//         final List<dynamic> visitsJson = jsonDecode(visitsString);
//         if (mounted) {
//           setState(() {
//             _visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
//           });
//         }
//         debugPrint('✅ Loaded ${_visits.length} visits for user: $_userId');
//       } else {
//         if (mounted) {
//           setState(() {
//             _visits = [];
//           });
//         }
//         debugPrint('ℹ️ No visits found for user: $_userId');
//       }
//     } catch (e) {
//       debugPrint('❌ Error loading visits: $e');
//       if (mounted) {
//         setState(() {
//           _visits = [];
//         });
//       }
//     }
//   }
//
//   // Save visits to SharedPreferences - USER SPECIFIC
//   Future<void> _saveVisits() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // Use user-specific key
//       final String visitsKey = 'visits_$_userId';
//       final visitsJson = _visits.map((visit) => visit.toJson()).toList();
//       await prefs.setString(visitsKey, jsonEncode(visitsJson));
//
//       debugPrint('✅ Saved ${_visits.length} visits for user: $_userId');
//     } catch (e) {
//       debugPrint('❌ Error saving visits: $e');
//     }
//   }
//
//   // Get current location with proper error handling
//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         if (mounted) {
//           setState(() {
//             _currentLocation = 'Coimbatore, Tamil Nadu';
//           });
//         }
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           if (mounted) {
//             setState(() {
//               _currentLocation = 'Coimbatore, Tamil Nadu';
//             });
//           }
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         if (mounted) {
//           setState(() {
//             _currentLocation = 'Coimbatore, Tamil Nadu';
//           });
//         }
//         return;
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );
//
//       // For demo purposes, using hardcoded location based on coordinates
//       if (mounted) {
//         setState(() {
//           _currentLocation = 'Coimbatore, Tamil Nadu';
//         });
//       }
//     } catch (e) {
//       debugPrint('Location error: $e');
//       if (mounted) {
//         setState(() {
//           _currentLocation = 'Coimbatore, Tamil Nadu';
//         });
//       }
//     }
//   }
//
//   // Get current date and day
//   String _getCurrentDateAndDay() {
//     final now = DateTime.now();
//     final formatter = DateFormat('EEEE, MMM dd');
//     return formatter.format(now);
//   }
//
//   // Add a new visit to the list
//   Future<void> _addVisit(summary.Visit visit) async {
//     // Convert summary.Visit to local Visit
//     final localVisit = Visit(
//       clientName: visit.clientName,
//       purpose: visit.purpose,
//       location: visit.location,
//       phoneNumber: visit.phoneNumber,
//       visitTime: visit.visitTime,
//       status: visit.status,
//       notes: visit.notes,
//     );
//
//     setState(() {
//       _visits.add(localVisit);
//     });
//     await _saveVisits();
//   }
//
//   // Update visit status
//   Future<void> _updateVisitStatus(int index, String newStatus) async {
//     if (index >= 0 && index < _visits.length) {
//       setState(() {
//         _visits[index] = _visits[index].copyWith(status: newStatus);
//       });
//       await _saveVisits();
//     }
//   }
//
//   // Delete visit
//   Future<void> _deleteVisit(int index) async {
//     if (index >= 0 && index < _visits.length) {
//       setState(() {
//         _visits.removeAt(index);
//       });
//       await _saveVisits();
//     }
//   }
//
//   // Calculate stats
//   Map<String, int> _calculateStats() {
//     int total = _visits.length;
//     int completed = _visits.where((v) => v.status == 'completed').length;
//     int pending = _visits.where((v) => v.status == 'pending').length;
//     int missed = _visits.where((v) => v.status == 'missed').length;
//
//     return {
//       'total': total,
//       'completed': completed,
//       'pending': pending,
//       'missed': missed,
//     };
//   }
//
//   // Navigate to different screens based on index
//   void _navigateToScreen(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//
//     switch (index) {
//       case 0:
//       // Already on Home screen, no navigation needed
//         break;
//       case 1:
//       // Navigate to Tasks screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const TasksScreen(),
//           ),
//         ).then((_) {
//           // Reset to home when coming back
//           setState(() {
//             _currentIndex = 0;
//           });
//           // IMPORTANT: Reload visits data when returning from Tasks screen
//           _loadVisits();
//         });
//         break;
//       case 2:
//       // Navigate to Calendar screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CalendarScreen(),
//           ),
//         ).then((_) {
//           // Reset to home when coming back
//           setState(() {
//             _currentIndex = 0;
//           });
//           // IMPORTANT: Reload visits data when returning from Calendar screen
//           _loadVisits();
//         });
//         break;
//       case 3:
//       // Navigate to Profile screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const ProfileScreen(),
//           ),
//         ).then((_) {
//           // Reset to home when coming back
//           setState(() {
//             _currentIndex = 0;
//           });
//           // IMPORTANT: Reload visits data when returning from Profile screen
//           _loadVisits();
//         });
//         break;
//     }
//   }
//
//   // Build the actual home content
//   Widget _buildHomeContent() {
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: primaryBlue,
//         body: const Center(
//           child: CircularProgressIndicator(color: Colors.white),
//         ),
//       );
//     }
//
//     final stats = _calculateStats();
//
//     return Scaffold(
//       backgroundColor: primaryBlue,
//       body: Column(
//         children: [
//           // Custom AppBar with blue background
//           Container(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 16,
//               left: 24,
//               right: 24,
//               bottom: 24,
//             ),
//             decoration: const BoxDecoration(
//               color: primaryBlue,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Home',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   child: const Icon(
//                     Icons.notifications_outlined,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Main content
//           Expanded(
//             child: Container(
//               color: const Color(0xFFF8F9FA),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Welcome Section
//                     Text(
//                       'Welcome, $_userName!',
//                       style: const TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1A1A1A),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '${_getCurrentDateAndDay()} • $_currentLocation',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Color(0xFF666666),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//
//                     const SizedBox(height: 32),
//
//                     // Stats Section - Professional blue theme
//                     Row(
//                       children: [
//                         _buildStatCard('Total', '${stats['total']}', primaryBlue, Icons.assessment_outlined),
//                         const SizedBox(width: 12),
//                         _buildStatCard('Completed', '${stats['completed']}', primaryBlue, Icons.check_circle_outline),
//                         const SizedBox(width: 12),
//                         _buildStatCard('Pending', '${stats['pending']}', primaryBlue, Icons.schedule_outlined),
//                         const SizedBox(width: 12),
//                         _buildStatCard('Missed', '${stats['missed']}', primaryBlue, Icons.cancel_outlined),
//                       ],
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     // Visits List - All dynamic
//                     if (_visits.isEmpty)
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(40),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               spreadRadius: 0,
//                               blurRadius: 20,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.event_note_outlined,
//                               size: 64,
//                               color: primaryBlue.withOpacity(0.5),
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'No Visits Scheduled',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF1A1A1A),
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Text(
//                               'Schedule your first client visit to get started',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey[600],
//                                 height: 1.5,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       )
//                     else
//                     // Dynamic visits list
//                       Column(
//                         children: _visits.asMap().entries.map((entry) {
//                           final index = entry.key;
//                           final visit = entry.value;
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 16),
//                             child: _buildVisitCard(
//                               visit.clientName,
//                               visit.purpose,
//                               visit.location,
//                               _formatTime(visit.visitTime),
//                               visit.status,
//                               visit.phoneNumber,
//                               index,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: Container(
//         width: 64,
//         height: 64,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: primaryBlue.withOpacity(0.3),
//               spreadRadius: 0,
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: FloatingActionButton(
//           onPressed: () async {
//             final result = await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const AddVisitScreen(), // ✅ Using the updated AddVisitScreen
//               ),
//             );
//
//             if (result != null && result is summary.Visit) {
//               await _addVisit(result);
//             }
//           },
//           backgroundColor: primaryBlue,
//           elevation: 0,
//           child: const Icon(Icons.add, color: Colors.white, size: 28),
//         ),
//       ),
//       // Updated bottom navigation bar
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
//           currentIndex: 0, // Always show Home as selected since we navigate away
//           onTap: _navigateToScreen, // Use the navigation function
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: primaryBlue,
//           unselectedItemColor: Colors.grey.shade400,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           selectedLabelStyle: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 12,
//           ),
//           unselectedLabelStyle: const TextStyle(
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
//   Widget _buildStatCard(String title, String count, Color color, IconData icon) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               spreadRadius: 0,
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 28),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Color(0xFF666666),
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               count,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Updated professional visit card
//   Widget _buildVisitCard(String name, String purpose, String location, String time, String status, String phoneNumber, int index) {
//     IconData statusIcon;
//     String statusText;
//     Color statusColor;
//
//     switch (status) {
//       case 'completed':
//         statusIcon = Icons.check_circle_outline;
//         statusText = 'COMPLETED';
//         statusColor = Colors.green;
//         break;
//       case 'missed':
//         statusIcon = Icons.cancel_outlined;
//         statusText = 'MISSED';
//         statusColor = Colors.red;
//         break;
//       default:
//         statusIcon = Icons.schedule_outlined;
//         statusText = 'PENDING';
//         statusColor = Colors.orange;
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border(left: BorderSide(color: primaryBlue, width: 3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             spreadRadius: 0,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Client name and status row
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             name,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF1A1A1A),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: statusColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(statusIcon, size: 12, color: statusColor),
//                               const SizedBox(width: 4),
//                               Text(
//                                 statusText,
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w600,
//                                   color: statusColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 4),
//
//                     // Purpose
//                     Text(
//                       purpose,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF666666),
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//
//                     const SizedBox(height: 8),
//
//                     // Location row
//                     Row(
//                       children: [
//                         Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             location,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(width: 12),
//
//               // Time and call button column
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     time,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1A1A1A),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: () {
//                       debugPrint('Calling $phoneNumber');
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Calling $phoneNumber...'),
//                           backgroundColor: primaryBlue,
//                           duration: const Duration(seconds: 2),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: 36,
//                       height: 36,
//                       decoration: BoxDecoration(
//                         color: primaryBlue,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: primaryBlue.withOpacity(0.2),
//                             spreadRadius: 0,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(Icons.phone_outlined, color: Colors.white, size: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//
//           // Action buttons
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               if (status == 'pending') ...[
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _updateVisitStatus(index, 'completed'),
//                     icon: const Icon(Icons.check_outlined, size: 14),
//                     label: const Text('Complete', style: TextStyle(fontSize: 12)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryBlue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       elevation: 0,
//                       minimumSize: const Size(0, 32),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _updateVisitStatus(index, 'missed'),
//                     icon: const Icon(Icons.close_outlined, size: 14),
//                     label: const Text('Missed', style: TextStyle(fontSize: 12)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[100],
//                       foregroundColor: Colors.grey[700],
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       elevation: 0,
//                       minimumSize: const Size(0, 32),
//                     ),
//                   ),
//                 ),
//               ] else ...[
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _updateVisitStatus(index, 'pending'),
//                     icon: const Icon(Icons.refresh_outlined, size: 14),
//                     label: const Text('Mark Pending', style: TextStyle(fontSize: 12)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryBlue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       elevation: 0,
//                       minimumSize: const Size(0, 32),
//                     ),
//                   ),
//                 ),
//               ],
//               const SizedBox(width: 8),
//               ElevatedButton.icon(
//                 onPressed: () => _showDeleteConfirmation(index),
//                 icon: const Icon(Icons.delete_outline, size: 14),
//                 label: const Text('Delete', style: TextStyle(fontSize: 12)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red[50],
//                   foregroundColor: Colors.red[600],
//                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   elevation: 0,
//                   minimumSize: const Size(0, 32),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Show delete confirmation dialog
//   void _showDeleteConfirmation(int index) {
//     if (index < 0 || index >= _visits.length) return;
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text('Delete Visit'),
//           content: Text('Are you sure you want to delete the visit with ${_visits[index].clientName}?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _deleteVisit(index);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryBlue,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text('Delete', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   String _formatTime(DateTime dateTime) {
//     final formatter = DateFormat('HH:mm');
//     return formatter.format(dateTime);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _buildHomeContent();
//   }
// }
//
// // ❌ REMOVED - Old AddVisitScreen class that was here
// // Now using the updated one from add_visit_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'tasks_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'add_visit_screen.dart';
import 'client_summary_screen.dart' as summary;

class Visit {
  final String clientName;
  final String purpose;
  final String location;
  final String phoneNumber;
  final DateTime visitTime;
  final String status;
  final String notes;

  Visit({
    required this.clientName,
    required this.purpose,
    required this.location,
    required this.phoneNumber,
    required this.visitTime,
    this.status = 'pending',
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'purpose': purpose,
      'location': location,
      'phoneNumber': phoneNumber,
      'visitTime': visitTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      clientName: json['clientName'] ?? '',
      purpose: json['purpose'] ?? '',
      location: json['location'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      visitTime: DateTime.parse(json['visitTime']),
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
    );
  }

  Visit copyWith({String? status}) {
    return Visit(
      clientName: clientName,
      purpose: purpose,
      location: location,
      phoneNumber: phoneNumber,
      visitTime: visitTime,
      status: status ?? this.status,
      notes: notes,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Visit> _visits = [];
  String _userName = '';
  String _userId = '';
  String _currentLocation = 'Loading...';
  bool _isLoading = true;

  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color darkBlue = Color(0xFF0A2A4F);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _loadVisits();
    await _getCurrentLocation();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
            _userName = userData['name']?.split(' ')[0] ?? 'User';
            _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
          });
        }
        debugPrint('✅ User loaded: $_userName (ID: $_userId)');
      } else {
        if (mounted) {
          setState(() {
            _userName = 'Professional';
            _userId = 'default';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      if (mounted) {
        setState(() {
          _userName = 'Professional';
          _userId = 'default';
        });
      }
    }
  }

  Future<void> _loadVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String visitsKey = 'visits_$_userId';
      final visitsString = prefs.getString(visitsKey);

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        if (mounted) {
          setState(() {
            _visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
          });
        }
        debugPrint('✅ Loaded ${_visits.length} visits for user: $_userId');
      } else {
        if (mounted) {
          setState(() {
            _visits = [];
          });
        }
        debugPrint('ℹ️ No visits found for user: $_userId');
      }
    } catch (e) {
      debugPrint('❌ Error loading visits: $e');
      if (mounted) {
        setState(() {
          _visits = [];
        });
      }
    }
  }

  Future<void> _saveVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String visitsKey = 'visits_$_userId';
      final visitsJson = _visits.map((visit) => visit.toJson()).toList();
      await prefs.setString(visitsKey, jsonEncode(visitsJson));
      debugPrint('✅ Saved ${_visits.length} visits for user: $_userId');
    } catch (e) {
      debugPrint('❌ Error saving visits: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _currentLocation = 'Coimbatore, Tamil Nadu';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _currentLocation = 'Coimbatore, Tamil Nadu';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _currentLocation = 'Coimbatore, Tamil Nadu';
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _currentLocation = 'Coimbatore, Tamil Nadu';
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        setState(() {
          _currentLocation = 'Coimbatore, Tamil Nadu';
        });
      }
    }
  }

  String _getCurrentDateAndDay() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM dd');
    return formatter.format(now);
  }

  Future<void> _addVisit(summary.Visit visit) async {
    final localVisit = Visit(
      clientName: visit.clientName,
      purpose: visit.purpose,
      location: visit.location,
      phoneNumber: visit.phoneNumber,
      visitTime: visit.visitTime,
      status: visit.status,
      notes: visit.notes,
    );

    setState(() {
      _visits.add(localVisit);
    });
    await _saveVisits();
  }

  Future<void> _updateVisitStatus(int index, String newStatus) async {
    if (index >= 0 && index < _visits.length) {
      setState(() {
        _visits[index] = _visits[index].copyWith(status: newStatus);
      });
      await _saveVisits();
    }
  }

  Future<void> _deleteVisit(int index) async {
    if (index >= 0 && index < _visits.length) {
      setState(() {
        _visits.removeAt(index);
      });
      await _saveVisits();
    }
  }

  Map<String, int> _calculateStats() {
    int total = _visits.length;
    int completed = _visits.where((v) => v.status == 'completed').length;
    int pending = _visits.where((v) => v.status == 'pending').length;
    int missed = _visits.where((v) => v.status == 'missed').length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'missed': missed,
    };
  }

  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TasksScreen(),
          ),
        ).then((_) {
          setState(() {
            _currentIndex = 0;
          });
          _loadVisits();
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalendarScreen(),
          ),
        ).then((_) {
          setState(() {
            _currentIndex = 0;
          });
          _loadVisits();
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        ).then((_) {
          setState(() {
            _currentIndex = 0;
          });
          _loadVisits();
        });
        break;
    }
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: primaryBlue,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: primaryBlue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $_userName!',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_getCurrentDateAndDay()} • $_currentLocation',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _buildStatCard('Total', '${stats['total']}', primaryBlue, Icons.assessment_outlined),
                        const SizedBox(width: 12),
                        _buildStatCard('Completed', '${stats['completed']}', primaryBlue, Icons.check_circle_outline),
                        const SizedBox(width: 12),
                        _buildStatCard('Pending', '${stats['pending']}', primaryBlue, Icons.schedule_outlined),
                        const SizedBox(width: 12),
                        _buildStatCard('Missed', '${stats['missed']}', primaryBlue, Icons.cancel_outlined),
                      ],
                    ),
                    const SizedBox(height: 40),
                    if (_visits.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              spreadRadius: 0,
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_note_outlined,
                              size: 64,
                              color: primaryBlue.withOpacity(0.5),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Visits Scheduled',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Schedule your first client visit to get started',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: _visits.asMap().entries.map((entry) {
                          final index = entry.key;
                          final visit = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildVisitCard(
                              visit.clientName,
                              visit.purpose,
                              visit.location,
                              _formatTime(visit.visitTime),
                              visit.status,
                              visit.phoneNumber,
                              visit.notes,
                              index,
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddVisitScreen(),
              ),
            );

            if (result != null && result is summary.Visit) {
              await _addVisit(result);
            }
          },
          backgroundColor: primaryBlue,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
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
          currentIndex: 0,
          onTap: _navigateToScreen,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryBlue,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
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

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(String name, String purpose, String location, String time, String status, String phoneNumber, String notes, int index) {
    IconData statusIcon;
    String statusText;
    Color statusColor;

    switch (status) {
      case 'completed':
        statusIcon = Icons.check_circle_outline;
        statusText = 'COMPLETED';
        statusColor = Colors.green;
        break;
      case 'missed':
        statusIcon = Icons.cancel_outlined;
        statusText = 'MISSED';
        statusColor = Colors.red;
        break;
      default:
        statusIcon = Icons.schedule_outlined;
        statusText = 'PENDING';
        statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: primaryBlue, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      purpose,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Display Notes if available
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes_outlined, size: 14, color: primaryBlue.withOpacity(0.7)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                notes,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      debugPrint('Calling $phoneNumber');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling $phoneNumber...'),
                          backgroundColor: primaryBlue,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.phone_outlined, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (status == 'pending') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateVisitStatus(index, 'completed'),
                    icon: const Icon(Icons.check_outlined, size: 14),
                    label: const Text('Complete', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateVisitStatus(index, 'missed'),
                    icon: const Icon(Icons.close_outlined, size: 14),
                    label: const Text('Missed', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateVisitStatus(index, 'pending'),
                    icon: const Icon(Icons.refresh_outlined, size: 14),
                    label: const Text('Mark Pending', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(index),
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('Delete', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    if (index < 0 || index >= _visits.length) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Visit'),
          content: Text('Are you sure you want to delete the visit with ${_visits[index].clientName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteVisit(index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeContent();
  }
}