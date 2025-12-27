//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:geolocator/geolocator.dart';
// // Import your other screens - adjust paths as needed
// // import '../utils/constants.dart';
// // import 'profile_screen.dart';
// // import 'tasks_screen.dart';
// // import 'notifications_screen.dart';
// // import 'add_visit_screen.dart';
//
// // Model class for Visit data
// class Visit {
//   final String clientName;
//   final String purpose;
//   final String location;
//   final String phoneNumber;
//   final DateTime visitTime;
//   final String status; // 'pending', 'completed', 'missed'
//
//   Visit({
//     required this.clientName,
//     required this.purpose,
//     required this.location,
//     required this.phoneNumber,
//     required this.visitTime,
//     this.status = 'pending',
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
//     await _loadUserData();
//     await _loadVisits();
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
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _userName = 'Professional';
//         });
//       }
//     }
//   }
//
//   // Load visits from SharedPreferences
//   Future<void> _loadVisits() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final visitsString = prefs.getString('visits');
//
//       if (visitsString != null) {
//         final List<dynamic> visitsJson = jsonDecode(visitsString);
//         if (mounted) {
//           setState(() {
//             _visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error loading visits: $e');
//     }
//   }
//
//   // Save visits to SharedPreferences
//   Future<void> _saveVisits() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final visitsJson = _visits.map((visit) => visit.toJson()).toList();
//       await prefs.setString('visits', jsonEncode(visitsJson));
//     } catch (e) {
//       debugPrint('Error saving visits: $e');
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
//   Future<void> _addVisit(Visit visit) async {
//     setState(() {
//       _visits.add(visit);
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
//                 builder: (context) => const AddVisitScreen(),
//               ),
//             );
//
//             if (result != null && result is Visit) {
//               await _addVisit(result);
//             }
//           },
//           backgroundColor: primaryBlue,
//           elevation: 0,
//           child: const Icon(Icons.add, color: Colors.white, size: 28),
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
//   // Placeholder screens - replace with your actual screens
//   Widget _buildPlaceholderScreen(String title) {
//     return Center(
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 24,
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_currentIndex == 0) {
//       return _buildHomeContent();
//     }
//
//     // Handle other screens
//     Widget selectedScreen;
//     switch (_currentIndex) {
//       case 1:
//         selectedScreen = _buildPlaceholderScreen('Tasks');
//         break;
//       case 2:
//         selectedScreen = _buildPlaceholderScreen('Calendar');
//         break;
//       case 3:
//         selectedScreen = _buildPlaceholderScreen('Profile');
//         break;
//       default:
//         selectedScreen = _buildHomeContent();
//     }
//
//     return Scaffold(
//       backgroundColor: primaryBlue,
//       body: selectedScreen,
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
//           currentIndex: _currentIndex,
//           onTap: (index) => setState(() => _currentIndex = index),
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
// }
//
// // Add Visit Screen
// class AddVisitScreen extends StatefulWidget {
//   const AddVisitScreen({super.key});
//
//   @override
//   State<AddVisitScreen> createState() => _AddVisitScreenState();
// }
//
// class _AddVisitScreenState extends State<AddVisitScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _clientNameController = TextEditingController();
//   final _purposeController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _phoneController = TextEditingController();
//
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   bool _isLoading = false;
//
//   static const Color primaryBlue = Color(0xFF0F3A68);
//
//   @override
//   void dispose() {
//     _clientNameController.dispose();
//     _purposeController.dispose();
//     _locationController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (BuildContext context, Widget? child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: primaryBlue,
//               onPrimary: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//       builder: (BuildContext context, Widget? child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: primaryBlue,
//               onPrimary: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }
//
//   void _saveVisit() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//
//       try {
//         // Combine date and time
//         final DateTime visitDateTime = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           _selectedTime.hour,
//           _selectedTime.minute,
//         );
//
//         final visit = Visit(
//           clientName: _clientNameController.text.trim(),
//           purpose: _purposeController.text.trim(),
//           location: _locationController.text.trim(),
//           phoneNumber: _phoneController.text.trim(),
//           visitTime: visitDateTime,
//           status: 'pending',
//         );
//
//         // Return the visit to the home screen
//         if (mounted) {
//           Navigator.pop(context, visit);
//
//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Visit scheduled successfully!'),
//               backgroundColor: primaryBlue,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error scheduling visit: $e'),
//               backgroundColor: Colors.red,
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return DateFormat('dd/MM/yyyy').format(date);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: primaryBlue,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Schedule New Visit',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.04),
//                       spreadRadius: 0,
//                       blurRadius: 20,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 56,
//                       height: 56,
//                       decoration: BoxDecoration(
//                         color: primaryBlue.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.person_add_outlined,
//                         color: primaryBlue,
//                         size: 28,
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Schedule New Visit',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF1A1A1A),
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             'Fill in the client details below',
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Color(0xFF666666),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 32),
//
//               // Form Fields
//               _buildInputField(
//                 controller: _clientNameController,
//                 label: 'Client Name',
//                 hint: 'Enter client full name',
//                 icon: Icons.person_outlined,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter client name';
//                   }
//                   if (value.trim().length < 2) {
//                     return 'Client name must be at least 2 characters';
//                   }
//                   return null;
//                 },
//               ),
//
//               const SizedBox(height: 20),
//
//               _buildInputField(
//                 controller: _purposeController,
//                 label: 'Purpose of Visit',
//                 hint: 'e.g., Meeting, Document Collection, Follow-up',
//                 icon: Icons.business_center_outlined,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter purpose of visit';
//                   }
//                   return null;
//                 },
//               ),
//
//               const SizedBox(height: 20),
//
//               _buildInputField(
//                 controller: _locationController,
//                 label: 'Location',
//                 hint: 'Enter visit location/address',
//                 icon: Icons.location_on_outlined,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter location';
//                   }
//                   return null;
//                 },
//               ),
//
//               const SizedBox(height: 20),
//
//               _buildInputField(
//                 controller: _phoneController,
//                 label: 'Client Phone Number',
//                 hint: 'Enter 10-digit phone number',
//                 icon: Icons.phone_outlined,
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter phone number';
//                   }
//                   // Remove any spaces or special characters for validation
//                   String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
//                   if (cleanPhone.length != 10) {
//                     return 'Please enter valid 10-digit phone number';
//                   }
//                   return null;
//                 },
//               ),
//
//               const SizedBox(height: 20),
//
//               // Date Selection
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.04),
//                       spreadRadius: 0,
//                       blurRadius: 20,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Row(
//                       children: [
//                         Icon(
//                           Icons.calendar_today_outlined,
//                           color: primaryBlue,
//                           size: 24,
//                         ),
//                         SizedBox(width: 16),
//                         Text(
//                           'Visit Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF1A1A1A),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     GestureDetector(
//                       onTap: () => _selectDate(context),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: primaryBlue.withOpacity(0.3)),
//                           borderRadius: BorderRadius.circular(12),
//                           color: primaryBlue.withOpacity(0.05),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               _formatDate(_selectedDate),
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Color(0xFF1A1A1A),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             Icon(
//                               Icons.keyboard_arrow_down_outlined,
//                               color: primaryBlue,
//                               size: 24,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Time Selection
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.04),
//                       spreadRadius: 0,
//                       blurRadius: 20,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Row(
//                       children: [
//                         Icon(
//                           Icons.access_time_outlined,
//                           color: primaryBlue,
//                           size: 24,
//                         ),
//                         SizedBox(width: 16),
//                         Text(
//                           'Visit Time',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF1A1A1A),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     GestureDetector(
//                       onTap: () => _selectTime(context),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: primaryBlue.withOpacity(0.3)),
//                           borderRadius: BorderRadius.circular(12),
//                           color: primaryBlue.withOpacity(0.05),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               _selectedTime.format(context),
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Color(0xFF1A1A1A),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             Icon(
//                               Icons.keyboard_arrow_down_outlined,
//                               color: primaryBlue,
//                               size: 24,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // Save Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _saveVisit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryBlue,
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 0,
//                     shadowColor: primaryBlue.withOpacity(0.3),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                     height: 24,
//                     width: 24,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2.5,
//                     ),
//                   )
//                       : const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.event_available_outlined, color: Colors.white, size: 22),
//                       SizedBox(width: 12),
//                       Text(
//                         'Schedule Visit',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 17,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Cancel Button
//               SizedBox(
//                 width: double.infinity,
//                 child: TextButton(
//                   onPressed: _isLoading ? null : () => Navigator.pop(context),
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       side: BorderSide(color: primaryBlue.withOpacity(0.3)),
//                     ),
//                   ),
//                   child: Text(
//                     'Cancel',
//                     style: TextStyle(
//                       color: primaryBlue,
//                       fontSize: 17,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             spreadRadius: 0,
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: primaryBlue,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 16),
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: controller,
//               keyboardType: keyboardType,
//               validator: validator,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF1A1A1A),
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: TextStyle(
//                   color: Colors.grey[500],
//                   fontWeight: FontWeight.w400,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: primaryBlue, width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.red),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.red, width: 2),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//                 filled: true,
//                 fillColor: primaryBlue.withOpacity(0.05),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'tasks_screen.dart';  // Remove the '../' prefix if they're in the same directory

// Import your actual screens - uncomment and adjust paths as needed
// import 'tasks_screen.dart';
// import 'calendar_screen.dart';
// import 'profile_screen.dart';

// Model class for Visit data
class Visit {
  final String clientName;
  final String purpose;
  final String location;
  final String phoneNumber;
  final DateTime visitTime;
  final String status; // 'pending', 'completed', 'missed'

  Visit({
    required this.clientName,
    required this.purpose,
    required this.location,
    required this.phoneNumber,
    required this.visitTime,
    this.status = 'pending',
  });

  // Convert Visit to JSON
  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'purpose': purpose,
      'location': location,
      'phoneNumber': phoneNumber,
      'visitTime': visitTime.toIso8601String(),
      'status': status,
    };
  }

  // Create Visit from JSON
  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      clientName: json['clientName'] ?? '',
      purpose: json['purpose'] ?? '',
      location: json['location'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      visitTime: DateTime.parse(json['visitTime']),
      status: json['status'] ?? 'pending',
    );
  }

  // Create a copy of visit with updated status
  Visit copyWith({String? status}) {
    return Visit(
      clientName: clientName,
      purpose: purpose,
      location: location,
      phoneNumber: phoneNumber,
      visitTime: visitTime,
      status: status ?? this.status,
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
  String _currentLocation = 'Loading...';
  bool _isLoading = true;

  // Professional blue color scheme
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color darkBlue = Color(0xFF0A2A4F);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialize all data
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

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final userData = jsonDecode(userString);
        if (mounted) {
          setState(() {
            _userName = userData['name']?.split(' ')[0] ?? 'User';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'Professional';
        });
      }
    }
  }

  // Load visits from SharedPreferences
  Future<void> _loadVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsString = prefs.getString('visits');

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        if (mounted) {
          setState(() {
            _visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading visits: $e');
    }
  }

  // Save visits to SharedPreferences
  Future<void> _saveVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsJson = _visits.map((visit) => visit.toJson()).toList();
      await prefs.setString('visits', jsonEncode(visitsJson));
    } catch (e) {
      debugPrint('Error saving visits: $e');
    }
  }

  // Get current location with proper error handling
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

      // For demo purposes, using hardcoded location based on coordinates
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

  // Get current date and day
  String _getCurrentDateAndDay() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM dd');
    return formatter.format(now);
  }

  // Add a new visit to the list
  Future<void> _addVisit(Visit visit) async {
    setState(() {
      _visits.add(visit);
    });
    await _saveVisits();
  }

  // Update visit status
  Future<void> _updateVisitStatus(int index, String newStatus) async {
    if (index >= 0 && index < _visits.length) {
      setState(() {
        _visits[index] = _visits[index].copyWith(status: newStatus);
      });
      await _saveVisits();
    }
  }

  // Delete visit
  Future<void> _deleteVisit(int index) async {
    if (index >= 0 && index < _visits.length) {
      setState(() {
        _visits.removeAt(index);
      });
      await _saveVisits();
    }
  }

  // Calculate stats
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

  // Navigate to different screens based on index
  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
      // Already on Home screen, no navigation needed
        break;
      case 1:
      // Navigate to Tasks screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TasksScreen(), // Replace with your actual TasksScreen
          ),
        ).then((_) {
          // Reset to home when coming back
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 2:
      // Navigate to Calendar screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalendarScreen(), // Replace with your actual CalendarScreen
          ),
        ).then((_) {
          // Reset to home when coming back
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 3:
      // Navigate to Profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(), // Replace with your actual ProfileScreen
          ),
        ).then((_) {
          // Reset to home when coming back
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
    }
  }

  // Build the actual home content
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
          // Custom AppBar with blue background
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

          // Main content
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
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

                    // Stats Section - Professional blue theme
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

                    // Visits List - All dynamic
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
                    // Dynamic visits list
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

            if (result != null && result is Visit) {
              await _addVisit(result);
            }
          },
          backgroundColor: primaryBlue,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      // Updated bottom navigation bar
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
          currentIndex: 0, // Always show Home as selected since we navigate away
          onTap: _navigateToScreen, // Use the navigation function
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

  // Updated professional visit card
  Widget _buildVisitCard(String name, String purpose, String location, String time, String status, String phoneNumber, int index) {
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
                    // Client name and status row
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

                    // Purpose
                    Text(
                      purpose,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Location row
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
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Time and call button column
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

          // Action buttons
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

  // Show delete confirmation dialog
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

// Placeholder screen classes - Replace these with your actual screen implementations
// class TasksScreen extends StatelessWidget {
//   const TasksScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tasks'),
//         backgroundColor: const Color(0xFF0F3A68),
//         foregroundColor: Colors.white,
//       ),
//       body: const Center(
//         child: Text(
//           'Tasks Screen\n\nReplace this with your actual TasksScreen implementation',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: const Color(0xFF0F3A68),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Calendar Screen\n\nReplace this with your actual CalendarScreen implementation',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0F3A68),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Profile Screen\n\nReplace this with your actual ProfileScreen implementation',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// Add Visit Screen - keeping this from your original code
class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF0F3A68);

  @override
  void dispose() {
    _clientNameController.dispose();
    _purposeController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveVisit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Combine date and time
        final DateTime visitDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final visit = Visit(
          clientName: _clientNameController.text.trim(),
          purpose: _purposeController.text.trim(),
          location: _locationController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          visitTime: visitDateTime,
          status: 'pending',
        );

        // Return the visit to the home screen
        if (mounted) {
          Navigator.pop(context, visit);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visit scheduled successfully!'),
              backgroundColor: primaryBlue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error scheduling visit: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule New Visit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule New Visit',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fill in the client details below',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form Fields
              _buildInputField(
                controller: _clientNameController,
                label: 'Client Name',
                hint: 'Enter client full name',
                icon: Icons.person_outlined,
                validator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) {
                    return 'Please enter client name';
                  }
                  if (value
                      .trim()
                      .length < 2) {
                    return 'Client name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildInputField(
                controller: _purposeController,
                label: 'Purpose of Visit',
                hint: 'e.g., Meeting, Document Collection, Follow-up',
                icon: Icons.business_center_outlined,
                validator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) {
                    return 'Please enter purpose of visit';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildInputField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter visit location/address',
                icon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildInputField(
                controller: _phoneController,
                label: 'Client Phone Number',
                hint: 'Enter 10-digit phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) {
                    return 'Please enter phone number';
                  }
                  // Remove any spaces or special characters for validation
                  String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (cleanPhone.length != 10) {
                    return 'Please enter valid 10-digit phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Date Selection
              Container(
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: primaryBlue,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Visit Date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: primaryBlue.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                          color: primaryBlue.withOpacity(0.05),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: primaryBlue,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Time Selection
              Container(
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          color: primaryBlue,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Visit Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: primaryBlue.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                          color: primaryBlue.withOpacity(0.05),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: primaryBlue,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveVisit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: primaryBlue.withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available_outlined, color: Colors.white,
                          size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Schedule Visit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: primaryBlue.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryBlue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                filled: true,
                fillColor: primaryBlue.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }
}