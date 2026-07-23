//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'expense_screen.dart';
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
// class EndDayScreen extends StatefulWidget {
//   const EndDayScreen({super.key});
//
//   @override
//   State<EndDayScreen> createState() => _EndDayScreenState();
// }
//
// class _EndDayScreenState extends State<EndDayScreen> {
//   static const Color primaryBlue = Color(0xFF0F3A68);
//   static const Color tealGreen = Color(0xFF00897B);
//
//   bool isLoading = true;
//   List<Visit> todayVisits = [];
//   DaySummary? summary;
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
//     await _loadTodayData();
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
//       debugPrint('✅ User ID loaded: $_userId');
//     } catch (e) {
//       debugPrint('❌ Error loading user ID: $e');
//       _userId = 'default';
//     }
//   }
//
//   Future<void> _loadTodayData() async {
//     try {
//       setState(() => isLoading = true);
//
//       final prefs = await SharedPreferences.getInstance();
//
//       // Use user-specific key
//       final String visitsKey = 'visits_$_userId';
//       final visitsString = prefs.getString(visitsKey);
//
//       if (visitsString != null) {
//         final List<dynamic> visitsJson = jsonDecode(visitsString);
//         final allVisits = visitsJson.map((json) => Visit.fromJson(json)).toList();
//
//         // Filter visits for today based on ORIGINAL scheduled date (visitTime)
//         final now = DateTime.now();
//         final today = DateTime(now.year, now.month, now.day);
//
//         todayVisits = allVisits.where((visit) {
//           final visitDate = DateTime(
//             visit.visitTime.year,
//             visit.visitTime.month,
//             visit.visitTime.day,
//           );
//           return visitDate.isAtSameMomentAs(today);
//         }).toList();
//
//         debugPrint('📊 Today\'s visits count: ${todayVisits.length}');
//
//         // Calculate statistics based on TODAY'S scheduled tasks
//         final totalTasks = todayVisits.length;
//
//         // Count completed tasks (completed or successfully_met status)
//         final completedTasks = todayVisits.where((v) =>
//         v.status == 'completed' || v.status == 'successfully_met'
//         ).length;
//
//         // Count missed tasks
//         final missedTasks = todayVisits.where((v) => v.status == 'missed').length;
//
//         // Count pending tasks
//         final pendingTasks = todayVisits.where((v) => v.status == 'pending').length;
//
//         debugPrint('📈 Statistics:');
//         debugPrint('  Total: $totalTasks');
//         debugPrint('  Completed: $completedTasks');
//         debugPrint('  Missed: $missedTasks');
//         debugPrint('  Pending: $pendingTasks');
//
//         // Calculate distance based on completed visits (1.5 km per visit)
//         final estimatedDistance = completedTasks * 1.5;
//
//         // Check flags
//         final attendanceMarked = prefs.getBool('attendance_marked_today') ?? false;
//         final taskUpdated = (completedTasks > 0 || missedTasks > 0);
//
//         // Check expenses submission
//         bool expensesSubmitted = prefs.getBool('expenses_submitted_today') ?? false;
//         final lastSubmissionDateStr = prefs.getString('last_expense_submission_date');
//         if (lastSubmissionDateStr != null) {
//           try {
//             final lastSubmissionDate = DateTime.parse(lastSubmissionDateStr);
//             final submissionDay = DateTime(
//               lastSubmissionDate.year,
//               lastSubmissionDate.month,
//               lastSubmissionDate.day,
//             );
//             if (submissionDay.isAtSameMomentAs(today)) {
//               expensesSubmitted = true;
//             }
//           } catch (e) {
//             debugPrint('Error parsing submission date: $e');
//           }
//         }
//
//         final notesMarked = todayVisits.any((v) => v.notes.isNotEmpty);
//
//         summary = DaySummary(
//           date: DateTime.now(),
//           totalTasks: totalTasks,
//           completedTasks: completedTasks,
//           missedTasks: missedTasks,
//           pendingTasks: pendingTasks,
//           totalDistance: '${estimatedDistance.toStringAsFixed(1)} km',
//           attendanceMarked: attendanceMarked,
//           taskUpdated: taskUpdated,
//           expensesSubmitted: expensesSubmitted,
//           notesMarked: notesMarked,
//         );
//       } else {
//         // No visits found
//         summary = DaySummary(
//           date: DateTime.now(),
//           totalTasks: 0,
//           completedTasks: 0,
//           missedTasks: 0,
//           pendingTasks: 0,
//           totalDistance: '0.0 km',
//           attendanceMarked: false,
//           taskUpdated: false,
//           expensesSubmitted: false,
//           notesMarked: false,
//         );
//       }
//
//       setState(() => isLoading = false);
//     } catch (e) {
//       debugPrint('❌ Error loading end day data: $e');
//       setState(() {
//         summary = DaySummary(
//           date: DateTime.now(),
//           totalTasks: 0,
//           completedTasks: 0,
//           missedTasks: 0,
//           pendingTasks: 0,
//           totalDistance: '0.0 km',
//           attendanceMarked: false,
//           taskUpdated: false,
//           expensesSubmitted: false,
//           notesMarked: false,
//         );
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _navigateToExpenseScreen() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const ExpenseScreen()),
//     );
//
//     if (result == true) {
//       await _loadTodayData();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Expense submitted successfully!'),
//             backgroundColor: tealGreen,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }
//
//   void _endDay() {
//     if (summary == null) return;
//
//     // Check if there are any tasks today
//     if (summary!.totalTasks == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No tasks scheduled for today'),
//           backgroundColor: Colors.orange,
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }
//
//     // Check if there are pending tasks
//     if (summary!.pendingTasks > 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('You have ${summary!.pendingTasks} pending task(s). Please complete or update them before ending the day.'),
//           backgroundColor: Colors.orange,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//       return;
//     }
//
//     // Check if expenses are submitted
//     if (!summary!.expensesSubmitted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please submit expenses before ending the day'),
//           backgroundColor: Colors.orange,
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }
//
//     // Show confirmation dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text(
//             'End Day',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1A1A1A),
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Are you sure you want to end your day?',
//                 style: TextStyle(
//                   color: Color(0xFF666666),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Summary:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text('📋 ${summary!.totalTasks} total task(s)'),
//               Text('✅ ${summary!.completedTasks} task(s) completed'),
//               if (summary!.missedTasks > 0)
//                 Text('❌ ${summary!.missedTasks} task(s) missed'),
//               Text('📍 ${summary!.totalDistance} traveled'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 // Reset flags for next day
//                 final prefs = await SharedPreferences.getInstance();
//                 await prefs.setBool('expenses_submitted_today', false);
//                 await prefs.setBool('attendance_marked_today', false);
//
//                 Navigator.pop(context); // Close dialog
//                 Navigator.pop(context); // Go back to previous screen
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Day ended successfully! See you tomorrow.'),
//                     backgroundColor: primaryBlue,
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryBlue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'End Day',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         backgroundColor: primaryBlue,
//         body: const Center(
//           child: CircularProgressIndicator(color: Colors.white),
//         ),
//       );
//     }
//
//     if (summary == null) {
//       return Scaffold(
//         backgroundColor: primaryBlue,
//         body: const Center(
//           child: Text(
//             'Unable to load data',
//             style: TextStyle(color: Colors.white, fontSize: 16),
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: primaryBlue,
//       body: Column(
//         children: [
//           // Custom AppBar
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
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(
//                     Icons.arrow_back_ios,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//                 const Expanded(
//                   child: Text(
//                     'End Day',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
//                   onPressed: _loadTodayData,
//                 ),
//               ],
//             ),
//           ),
//
//           // Main content
//           Expanded(
//             child: Container(
//               color: const Color(0xFFF5F5F5),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Date
//                     Text(
//                       DateFormat('MMM dd, yyyy').format(summary!.date),
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1A1A1A),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Stats Cards
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatCard(
//                             icon: Icons.flag,
//                             label: 'Total',
//                             value: '${summary!.totalTasks}',
//                             color: primaryBlue,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _buildStatCard(
//                             icon: Icons.check_circle,
//                             label: 'Completed',
//                             value: '${summary!.completedTasks}',
//                             color: tealGreen,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatCard(
//                             icon: Icons.trending_down,
//                             label: 'Missed',
//                             value: '${summary!.missedTasks}',
//                             color: Colors.orange,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _buildStatCard(
//                             icon: Icons.flight,
//                             label: 'Total\nDistance',
//                             value: summary!.totalDistance,
//                             color: primaryBlue,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Checklist
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             spreadRadius: 0,
//                             blurRadius: 12,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           _buildChecklistItem(
//                             'Attendance Marked',
//                             summary!.attendanceMarked,
//                             onTap: summary!.attendanceMarked ? null : () async {
//                               final prefs = await SharedPreferences.getInstance();
//                               await prefs.setBool('attendance_marked_today', true);
//                               await _loadTodayData();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Attendance marked'),
//                                   backgroundColor: tealGreen,
//                                 ),
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 20),
//                           _buildChecklistItem(
//                             'Task Updated',
//                             summary!.taskUpdated,
//                           ),
//                           const SizedBox(height: 20),
//                           _buildChecklistItem(
//                             'Expenses Submitted',
//                             summary!.expensesSubmitted,
//                             onTap: summary!.expensesSubmitted ? null : _navigateToExpenseScreen,
//                           ),
//                           const SizedBox(height: 20),
//                           _buildChecklistItem(
//                             'Notes Marked (if any)',
//                             summary!.notesMarked,
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     // End Day Button
//                     GestureDetector(
//                       onTap: _endDay,
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 18),
//                         decoration: BoxDecoration(
//                           color: primaryBlue,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: primaryBlue.withOpacity(0.3),
//                               spreadRadius: 0,
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: const Text(
//                           'End my Day',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       // Bottom Navigation Bar
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
//   Widget _buildStatCard({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//           Icon(icon, color: color, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF666666),
//               fontWeight: FontWeight.w500,
//               height: 1.3,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF1A1A1A),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChecklistItem(String title, bool isCompleted, {VoidCallback? onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Container(
//             width: 28,
//             height: 28,
//             decoration: BoxDecoration(
//               color: isCompleted ? tealGreen : Colors.grey.shade400,
//               shape: BoxShape.circle,
//             ),
//             child: isCompleted
//                 ? const Icon(
//               Icons.check,
//               color: Colors.white,
//               size: 18,
//             )
//                 : null,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: isCompleted ? const Color(0xFF1A1A1A) : const Color(0xFF666666),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           if (onTap != null && !isCompleted)
//             const Icon(
//               Icons.chevron_right,
//               color: Color(0xFF1A1A1A),
//               size: 24,
//             ),
//         ],
//       ),
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
//
// // Day Summary Model
// class DaySummary {
//   final DateTime date;
//   final int totalTasks;
//   final int completedTasks;
//   final int missedTasks;
//   final int pendingTasks;
//   final String totalDistance;
//   final bool attendanceMarked;
//   final bool taskUpdated;
//   final bool expensesSubmitted;
//   final bool notesMarked;
//
//   DaySummary({
//     required this.date,
//     required this.totalTasks,
//     required this.completedTasks,
//     required this.missedTasks,
//     required this.pendingTasks,
//     required this.totalDistance,
//     required this.attendanceMarked,
//     required this.taskUpdated,
//     required this.expensesSubmitted,
//     required this.notesMarked,
//   });
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_form_screen.dart'; // CHANGED: Import ExpenseFormScreen instead

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

class EndDayScreen extends StatefulWidget {
  const EndDayScreen({super.key});

  @override
  State<EndDayScreen> createState() => _EndDayScreenState();
}

class _EndDayScreenState extends State<EndDayScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color tealGreen = Color(0xFF00897B);

  bool isLoading = true;
  List<Visit> todayVisits = [];
  DaySummary? summary;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    await _loadUserId();
    await _loadTodayData();
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
      debugPrint('✅ User ID loaded: $_userId');
    } catch (e) {
      debugPrint('❌ Error loading user ID: $e');
      _userId = 'default';
    }
  }

  Future<void> _loadTodayData() async {
    try {
      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();

      // Use user-specific key
      final String visitsKey = 'visits_$_userId';
      final visitsString = prefs.getString(visitsKey);

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        final allVisits = visitsJson.map((json) => Visit.fromJson(json)).toList();

        // Filter visits for today based on ORIGINAL scheduled date (visitTime)
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        todayVisits = allVisits.where((visit) {
          final visitDate = DateTime(
            visit.visitTime.year,
            visit.visitTime.month,
            visit.visitTime.day,
          );
          return visitDate.isAtSameMomentAs(today);
        }).toList();

        debugPrint('📊 Today\'s visits count: ${todayVisits.length}');

        // Calculate statistics based on TODAY'S scheduled tasks
        final totalTasks = todayVisits.length;

        // Count completed tasks (completed or successfully_met status)
        final completedTasks = todayVisits.where((v) =>
        v.status == 'completed' || v.status == 'successfully_met'
        ).length;

        // Count missed tasks
        final missedTasks = todayVisits.where((v) => v.status == 'missed').length;

        // Count pending tasks
        final pendingTasks = todayVisits.where((v) => v.status == 'pending').length;

        debugPrint('📈 Statistics:');
        debugPrint('  Total: $totalTasks');
        debugPrint('  Completed: $completedTasks');
        debugPrint('  Missed: $missedTasks');
        debugPrint('  Pending: $pendingTasks');

        // Calculate distance based on completed visits (1.5 km per visit)
        final estimatedDistance = completedTasks * 1.5;

        // Check flags
        final attendanceMarked = prefs.getBool('attendance_marked_today') ?? false;
        final taskUpdated = (completedTasks > 0 || missedTasks > 0);

        // IMPROVED: Check expenses submission with better date handling
        bool expensesSubmitted = false;

        // Check if there are any expenses submitted today
        final expensesString = prefs.getStringList('expenses');
        if (expensesString != null && expensesString.isNotEmpty) {
          for (String expenseJson in expensesString) {
            try {
              final expense = jsonDecode(expenseJson);
              final submittedAt = DateTime.parse(expense['submittedAt']);
              final submittedDay = DateTime(
                submittedAt.year,
                submittedAt.month,
                submittedAt.day,
              );

              if (submittedDay.isAtSameMomentAs(today)) {
                expensesSubmitted = true;
                break;
              }
            } catch (e) {
              debugPrint('Error parsing expense: $e');
            }
          }
        }

        debugPrint('💰 Expenses submitted today: $expensesSubmitted');

        final notesMarked = todayVisits.any((v) => v.notes.isNotEmpty);

        summary = DaySummary(
          date: DateTime.now(),
          totalTasks: totalTasks,
          completedTasks: completedTasks,
          missedTasks: missedTasks,
          pendingTasks: pendingTasks,
          totalDistance: '${estimatedDistance.toStringAsFixed(1)} km',
          attendanceMarked: attendanceMarked,
          taskUpdated: taskUpdated,
          expensesSubmitted: expensesSubmitted,
          notesMarked: notesMarked,
        );
      } else {
        // No visits found
        summary = DaySummary(
          date: DateTime.now(),
          totalTasks: 0,
          completedTasks: 0,
          missedTasks: 0,
          pendingTasks: 0,
          totalDistance: '0.0 km',
          attendanceMarked: false,
          taskUpdated: false,
          expensesSubmitted: false,
          notesMarked: false,
        );
      }

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ Error loading end day data: $e');
      setState(() {
        summary = DaySummary(
          date: DateTime.now(),
          totalTasks: 0,
          completedTasks: 0,
          missedTasks: 0,
          pendingTasks: 0,
          totalDistance: '0.0 km',
          attendanceMarked: false,
          taskUpdated: false,
          expensesSubmitted: false,
          notesMarked: false,
        );
        isLoading = false;
      });
    }
  }

  // CHANGED: Navigate to ExpenseFormScreen and refresh on return
  Future<void> _navigateToExpenseScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseFormScreen()),
    );

    // Refresh data when returning from expense form
    if (result == true) {
      await _loadTodayData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense submitted successfully!'),
            backgroundColor: tealGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _endDay() {
    if (summary == null) return;

    // Check if there are any tasks today
    if (summary!.totalTasks == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tasks scheduled for today'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if there are pending tasks
    if (summary!.pendingTasks > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have ${summary!.pendingTasks} pending task(s). Please complete or update them before ending the day.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check if expenses are submitted
    if (!summary!.expensesSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please submit expenses before ending the day'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'End Day',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to end your day?',
                style: TextStyle(
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Summary:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text('📋 ${summary!.totalTasks} total task(s)'),
              Text('✅ ${summary!.completedTasks} task(s) completed'),
              if (summary!.missedTasks > 0)
                Text('❌ ${summary!.missedTasks} task(s) missed'),
              Text('📍 ${summary!.totalDistance} traveled'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Reset flags for next day
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('attendance_marked_today', false);

                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Day ended successfully! See you tomorrow.'),
                    backgroundColor: primaryBlue,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'End Day',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: primaryBlue,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (summary == null) {
      return Scaffold(
        backgroundColor: primaryBlue,
        body: const Center(
          child: Text(
            'Unable to load data',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Column(
        children: [
          // Custom AppBar
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
                    'End Day',
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
                  onPressed: _loadTodayData,
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Text(
                      DateFormat('MMM dd, yyyy').format(summary!.date),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.flag,
                            label: 'Total',
                            value: '${summary!.totalTasks}',
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle,
                            label: 'Completed',
                            value: '${summary!.completedTasks}',
                            color: tealGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.trending_down,
                            label: 'Missed',
                            value: '${summary!.missedTasks}',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.flight,
                            label: 'Total\nDistance',
                            value: summary!.totalDistance,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Checklist
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          _buildChecklistItem(
                            'Attendance Marked',
                            summary!.attendanceMarked,
                            onTap: summary!.attendanceMarked ? null : () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('attendance_marked_today', true);
                              await _loadTodayData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Attendance marked'),
                                  backgroundColor: tealGreen,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildChecklistItem(
                            'Task Updated',
                            summary!.taskUpdated,
                          ),
                          const SizedBox(height: 20),
                          _buildChecklistItem(
                            'Expenses Submitted',
                            summary!.expensesSubmitted,
                            onTap: summary!.expensesSubmitted ? null : _navigateToExpenseScreen,
                          ),
                          const SizedBox(height: 20),
                          _buildChecklistItem(
                            'Notes Marked (if any)',
                            summary!.notesMarked,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // End Day Button
                    GestureDetector(
                      onTap: _endDay,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'End my Day',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool isCompleted, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? tealGreen : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isCompleted ? const Color(0xFF1A1A1A) : const Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onTap != null && !isCompleted)
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF1A1A1A),
              size: 24,
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

// Day Summary Model
class DaySummary {
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final int missedTasks;
  final int pendingTasks;
  final String totalDistance;
  final bool attendanceMarked;
  final bool taskUpdated;
  final bool expensesSubmitted;
  final bool notesMarked;

  DaySummary({
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
    required this.missedTasks,
    required this.pendingTasks,
    required this.totalDistance,
    required this.attendanceMarked,
    required this.taskUpdated,
    required this.expensesSubmitted,
    required this.notesMarked,
  });
}