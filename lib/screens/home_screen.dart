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

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'tasks_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'add_visit_screen.dart';
import 'client_summary_screen.dart' as summary;
import 'notifications_screen.dart';
import 'leads_screen.dart';
import 'filtered_tasks_screen.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'expense_screen.dart';

class Visit {
  final int? id;
  final String clientName;
  final String purpose;
  final String location;
  final String phoneNumber;
  final DateTime visitTime;
  final String status;
  final String notes;
  final bool isTask;

  Visit({
    this.id,
    required this.clientName,
    required this.purpose,
    required this.location,
    required this.phoneNumber,
    required this.visitTime,
    this.status = 'pending',
    this.notes = '',
    this.isTask = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'purpose': purpose,
      'location': location,
      'phoneNumber': phoneNumber,
      'visitTime': visitTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'isTask': isTask,
    };
  }

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      clientName: json['clientName'] ?? json['client_name'] ?? '',
      purpose: json['purpose'] ?? json['title'] ?? '',
      location: json['location'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['client_phone'] ?? '',
      visitTime: json['visitTime'] != null 
          ? DateTime.parse(json['visitTime']) 
          : json['scheduled_time'] != null 
              ? DateTime.parse(json['scheduled_time']) 
              : json['created_at'] != null 
                  ? DateTime.parse(json['created_at']) 
                  : DateTime.now(),
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
      isTask: json['isTask'] ?? json['assigned_to'] != null,
    );
  }

  Visit copyWith({int? id, String? status}) {
    return Visit(
      id: id ?? this.id,
      clientName: clientName,
      purpose: purpose,
      location: location,
      phoneNumber: phoneNumber,
      visitTime: visitTime,
      status: status ?? this.status,
      notes: notes,
      isTask: isTask,
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
  int _unreadNotifications = 0;

  // Notification polling subscriptions
  StreamSubscription<int>? _unreadSub;
  StreamSubscription<String>? _newNotifSub;

  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color darkBlue = Color(0xFF0A2A4F);

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupNotificationPolling();
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    _newNotifSub?.cancel();
    NotificationService().stopPolling();
    super.dispose();
  }

  void _setupNotificationPolling() {
    final notifService = NotificationService();
    notifService.startPolling();

    _unreadSub = notifService.unreadCountStream.listen((count) {
      if (mounted) {
        setState(() => _unreadNotifications = count);
      }
    });

    _newNotifSub = notifService.newNotificationStream.listen((message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: primaryBlue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ).then((_) => NotificationService().pollNow());
              },
            ),
          ),
        );
      }
    });
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _loadVisits();
    await _getCurrentLocation();
    await _loadNotificationCount();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotificationCount() async {
    try {
      final response = await ApiService.getNotifications();
      if (response['success'] == true && mounted) {
        setState(() {
          _unreadNotifications = response['unreadCount'] ?? 0;
        });
      }
    } catch (_) {
      // Notification count is non-critical, silently ignore
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
    setState(() => _isLoading = true);
    try {
      // Fetch only tasks now
      final taskRes = await ApiService.getTasks();

      List<Visit> combined = [];

      if (taskRes['success'] == true && taskRes['data'] != null) {
        final List data = taskRes['data'];
        combined.addAll(data.map((e) => Visit.fromJson(e as Map<String, dynamic>)));
      }

      if (mounted) {
        setState(() {
          _visits = combined;
          _visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
          _isLoading = false;
        });
      }
      
      if (combined.isNotEmpty) {
        await _saveVisits();
        return;
      }
    } catch (e) {
      debugPrint('ℹ️ API load failed, falling back to local: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String visitsKey = 'visits_$_userId';
      final visitsString = prefs.getString(visitsKey);

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        if (mounted) {
          setState(() {
            _visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
            _visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error loading visits: $e');
      if (mounted) setState(() => _isLoading = false);
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
        if (mounted) setState(() => _currentLocation = 'Location unavailable');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _currentLocation = 'Location denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _currentLocation = 'Location denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Reverse geocode using Nominatim (free, no API key)
      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) setState(() => _currentLocation = 'Location unavailable');
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'PegasosFieldApp/1.0'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] ?? {};
        final city = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'] ??
            '';
        final state = address['state'] ?? '';
        if (city.isNotEmpty || state.isNotEmpty) {
          if (mounted) {
            setState(() {
              _currentLocation = [city, state]
                  .where((s) => s.isNotEmpty)
                  .join(', ');
            });
          }
          return;
        }
      }
      if (mounted) setState(() => _currentLocation = 'Location unavailable');
    } catch (e) {
      debugPrint('Geocoding error: $e');
      if (mounted) setState(() => _currentLocation = 'Location unavailable');
    }
  }

  String _getCurrentDateAndDay() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy');
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

    // REQ #4: Schedule a local push notification reminder (30 mins before)
    await NotificationService().scheduleVisitReminder(
      visitId: (DateTime.now().millisecondsSinceEpoch % 2147483647).toInt(),
      clientName: localVisit.clientName,
      title: localVisit.purpose,
      visitTime: localVisit.visitTime,
      minutesBefore: 30,
    );
  }

  Future<void> _updateVisitStatus(int index, String newStatus) async {
    if (index >= 0 && index < _visits.length) {
      final visit = _visits[index];
      if (visit.id == null) {
        _showSnackBar('Cannot update task without ID', isError: true);
        return;
      }

      setState(() => _isLoading = true);
      try {
        final response = await ApiService.updateTaskStatus(visit.id!, newStatus);

        if (response['success'] == true) {
          await _loadVisits(); // Refresh list from API
          _showSnackBar('Status updated: $newStatus');
        } else {
          _showSnackBar(response['message'] ?? 'Failed to update status', isError: true);
        }
      } catch (e) {
        _showSnackBar('Network error: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _deleteVisit(int index) async {
    if (index >= 0 && index < _visits.length) {
      final visit = _visits[index];
      if (visit.id == null) {
        _showSnackBar('Cannot delete task without ID', isError: true);
        return;
      }

      setState(() => _isLoading = true);
      try {
        final response = await ApiService.deleteTask(visit.id!);
        if (response['success'] == true) {
          await _loadVisits(); // Refresh list from API
          _showSnackBar('Visit deleted successfully');
        } else {
          _showSnackBar(response['message'] ?? 'Failed to delete task', isError: true);
        }
      } catch (e) {
        _showSnackBar('Network error: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
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
      case 1: // Leads
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LeadsScreen(),
          ),
        ).then((_) {
          setState(() => _currentIndex = 0);
          _loadVisits();
        });
        break;
      case 2: // Tasks
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TasksScreen(),
          ),
        ).then((_) {
          setState(() => _currentIndex = 0);
          _loadVisits();
        });
        break;
      case 3: // Calendar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalendarScreen(),
          ),
        ).then((_) {
          setState(() => _currentIndex = 0);
          _loadVisits();
        });
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        ).then((_) {
          setState(() => _currentIndex = 0);
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                        _loadNotificationCount();
                      },
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          if (_unreadNotifications > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$_unreadNotifications',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _logout(context),
                    ),
                  ],
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
                    const SizedBox(height: 24),
                    

                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _buildClickableStatCard('Total', '${stats['total']}', primaryBlue, Icons.assessment_outlined, 'all', 'Total'),
                        const SizedBox(width: 12),
                        _buildClickableStatCard('Completed', '${stats['completed']}', Colors.green, Icons.check_circle_outline, 'completed', 'Completed'),
                        const SizedBox(width: 12),
                        _buildClickableStatCard('Pending', '${stats['pending']}', Colors.orange, Icons.schedule_outlined, 'pending', 'Pending'),
                        const SizedBox(width: 12),
                        _buildClickableStatCard('Missed', '${stats['missed']}', Colors.red, Icons.cancel_outlined, 'missed', 'Missed'),
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

            if (result == true) {
              await _loadVisits();
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
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Leads',
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

  Widget _buildClickableStatCard(String title, String count, Color color, IconData icon, String filterStatus, String filterLabel) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilteredTasksScreen(
                filterStatus: filterStatus,
                filterLabel: filterLabel,
              ),
            ),
          ).then((_) => _loadVisits());
        },
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
                    onTap: () async {
                      final uri = Uri.parse('tel:$phoneNumber');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not call $phoneNumber'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
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
                    onPressed: () => _showEditTaskDialog(_visits[index]),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              ] else ...[
                // Completed/Missed task — LOCKED
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: status == 'completed' ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: status == 'completed' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: status == 'completed' ? Colors.green[700] : Colors.red[700]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'This task is locked and cannot be modified',
                            style: TextStyle(fontSize: 11, color: status == 'completed' ? Colors.green[700] : Colors.red[700], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Mail It button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final subject = Uri.encodeComponent('Visit Update: $name');
                final body = Uri.encodeComponent(
                  'Client: $name\n'
                  'Title: $purpose\n'
                  'Location: $location\n'
                  'Time: $time\n'
                  'Status: ${status.toUpperCase()}\n'
                  'Notes: $notes',
                );
                final uri = Uri.parse('mailto:?subject=$subject&body=$body');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.email_outlined, size: 14),
              label: const Text('Mail It', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 30),
              ),
            ),
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
  // ── Edit Task Dialog ──
  void _showEditTaskDialog(Visit visit) {
    final titleController = TextEditingController(text: visit.purpose);
    final locationController = TextEditingController(text: visit.location);
    final notesController = TextEditingController(text: visit.notes);
    final phoneController = TextEditingController(text: visit.phoneNumber);
    DateTime selectedDate = visit.visitTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(visit.visitTime);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.edit, color: primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  const Text('Edit Task', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title / Purpose
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title / Purpose',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Location
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Phone
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Date picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (c, child) => Theme(
                            data: Theme.of(c).copyWith(
                              colorScheme: const ColorScheme.light(primary: primaryBlue),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = DateTime(
                            picked.year, picked.month, picked.day,
                            selectedTime.hour, selectedTime.minute,
                          ));
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true, fillColor: Colors.grey[50],
                        ),
                        child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Time picker
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (c, child) => Theme(
                            data: Theme.of(c).copyWith(
                              colorScheme: const ColorScheme.light(primary: primaryBlue),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                            selectedDate = DateTime(
                              selectedDate.year, selectedDate.month, selectedDate.day,
                              picked.hour, picked.minute,
                            );
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true, fillColor: Colors.grey[50],
                        ),
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Notes
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: const Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _editTask(
                      visit,
                      title: titleController.text.trim(),
                      location: locationController.text.trim(),
                      phone: phoneController.text.trim(),
                      notes: notesController.text.trim(),
                      scheduledTime: selectedDate,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editTask(Visit visit, {
    required String title,
    required String location,
    required String phone,
    required String notes,
    required DateTime scheduledTime,
  }) async {
    if (visit.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit task without ID'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.editTask(visit.id!, {
        'title': title,
        'location': location,
        'client_phone': phone,
        'notes': notes,
        'scheduled_time': scheduledTime.toUtc().toIso8601String(),
      });

      if (response['success'] == true) {
        await _loadVisits();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update task'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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