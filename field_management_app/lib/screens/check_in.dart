// //
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // // Visit model (matching your tasks_screen.dart)
// // class Visit {
// //   final String clientName;
// //   final String purpose;
// //   final String location;
// //   final String phoneNumber;
// //   final DateTime visitTime;
// //   final String status;
// //   final String notes;
// //
// //   Visit({
// //     required this.clientName,
// //     required this.purpose,
// //     required this.location,
// //     required this.phoneNumber,
// //     required this.visitTime,
// //     this.status = 'pending',
// //     this.notes = '',
// //   });
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'clientName': clientName,
// //       'purpose': purpose,
// //       'location': location,
// //       'phoneNumber': phoneNumber,
// //       'visitTime': visitTime.toIso8601String(),
// //       'status': status,
// //       'notes': notes,
// //     };
// //   }
// //
// //   factory Visit.fromJson(Map<String, dynamic> json) {
// //     return Visit(
// //       clientName: json['clientName'] ?? '',
// //       purpose: json['purpose'] ?? '',
// //       location: json['location'] ?? '',
// //       phoneNumber: json['phoneNumber'] ?? '',
// //       visitTime: DateTime.parse(json['visitTime']),
// //       status: json['status'] ?? 'pending',
// //       notes: json['notes'] ?? '',
// //     );
// //   }
// // }
// //
// // // Check-in session model to group visits
// // class CheckInSession {
// //   final DateTime date;
// //   final List<Visit> visits;
// //
// //   CheckInSession({
// //     required this.date,
// //     required this.visits,
// //   });
// // }
// //
// // class CheckInHistoryScreen extends StatefulWidget {
// //   const CheckInHistoryScreen({super.key});
// //
// //   @override
// //   State<CheckInHistoryScreen> createState() => _CheckInHistoryScreenState();
// // }
// //
// // class _CheckInHistoryScreenState extends State<CheckInHistoryScreen> {
// //   static const Color primaryBlue = Color(0xFF0F3A68);
// //   static const Color tealGreen = Color(0xFF00897B);
// //
// //   DateTime selectedDate = DateTime.now();
// //   List<Visit> allVisits = [];
// //   bool isLoading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadVisits();
// //   }
// //
// //   Future<void> _loadVisits() async {
// //     try {
// //       setState(() => isLoading = true);
// //       final prefs = await SharedPreferences.getInstance();
// //       final visitsString = prefs.getString('visits');
// //
// //       if (visitsString != null) {
// //         final List<dynamic> visitsJson = jsonDecode(visitsString);
// //         setState(() {
// //           allVisits = visitsJson.map((json) => Visit.fromJson(json)).toList();
// //           // Sort by date/time
// //           allVisits.sort((a, b) => b.visitTime.compareTo(a.visitTime));
// //           isLoading = false;
// //         });
// //       } else {
// //         setState(() {
// //           allVisits = [];
// //           isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         allVisits = [];
// //         isLoading = false;
// //       });
// //     }
// //   }
// //
// //   // Get completed visits filtered by selected date
// //   List<CheckInSession> _getCheckInSessions() {
// //     // Filter completed visits for the selected date
// //     final selectedDateOnly = DateTime(
// //       selectedDate.year,
// //       selectedDate.month,
// //       selectedDate.day,
// //     );
// //
// //     final completedVisits = allVisits.where((visit) {
// //       final visitDateOnly = DateTime(
// //         visit.visitTime.year,
// //         visit.visitTime.month,
// //         visit.visitTime.day,
// //       );
// //
// //       return (visit.status == 'completed' || visit.status == 'successfully_met') &&
// //           visitDateOnly.isAtSameMomentAs(selectedDateOnly);
// //     }).toList();
// //
// //     if (completedVisits.isEmpty) return [];
// //
// //     // Create individual check-in sessions for each completed visit
// //     List<CheckInSession> sessions = [];
// //
// //     for (var visit in completedVisits) {
// //       sessions.add(CheckInSession(
// //         date: visit.visitTime,
// //         visits: [visit],
// //       ));
// //     }
// //
// //     // Sort sessions by time (most recent first)
// //     sessions.sort((a, b) => b.date.compareTo(a.date));
// //
// //     return sessions;
// //   }
// //
// //   Future<void> _selectDate(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: selectedDate,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       builder: (context, child) {
// //         return Theme(
// //           data: Theme.of(context).copyWith(
// //             colorScheme: const ColorScheme.light(
// //               primary: primaryBlue,
// //               onPrimary: Colors.white,
// //               onSurface: Colors.black,
// //             ),
// //           ),
// //           child: child!,
// //         );
// //       },
// //     );
// //
// //     if (picked != null && picked != selectedDate) {
// //       setState(() {
// //         selectedDate = picked;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final sessions = _getCheckInSessions();
// //
// //     return Scaffold(
// //       backgroundColor: primaryBlue,
// //       body: Column(
// //         children: [
// //           Container(
// //             padding: EdgeInsets.only(
// //               top: MediaQuery.of(context).padding.top + 16,
// //               left: 24,
// //               right: 24,
// //               bottom: 24,
// //             ),
// //             decoration: const BoxDecoration(
// //               color: primaryBlue,
// //             ),
// //             child: Row(
// //               children: [
// //                 GestureDetector(
// //                   onTap: () => Navigator.pop(context),
// //                   child: const Icon(
// //                     Icons.arrow_back_ios,
// //                     color: Colors.white,
// //                     size: 24,
// //                   ),
// //                 ),
// //                 const Expanded(
// //                   child: Text(
// //                     'Check-In History',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 22,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 24),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             child: Container(
// //               color: const Color(0xFFF8F9FA),
// //               child: Column(
// //                 children: [
// //                   Padding(
// //                     padding: const EdgeInsets.all(24),
// //                     child: GestureDetector(
// //                       onTap: () => _selectDate(context),
// //                       child: Container(
// //                         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           border: Border.all(color: Colors.grey.shade300),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.04),
// //                               spreadRadius: 0,
// //                               blurRadius: 8,
// //                               offset: const Offset(0, 2),
// //                             ),
// //                           ],
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Row(
// //                               children: [
// //                                 const Icon(
// //                                   Icons.calendar_today,
// //                                   color: primaryBlue,
// //                                   size: 20,
// //                                 ),
// //                                 const SizedBox(width: 12),
// //                                 Text(
// //                                   DateFormat('MMM dd, yyyy').format(selectedDate),
// //                                   style: const TextStyle(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: Color(0xFF1A1A1A),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             const Icon(
// //                               Icons.keyboard_arrow_down,
// //                               color: Color(0xFF1A1A1A),
// //                               size: 24,
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   Expanded(
// //                     child: isLoading
// //                         ? const Center(
// //                       child: CircularProgressIndicator(color: primaryBlue),
// //                     )
// //                         : sessions.isEmpty
// //                         ? _buildEmptyState()
// //                         : ListView.builder(
// //                       padding: const EdgeInsets.symmetric(horizontal: 24),
// //                       itemCount: sessions.length,
// //                       itemBuilder: (context, index) {
// //                         final session = sessions[index];
// //                         return _buildHistoryCard(session);
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //       bottomNavigationBar: Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 10,
// //             ),
// //           ],
// //         ),
// //         child: SafeArea(
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 _buildNavItem(Icons.home_outlined, 'Home', false),
// //                 _buildNavItem(Icons.task_alt_outlined, 'Task', false),
// //                 _buildNavItem(Icons.calendar_today_outlined, 'Calendar', true),
// //                 _buildNavItem(Icons.person_outline, 'Profile', false),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmptyState() {
// //     final isToday = DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
// //         .isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
// //
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.event_busy,
// //             size: 64,
// //             color: Colors.grey[400],
// //           ),
// //           const SizedBox(height: 16),
// //           Text(
// //             isToday ? 'No Tasks Completed Today' : 'No Tasks Scheduled',
// //             style: const TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.w600,
// //               color: Colors.black87,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 40),
// //             child: Text(
// //               isToday
// //                   ? 'Complete tasks today to see them in your check-in history'
// //                   : 'No tasks were scheduled for ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: Colors.grey[600],
// //                 height: 1.5,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHistoryCard(CheckInSession session) {
// //     final visit = session.visits.first; // Since each session has one visit
// //     final checkInTime = DateFormat('hh:mm a').format(session.date);
// //     // For check-out time, add 30 minutes as default (you can customize this)
// //     final checkOutTime = DateFormat('hh:mm a').format(
// //         session.date.add(const Duration(minutes: 30))
// //     );
// //
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             spreadRadius: 0,
// //             blurRadius: 12,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 DateFormat('MMM dd, yyyy').format(session.date),
// //                 style: const TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.w600,
// //                   color: Color(0xFF1A1A1A),
// //                 ),
// //               ),
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                 decoration: BoxDecoration(
// //                   color: tealGreen.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: const Text(
// //                   'COMPLETED',
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.w600,
// //                     color: tealGreen,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 12),
// //           Text(
// //             visit.clientName,
// //             style: const TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w600,
// //               color: Color(0xFF1A1A1A),
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             visit.purpose,
// //             style: TextStyle(
// //               fontSize: 14,
// //               color: Colors.grey[600],
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.all(8),
// //                       decoration: BoxDecoration(
// //                         color: const Color(0xFFF5F5F5),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Icon(
// //                         Icons.access_time,
// //                         color: Colors.grey[600],
// //                         size: 20,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Text(
// //                       checkInTime,
// //                       style: const TextStyle(
// //                         fontSize: 15,
// //                         color: Color(0xFF1A1A1A),
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Expanded(
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.all(8),
// //                       decoration: BoxDecoration(
// //                         color: const Color(0xFFF5F5F5),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Icon(
// //                         Icons.access_time,
// //                         color: Colors.grey[600],
// //                         size: 20,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Text(
// //                       checkOutTime,
// //                       style: const TextStyle(
// //                         fontSize: 15,
// //                         color: Color(0xFF1A1A1A),
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 16),
// //           Row(
// //             children: [
// //               Icon(
// //                 Icons.location_on,
// //                 color: Colors.grey[600],
// //                 size: 18,
// //               ),
// //               const SizedBox(width: 6),
// //               Expanded(
// //                 child: Text(
// //                   visit.location,
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     color: Colors.grey[600],
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildNavItem(IconData icon, String label, bool isActive) {
// //     return Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Icon(
// //           icon,
// //           color: isActive ? primaryBlue : Colors.grey,
// //           size: 24,
// //         ),
// //         const SizedBox(height: 4),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             color: isActive ? primaryBlue : Colors.grey,
// //             fontSize: 12,
// //             fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Visit model (matching your tasks_screen.dart)
// class Visit {
//   final String clientName;
//   final String purpose;
//   final String location;
//   final String phoneNumber;
//   final DateTime visitTime;
//   final String status;
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
// }
//
// class CheckInHistoryScreen extends StatefulWidget {
//   const CheckInHistoryScreen({super.key});
//
//   @override
//   State<CheckInHistoryScreen> createState() => _CheckInHistoryScreenState();
// }
//
// class _CheckInHistoryScreenState extends State<CheckInHistoryScreen> {
//   static const Color primaryBlue = Color(0xFF0F3A68);
//   static const Color tealGreen = Color(0xFF00897B);
//
//   DateTime selectedDate = DateTime.now();
//   List<Visit> allVisits = [];
//   bool isLoading = true;
//   String _userId = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAndLoadData();
//   }
//
//   Future<void> _initializeAndLoadData() async {
//     await _loadUserId();
//     await _loadVisits();
//   }
//
//   Future<void> _loadUserId() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userString = prefs.getString('user');
//
//       if (userString != null) {
//         final userData = jsonDecode(userString);
//         _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
//       } else {
//         _userId = 'default';
//       }
//       debugPrint('✅ User ID loaded in Check-In History: $_userId');
//     } catch (e) {
//       debugPrint('❌ Error loading user ID: $e');
//       _userId = 'default';
//     }
//   }
//
//   Future<void> _loadVisits() async {
//     try {
//       setState(() => isLoading = true);
//       final prefs = await SharedPreferences.getInstance();
//
//       // Use user-specific key
//       final String visitsKey = 'visits_$_userId';
//       final visitsString = prefs.getString(visitsKey);
//
//       if (visitsString != null) {
//         final List<dynamic> visitsJson = jsonDecode(visitsString);
//         setState(() {
//           allVisits = visitsJson.map((json) => Visit.fromJson(json)).toList();
//           // Sort by date/time (most recent first)
//           allVisits.sort((a, b) => b.visitTime.compareTo(a.visitTime));
//           isLoading = false;
//         });
//         debugPrint('✅ Loaded ${allVisits.length} visits for check-in history');
//       } else {
//         setState(() {
//           allVisits = [];
//           isLoading = false;
//         });
//         debugPrint('ℹ️ No visits found for check-in history');
//       }
//     } catch (e) {
//       debugPrint('❌ Error loading visits: $e');
//       setState(() {
//         allVisits = [];
//         isLoading = false;
//       });
//     }
//   }
//
//   // Get completed visits for the selected date
//   List<Visit> _getCompletedVisitsForSelectedDate() {
//     final selectedDateOnly = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//     );
//
//     // Filter visits that were COMPLETED on the selected date
//     final completedVisits = allVisits.where((visit) {
//       // Check if the visit is completed
//       if (visit.status != 'completed' && visit.status != 'successfully_met') {
//         return false;
//       }
//
//       // Check if completion date matches selected date
//       final completionDateOnly = DateTime(
//         visit.visitTime.year,
//         visit.visitTime.month,
//         visit.visitTime.day,
//       );
//
//       return completionDateOnly.isAtSameMomentAs(selectedDateOnly);
//     }).toList();
//
//     // Sort by time (most recent first)
//     completedVisits.sort((a, b) => b.visitTime.compareTo(a.visitTime));
//
//     debugPrint('📊 Completed visits on ${DateFormat('MMM dd, yyyy').format(selectedDate)}: ${completedVisits.length}');
//
//     return completedVisits;
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: primaryBlue,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//       debugPrint('📅 Date changed to: ${DateFormat('MMM dd, yyyy').format(selectedDate)}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final completedVisits = _getCompletedVisitsForSelectedDate();
//     final completedCount = completedVisits.length;
//
//     return Scaffold(
//       backgroundColor: primaryBlue,
//       body: Column(
//         children: [
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
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: const Icon(
//                         Icons.arrow_back_ios,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                     const Expanded(
//                       child: Text(
//                         'Check-In History',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 22,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
//                       onPressed: _loadVisits,
//                     ),
//                   ],
//                 ),
//                 // Summary Card
//                 if (!isLoading) ...[
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.check_circle,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           '$completedCount Task${completedCount != 1 ? 's' : ''} Completed',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           Expanded(
//             child: Container(
//               color: const Color(0xFFF8F9FA),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: GestureDetector(
//                       onTap: () => _selectDate(context),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               spreadRadius: 0,
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.calendar_today,
//                                   color: primaryBlue,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Text(
//                                   DateFormat('MMM dd, yyyy').format(selectedDate),
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF1A1A1A),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const Icon(
//                               Icons.keyboard_arrow_down,
//                               color: Color(0xFF1A1A1A),
//                               size: 24,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: isLoading
//                         ? const Center(
//                       child: CircularProgressIndicator(color: primaryBlue),
//                     )
//                         : completedVisits.isEmpty
//                         ? _buildEmptyState()
//                         : ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       itemCount: completedVisits.length,
//                       itemBuilder: (context, index) {
//                         final visit = completedVisits[index];
//                         return _buildHistoryCard(visit, index + 1);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildNavItem(Icons.home_outlined, 'Home', false),
//                 _buildNavItem(Icons.task_alt_outlined, 'Task', false),
//                 _buildNavItem(Icons.calendar_today_outlined, 'Calendar', true),
//                 _buildNavItem(Icons.person_outline, 'Profile', false),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     final isToday = DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
//         .isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
//
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.event_busy,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             isToday ? 'No Tasks Completed Today' : 'No Tasks Completed',
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               isToday
//                   ? 'Complete tasks today to see them in your check-in history'
//                   : 'No tasks were completed on ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHistoryCard(Visit visit, int index) {
//     final completionTime = DateFormat('hh:mm a').format(visit.visitTime);
//     // Calculate check-out time (30 minutes after completion)
//     final checkOutTime = DateFormat('hh:mm a').format(
//       visit.visitTime.add(const Duration(minutes: 30)),
//     );
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             spreadRadius: 0,
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header with number badge
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: primaryBlue.withOpacity(0.05),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: const BoxDecoration(
//                     color: primaryBlue,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       '$index',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         visit.clientName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1A1A1A),
//                         ),
//                       ),
//                       Text(
//                         visit.purpose,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: tealGreen.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     'COMPLETED',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: tealGreen,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Content
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 // Time Information
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildTimeItem(
//                         icon: Icons.login,
//                         label: 'Check-In',
//                         time: completionTime,
//                       ),
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: Colors.grey[300],
//                     ),
//                     Expanded(
//                       child: _buildTimeItem(
//                         icon: Icons.logout,
//                         label: 'Check-Out',
//                         time: checkOutTime,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Location Information
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         color: Colors.grey[600],
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           visit.location,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[700],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Notes (if available)
//                 if (visit.notes.isNotEmpty) ...[
//                   const SizedBox(height: 12),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: primaryBlue.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: primaryBlue.withOpacity(0.1)),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.notes, size: 14, color: primaryBlue),
//                             const SizedBox(width: 6),
//                             const Text(
//                               'Notes:',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: primaryBlue,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           visit.notes,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTimeItem({
//     required IconData icon,
//     required String label,
//     required String time,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: primaryBlue, size: 20),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey[600],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           time,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Color(0xFF1A1A1A),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, bool isActive) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           icon,
//           color: isActive ? primaryBlue : Colors.grey,
//           size: 24,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             color: isActive ? primaryBlue : Colors.grey,
//             fontSize: 12,
//             fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Visit model
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
}

class CheckInHistoryScreen extends StatefulWidget {
  const CheckInHistoryScreen({super.key});

  @override
  State<CheckInHistoryScreen> createState() => _CheckInHistoryScreenState();
}

class _CheckInHistoryScreenState extends State<CheckInHistoryScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color tealGreen = Color(0xFF00897B);

  DateTime selectedDate = DateTime.now();
  List<Visit> allVisits = [];
  bool isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    await _loadUserId();
    await _loadVisits();
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final userData = jsonDecode(userString);
        _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
      } else {
        _userId = 'default';
      }
      debugPrint('✅ User ID loaded in Check-In History: $_userId');
    } catch (e) {
      debugPrint('❌ Error loading user ID: $e');
      _userId = 'default';
    }
  }

  Future<void> _loadVisits() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();

      final String visitsKey = 'visits_$_userId';
      final visitsString = prefs.getString(visitsKey);

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        setState(() {
          allVisits = visitsJson.map((json) => Visit.fromJson(json)).toList();
          allVisits.sort((a, b) => b.visitTime.compareTo(a.visitTime));
          isLoading = false;
        });
        debugPrint('✅ Loaded ${allVisits.length} visits for check-in history');
      } else {
        setState(() {
          allVisits = [];
          isLoading = false;
        });
        debugPrint('ℹ️ No visits found for check-in history');
      }
    } catch (e) {
      debugPrint('❌ Error loading visits: $e');
      setState(() {
        allVisits = [];
        isLoading = false;
      });
    }
  }

  List<Visit> _getCompletedVisitsForSelectedDate() {
    final selectedDateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final completedVisits = allVisits.where((visit) {
      if (visit.status != 'completed' && visit.status != 'successfully_met') {
        return false;
      }

      final completionDateOnly = DateTime(
        visit.visitTime.year,
        visit.visitTime.month,
        visit.visitTime.day,
      );

      return completionDateOnly.isAtSameMomentAs(selectedDateOnly);
    }).toList();

    completedVisits.sort((a, b) => b.visitTime.compareTo(a.visitTime));

    debugPrint('📊 Completed visits on ${DateFormat('MMM dd, yyyy').format(selectedDate)}: ${completedVisits.length}');

    return completedVisits;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      debugPrint('📅 Date changed to: ${DateFormat('MMM dd, yyyy').format(selectedDate)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedVisits = _getCompletedVisitsForSelectedDate();
    final completedCount = completedVisits.length;

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
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Completed Tasks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                      onPressed: _loadVisits,
                    ),
                  ],
                ),
                if (!isLoading) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completedCount Task${completedCount != 1 ? 's' : ''} Completed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF1A1A1A),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    )
                        : completedVisits.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: completedVisits.length,
                      itemBuilder: (context, index) {
                        final visit = completedVisits[index];
                        return _buildTaskCard(visit, index + 1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 'Home', false),
                _buildNavItem(Icons.task_alt_outlined, 'Task', false),
                _buildNavItem(Icons.calendar_today_outlined, 'Calendar', true),
                _buildNavItem(Icons.person_outline, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isToday = DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        .isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isToday ? 'No Tasks Completed Today' : 'No Tasks Completed',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isToday
                  ? 'Complete tasks today to see them in your history'
                  : 'No tasks were completed on ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Visit visit, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        visit.purpose,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: tealGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: tealGreen,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'DONE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tealGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          visit.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Notes
                if (visit.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note_alt, size: 14, color: Colors.orange[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Notes:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          visit.notes,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? primaryBlue : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? primaryBlue : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}