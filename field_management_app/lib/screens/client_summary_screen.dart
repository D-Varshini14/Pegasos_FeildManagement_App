// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:file_picker/file_picker.dart';
// import 'client_summary_screen.dart' as summary;
//
// // Visit model class (enhanced with additional fields)
// class Visit {
//   final String clientName;
//   final String purpose;
//   final String location;
//   final String phoneNumber;
//   final DateTime visitTime;
//   final String status;
//   final String notes;
//   final String nextAction;
//   final bool hasReminder;
//   final List<String> attachedDocuments;
//
//   Visit({
//     required this.clientName,
//     required this.purpose,
//     required this.location,
//     required this.phoneNumber,
//     required this.visitTime,
//     this.status = 'pending',
//     this.notes = '',
//     this.nextAction = '',
//     this.hasReminder = false,
//     this.attachedDocuments = const [],
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
//       'nextAction': nextAction,
//       'hasReminder': hasReminder,
//       'attachedDocuments': attachedDocuments,
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
//       nextAction: json['nextAction'] ?? '',
//       hasReminder: json['hasReminder'] ?? false,
//       attachedDocuments: json['attachedDocuments'] != null
//           ? List<String>.from(json['attachedDocuments'])
//           : [],
//     );
//   }
//
//   Visit copyWith({
//     String? status,
//     String? notes,
//     String? nextAction,
//     bool? hasReminder,
//     List<String>? attachedDocuments,
//   }) {
//     return Visit(
//       clientName: clientName,
//       purpose: purpose,
//       location: location,
//       phoneNumber: phoneNumber,
//       visitTime: visitTime,
//       status: status ?? this.status,
//       notes: notes ?? this.notes,
//       nextAction: nextAction ?? this.nextAction,
//       hasReminder: hasReminder ?? this.hasReminder,
//       attachedDocuments: attachedDocuments ?? this.attachedDocuments,
//     );
//   }
// }
//
// class ClientSummaryScreen extends StatefulWidget {
//   final Visit? selectedVisit;
//
//   const ClientSummaryScreen({super.key, this.selectedVisit});
//
//   @override
//   State<ClientSummaryScreen> createState() => _ClientSummaryScreenState();
// }
//
// class _ClientSummaryScreenState extends State<ClientSummaryScreen> {
//   // Colors to match the UI
//   static const Color primaryBlue = Color(0xFF0F3A68);
//   static const Color lightGray = Color(0xFFF1F5F9);
//   static const Color cardBackground = Colors.white;
//
//   List<Visit> _visits = [];
//   Visit? _currentVisit;
//   String _selectedVisitStatus = '';
//   String _visitNotes = '';
//   String _nextAction = '';
//   bool _setReminder = false;
//   List<String> _attachedDocuments = [];
//   bool _isLoading = false;
//   String _userName = 'User';
//
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _nextActionController = TextEditingController();
//
//   // Visit status options
//   final List<String> _statusOptions = [
//     'Successfully Met',
//     'Client Not Available',
//     'Postponed',
//     'Cancelled',
//     'In Progress'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _initializeVisit();
//   }
//
//   Future<void> _initializeVisit() async {
//     if (widget.selectedVisit != null) {
//       setState(() {
//         _currentVisit = widget.selectedVisit;
//         _visitNotes = _currentVisit!.notes;
//         _notesController.text = _visitNotes;
//         _nextAction = _currentVisit!.nextAction;
//         _nextActionController.text = _nextAction;
//         _setReminder = _currentVisit!.hasReminder;
//         _attachedDocuments = List<String>.from(_currentVisit!.attachedDocuments);
//
//         if (_currentVisit!.status != 'pending') {
//           _selectedVisitStatus = _getDisplayStatus(_currentVisit!.status);
//         }
//       });
//       debugPrint('Initialized with selected visit: ${_currentVisit!.clientName}');
//     }
//
//     await _loadVisits();
//   }
//
//   @override
//   void dispose() {
//     _notesController.dispose();
//     _nextActionController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userString = prefs.getString('user');
//
//       if (userString != null) {
//         final userData = jsonDecode(userString);
//         setState(() {
//           _userName = userData['name'] ?? 'User';
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading user data: $e');
//     }
//   }
//
//   Future<void> _loadVisits() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final visitsString = prefs.getString('visits');
//
//       if (visitsString != null) {
//         final List<dynamic> visitsJson = jsonDecode(visitsString);
//         setState(() {
//           _visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
//
//           if (widget.selectedVisit != null) {
//             _currentVisit = widget.selectedVisit;
//             debugPrint('Using selected visit: ${_currentVisit!.clientName}');
//           } else if (_visits.isNotEmpty) {
//             _currentVisit = _visits.firstWhere(
//                   (visit) => visit.status == 'pending',
//               orElse: () => _visits.first,
//             );
//             debugPrint('Using fallback visit: ${_currentVisit!.clientName}');
//           }
//
//           if (_currentVisit != null) {
//             _visitNotes = _currentVisit!.notes;
//             _notesController.text = _visitNotes;
//             _nextAction = _currentVisit!.nextAction;
//             _nextActionController.text = _nextAction;
//             _setReminder = _currentVisit!.hasReminder;
//             _attachedDocuments = List<String>.from(_currentVisit!.attachedDocuments);
//
//             if (_currentVisit!.status != 'pending') {
//               _selectedVisitStatus = _getDisplayStatus(_currentVisit!.status);
//             }
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading visits: $e');
//     }
//   }
//
//   String _getDisplayStatus(String status) {
//     switch (status) {
//       case 'completed':
//       case 'successfully_met':
//         return 'Successfully Met';
//       case 'client_not_available':
//         return 'Client Not Available';
//       case 'postponed':
//         return 'Postponed';
//       case 'cancelled':
//         return 'Cancelled';
//       case 'in_progress':
//         return 'In Progress';
//       default:
//         return 'Successfully Met';
//     }
//   }
//
//   String _convertStatusForSaving(String displayStatus) {
//     switch (displayStatus) {
//       case 'Successfully Met':
//         return 'completed';
//       case 'Client Not Available':
//         return 'client_not_available';
//       case 'Postponed':
//         return 'postponed';
//       case 'Cancelled':
//         return 'cancelled';
//       case 'In Progress':
//         return 'in_progress';
//       default:
//         return 'completed';
//     }
//   }
//
//   Future<void> _saveVisits() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final visitsJson = _visits.map((visit) => visit.toJson()).toList();
//       await prefs.setString('visits', jsonEncode(visitsJson));
//       debugPrint('Visits saved successfully');
//     } catch (e) {
//       debugPrint('Error saving visits: $e');
//     }
//   }
//
//   // NEW: Auto-save function to persist data immediately
//   Future<void> _autoSaveCurrentVisit() async {
//     if (_currentVisit == null) return;
//
//     final updatedVisit = _currentVisit!.copyWith(
//       notes: _notesController.text,
//       nextAction: _nextActionController.text,
//       hasReminder: _setReminder,
//       attachedDocuments: _attachedDocuments,
//     );
//
//     final visitIndex = _visits.indexWhere(
//           (visit) =>
//       visit.clientName == _currentVisit!.clientName &&
//           visit.visitTime == _currentVisit!.visitTime &&
//           visit.location == _currentVisit!.location,
//     );
//
//     if (visitIndex != -1) {
//       setState(() {
//         _visits[visitIndex] = updatedVisit;
//         _currentVisit = updatedVisit;
//       });
//
//       await _saveVisits();
//       debugPrint('Auto-saved visit data for ${updatedVisit.clientName}');
//     }
//   }
//
//   Future<void> _updateVisitStatus(String newStatus) async {
//     if (_currentVisit == null) return;
//
//     final updatedVisit = _currentVisit!.copyWith(
//       status: _convertStatusForSaving(newStatus),
//       notes: _notesController.text,
//       nextAction: _nextActionController.text,
//       hasReminder: _setReminder,
//       attachedDocuments: _attachedDocuments,
//     );
//
//     final visitIndex = _visits.indexWhere(
//           (visit) =>
//       visit.clientName == _currentVisit!.clientName &&
//           visit.visitTime == _currentVisit!.visitTime &&
//           visit.location == _currentVisit!.location,
//     );
//
//     if (visitIndex != -1) {
//       setState(() {
//         _visits[visitIndex] = updatedVisit;
//         _currentVisit = updatedVisit;
//       });
//
//       await _saveVisits();
//       debugPrint('Updated visit: $newStatus for ${updatedVisit.clientName}');
//     }
//   }
//
//   // NEW: Dynamic document picker from gallery/files
//   Future<void> _attachDocument() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
//         allowMultiple: false,
//       );
//
//       if (result != null && result.files.isNotEmpty) {
//         PlatformFile file = result.files.first;
//         String fileName = file.name;
//
//         setState(() {
//           _attachedDocuments.add(fileName);
//         });
//
//         // Auto-save after attaching document
//         await _autoSaveCurrentVisit();
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Document "$fileName" attached successfully'),
//               backgroundColor: primaryBlue,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking file: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Error attaching document'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _markVisitAsComplete() async {
//     if (_currentVisit == null) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       String statusToSave = _selectedVisitStatus.isEmpty
//           ? 'Successfully Met'
//           : _selectedVisitStatus;
//
//       await _updateVisitStatus(statusToSave);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Visit for ${_currentVisit!.clientName} marked as complete!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error completing visit: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _showVisitSelectionDialog() {
//     if (_visits.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No visits scheduled'),
//           backgroundColor: primaryBlue,
//         ),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select Visit'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: _visits.length,
//               itemBuilder: (context, index) {
//                 final visit = _visits[index];
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: primaryBlue.withOpacity(0.1),
//                     child: Text(
//                       visit.clientName[0].toUpperCase(),
//                       style: const TextStyle(
//                         color: primaryBlue,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     visit.clientName,
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(visit.purpose),
//                       Text(
//                         'Status: ${_getDisplayStatus(visit.status)}',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     setState(() {
//                       _currentVisit = visit;
//                       _visitNotes = visit.notes;
//                       _notesController.text = _visitNotes;
//                       _nextAction = visit.nextAction;
//                       _nextActionController.text = _nextAction;
//                       _setReminder = visit.hasReminder;
//                       _attachedDocuments = List<String>.from(visit.attachedDocuments);
//                       _selectedVisitStatus = _getDisplayStatus(visit.status);
//                     });
//                     Navigator.of(context).pop();
//                     debugPrint('Switched to visit: ${visit.clientName}');
//                   },
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
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
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Client Visit Summary',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           if (_visits.length > 1)
//             IconButton(
//               icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 24),
//               onPressed: _showVisitSelectionDialog,
//             ),
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined,
//                 color: Colors.white, size: 24),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Notifications'),
//                   backgroundColor: primaryBlue,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _currentVisit == null
//           ? const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.event_note, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               'No visits found',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Schedule a visit from the home screen',
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       )
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Client Info Section
//             Row(
//               children: [
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: primaryBlue.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       _currentVisit!.clientName[0].toUpperCase(),
//                       style: const TextStyle(
//                         color: primaryBlue,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _currentVisit!.clientName,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _currentVisit!.purpose,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 32),
//
//             // Visit Status Section
//             const Text(
//               'Visit Status',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               padding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               decoration: BoxDecoration(
//                 color: cardBackground,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedVisitStatus.isEmpty
//                       ? null
//                       : _selectedVisitStatus,
//                   hint: const Text(
//                     'Select visit status',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   isExpanded: true,
//                   items: _statusOptions.map((String status) {
//                     return DropdownMenuItem<String>(
//                       value: status,
//                       child: Text(
//                         status,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedVisitStatus = newValue ?? '';
//                     });
//                   },
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 32),
//
//             // Visit Notes Section (with auto-save)
//             const Text(
//               'Visit Notes',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: cardBackground,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: TextField(
//                 controller: _notesController,
//                 maxLines: 4,
//                 decoration: const InputDecoration(
//                   hintText: 'Add notes about the visit...',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(16),
//                 ),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.black87,
//                   height: 1.5,
//                 ),
//                 onChanged: (value) {
//                   _visitNotes = value;
//                   // Auto-save after 1 second of no typing
//                   Future.delayed(const Duration(seconds: 1), () {
//                     _autoSaveCurrentVisit();
//                   });
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 32),
//
//             // Attach Documents Section (DYNAMIC)
//             Row(
//               children: [
//                 const Icon(
//                   Icons.attach_file,
//                   color: Colors.black87,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Attach Documents',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const Spacer(),
//                 ElevatedButton.icon(
//                   onPressed: _attachDocument,
//                   icon: const Icon(Icons.add, size: 18),
//                   label: const Text('Add'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryBlue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             if (_attachedDocuments.isNotEmpty) ...[
//               const SizedBox(height: 12),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: cardBackground,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Attached Documents:',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ..._attachedDocuments.map((doc) => Padding(
//                       padding: const EdgeInsets.only(bottom: 4),
//                       child: Row(
//                         children: [
//                           Icon(
//                             _getFileIcon(doc),
//                             size: 16,
//                             color: primaryBlue,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               doc,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete_outline,
//                                 size: 18, color: Colors.red),
//                             onPressed: () async {
//                               setState(() {
//                                 _attachedDocuments.remove(doc);
//                               });
//                               await _autoSaveCurrentVisit();
//                             },
//                           ),
//                         ],
//                       ),
//                     )),
//                   ],
//                 ),
//               ),
//             ],
//
//             const SizedBox(height: 32),
//
//             // Next Action Section (with auto-save)
//             const Text(
//               'Next Action',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: cardBackground,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: TextField(
//                 controller: _nextActionController,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter next action required...',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(16),
//                 ),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.black87,
//                 ),
//                 onChanged: (value) {
//                   _nextAction = value;
//                   // Auto-save after 1 second of no typing
//                   Future.delayed(const Duration(seconds: 1), () {
//                     _autoSaveCurrentVisit();
//                   });
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 32),
//
//             // Set Reminder Section (with auto-save)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Set Reminder?',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Switch(
//                   value: _setReminder,
//                   onChanged: (value) async {
//                     setState(() {
//                       _setReminder = value;
//                     });
//
//                     // Auto-save immediately
//                     await _autoSaveCurrentVisit();
//
//                     if (value && mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                               'Reminder set for ${_currentVisit!.clientName}'),
//                           backgroundColor: primaryBlue,
//                         ),
//                       );
//                     }
//                   },
//                   activeColor: primaryBlue,
//                   activeTrackColor: primaryBlue.withOpacity(0.3),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 50),
//
//             // Mark Visit as Complete Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _markVisitAsComplete,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryBlue,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//                     : const Text(
//                   'Mark Visit as Complete',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         height: 80,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildBottomNavItem(
//               icon: Icons.home_outlined,
//               label: 'Home',
//               isActive: false,
//             ),
//             _buildBottomNavItem(
//               icon: Icons.task_alt,
//               label: 'Task',
//               isActive: true,
//             ),
//             _buildBottomNavItem(
//               icon: Icons.calendar_today_outlined,
//               label: 'Calendar',
//               isActive: false,
//             ),
//             _buildBottomNavItem(
//               icon: Icons.person_outline,
//               label: 'Profile',
//               isActive: false,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   IconData _getFileIcon(String fileName) {
//     if (fileName.toLowerCase().endsWith('.pdf')) {
//       return Icons.picture_as_pdf;
//     } else if (fileName.toLowerCase().endsWith('.jpg') ||
//         fileName.toLowerCase().endsWith('.jpeg') ||
//         fileName.toLowerCase().endsWith('.png')) {
//       return Icons.image;
//     } else if (fileName.toLowerCase().endsWith('.doc') ||
//         fileName.toLowerCase().endsWith('.docx')) {
//       return Icons.description;
//     }
//     return Icons.attach_file;
//   }
//
//   Widget _buildBottomNavItem({
//     required IconData icon,
//     required String label,
//     required bool isActive,
//   }) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
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
//             fontSize: 12,
//             color: isActive ? primaryBlue : Colors.grey,
//             fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

// Visit model class (enhanced with additional fields)
class Visit {
  final String clientName;
  final String purpose;
  final String location;
  final String phoneNumber;
  final DateTime visitTime;
  final String status;
  final String notes;
  final String nextAction;
  final bool hasReminder;
  final List<String> attachedDocuments;

  Visit({
    required this.clientName,
    required this.purpose,
    required this.location,
    required this.phoneNumber,
    required this.visitTime,
    this.status = 'pending',
    this.notes = '',
    this.nextAction = '',
    this.hasReminder = false,
    this.attachedDocuments = const [],
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
      'nextAction': nextAction,
      'hasReminder': hasReminder,
      'attachedDocuments': attachedDocuments,
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
      nextAction: json['nextAction'] ?? '',
      hasReminder: json['hasReminder'] ?? false,
      attachedDocuments: json['attachedDocuments'] != null
          ? List<String>.from(json['attachedDocuments'])
          : [],
    );
  }

  Visit copyWith({
    String? status,
    String? notes,
    String? nextAction,
    bool? hasReminder,
    List<String>? attachedDocuments,
  }) {
    return Visit(
      clientName: clientName,
      purpose: purpose,
      location: location,
      phoneNumber: phoneNumber,
      visitTime: visitTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      nextAction: nextAction ?? this.nextAction,
      hasReminder: hasReminder ?? this.hasReminder,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
    );
  }
}

class ClientSummaryScreen extends StatefulWidget {
  final Visit? selectedVisit;

  const ClientSummaryScreen({super.key, this.selectedVisit});

  @override
  State<ClientSummaryScreen> createState() => _ClientSummaryScreenState();
}

class _ClientSummaryScreenState extends State<ClientSummaryScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color cardBackground = Colors.white;

  List<Visit> _visits = [];
  Visit? _currentVisit;
  String _selectedVisitStatus = '';
  String _visitNotes = '';
  String _nextAction = '';
  bool _setReminder = false;
  List<String> _attachedDocuments = [];
  bool _isLoading = false;
  String _userName = 'User';
  String _userId = ''; // ADD USER ID

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nextActionController = TextEditingController();

  final List<String> _statusOptions = [
    'Successfully Met',
    'Client Not Available',
    'Postponed',
    'Cancelled',
    'In Progress'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeVisit();
  }

  Future<void> _initializeVisit() async {
    if (widget.selectedVisit != null) {
      setState(() {
        _currentVisit = widget.selectedVisit;
        _visitNotes = _currentVisit!.notes;
        _notesController.text = _visitNotes;
        _nextAction = _currentVisit!.nextAction;
        _nextActionController.text = _nextAction;
        _setReminder = _currentVisit!.hasReminder;
        _attachedDocuments = List<String>.from(_currentVisit!.attachedDocuments);

        if (_currentVisit!.status != 'pending') {
          _selectedVisitStatus = _getDisplayStatus(_currentVisit!.status);
        }
      });
      debugPrint('Initialized with selected visit: ${_currentVisit!.clientName}');
    }

    await _loadVisits();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  // FIXED: Load user data AND user ID
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final userData = jsonDecode(userString);
        setState(() {
          _userName = userData['name'] ?? 'User';
          _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
        });
        debugPrint('✅ User loaded in ClientSummary: $_userId');
      } else {
        setState(() {
          _userId = 'default';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _userId = 'default';
      });
    }
  }

  // FIXED: Use user-specific key
  Future<void> _loadVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Wait for userId to be loaded
      if (_userId.isEmpty) {
        await _loadUserData();
      }

      final String visitsKey = 'visits_$_userId'; // USER-SPECIFIC KEY
      final visitsString = prefs.getString(visitsKey);

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        setState(() {
          _visits = visitsJson.map((json) => Visit.fromJson(json)).toList();

          if (widget.selectedVisit != null) {
            _currentVisit = widget.selectedVisit;
            debugPrint('Using selected visit: ${_currentVisit!.clientName}');
          } else if (_visits.isNotEmpty) {
            _currentVisit = _visits.firstWhere(
                  (visit) => visit.status == 'pending',
              orElse: () => _visits.first,
            );
            debugPrint('Using fallback visit: ${_currentVisit!.clientName}');
          }

          if (_currentVisit != null) {
            _visitNotes = _currentVisit!.notes;
            _notesController.text = _visitNotes;
            _nextAction = _currentVisit!.nextAction;
            _nextActionController.text = _nextAction;
            _setReminder = _currentVisit!.hasReminder;
            _attachedDocuments = List<String>.from(_currentVisit!.attachedDocuments);

            if (_currentVisit!.status != 'pending') {
              _selectedVisitStatus = _getDisplayStatus(_currentVisit!.status);
            }
          }
        });
        debugPrint('✅ Loaded ${_visits.length} visits from user-specific key');
      }
    } catch (e) {
      debugPrint('Error loading visits: $e');
    }
  }

  String _getDisplayStatus(String status) {
    switch (status) {
      case 'completed':
      case 'successfully_met':
        return 'Successfully Met';
      case 'client_not_available':
        return 'Client Not Available';
      case 'postponed':
        return 'Postponed';
      case 'cancelled':
        return 'Cancelled';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Successfully Met';
    }
  }

  String _convertStatusForSaving(String displayStatus) {
    switch (displayStatus) {
      case 'Successfully Met':
        return 'completed';
      case 'Client Not Available':
        return 'client_not_available';
      case 'Postponed':
        return 'postponed';
      case 'Cancelled':
        return 'cancelled';
      case 'In Progress':
        return 'in_progress';
      default:
        return 'completed';
    }
  }

  // FIXED: Use user-specific key
  Future<void> _saveVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String visitsKey = 'visits_$_userId'; // USER-SPECIFIC KEY
      final visitsJson = _visits.map((visit) => visit.toJson()).toList();
      await prefs.setString(visitsKey, jsonEncode(visitsJson));
      debugPrint('✅ Visits saved successfully for user: $_userId');
    } catch (e) {
      debugPrint('Error saving visits: $e');
    }
  }

  Future<void> _autoSaveCurrentVisit() async {
    if (_currentVisit == null) return;

    final updatedVisit = _currentVisit!.copyWith(
      notes: _notesController.text,
      nextAction: _nextActionController.text,
      hasReminder: _setReminder,
      attachedDocuments: _attachedDocuments,
    );

    final visitIndex = _visits.indexWhere(
          (visit) =>
      visit.clientName == _currentVisit!.clientName &&
          visit.visitTime == _currentVisit!.visitTime &&
          visit.location == _currentVisit!.location,
    );

    if (visitIndex != -1) {
      setState(() {
        _visits[visitIndex] = updatedVisit;
        _currentVisit = updatedVisit;
      });

      await _saveVisits();
      debugPrint('Auto-saved visit data for ${updatedVisit.clientName}');
    }
  }

  Future<void> _updateVisitStatus(String newStatus) async {
    if (_currentVisit == null) return;

    final updatedVisit = _currentVisit!.copyWith(
      status: _convertStatusForSaving(newStatus),
      notes: _notesController.text,
      nextAction: _nextActionController.text,
      hasReminder: _setReminder,
      attachedDocuments: _attachedDocuments,
    );

    final visitIndex = _visits.indexWhere(
          (visit) =>
      visit.clientName == _currentVisit!.clientName &&
          visit.visitTime == _currentVisit!.visitTime &&
          visit.location == _currentVisit!.location,
    );

    if (visitIndex != -1) {
      setState(() {
        _visits[visitIndex] = updatedVisit;
        _currentVisit = updatedVisit;
      });

      await _saveVisits();
      debugPrint('Updated visit: $newStatus for ${updatedVisit.clientName}');
    }
  }

  Future<void> _attachDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        String fileName = file.name;

        setState(() {
          _attachedDocuments.add(fileName);
        });

        await _autoSaveCurrentVisit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document "$fileName" attached successfully'),
              backgroundColor: primaryBlue,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error attaching document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markVisitAsComplete() async {
    if (_currentVisit == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String statusToSave = _selectedVisitStatus.isEmpty
          ? 'Successfully Met'
          : _selectedVisitStatus;

      await _updateVisitStatus(statusToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Visit for ${_currentVisit!.clientName} marked as complete!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing visit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showVisitSelectionDialog() {
    if (_visits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No visits scheduled'),
          backgroundColor: primaryBlue,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Visit'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _visits.length,
              itemBuilder: (context, index) {
                final visit = _visits[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    child: Text(
                      visit.clientName[0].toUpperCase(),
                      style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    visit.clientName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visit.purpose),
                      Text(
                        'Status: ${_getDisplayStatus(visit.status)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _currentVisit = visit;
                      _visitNotes = visit.notes;
                      _notesController.text = _visitNotes;
                      _nextAction = visit.nextAction;
                      _nextActionController.text = _nextAction;
                      _setReminder = visit.hasReminder;
                      _attachedDocuments = List<String>.from(visit.attachedDocuments);
                      _selectedVisitStatus = _getDisplayStatus(visit.status);
                    });
                    Navigator.of(context).pop();
                    debugPrint('Switched to visit: ${visit.clientName}');
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Client Visit Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_visits.length > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 24),
              onPressed: _showVisitSelectionDialog,
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications'),
                  backgroundColor: primaryBlue,
                ),
              );
            },
          ),
        ],
      ),
      body: _currentVisit == null
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No visits found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Schedule a visit from the home screen',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _currentVisit!.clientName[0].toUpperCase(),
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentVisit!.clientName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentVisit!.purpose,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Visit Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVisitStatus.isEmpty ? null : _selectedVisitStatus,
                  hint: const Text(
                    'Select visit status',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  isExpanded: true,
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedVisitStatus = newValue ?? '';
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Visit Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add notes about the visit...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                onChanged: (value) {
                  _visitNotes = value;
                  Future.delayed(const Duration(seconds: 1), () {
                    _autoSaveCurrentVisit();
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.attach_file, color: Colors.black87, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Attach Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _attachDocument,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            if (_attachedDocuments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attached Documents:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._attachedDocuments.map((doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(_getFileIcon(doc), size: 16, color: primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              doc,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            onPressed: () async {
                              setState(() {
                                _attachedDocuments.remove(doc);
                              });
                              await _autoSaveCurrentVisit();
                            },
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            const Text(
              'Next Action',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _nextActionController,
                decoration: const InputDecoration(
                  hintText: 'Enter next action required...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                onChanged: (value) {
                  _nextAction = value;
                  Future.delayed(const Duration(seconds: 1), () {
                    _autoSaveCurrentVisit();
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Set Reminder?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                  value: _setReminder,
                  onChanged: (value) async {
                    setState(() {
                      _setReminder = value;
                    });
                    await _autoSaveCurrentVisit();
                    if (value && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reminder set for ${_currentVisit!.clientName}'),
                          backgroundColor: primaryBlue,
                        ),
                      );
                    }
                  },
                  activeColor: primaryBlue,
                  activeTrackColor: primaryBlue.withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _markVisitAsComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Mark Visit as Complete',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              isActive: false,
            ),
            _buildBottomNavItem(
              icon: Icons.task_alt,
              label: 'Task',
              isActive: true,
            ),
            _buildBottomNavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Calendar',
              isActive: false,
            ),
            _buildBottomNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png')) {
      return Icons.image;
    } else if (fileName.toLowerCase().endsWith('.doc') ||
        fileName.toLowerCase().endsWith('.docx')) {
      return Icons.description;
    }
    return Icons.attach_file;
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
            fontSize: 12,
            color: isActive ? primaryBlue : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}