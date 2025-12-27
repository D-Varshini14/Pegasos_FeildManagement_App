//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'break.dart';
// import 'check_in.dart';
// import 'end_day.dart';
// import 'leave.dart';
// import 'client_summary_screen.dart' as summary;
//
// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({super.key});
//
//   @override
//   State<CalendarScreen> createState() => _CalendarScreenState();
// }
//
// class _CalendarScreenState extends State<CalendarScreen> {
//   static const Color primaryBlue = Color(0xFF0F3A68);
//   DateTime _currentDate = DateTime.now();
//   DateTime _selectedDate = DateTime.now();
//   List<summary.Visit> _allVisits = [];
//   bool _isLoading = true;
//   String _userId = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }
//
//   Future<void> _initializeData() async {
//     await _loadUserData();
//     await _loadVisits();
//   }
//
//   Future<void> _loadUserData() async {
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
//       debugPrint('✅ User loaded in Calendar: $_userId');
//     } catch (e) {
//       debugPrint('❌ Error loading user data: $e');
//       _userId = 'default';
//     }
//   }
//
//   Future<void> _loadVisits() async {
//     try {
//       setState(() => _isLoading = true);
//       final prefs = await SharedPreferences.getInstance();
//
//       // Use user-specific key
//       final String visitsKey = 'visits_$_userId';
//       final visitsString = prefs.getString(visitsKey);
//
//       if (visitsString != null) {
//         final List<dynamic> visitsJson = jsonDecode(visitsString);
//         setState(() {
//           _allVisits = visitsJson.map((json) => summary.Visit.fromJson(json)).toList();
//           _allVisits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
//           _isLoading = false;
//         });
//         debugPrint('✅ Calendar: Loaded ${_allVisits.length} visits for user: $_userId');
//
//         // Debug: Print all visit dates
//         for (var visit in _allVisits) {
//           debugPrint('📅 Visit: ${visit.clientName} on ${DateFormat('MMM dd, yyyy').format(visit.visitTime)}');
//         }
//       } else {
//         setState(() {
//           _allVisits = [];
//           _isLoading = false;
//         });
//         debugPrint('ℹ️ No visits found for user: $_userId');
//       }
//     } catch (e) {
//       debugPrint('❌ Calendar: Error loading visits - $e');
//       setState(() {
//         _allVisits = [];
//         _isLoading = false;
//       });
//     }
//   }
//
//   List<summary.Visit> _getVisitsForSelectedDate() {
//     // Normalize the selected date to midnight for comparison
//     final selectedDateOnly = DateTime(
//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//     );
//
//     debugPrint('🔍 Looking for visits on: ${DateFormat('MMM dd, yyyy').format(selectedDateOnly)}');
//
//     final matchingVisits = _allVisits.where((visit) {
//       // Normalize the visit date to midnight for comparison
//       final visitDateOnly = DateTime(
//         visit.visitTime.year,
//         visit.visitTime.month,
//         visit.visitTime.day,
//       );
//
//       final matches = visitDateOnly.year == selectedDateOnly.year &&
//           visitDateOnly.month == selectedDateOnly.month &&
//           visitDateOnly.day == selectedDateOnly.day;
//
//       if (matches) {
//         debugPrint('✅ Found match: ${visit.clientName} on ${DateFormat('MMM dd, yyyy').format(visitDateOnly)}');
//       }
//
//       return matches;
//     }).toList();
//
//     debugPrint('📊 Total visits for selected date: ${matchingVisits.length}');
//     return matchingVisits;
//   }
//
//   String _formatTime(DateTime dateTime) {
//     return DateFormat('hh:mm a').format(dateTime);
//   }
//
//   // Check if a specific date has any visits
//   bool _hasVisitsOnDate(DateTime date) {
//     final dateOnly = DateTime(date.year, date.month, date.day);
//
//     return _allVisits.any((visit) {
//       final visitDateOnly = DateTime(
//         visit.visitTime.year,
//         visit.visitTime.month,
//         visit.visitTime.day,
//       );
//       return visitDateOnly.year == dateOnly.year &&
//           visitDateOnly.month == dateOnly.month &&
//           visitDateOnly.day == dateOnly.day;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final visitsForSelectedDate = _getVisitsForSelectedDate();
//
//     return Scaffold(
//       backgroundColor: primaryBlue,
//       drawer: _buildSidebar(context),
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
//             child: Row(
//               children: [
//                 Builder(
//                   builder: (context) => GestureDetector(
//                     onTap: () => Scaffold.of(context).openDrawer(),
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       child: const Icon(
//                         Icons.menu,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const Expanded(
//                   child: Text(
//                     'Calendar',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 28,
//                       fontWeight: FontWeight.w600,
//                     ),
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
//           Expanded(
//             child: Container(
//               color: const Color(0xFFF8F9FA),
//               child: _isLoading
//                   ? const Center(
//                 child: CircularProgressIndicator(color: primaryBlue),
//               )
//                   : RefreshIndicator(
//                 onRefresh: _loadVisits,
//                 child: SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(20),
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
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 IconButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _currentDate = DateTime(
//                                         _currentDate.year,
//                                         _currentDate.month - 1,
//                                       );
//                                     });
//                                   },
//                                   icon: const Icon(Icons.chevron_left, color: primaryBlue),
//                                 ),
//                                 Text(
//                                   DateFormat('MMMM yyyy').format(_currentDate),
//                                   style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w600,
//                                     color: primaryBlue,
//                                   ),
//                                 ),
//                                 IconButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _currentDate = DateTime(
//                                         _currentDate.year,
//                                         _currentDate.month + 1,
//                                       );
//                                     });
//                                   },
//                                   icon: const Icon(Icons.chevron_right, color: primaryBlue),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             _buildCalendarGrid(),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       // Display selected date info
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: primaryBlue.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: primaryBlue.withOpacity(0.2)),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.calendar_today, color: primaryBlue, size: 20),
//                             const SizedBox(width: 12),
//                             Text(
//                               'Selected: ${DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate)}',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: primaryBlue,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       if (visitsForSelectedDate.isNotEmpty) ...[
//                         ...visitsForSelectedDate.map(
//                               (visit) => _buildVisitCard(visit),
//                         ),
//                       ] else ...[
//                         Container(
//                           padding: const EdgeInsets.all(40),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.04),
//                                 spreadRadius: 0,
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.event_busy,
//                                 size: 64,
//                                 color: Colors.grey[400],
//                               ),
//                               const SizedBox(height: 16),
//                               const Text(
//                                 'No Events Scheduled',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'No visits scheduled for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                   height: 1.5,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCalendarGrid() {
//     final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
//     final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
//     final firstDayWeekday = firstDayOfMonth.weekday;
//     final daysInMonth = lastDayOfMonth.day;
//     const weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
//
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: weekDays
//               .map((day) => Container(
//             width: 40,
//             height: 40,
//             alignment: Alignment.center,
//             child: Text(
//               day,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ))
//               .toList(),
//         ),
//         const SizedBox(height: 8),
//         ...List.generate(6, (weekIndex) {
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(7, (dayIndex) {
//               final dayNumber = weekIndex * 7 + dayIndex + 1 - (firstDayWeekday % 7);
//
//               if (dayNumber < 1 || dayNumber > daysInMonth) {
//                 return Container(width: 40, height: 40);
//               }
//
//               final dayDate = DateTime(_currentDate.year, _currentDate.month, dayNumber);
//               final isSelected = _isSameDay(dayDate, _selectedDate);
//               final isToday = _isSameDay(dayDate, DateTime.now());
//               final hasVisits = _hasVisitsOnDate(dayDate);
//
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedDate = dayDate;
//                   });
//                   debugPrint('📅 Selected date: ${DateFormat('MMM dd, yyyy').format(dayDate)}');
//                 },
//                 child: Container(
//                   width: 40,
//                   height: 40,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? primaryBlue
//                         : isToday
//                         ? primaryBlue.withOpacity(0.1)
//                         : null,
//                     shape: BoxShape.circle,
//                     border: hasVisits && !isSelected
//                         ? Border.all(color: primaryBlue.withOpacity(0.5), width: 2)
//                         : null,
//                   ),
//                   child: Text(
//                     '$dayNumber',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: isSelected
//                           ? Colors.white
//                           : isToday
//                           ? primaryBlue
//                           : const Color(0xFF1A1A1A),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           );
//         }),
//       ],
//     );
//   }
//
//   bool _isSameDay(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }
//
//   Widget _buildSidebar(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Column(
//         children: [
//           Container(
//             height: 200,
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               color: primaryBlue,
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.person,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Professional Dashboard',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 _buildSidebarItem(
//                   context,
//                   icon: Icons.coffee_outlined,
//                   title: 'Take a Break',
//                   onTap: () => _navigateToScreen(context, const TakeBreakScreen()),
//                 ),
//                 _buildSidebarItem(
//                   context,
//                   icon: Icons.beach_access_outlined,
//                   title: 'Apply for Leave',
//                   onTap: () => _navigateToScreen(context, const ApplyLeaveScreen()),
//                 ),
//                 _buildSidebarItem(
//                   context,
//                   icon: Icons.wb_sunny_outlined,
//                   title: 'End Day',
//                   onTap: () => _navigateToScreen(context, const EndDayScreen()),
//                 ),
//                 _buildSidebarItem(
//                   context,
//                   icon: Icons.history_outlined,
//                   title: 'Check-In History',
//                   onTap: () => _navigateToScreen(context, const CheckInHistoryScreen()),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSidebarItem(
//       BuildContext context, {
//         required IconData icon,
//         required String title,
//         required VoidCallback onTap,
//       }) {
//     return ListTile(
//       leading: Icon(icon, color: primaryBlue, size: 24),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: Color(0xFF1A1A1A),
//         ),
//       ),
//       onTap: () {
//         Navigator.of(context).pop();
//         onTap();
//       },
//       contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//     );
//   }
//
//   void _navigateToScreen(BuildContext context, Widget screen) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => screen),
//     );
//   }
//
//   // Get status display text
//   String _getStatusDisplayText(String status) {
//     switch (status) {
//       case 'completed':
//       case 'successfully_met':
//         return 'COMPLETED';
//       case 'pending':
//         return 'PENDING';
//       case 'missed':
//         return 'MISSED';
//       case 'client_not_available':
//         return 'CLIENT NOT AVAILABLE';
//       case 'postponed':
//         return 'POSTPONED';
//       case 'cancelled':
//         return 'CANCELLED';
//       case 'in_progress':
//         return 'IN PROGRESS';
//       default:
//         return status.replaceAll('_', ' ').toUpperCase();
//     }
//   }
//
//   // Get status color
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'completed':
//       case 'successfully_met':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'missed':
//         return Colors.red;
//       case 'client_not_available':
//         return Colors.grey;
//       case 'postponed':
//         return Colors.blue;
//       case 'cancelled':
//         return Colors.red;
//       case 'in_progress':
//         return primaryBlue;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   // Get status icon
//   IconData _getStatusIcon(String status) {
//     switch (status) {
//       case 'completed':
//       case 'successfully_met':
//         return Icons.check_circle_outline;
//       case 'pending':
//         return Icons.schedule_outlined;
//       case 'missed':
//         return Icons.cancel_outlined;
//       case 'client_not_available':
//         return Icons.person_off_outlined;
//       case 'postponed':
//         return Icons.update_outlined;
//       case 'cancelled':
//         return Icons.close_outlined;
//       case 'in_progress':
//         return Icons.sync_outlined;
//       default:
//         return Icons.info_outline;
//     }
//   }
//
//   // Build visit card with status
//   Widget _buildVisitCard(summary.Visit visit) {
//     final statusColor = _getStatusColor(visit.status);
//     final statusText = _getStatusDisplayText(visit.status);
//     final statusIcon = _getStatusIcon(visit.status);
//     final isCompleted = visit.status == 'completed' || visit.status == 'successfully_met';
//     final isMissed = visit.status == 'missed';
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border(
//           left: BorderSide(
//             color: statusColor,
//             width: 4,
//           ),
//         ),
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with name and status
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       visit.clientName,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: const Color(0xFF1A1A1A),
//                         decoration: isMissed ? TextDecoration.lineThrough : null,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       visit.purpose,
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: const Color(0xFF666666),
//                         decoration: isMissed ? TextDecoration.lineThrough : null,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Status badge
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: statusColor.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(statusIcon, size: 14, color: statusColor),
//                     const SizedBox(width: 6),
//                     Text(
//                       statusText,
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         color: statusColor,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 12),
//
//           // Location and time row
//           Row(
//             children: [
//               Icon(
//                 Icons.location_on_outlined,
//                 size: 16,
//                 color: Colors.grey[600],
//               ),
//               const SizedBox(width: 4),
//               Expanded(
//                 child: Text(
//                   visit.location,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Icon(
//                 Icons.access_time_outlined,
//                 size: 16,
//                 color: Colors.grey[600],
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 _formatTime(visit.visitTime),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1A1A1A),
//                 ),
//               ),
//             ],
//           ),
//
//           // Notes if available
//           if (visit.notes.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: primaryBlue.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: primaryBlue.withOpacity(0.1)),
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
//           const SizedBox(height: 16),
//
//           // Action button
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Calling ${visit.phoneNumber}...'),
//                         backgroundColor: primaryBlue,
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.phone, size: 16),
//                   label: const Text('Call Client'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: primaryBlue,
//                     side: const BorderSide(color: primaryBlue),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//               if (isCompleted) ...[
//                 const SizedBox(width: 12),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.check_circle,
//                     color: Colors.green,
//                     size: 20,
//                   ),
//                 ),
//               ],
//               if (isMissed) ...[
//                 const SizedBox(width: 12),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.cancel,
//                     color: Colors.red,
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'break.dart';
import 'check_in.dart';
import 'end_day.dart';
import 'leave.dart';
import 'client_summary_screen.dart' as summary;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<summary.Visit> _allVisits = [];
  bool _isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _loadVisits();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final userData = jsonDecode(userString);
        _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
      } else {
        _userId = 'default';
      }
      debugPrint('✅ User loaded in Calendar: $_userId');
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      _userId = 'default';
    }
  }

  Future<void> _loadVisits() async {
    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();

      // Use user-specific key
      final String visitsKey = 'visits_$_userId';
      final visitsString = prefs.getString(visitsKey);

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        setState(() {
          _allVisits = visitsJson.map((json) => summary.Visit.fromJson(json)).toList();
          _allVisits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
          _isLoading = false;
        });
        debugPrint('✅ Calendar: Loaded ${_allVisits.length} visits for user: $_userId');

        // Debug: Print all visit dates
        for (var visit in _allVisits) {
          debugPrint('📅 Visit: ${visit.clientName} on ${DateFormat('MMM dd, yyyy').format(visit.visitTime)}');
        }
      } else {
        setState(() {
          _allVisits = [];
          _isLoading = false;
        });
        debugPrint('ℹ️ No visits found for user: $_userId');
      }
    } catch (e) {
      debugPrint('❌ Calendar: Error loading visits - $e');
      setState(() {
        _allVisits = [];
        _isLoading = false;
      });
    }
  }

  List<summary.Visit> _getVisitsForSelectedDate() {
    // Normalize the selected date to midnight for comparison
    final selectedDateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    debugPrint('🔍 Looking for visits on: ${DateFormat('MMM dd, yyyy').format(selectedDateOnly)}');

    final matchingVisits = _allVisits.where((visit) {
      // Normalize the visit date to midnight for comparison
      final visitDateOnly = DateTime(
        visit.visitTime.year,
        visit.visitTime.month,
        visit.visitTime.day,
      );

      final matches = visitDateOnly.year == selectedDateOnly.year &&
          visitDateOnly.month == selectedDateOnly.month &&
          visitDateOnly.day == selectedDateOnly.day;

      if (matches) {
        debugPrint('✅ Found match: ${visit.clientName} on ${DateFormat('MMM dd, yyyy').format(visitDateOnly)}');
      }

      return matches;
    }).toList();

    debugPrint('📊 Total visits for selected date: ${matchingVisits.length}');
    return matchingVisits;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Check if a specific date has any visits
  bool _hasVisitsOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return _allVisits.any((visit) {
      final visitDateOnly = DateTime(
        visit.visitTime.year,
        visit.visitTime.month,
        visit.visitTime.day,
      );
      return visitDateOnly.year == dateOnly.year &&
          visitDateOnly.month == dateOnly.month &&
          visitDateOnly.day == dateOnly.day;
    });
  }

  // Check if date is in the past
  bool _isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  // Check if date is in the future
  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    final visitsForSelectedDate = _getVisitsForSelectedDate();

    return Scaffold(
      backgroundColor: primaryBlue,
      drawer: _buildSidebar(context),
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
              children: [
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Calendar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
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
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              )
                  : RefreshIndicator(
                onRefresh: _loadVisits,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentDate = DateTime(
                                        _currentDate.year,
                                        _currentDate.month - 1,
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.chevron_left, color: primaryBlue),
                                ),
                                Text(
                                  DateFormat('MMMM yyyy').format(_currentDate),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: primaryBlue,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentDate = DateTime(
                                        _currentDate.year,
                                        _currentDate.month + 1,
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.chevron_right, color: primaryBlue),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildCalendarGrid(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Display selected date info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryBlue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: primaryBlue, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Selected: ${DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (visitsForSelectedDate.isNotEmpty) ...[
                        ...visitsForSelectedDate.map(
                              (visit) => _buildVisitCard(visit),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(40),
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
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Events Scheduled',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No visits scheduled for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    const weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays
              .map((day) => Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(6, (weekIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex + 1 - (firstDayWeekday % 7);

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(width: 40, height: 40);
              }

              final dayDate = DateTime(_currentDate.year, _currentDate.month, dayNumber);
              final isSelected = _isSameDay(dayDate, _selectedDate);
              final isToday = _isSameDay(dayDate, DateTime.now());
              final hasVisits = _hasVisitsOnDate(dayDate);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = dayDate;
                  });
                  debugPrint('📅 Selected date: ${DateFormat('MMM dd, yyyy').format(dayDate)}');
                },
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryBlue
                        : isToday
                        ? primaryBlue.withOpacity(0.1)
                        : null,
                    shape: BoxShape.circle,
                    border: hasVisits && !isSelected
                        ? Border.all(color: primaryBlue.withOpacity(0.5), width: 2)
                        : null,
                  ),
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? primaryBlue
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: primaryBlue,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Professional Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.coffee_outlined,
                  title: 'Take a Break',
                  onTap: () => _navigateToScreen(context, const TakeBreakScreen()),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.beach_access_outlined,
                  title: 'Apply for Leave',
                  onTap: () => _navigateToScreen(context, const ApplyLeaveScreen()),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  title: 'End Day',
                  onTap: () => _navigateToScreen(context, const EndDayScreen()),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.history_outlined,
                  title: 'Check-In History',
                  onTap: () => _navigateToScreen(context, const CheckInHistoryScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: primaryBlue, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A1A),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Get status display text
  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'completed':
      case 'successfully_met':
        return 'COMPLETED';
      case 'pending':
        return 'PENDING';
      case 'missed':
        return 'MISSED';
      case 'client_not_available':
        return 'CLIENT NOT AVAILABLE';
      case 'postponed':
        return 'POSTPONED';
      case 'cancelled':
        return 'CANCELLED';
      case 'in_progress':
        return 'IN PROGRESS';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  // Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'successfully_met':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      case 'client_not_available':
        return Colors.grey;
      case 'postponed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return primaryBlue;
      default:
        return Colors.grey;
    }
  }

  // Get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
      case 'successfully_met':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.schedule_outlined;
      case 'missed':
        return Icons.cancel_outlined;
      case 'client_not_available':
        return Icons.person_off_outlined;
      case 'postponed':
        return Icons.update_outlined;
      case 'cancelled':
        return Icons.close_outlined;
      case 'in_progress':
        return Icons.sync_outlined;
      default:
        return Icons.info_outline;
    }
  }

  // Build visit card with status - Professional design
  Widget _buildVisitCard(summary.Visit visit) {
    final statusColor = _getStatusColor(visit.status);
    final statusText = _getStatusDisplayText(visit.status);
    final statusIcon = _getStatusIcon(visit.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    visit.clientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
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
              visit.purpose,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 8),

            // Location and time
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    visit.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTime(visit.visitTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),

            // Notes if available
            if (visit.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryBlue.withOpacity(0.1)),
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}