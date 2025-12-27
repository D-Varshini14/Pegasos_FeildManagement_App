// // // // import 'dart:convert';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import 'package:intl/intl.dart';
// // // //
// // // // // Visit model class - matches the one from home_screen.dart
// // // // class Visit {
// // // //   final String clientName;
// // // //   final String purpose;
// // // //   final String location;
// // // //   final String phoneNumber;
// // // //   final DateTime visitTime;
// // // //   final String status;
// // // //   final String notes;
// // // //
// // // //   Visit({
// // // //     required this.clientName,
// // // //     required this.purpose,
// // // //     required this.location,
// // // //     required this.phoneNumber,
// // // //     required this.visitTime,
// // // //     this.status = 'pending',
// // // //     this.notes = '',
// // // //   });
// // // //
// // // //   Map<String, dynamic> toJson() {
// // // //     return {
// // // //       'clientName': clientName,
// // // //       'purpose': purpose,
// // // //       'location': location,
// // // //       'phoneNumber': phoneNumber,
// // // //       'visitTime': visitTime.toIso8601String(),
// // // //       'status': status,
// // // //       'notes': notes,
// // // //     };
// // // //   }
// // // //
// // // //   factory Visit.fromJson(Map<String, dynamic> json) {
// // // //     return Visit(
// // // //       clientName: json['clientName'] ?? '',
// // // //       purpose: json['purpose'] ?? '',
// // // //       location: json['location'] ?? '',
// // // //       phoneNumber: json['phoneNumber'] ?? '',
// // // //       visitTime: DateTime.parse(json['visitTime']),
// // // //       status: json['status'] ?? 'pending',
// // // //       notes: json['notes'] ?? '',
// // // //     );
// // // //   }
// // // //
// // // //   Visit copyWith({String? status}) {
// // // //     return Visit(
// // // //       clientName: clientName,
// // // //       purpose: purpose,
// // // //       location: location,
// // // //       phoneNumber: phoneNumber,
// // // //       visitTime: visitTime,
// // // //       status: status ?? this.status,
// // // //       notes: notes,
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // class TasksScreen extends StatefulWidget {
// // // //   const TasksScreen({super.key});
// // // //
// // // //   @override
// // // //   State<TasksScreen> createState() => _TasksScreenState();
// // // // }
// // // //
// // // // class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
// // // //   List<Visit> visits = [];
// // // //   bool isLoading = true;
// // // //   TabController? _tabController;
// // // //   String selectedFilter = 'All';
// // // //
// // // //   // Professional blue color scheme - matching your home screen
// // // //   static const Color primaryBlue = Color(0xFF0F3A68);
// // // //   static const Color lightBlue = Color(0xFF1565C0);
// // // //   static const Color darkGray = Color(0xFF666666);
// // // //   static const Color lightGray = Color(0xFFF8F9FA);
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _tabController = TabController(length: 5, vsync: this);
// // // //     _loadVisits();
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     _tabController?.dispose();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   // Load visits from SharedPreferences (same as home screen)
// // // //   Future<void> _loadVisits() async {
// // // //     try {
// // // //       setState(() => isLoading = true);
// // // //
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       final visitsString = prefs.getString('visits');
// // // //
// // // //       if (visitsString != null) {
// // // //         final List<dynamic> visitsJson = jsonDecode(visitsString);
// // // //         setState(() {
// // // //           visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
// // // //           // Sort visits by date/time
// // // //           visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
// // // //           isLoading = false;
// // // //         });
// // // //       } else {
// // // //         setState(() {
// // // //           visits = [];
// // // //           isLoading = false;
// // // //         });
// // // //       }
// // // //     } catch (e) {
// // // //       setState(() {
// // // //         visits = [];
// // // //         isLoading = false;
// // // //       });
// // // //       if (mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(
// // // //             content: Text('Error loading tasks'),
// // // //             backgroundColor: Colors.red,
// // // //           ),
// // // //         );
// // // //       }
// // // //     }
// // // //   }
// // // //
// // // //   // Save visits back to SharedPreferences
// // // //   Future<void> _saveVisits() async {
// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       final visitsJson = visits.map((visit) => visit.toJson()).toList();
// // // //       await prefs.setString('visits', jsonEncode(visitsJson));
// // // //     } catch (e) {
// // // //       debugPrint('Error saving visits: $e');
// // // //     }
// // // //   }
// // // //
// // // //   // Update visit status
// // // //   Future<void> _updateVisitStatus(int index, String newStatus) async {
// // // //     if (index >= 0 && index < visits.length) {
// // // //       setState(() {
// // // //         visits[index] = visits[index].copyWith(status: newStatus);
// // // //       });
// // // //       await _saveVisits();
// // // //     }
// // // //   }
// // // //
// // // //   List<Visit> _getFilteredTasks() {
// // // //     final now = DateTime.now();
// // // //     final today = DateTime(now.year, now.month, now.day);
// // // //     final tomorrow = today.add(const Duration(days: 1));
// // // //
// // // //     switch (selectedFilter) {
// // // //       case 'Today':
// // // //         return visits.where((visit) {
// // // //           final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
// // // //           return visitDate == today;
// // // //         }).toList();
// // // //       case 'Upcoming':
// // // //         return visits.where((visit) {
// // // //           final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
// // // //           return visitDate.isAfter(today) && visit.status == 'pending';
// // // //         }).toList();
// // // //       case 'Completed':
// // // //         return visits.where((visit) => visit.status == 'completed').toList();
// // // //       case 'Missed':
// // // //         return visits.where((visit) => visit.status == 'missed').toList();
// // // //       default:
// // // //         return visits;
// // // //     }
// // // //   }
// // // //
// // // //   String _formatTime(DateTime dateTime) {
// // // //     return DateFormat('hh:mm a').format(dateTime);
// // // //   }
// // // //
// // // //   String _formatDate(DateTime dateTime) {
// // // //     final now = DateTime.now();
// // // //     final today = DateTime(now.year, now.month, now.day);
// // // //     final visitDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
// // // //
// // // //     if (visitDate == today) {
// // // //       return 'Today';
// // // //     } else if (visitDate == today.add(const Duration(days: 1))) {
// // // //       return 'Tomorrow';
// // // //     } else if (visitDate == today.subtract(const Duration(days: 1))) {
// // // //       return 'Yesterday';
// // // //     } else {
// // // //       return DateFormat('MMM dd').format(dateTime);
// // // //     }
// // // //   }
// // // //
// // // //   bool _isToday(DateTime date) {
// // // //     final now = DateTime.now();
// // // //     final today = DateTime(now.year, now.month, now.day);
// // // //     final visitDate = DateTime(date.year, date.month, date.day);
// // // //     return visitDate == today;
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: lightGray,
// // // //       appBar: AppBar(
// // // //         backgroundColor: primaryBlue,
// // // //         elevation: 0,
// // // //         leading: IconButton(
// // // //           icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
// // // //           onPressed: () => Navigator.pop(context),
// // // //         ),
// // // //         title: const Text(
// // // //           'Tasks',
// // // //           style: TextStyle(
// // // //             fontSize: 24,
// // // //             fontWeight: FontWeight.bold,
// // // //             color: Colors.white,
// // // //           ),
// // // //         ),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: Stack(
// // // //               children: [
// // // //                 const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
// // // //                 Positioned(
// // // //                   right: 0,
// // // //                   top: 0,
// // // //                   child: Container(
// // // //                     width: 12,
// // // //                     height: 12,
// // // //                     decoration: const BoxDecoration(
// // // //                       color: Colors.red,
// // // //                       shape: BoxShape.circle,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             onPressed: () {
// // // //               ScaffoldMessenger.of(context).showSnackBar(
// // // //                 const SnackBar(
// // // //                   content: Text('Notifications clicked'),
// // // //                   backgroundColor: primaryBlue,
// // // //                   duration: Duration(seconds: 2),
// // // //                 ),
// // // //               );
// // // //             },
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       body: Column(
// // // //         children: [
// // // //           // Search Bar
// // // //           Container(
// // // //             color: primaryBlue,
// // // //             padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
// // // //             child: TextField(
// // // //               decoration: InputDecoration(
// // // //                 hintText: 'Search',
// // // //                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
// // // //                 filled: true,
// // // //                 fillColor: Colors.white,
// // // //                 border: OutlineInputBorder(
// // // //                   borderRadius: BorderRadius.circular(25),
// // // //                   borderSide: BorderSide.none,
// // // //                 ),
// // // //                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //
// // // //           // Filter Tabs
// // // //           Container(
// // // //             color: lightGray,
// // // //             padding: const EdgeInsets.symmetric(vertical: 10),
// // // //             child: TabBar(
// // // //               controller: _tabController,
// // // //               isScrollable: true,
// // // //               labelColor: Colors.white,
// // // //               unselectedLabelColor: darkGray,
// // // //               indicator: BoxDecoration(
// // // //                 color: primaryBlue,
// // // //                 borderRadius: BorderRadius.circular(25),
// // // //               ),
// // // //               tabs: ['All', 'Today', 'Upcoming', 'Completed', 'Missed']
// // // //                   .map((filter) => Tab(
// // // //                 child: Container(
// // // //                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
// // // //                   child: Text(filter),
// // // //                 ),
// // // //               ))
// // // //                   .toList(),
// // // //               onTap: (index) {
// // // //                 setState(() {
// // // //                   selectedFilter = ['All', 'Today', 'Upcoming', 'Completed', 'Missed'][index];
// // // //                 });
// // // //               },
// // // //             ),
// // // //           ),
// // // //
// // // //           // Tasks List
// // // //           Expanded(
// // // //             child: isLoading
// // // //                 ? const Center(child: CircularProgressIndicator(color: primaryBlue))
// // // //                 : _getFilteredTasks().isEmpty
// // // //                 ? _buildEmptyState()
// // // //                 : RefreshIndicator(
// // // //               onRefresh: _loadVisits,
// // // //               child: ListView.builder(
// // // //                 padding: const EdgeInsets.all(20),
// // // //                 itemCount: _getFilteredTasks().length,
// // // //                 itemBuilder: (context, index) {
// // // //                   final visit = _getFilteredTasks()[index];
// // // //                   return _buildTaskCard(visit, index);
// // // //                 },
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       floatingActionButton: Container(
// // // //         width: 64,
// // // //         height: 64,
// // // //         decoration: BoxDecoration(
// // // //           shape: BoxShape.circle,
// // // //           boxShadow: [
// // // //             BoxShadow(
// // // //               color: primaryBlue.withOpacity(0.3),
// // // //               spreadRadius: 0,
// // // //               blurRadius: 20,
// // // //               offset: const Offset(0, 8),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         child: FloatingActionButton(
// // // //           backgroundColor: primaryBlue,
// // // //           elevation: 0,
// // // //           onPressed: () {
// // // //             Navigator.pop(context); // Go back to home to add new visit
// // // //           },
// // // //           child: const Icon(Icons.add, color: Colors.white, size: 28),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildEmptyState() {
// // // //     return Container(
// // // //       width: double.infinity,
// // // //       padding: const EdgeInsets.all(40),
// // // //       child: Column(
// // // //         mainAxisAlignment: MainAxisAlignment.center,
// // // //         children: [
// // // //           Icon(
// // // //             Icons.assignment_outlined,
// // // //             size: 64,
// // // //             color: primaryBlue.withOpacity(0.5),
// // // //           ),
// // // //           const SizedBox(height: 20),
// // // //           const Text(
// // // //             'No Tasks Found',
// // // //             style: TextStyle(
// // // //               fontSize: 20,
// // // //               fontWeight: FontWeight.w600,
// // // //               color: Color(0xFF1A1A1A),
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 12),
// // // //           Text(
// // // //             selectedFilter == 'All'
// // // //                 ? 'No tasks scheduled yet.\nTap + to add your first visit.'
// // // //                 : 'No $selectedFilter tasks found.',
// // // //             style: TextStyle(
// // // //               fontSize: 16,
// // // //               color: Colors.grey[600],
// // // //               height: 1.5,
// // // //             ),
// // // //             textAlign: TextAlign.center,
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildTaskCard(Visit visit, int index) {
// // // //     final isToday = _isToday(visit.visitTime);
// // // //
// // // //     return Container(
// // // //       margin: const EdgeInsets.only(bottom: 15),
// // // //       padding: const EdgeInsets.all(20),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: Colors.black.withOpacity(0.05),
// // // //             blurRadius: 10,
// // // //             offset: const Offset(0, 2),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Expanded(
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     Text(
// // // //                       visit.clientName,
// // // //                       style: const TextStyle(
// // // //                         fontSize: 18,
// // // //                         fontWeight: FontWeight.bold,
// // // //                         color: Colors.black,
// // // //                       ),
// // // //                     ),
// // // //                     const SizedBox(height: 4),
// // // //                     Text(
// // // //                       visit.purpose,
// // // //                       style: const TextStyle(
// // // //                         fontSize: 14,
// // // //                         color: darkGray,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               GestureDetector(
// // // //                 onTap: () {
// // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // //                     SnackBar(
// // // //                       content: Text('Calling ${visit.phoneNumber}...'),
// // // //                       backgroundColor: primaryBlue,
// // // //                       duration: const Duration(seconds: 2),
// // // //                     ),
// // // //                   );
// // // //                 },
// // // //                 child: Container(
// // // //                   width: 40,
// // // //                   height: 40,
// // // //                   decoration: BoxDecoration(
// // // //                     color: primaryBlue,
// // // //                     borderRadius: BorderRadius.circular(20),
// // // //                   ),
// // // //                   child: const Icon(
// // // //                     Icons.phone,
// // // //                     color: Colors.white,
// // // //                     size: 20,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 15),
// // // //           Row(
// // // //             children: [
// // // //               const Icon(Icons.location_on, color: primaryBlue, size: 16),
// // // //               const SizedBox(width: 5),
// // // //               Expanded(
// // // //                 child: Text(
// // // //                   visit.location,
// // // //                   style: const TextStyle(
// // // //                     fontSize: 14,
// // // //                     color: Colors.black,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //               GestureDetector(
// // // //                 onTap: () {
// // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // //                     const SnackBar(
// // // //                       content: Text('Opening map...'),
// // // //                       backgroundColor: primaryBlue,
// // // //                       duration: Duration(seconds: 2),
// // // //                     ),
// // // //                   );
// // // //                 },
// // // //                 child: const Text(
// // // //                   'Open Map',
// // // //                   style: TextStyle(
// // // //                     fontSize: 14,
// // // //                     color: Colors.blue,
// // // //                     decoration: TextDecoration.underline,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 20),
// // // //               Text(
// // // //                 _formatTime(visit.visitTime),
// // // //                 style: const TextStyle(
// // // //                   fontSize: 14,
// // // //                   color: Colors.black,
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //
// // // //           // Date indicator if not today
// // // //           if (!isToday)
// // // //             Padding(
// // // //               padding: const EdgeInsets.only(top: 8),
// // // //               child: Row(
// // // //                 children: [
// // // //                   const Icon(Icons.calendar_today, color: primaryBlue, size: 14),
// // // //                   const SizedBox(width: 5),
// // // //                   Text(
// // // //                     _formatDate(visit.visitTime),
// // // //                     style: const TextStyle(
// // // //                       fontSize: 12,
// // // //                       color: darkGray,
// // // //                       fontWeight: FontWeight.w500,
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //
// // // //           // Status indicator
// // // //           if (visit.status == 'missed')
// // // //             Padding(
// // // //               padding: const EdgeInsets.only(top: 10),
// // // //               child: Align(
// // // //                 alignment: Alignment.centerRight,
// // // //                 child: Text(
// // // //                   'Missed',
// // // //                   style: TextStyle(
// // // //                     color: Colors.red,
// // // //                     fontSize: 14,
// // // //                     fontWeight: FontWeight.w500,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //
// // // //           // Action buttons for pending tasks
// // // //           if (visit.status == 'pending' && isToday)
// // // //             Padding(
// // // //               padding: const EdgeInsets.only(top: 15),
// // // //               child: Row(
// // // //                 children: [
// // // //                   Expanded(
// // // //                     child: ElevatedButton(
// // // //                       onPressed: () {
// // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // //                           const SnackBar(
// // // //                             content: Text('Starting task now...'),
// // // //                             backgroundColor: primaryBlue,
// // // //                             duration: Duration(seconds: 2),
// // // //                           ),
// // // //                         );
// // // //                       },
// // // //                       style: ElevatedButton.styleFrom(
// // // //                         backgroundColor: primaryBlue,
// // // //                         shape: RoundedRectangleBorder(
// // // //                           borderRadius: BorderRadius.circular(8),
// // // //                         ),
// // // //                       ),
// // // //                       child: const Text(
// // // //                         'Start Now',
// // // //                         style: TextStyle(color: Colors.white),
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(width: 15),
// // // //                   Expanded(
// // // //                     child: OutlinedButton(
// // // //                       onPressed: () async {
// // // //                         await _updateVisitStatus(visits.indexOf(visit), 'completed');
// // // //                         if (mounted) {
// // // //                           ScaffoldMessenger.of(context).showSnackBar(
// // // //                             const SnackBar(
// // // //                               content: Text('Task marked as completed'),
// // // //                               backgroundColor: Colors.green,
// // // //                               duration: Duration(seconds: 2),
// // // //                             ),
// // // //                           );
// // // //                         }
// // // //                       },
// // // //                       style: OutlinedButton.styleFrom(
// // // //                         side: const BorderSide(color: darkGray),
// // // //                         shape: RoundedRectangleBorder(
// // // //                           borderRadius: BorderRadius.circular(8),
// // // //                         ),
// // // //                       ),
// // // //                       child: const Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // //                         children: [
// // // //                           Icon(Icons.check, color: darkGray, size: 16),
// // // //                           SizedBox(width: 5),
// // // //                           Text(
// // // //                             'Mark as Visited',
// // // //                             style: TextStyle(color: darkGray),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //
// // // //           // Show notes if available
// // // //           if (visit.notes.isNotEmpty)
// // // //             Padding(
// // // //               padding: const EdgeInsets.only(top: 10),
// // // //               child: Container(
// // // //                 width: double.infinity,
// // // //                 padding: const EdgeInsets.all(12),
// // // //                 decoration: BoxDecoration(
// // // //                   color: primaryBlue.withOpacity(0.05),
// // // //                   borderRadius: BorderRadius.circular(8),
// // // //                   border: Border.all(
// // // //                     color: primaryBlue.withOpacity(0.1),
// // // //                   ),
// // // //                 ),
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     const Row(
// // // //                       children: [
// // // //                         Icon(Icons.notes, size: 14, color: primaryBlue),
// // // //                         SizedBox(width: 6),
// // // //                         Text(
// // // //                           'Notes:',
// // // //                           style: TextStyle(
// // // //                             fontSize: 12,
// // // //                             fontWeight: FontWeight.w600,
// // // //                             color: primaryBlue,
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                     const SizedBox(height: 4),
// // // //                     Text(
// // // //                       visit.notes,
// // // //                       style: const TextStyle(
// // // //                         fontSize: 12,
// // // //                         color: darkGray,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // //
// // // import 'dart:convert';
// // // import 'package:flutter/material.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:intl/intl.dart';
// // // import 'add_visit_screen.dart'; // Add this import
// // //
// // // // Visit model class - matches the one from home_screen.dart
// // // class Visit {
// // //   final String clientName;
// // //   final String purpose;
// // //   final String location;
// // //   final String phoneNumber;
// // //   final DateTime visitTime;
// // //   final String status;
// // //   final String notes;
// // //
// // //   Visit({
// // //     required this.clientName,
// // //     required this.purpose,
// // //     required this.location,
// // //     required this.phoneNumber,
// // //     required this.visitTime,
// // //     this.status = 'pending',
// // //     this.notes = '',
// // //   });
// // //
// // //   Map<String, dynamic> toJson() {
// // //     return {
// // //       'clientName': clientName,
// // //       'purpose': purpose,
// // //       'location': location,
// // //       'phoneNumber': phoneNumber,
// // //       'visitTime': visitTime.toIso8601String(),
// // //       'status': status,
// // //       'notes': notes,
// // //     };
// // //   }
// // //
// // //   factory Visit.fromJson(Map<String, dynamic> json) {
// // //     return Visit(
// // //       clientName: json['clientName'] ?? '',
// // //       purpose: json['purpose'] ?? '',
// // //       location: json['location'] ?? '',
// // //       phoneNumber: json['phoneNumber'] ?? '',
// // //       visitTime: DateTime.parse(json['visitTime']),
// // //       status: json['status'] ?? 'pending',
// // //       notes: json['notes'] ?? '',
// // //     );
// // //   }
// // //
// // //   Visit copyWith({String? status}) {
// // //     return Visit(
// // //       clientName: clientName,
// // //       purpose: purpose,
// // //       location: location,
// // //       phoneNumber: phoneNumber,
// // //       visitTime: visitTime,
// // //       status: status ?? this.status,
// // //       notes: notes,
// // //     );
// // //   }
// // // }
// // //
// // // class TasksScreen extends StatefulWidget {
// // //   const TasksScreen({super.key});
// // //
// // //   @override
// // //   State<TasksScreen> createState() => _TasksScreenState();
// // // }
// // //
// // // class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
// // //   List<Visit> visits = [];
// // //   bool isLoading = true;
// // //   TabController? _tabController;
// // //   String selectedFilter = 'All';
// // //
// // //   // Professional blue color scheme - matching your home screen
// // //   static const Color primaryBlue = Color(0xFF0F3A68);
// // //   static const Color lightBlue = Color(0xFF1565C0);
// // //   static const Color darkGray = Color(0xFF666666);
// // //   static const Color lightGray = Color(0xFFF8F9FA);
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _tabController = TabController(length: 5, vsync: this);
// // //     _loadVisits();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _tabController?.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   // Load visits from SharedPreferences (same as home screen)
// // //   Future<void> _loadVisits() async {
// // //     try {
// // //       setState(() => isLoading = true);
// // //
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final visitsString = prefs.getString('visits');
// // //
// // //       if (visitsString != null) {
// // //         final List<dynamic> visitsJson = jsonDecode(visitsString);
// // //         setState(() {
// // //           visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
// // //           // Sort visits by date/time
// // //           visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
// // //           isLoading = false;
// // //         });
// // //       } else {
// // //         setState(() {
// // //           visits = [];
// // //           isLoading = false;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       setState(() {
// // //         visits = [];
// // //         isLoading = false;
// // //       });
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Error loading tasks'),
// // //             backgroundColor: Colors.red,
// // //           ),
// // //         );
// // //       }
// // //     }
// // //   }
// // //
// // //   // Save visits back to SharedPreferences
// // //   Future<void> _saveVisits() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final visitsJson = visits.map((visit) => visit.toJson()).toList();
// // //       await prefs.setString('visits', jsonEncode(visitsJson));
// // //     } catch (e) {
// // //       debugPrint('Error saving visits: $e');
// // //     }
// // //   }
// // //
// // //   // Update visit status
// // //   Future<void> _updateVisitStatus(int index, String newStatus) async {
// // //     if (index >= 0 && index < visits.length) {
// // //       setState(() {
// // //         visits[index] = visits[index].copyWith(status: newStatus);
// // //       });
// // //       await _saveVisits();
// // //     }
// // //   }
// // //
// // //   List<Visit> _getFilteredTasks() {
// // //     final now = DateTime.now();
// // //     final today = DateTime(now.year, now.month, now.day);
// // //     final tomorrow = today.add(const Duration(days: 1));
// // //
// // //     switch (selectedFilter) {
// // //       case 'Today':
// // //         return visits.where((visit) {
// // //           final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
// // //           return visitDate == today;
// // //         }).toList();
// // //       case 'Upcoming':
// // //         return visits.where((visit) {
// // //           final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
// // //           return visitDate.isAfter(today) && visit.status == 'pending';
// // //         }).toList();
// // //       case 'Completed':
// // //         return visits.where((visit) => visit.status == 'completed').toList();
// // //       case 'Missed':
// // //         return visits.where((visit) => visit.status == 'missed').toList();
// // //       default:
// // //         return visits;
// // //     }
// // //   }
// // //
// // //   String _formatTime(DateTime dateTime) {
// // //     return DateFormat('hh:mm a').format(dateTime);
// // //   }
// // //
// // //   String _formatDate(DateTime dateTime) {
// // //     final now = DateTime.now();
// // //     final today = DateTime(now.year, now.month, now.day);
// // //     final visitDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
// // //
// // //     if (visitDate == today) {
// // //       return 'Today';
// // //     } else if (visitDate == today.add(const Duration(days: 1))) {
// // //       return 'Tomorrow';
// // //     } else if (visitDate == today.subtract(const Duration(days: 1))) {
// // //       return 'Yesterday';
// // //     } else {
// // //       return DateFormat('MMM dd').format(dateTime);
// // //     }
// // //   }
// // //
// // //   bool _isToday(DateTime date) {
// // //     final now = DateTime.now();
// // //     final today = DateTime(now.year, now.month, now.day);
// // //     final visitDate = DateTime(date.year, date.month, date.day);
// // //     return visitDate == today;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: lightGray,
// // //       appBar: AppBar(
// // //         backgroundColor: primaryBlue,
// // //         elevation: 0,
// // //         leading: IconButton(
// // //           icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
// // //           onPressed: () => Navigator.pop(context),
// // //         ),
// // //         title: const Text(
// // //           'Tasks',
// // //           style: TextStyle(
// // //             fontSize: 24,
// // //             fontWeight: FontWeight.bold,
// // //             color: Colors.white,
// // //           ),
// // //         ),
// // //         actions: [
// // //           IconButton(
// // //             icon: Stack(
// // //               children: [
// // //                 const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
// // //                 Positioned(
// // //                   right: 0,
// // //                   top: 0,
// // //                   child: Container(
// // //                     width: 12,
// // //                     height: 12,
// // //                     decoration: const BoxDecoration(
// // //                       color: Colors.red,
// // //                       shape: BoxShape.circle,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             onPressed: () {
// // //               ScaffoldMessenger.of(context).showSnackBar(
// // //                 const SnackBar(
// // //                   content: Text('Notifications clicked'),
// // //                   backgroundColor: primaryBlue,
// // //                   duration: Duration(seconds: 2),
// // //                 ),
// // //               );
// // //             },
// // //           ),
// // //         ],
// // //       ),
// // //       body: Column(
// // //         children: [
// // //           // Search Bar
// // //           Container(
// // //             color: primaryBlue,
// // //             padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
// // //             child: TextField(
// // //               decoration: InputDecoration(
// // //                 hintText: 'Search',
// // //                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
// // //                 filled: true,
// // //                 fillColor: Colors.white,
// // //                 border: OutlineInputBorder(
// // //                   borderRadius: BorderRadius.circular(25),
// // //                   borderSide: BorderSide.none,
// // //                 ),
// // //                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
// // //               ),
// // //             ),
// // //           ),
// // //
// // //           // Filter Tabs
// // //           Container(
// // //             color: lightGray,
// // //             padding: const EdgeInsets.symmetric(vertical: 10),
// // //             child: TabBar(
// // //               controller: _tabController,
// // //               isScrollable: true,
// // //               labelColor: Colors.white,
// // //               unselectedLabelColor: darkGray,
// // //               indicator: BoxDecoration(
// // //                 color: primaryBlue,
// // //                 borderRadius: BorderRadius.circular(25),
// // //               ),
// // //               tabs: ['All', 'Today', 'Upcoming', 'Completed', 'Missed']
// // //                   .map((filter) => Tab(
// // //                 child: Container(
// // //                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
// // //                   child: Text(filter),
// // //                 ),
// // //               ))
// // //                   .toList(),
// // //               onTap: (index) {
// // //                 setState(() {
// // //                   selectedFilter = ['All', 'Today', 'Upcoming', 'Completed', 'Missed'][index];
// // //                 });
// // //               },
// // //             ),
// // //           ),
// // //
// // //           // Tasks List
// // //           Expanded(
// // //             child: isLoading
// // //                 ? const Center(child: CircularProgressIndicator(color: primaryBlue))
// // //                 : _getFilteredTasks().isEmpty
// // //                 ? _buildEmptyState()
// // //                 : RefreshIndicator(
// // //               onRefresh: _loadVisits,
// // //               child: ListView.builder(
// // //                 padding: const EdgeInsets.all(20),
// // //                 itemCount: _getFilteredTasks().length,
// // //                 itemBuilder: (context, index) {
// // //                   final visit = _getFilteredTasks()[index];
// // //                   return _buildTaskCard(visit, index);
// // //                 },
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //       floatingActionButton: Container(
// // //         width: 64,
// // //         height: 64,
// // //         decoration: BoxDecoration(
// // //           shape: BoxShape.circle,
// // //           boxShadow: [
// // //             BoxShadow(
// // //               color: primaryBlue.withOpacity(0.3),
// // //               spreadRadius: 0,
// // //               blurRadius: 20,
// // //               offset: const Offset(0, 8),
// // //             ),
// // //           ],
// // //         ),
// // //         child: FloatingActionButton(
// // //           backgroundColor: primaryBlue,
// // //           elevation: 0,
// // //           onPressed: () async {
// // //             // Navigate to AddVisitScreen and refresh tasks when returning
// // //             final result = await Navigator.push(
// // //               context,
// // //               MaterialPageRoute(
// // //                 builder: (context) => const AddVisitScreen(),
// // //               ),
// // //             );
// // //
// // //             // Refresh the tasks list when returning from AddVisitScreen
// // //             if (result == true) {
// // //               _loadVisits();
// // //             }
// // //           },
// // //           child: const Icon(Icons.add, color: Colors.white, size: 28),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildEmptyState() {
// // //     return Container(
// // //       width: double.infinity,
// // //       padding: const EdgeInsets.all(40),
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Icon(
// // //             Icons.assignment_outlined,
// // //             size: 64,
// // //             color: primaryBlue.withOpacity(0.5),
// // //           ),
// // //           const SizedBox(height: 20),
// // //           const Text(
// // //             'No Tasks Found',
// // //             style: TextStyle(
// // //               fontSize: 20,
// // //               fontWeight: FontWeight.w600,
// // //               color: Color(0xFF1A1A1A),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 12),
// // //           Text(
// // //             selectedFilter == 'All'
// // //                 ? 'No tasks scheduled yet.\nTap + to add your first visit.'
// // //                 : 'No $selectedFilter tasks found.',
// // //             style: TextStyle(
// // //               fontSize: 16,
// // //               color: Colors.grey[600],
// // //               height: 1.5,
// // //             ),
// // //             textAlign: TextAlign.center,
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildTaskCard(Visit visit, int index) {
// // //     final isToday = _isToday(visit.visitTime);
// // //
// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 15),
// // //       padding: const EdgeInsets.all(16),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(12),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.05),
// // //             blurRadius: 8,
// // //             offset: const Offset(0, 2),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           // Client + Call Icon
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               Expanded(
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Text(
// // //                       visit.clientName,
// // //                       style: const TextStyle(
// // //                         fontSize: 18,
// // //                         fontWeight: FontWeight.bold,
// // //                         color: Colors.black,
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 4),
// // //                     Text(
// // //                       visit.purpose,
// // //                       style: const TextStyle(
// // //                         fontSize: 14,
// // //                         color: Colors.black54,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               GestureDetector(
// // //                 onTap: () {
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     SnackBar(
// // //                       content: Text('Calling ${visit.phoneNumber}...'),
// // //                       backgroundColor: primaryBlue,
// // //                       duration: const Duration(seconds: 2),
// // //                     ),
// // //                   );
// // //                 },
// // //                 child: Container(
// // //                   width: 40,
// // //                   height: 40,
// // //                   decoration: BoxDecoration(
// // //                     color: primaryBlue,
// // //                     borderRadius: BorderRadius.circular(20),
// // //                   ),
// // //                   child: const Icon(Icons.phone, color: Colors.white, size: 20),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //
// // //           const SizedBox(height: 15),
// // //
// // //           // Location + Map + Time
// // //           Row(
// // //             children: [
// // //               const Icon(Icons.location_on, color: primaryBlue, size: 16),
// // //               const SizedBox(width: 5),
// // //               Expanded(
// // //                 child: Text(
// // //                   visit.location,
// // //                   style: const TextStyle(fontSize: 14, color: Colors.black),
// // //                 ),
// // //               ),
// // //               GestureDetector(
// // //                 onTap: () {
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     const SnackBar(
// // //                       content: Text('Opening map...'),
// // //                       backgroundColor: primaryBlue,
// // //                       duration: Duration(seconds: 2),
// // //                     ),
// // //                   );
// // //                 },
// // //                 child: const Text(
// // //                   'Open Map',
// // //                   style: TextStyle(
// // //                     fontSize: 14,
// // //                     color: Colors.blue,
// // //                     decoration: TextDecoration.underline,
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 20),
// // //               Text(
// // //                 _formatTime(visit.visitTime),
// // //                 style: const TextStyle(fontSize: 14, color: Colors.black),
// // //               ),
// // //             ],
// // //           ),
// // //
// // //           if (!isToday) ...[
// // //             const SizedBox(height: 8),
// // //             Row(
// // //               children: [
// // //                 const Icon(Icons.calendar_today, color: primaryBlue, size: 14),
// // //                 const SizedBox(width: 5),
// // //                 Text(
// // //                   _formatDate(visit.visitTime),
// // //                   style: const TextStyle(
// // //                     fontSize: 12,
// // //                     color: Colors.black54,
// // //                     fontWeight: FontWeight.w500,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ],
// // //
// // //           // Missed Status
// // //           if (visit.status == 'missed')
// // //             Padding(
// // //               padding: const EdgeInsets.only(top: 10),
// // //               child: Align(
// // //                 alignment: Alignment.centerRight,
// // //                 child: Text(
// // //                   'Missed',
// // //                   style: const TextStyle(
// // //                     color: Colors.red,
// // //                     fontSize: 14,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //
// // //           // Buttons (only Today & pending)
// // //           if (visit.status == 'pending' && isToday) ...[
// // //             const SizedBox(height: 15),
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: ElevatedButton(
// // //                     onPressed: () {
// // //                       ScaffoldMessenger.of(context).showSnackBar(
// // //                         const SnackBar(
// // //                           content: Text('Starting task now...'),
// // //                           backgroundColor: primaryBlue,
// // //                           duration: Duration(seconds: 2),
// // //                         ),
// // //                       );
// // //                     },
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: primaryBlue,
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                     ),
// // //                     child: const Text('Start Now', style: TextStyle(color: Colors.white)),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 15),
// // //                 Expanded(
// // //                   child: OutlinedButton(
// // //                     onPressed: () async {
// // //                       await _updateVisitStatus(visits.indexOf(visit), 'completed');
// // //                     },
// // //                     style: OutlinedButton.styleFrom(
// // //                       side: const BorderSide(color: Colors.black54),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                     ),
// // //                     child: const Text(
// // //                       'Mark as Visited',
// // //                       style: TextStyle(color: Colors.black54),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ],
// // //
// // //           // Notes Section
// // //           if (visit.notes.isNotEmpty)
// // //             Padding(
// // //               padding: const EdgeInsets.only(top: 12),
// // //               child: Container(
// // //                 width: double.infinity,
// // //                 padding: const EdgeInsets.all(12),
// // //                 decoration: BoxDecoration(
// // //                   color: primaryBlue.withOpacity(0.05),
// // //                   borderRadius: BorderRadius.circular(8),
// // //                 ),
// // //                 child: Row(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     const Icon(Icons.notes, size: 16, color: primaryBlue),
// // //                     const SizedBox(width: 6),
// // //                     Expanded(
// // //                       child: Text(
// // //                         visit.notes,
// // //                         style: const TextStyle(fontSize: 13, color: Colors.black54),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // // }
// //
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:intl/intl.dart';
// // import 'add_visit_screen.dart';
// //
// // // Visit model class
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
// //
// //   Visit copyWith({String? status}) {
// //     return Visit(
// //       clientName: clientName,
// //       purpose: purpose,
// //       location: location,
// //       phoneNumber: phoneNumber,
// //       visitTime: visitTime,
// //       status: status ?? this.status,
// //       notes: notes,
// //     );
// //   }
// // }
// //
// // class TasksScreen extends StatefulWidget {
// //   const TasksScreen({super.key});
// //
// //   @override
// //   State<TasksScreen> createState() => _TasksScreenState();
// // }
// //
// // class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
// //   List<Visit> visits = [];
// //   bool isLoading = true;
// //   TabController? _tabController;
// //   String selectedFilter = 'All';
// //
// //   // Colors to match the UI
// //   static const Color primaryBlue = Color(0xFF0F3A68);
// //   static const Color lightGray = Color(0xFFF1F5F9);
// //   static const Color cardBackground = Colors.white;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 5, vsync: this);
// //     _loadVisits();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabController?.dispose();
// //     super.dispose();
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
// //           visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
// //           visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
// //           isLoading = false;
// //         });
// //       } else {
// //         setState(() {
// //           visits = [];
// //           isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         visits = [];
// //         isLoading = false;
// //       });
// //     }
// //   }
// //
// //   Future<void> _saveVisits() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final visitsJson = visits.map((visit) => visit.toJson()).toList();
// //       await prefs.setString('visits', jsonEncode(visitsJson));
// //     } catch (e) {
// //       debugPrint('Error saving visits: $e');
// //     }
// //   }
// //
// //   Future<void> _updateVisitStatus(int index, String newStatus) async {
// //     if (index >= 0 && index < visits.length) {
// //       setState(() {
// //         visits[index] = visits[index].copyWith(status: newStatus);
// //       });
// //       await _saveVisits();
// //     }
// //   }
// //
// //   List<Visit> _getFilteredTasks() {
// //     final now = DateTime.now();
// //     final today = DateTime(now.year, now.month, now.day);
// //
// //     switch (selectedFilter) {
// //       case 'Today':
// //         return visits.where((visit) {
// //           final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
// //           return visitDate == today;
// //         }).toList();
// //       case 'Upcoming':
// //         return visits.where((visit) {
// //           final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
// //           return visitDate.isAfter(today) && visit.status == 'pending';
// //         }).toList();
// //       case 'Completed':
// //         return visits.where((visit) => visit.status == 'completed').toList();
// //       case 'Missed':
// //         return visits.where((visit) => visit.status == 'missed').toList();
// //       default:
// //         return visits;
// //     }
// //   }
// //
// //   String _formatTime(DateTime dateTime) {
// //     return DateFormat('hh:mm a').format(dateTime);
// //   }
// //
// //   bool _isToday(DateTime date) {
// //     final now = DateTime.now();
// //     final today = DateTime(now.year, now.month, now.day);
// //     final visitDate = DateTime(date.year, date.month, date.day);
// //     return visitDate == today;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: lightGray,
// //       appBar: AppBar(
// //         backgroundColor: primaryBlue,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: const Text(
// //           'Tasks',
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w600,
// //             color: Colors.white,
// //           ),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: Stack(
// //               children: [
// //                 const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
// //                 Positioned(
// //                   right: 2,
// //                   top: 2,
// //                   child: Container(
// //                     width: 8,
// //                     height: 8,
// //                     decoration: const BoxDecoration(
// //                       color: Colors.red,
// //                       shape: BoxShape.circle,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             onPressed: () {},
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Search Bar
// //           Container(
// //             color: primaryBlue,
// //             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //             child: TextField(
// //               decoration: InputDecoration(
// //                 hintText: 'Search',
// //                 hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
// //                 prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
// //                 filled: true,
// //                 fillColor: Colors.white,
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(25),
// //                   borderSide: BorderSide.none,
// //                 ),
// //                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //               ),
// //             ),
// //           ),
// //
// //           // Filter Tabs
// //           Container(
// //             color: lightGray,
// //             padding: const EdgeInsets.symmetric(vertical: 12),
// //             child: SingleChildScrollView(
// //               scrollDirection: Axis.horizontal,
// //               padding: const EdgeInsets.symmetric(horizontal: 16),
// //               child: Row(
// //                 children: ['All', 'Today', 'Upcoming', 'Completed', 'Missed']
// //                     .map((filter) => GestureDetector(
// //                   onTap: () {
// //                     setState(() {
// //                       selectedFilter = filter;
// //                     });
// //                   },
// //                   child: Container(
// //                     margin: const EdgeInsets.only(right: 12),
// //                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //                     decoration: BoxDecoration(
// //                       color: selectedFilter == filter ? primaryBlue : Colors.transparent,
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: Text(
// //                       filter,
// //                       style: TextStyle(
// //                         color: selectedFilter == filter ? Colors.white : Colors.grey[600],
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ),
// //                 ))
// //                     .toList(),
// //               ),
// //             ),
// //           ),
// //
// //           // Tasks List
// //           Expanded(
// //             child: isLoading
// //                 ? const Center(child: CircularProgressIndicator(color: primaryBlue))
// //                 : _getFilteredTasks().isEmpty
// //                 ? _buildEmptyState()
// //                 : ListView.separated(
// //               padding: const EdgeInsets.all(16),
// //               itemCount: _getFilteredTasks().length,
// //               separatorBuilder: (context, index) => const SizedBox(height: 12),
// //               itemBuilder: (context, index) {
// //                 final visit = _getFilteredTasks()[index];
// //                 return _buildTaskCard(visit, index);
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         backgroundColor: primaryBlue,
// //         onPressed: () async {
// //           final result = await Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (context) => const AddVisitScreen(),
// //             ),
// //           );
// //           if (result == true) {
// //             _loadVisits();
// //           }
// //         },
// //         child: const Icon(Icons.add, color: Colors.white, size: 24),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmptyState() {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(40),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.assignment_outlined,
// //             size: 64,
// //             color: Colors.grey[400],
// //           ),
// //           const SizedBox(height: 20),
// //           const Text(
// //             'No Tasks Found',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.w600,
// //               color: Colors.black87,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             selectedFilter == 'All'
// //                 ? 'No tasks scheduled yet.\nTap + to add your first visit.'
// //                 : 'No $selectedFilter tasks found.',
// //             style: TextStyle(
// //               fontSize: 14,
// //               color: Colors.grey[600],
// //               height: 1.4,
// //             ),
// //             textAlign: TextAlign.center,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTaskCard(Visit visit, int index) {
// //     final isToday = _isToday(visit.visitTime);
// //     final isMissed = visit.status == 'missed';
// //
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: cardBackground,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Header Row - Name and Call Button
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       visit.clientName,
// //                       style: const TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.black,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 2),
// //                     Text(
// //                       visit.purpose,
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         color: Colors.grey[600],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Container(
// //                 width: 44,
// //                 height: 44,
// //                 decoration: const BoxDecoration(
// //                   color: primaryBlue,
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: IconButton(
// //                   icon: const Icon(Icons.phone, color: Colors.white, size: 20),
// //                   onPressed: () {
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       SnackBar(
// //                         content: Text('Calling ${visit.phoneNumber}...'),
// //                         backgroundColor: primaryBlue,
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //
// //           const SizedBox(height: 12),
// //
// //           // Location and Time Row
// //           Row(
// //             children: [
// //               Icon(Icons.location_on, size: 16, color: primaryBlue),
// //               const SizedBox(width: 4),
// //               Expanded(
// //                 child: Text(
// //                   visit.location,
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     color: Colors.black87,
// //                   ),
// //                 ),
// //               ),
// //               GestureDetector(
// //                 onTap: () {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text('Opening map...'),
// //                       backgroundColor: primaryBlue,
// //                     ),
// //                   );
// //                 },
// //                 child: Text(
// //                   'Open Map',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     color: Colors.blue[600],
// //                     decoration: TextDecoration.underline,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 20),
// //               Text(
// //                 _formatTime(visit.visitTime),
// //                 style: const TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.w500,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //             ],
// //           ),
// //
// //           // Missed Status or Action Buttons
// //           if (isMissed) ...[
// //             const SizedBox(height: 12),
// //             Align(
// //               alignment: Alignment.centerRight,
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                 child: const Text(
// //                   'Missed',
// //                   style: TextStyle(
// //                     color: Colors.red,
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ] else if (visit.status == 'pending' && isToday) ...[
// //             const SizedBox(height: 16),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                           content: Text('Starting task now...'),
// //                           backgroundColor: primaryBlue,
// //                         ),
// //                       );
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: primaryBlue,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(vertical: 12),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       elevation: 0,
// //                     ),
// //                     child: const Text(
// //                       'Start Now',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: OutlinedButton.icon(
// //                     onPressed: () async {
// //                       await _updateVisitStatus(visits.indexOf(visit), 'completed');
// //                       if (mounted) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(
// //                             content: Text('Task marked as completed'),
// //                             backgroundColor: Colors.green,
// //                           ),
// //                         );
// //                       }
// //                     },
// //                     icon: const Icon(Icons.check, size: 16),
// //                     label: const Text(
// //                       'Mark as Visited',
// //                       style: TextStyle(fontSize: 14),
// //                     ),
// //                     style: OutlinedButton.styleFrom(
// //                       foregroundColor: Colors.grey[700],
// //                       side: BorderSide(color: Colors.grey[400]!),
// //                       padding: const EdgeInsets.symmetric(vertical: 12),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'add_visit_screen.dart';
//
// // Visit model class
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
//
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
// class TasksScreen extends StatefulWidget {
//   const TasksScreen({super.key});
//
//   @override
//   State<TasksScreen> createState() => _TasksScreenState();
// }
//
// class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
//   List<Visit> visits = [];
//   bool isLoading = true;
//   TabController? _tabController;
//   String selectedFilter = 'All';
//
//   // Colors to match the UI
//   static const Color primaryBlue = Color(0xFF0F3A68);
//   static const Color lightGray = Color(0xFFF1F5F9);
//   static const Color cardBackground = Colors.white;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this);
//     _loadVisits();
//   }
//
//   @override
//   void dispose() {
//     _tabController?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadVisits() async {
//     try {
//       setState(() => isLoading = true);
//       final prefs = await SharedPreferences.getInstance();
//       final visitsString = prefs.getString('visits');
//
//       if (visitsString != null) {
//         final List<dynamic> visitsJson = jsonDecode(visitsString);
//         setState(() {
//           visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
//           visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           visits = [];
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         visits = [];
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _saveVisits() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final visitsJson = visits.map((visit) => visit.toJson()).toList();
//       await prefs.setString('visits', jsonEncode(visitsJson));
//     } catch (e) {
//       debugPrint('Error saving visits: $e');
//     }
//   }
//
//   // Add a new visit to the list - FIXED METHOD
//   Future<void> _addVisit(Visit visit) async {
//     setState(() {
//       visits.add(visit);
//       visits.sort((a, b) => a.visitTime.compareTo(b.visitTime)); // Keep sorted
//     });
//     await _saveVisits();
//   }
//
//   Future<void> _updateVisitStatus(int index, String newStatus) async {
//     if (index >= 0 && index < visits.length) {
//       setState(() {
//         visits[index] = visits[index].copyWith(status: newStatus);
//       });
//       await _saveVisits();
//     }
//   }
//
//   List<Visit> _getFilteredTasks() {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//
//     switch (selectedFilter) {
//       case 'Today':
//         return visits.where((visit) {
//           final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
//           return visitDate == today;
//         }).toList();
//       case 'Upcoming':
//         return visits.where((visit) {
//           final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
//           return visitDate.isAfter(today) && visit.status == 'pending';
//         }).toList();
//       case 'Completed':
//         return visits.where((visit) => visit.status == 'completed').toList();
//       case 'Missed':
//         return visits.where((visit) => visit.status == 'missed').toList();
//       default:
//         return visits;
//     }
//   }
//
//   String _formatTime(DateTime dateTime) {
//     return DateFormat('hh:mm a').format(dateTime);
//   }
//
//   bool _isToday(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final visitDate = DateTime(date.year, date.month, date.day);
//     return visitDate == today;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: lightGray,
//       appBar: AppBar(
//         backgroundColor: primaryBlue,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Tasks',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
//                 Positioned(
//                   right: 2,
//                   top: 2,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Container(
//             color: primaryBlue,
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search',
//                 hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
//                 prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
//           ),
//
//           // Filter Tabs
//           Container(
//             color: lightGray,
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: ['All', 'Today', 'Upcoming', 'Completed', 'Missed']
//                     .map((filter) => GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedFilter = filter;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 12),
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: selectedFilter == filter ? primaryBlue : Colors.transparent,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       filter,
//                       style: TextStyle(
//                         color: selectedFilter == filter ? Colors.white : Colors.grey[600],
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ))
//                     .toList(),
//               ),
//             ),
//           ),
//
//           // Tasks List
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator(color: primaryBlue))
//                 : _getFilteredTasks().isEmpty
//                 ? _buildEmptyState()
//                 : RefreshIndicator(
//               onRefresh: _loadVisits,
//               child: ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: _getFilteredTasks().length,
//                 separatorBuilder: (context, index) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final visit = _getFilteredTasks()[index];
//                   return _buildTaskCard(visit, index);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: primaryBlue,
//         onPressed: () async {
//           // FIXED: Properly handle the result from AddVisitScreen
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AddVisitScreen(),
//             ),
//           );
//
//           // Check if a Visit object was returned and add it to the list
//           if (result != null && result is Visit) {
//             await _addVisit(result);
//
//             // Show success message
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Visit scheduled successfully!'),
//                   backgroundColor: Color(0xFF4CAF50),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             }
//           }
//         },
//         child: const Icon(Icons.add, color: Colors.white, size: 24),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.assignment_outlined,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'No Tasks Found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             selectedFilter == 'All'
//                 ? 'No tasks scheduled yet.\nTap + to add your first visit.'
//                 : 'No $selectedFilter tasks found.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//               height: 1.4,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTaskCard(Visit visit, int index) {
//     final isToday = _isToday(visit.visitTime);
//     final isMissed = visit.status == 'missed';
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: cardBackground,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Row - Name and Call Button
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       visit.clientName,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       visit.purpose,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 width: 44,
//                 height: 44,
//                 decoration: const BoxDecoration(
//                   color: primaryBlue,
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: const Icon(Icons.phone, color: Colors.white, size: 20),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Calling ${visit.phoneNumber}...'),
//                         backgroundColor: primaryBlue,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 12),
//
//           // Location and Time Row
//           Row(
//             children: [
//               Icon(Icons.location_on, size: 16, color: primaryBlue),
//               const SizedBox(width: 4),
//               Expanded(
//                 child: Text(
//                   visit.location,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Opening map...'),
//                       backgroundColor: primaryBlue,
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'Open Map',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.blue[600],
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 20),
//               Text(
//                 _formatTime(visit.visitTime),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//
//           // Show notes if available
//           if (visit.notes.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: primaryBlue.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: primaryBlue.withOpacity(0.1),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.notes, size: 14, color: primaryBlue),
//                       const SizedBox(width: 6),
//                       const Text(
//                         'Notes:',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: primaryBlue,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     visit.notes,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//
//           // Missed Status or Action Buttons
//           if (isMissed) ...[
//             const SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerRight,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 child: const Text(
//                   'Missed',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//           ] else if (visit.status == 'pending' && isToday) ...[
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Starting task now...'),
//                           backgroundColor: primaryBlue,
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryBlue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       'Start Now',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () async {
//                       await _updateVisitStatus(visits.indexOf(visit), 'completed');
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Task marked as completed'),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       }
//                     },
//                     icon: const Icon(Icons.check, size: 16),
//                     label: const Text(
//                       'Mark as Visited',
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.grey[700],
//                       side: BorderSide(color: Colors.grey[400]!),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'add_visit_screen.dart';

// Visit model class
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

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
  List<Visit> visits = [];
  bool isLoading = true;
  TabController? _tabController;
  String selectedFilter = 'All';

  // Colors to match the UI
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color cardBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadVisits();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadVisits() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final visitsString = prefs.getString('visits');

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        setState(() {
          visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
          visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
          isLoading = false;
        });
      } else {
        setState(() {
          visits = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        visits = [];
        isLoading = false;
      });
    }
  }

  Future<void> _saveVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsJson = visits.map((visit) => visit.toJson()).toList();
      await prefs.setString('visits', jsonEncode(visitsJson));
    } catch (e) {
      debugPrint('Error saving visits: $e');
    }
  }

  // Add a new visit to the list - FIXED METHOD
  Future<void> _addVisit(Visit visit) async {
    setState(() {
      visits.add(visit);
      visits.sort((a, b) => a.visitTime.compareTo(b.visitTime)); // Keep sorted
    });
    await _saveVisits();
  }

  Future<void> _updateVisitStatus(int index, String newStatus) async {
    if (index >= 0 && index < visits.length) {
      setState(() {
        visits[index] = visits[index].copyWith(status: newStatus);
      });
      await _saveVisits();
    }
  }

  List<Visit> _getFilteredTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedFilter) {
      case 'Today':
        return visits.where((visit) {
          final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
          return visitDate == today;
        }).toList();
      case 'Upcoming':
        return visits.where((visit) {
          final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
          return visitDate.isAfter(today) && visit.status == 'pending';
        }).toList();
      case 'Completed':
        return visits.where((visit) => visit.status == 'completed').toList();
      case 'Missed':
        return visits.where((visit) => visit.status == 'missed').toList();
      default:
        return visits;
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDate = DateTime(date.year, date.month, date.day);
    return visitDate == today;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: primaryBlue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),

          // Filter Tabs
          Container(
            color: lightGray,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Today', 'Upcoming', 'Completed', 'Missed']
                    .map((filter) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedFilter == filter ? primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: selectedFilter == filter ? Colors.white : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),

          // Tasks List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                : _getFilteredTasks().isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadVisits,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _getFilteredTasks().length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final visit = _getFilteredTasks()[index];
                  return _buildTaskCard(visit, index);
                },
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
          backgroundColor: primaryBlue,
          elevation: 0,
          onPressed: () async {
            // FIXED: Properly handle the result from AddVisitScreen (same as home_screen.dart)
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddVisitScreen(),
              ),
            );

            // Check if a Visit object was returned and add it to the list
            if (result != null && result is Visit) {
              await _addVisit(result);

              // Show success message (this will be shown by AddVisitScreen, but we can add our own)
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task added successfully!'),
                    backgroundColor: Color(0xFF4CAF50),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Tasks Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedFilter == 'All'
                ? 'No tasks scheduled yet.\nTap + to add your first visit.'
                : 'No $selectedFilter tasks found.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Visit visit, int index) {
    final isToday = _isToday(visit.visitTime);
    final isMissed = visit.status == 'missed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row - Name and Call Button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.clientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visit.purpose,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${visit.phoneNumber}...'),
                        backgroundColor: primaryBlue,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location and Time Row
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: primaryBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  visit.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening map...'),
                      backgroundColor: primaryBlue,
                    ),
                  );
                },
                child: Text(
                  'Open Map',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                _formatTime(visit.visitTime),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // Show notes if available
          if (visit.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: primaryBlue.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, size: 14, color: primaryBlue),
                      const SizedBox(width: 6),
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visit.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Missed Status or Action Buttons
          if (isMissed) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: const Text(
                  'Missed',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ] else if (visit.status == 'pending' && isToday) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Starting task now...'),
                          backgroundColor: primaryBlue,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _updateVisitStatus(visits.indexOf(visit), 'completed');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task marked as completed'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text(
                      'Mark as Visited',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}