//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// class ApplyLeaveScreen extends StatefulWidget {
//   const ApplyLeaveScreen({super.key});
//
//   @override
//   State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
// }
//
// class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
//   static const Color primaryBlue = Color(0xFF0F3A68);
//
//   String selectedLeaveType = 'Vacation';
//   DateTime fromDate = DateTime.now().add(const Duration(days: 1));
//   DateTime toDate = DateTime.now().add(const Duration(days: 5));
//   final TextEditingController notesController = TextEditingController();
//   String? attachedFileName;
//   File? attachedFile;
//   final ImagePicker _imagePicker = ImagePicker();
//
//   final List<String> leaveTypes = [
//     'Vacation',
//     'Sick Leave',
//     'Personal Leave',
//     'Emergency Leave',
//     'Maternity/Paternity',
//     'Other'
//   ];
//
//   @override
//   void dispose() {
//     notesController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context, bool isFromDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isFromDate ? fromDate : toDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
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
//     if (picked != null) {
//       setState(() {
//         if (isFromDate) {
//           fromDate = picked;
//           // Ensure toDate is after fromDate
//           if (toDate.isBefore(fromDate)) {
//             toDate = fromDate.add(const Duration(days: 1));
//           }
//         } else {
//           // Ensure toDate is not before fromDate
//           if (picked.isBefore(fromDate)) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('End date cannot be before start date'),
//                 backgroundColor: Colors.orange,
//                 duration: Duration(seconds: 2),
//               ),
//             );
//             return;
//           }
//           toDate = picked;
//         }
//       });
//     }
//   }
//
//   void _showAttachmentOptions() {
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
//                 'Choose Attachment',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt, color: primaryBlue),
//                 title: const Text('Take Photo'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromCamera();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library, color: primaryBlue),
//                 title: const Text('Choose from Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromGallery();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.insert_drive_file, color: primaryBlue),
//                 title: const Text('Choose Document (PDF)'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickDocument();
//                 },
//               ),
//               if (attachedFile != null)
//                 ListTile(
//                   leading: const Icon(Icons.delete, color: Colors.red),
//                   title: const Text(
//                     'Remove Attachment',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _removeAttachment();
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _pickImageFromCamera() async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 1920,
//         maxHeight: 1920,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() {
//           attachedFile = File(image.path);
//           attachedFileName = image.name;
//         });
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Photo captured successfully'),
//               backgroundColor: primaryBlue,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking image from camera: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to capture photo'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _pickImageFromGallery() async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1920,
//         maxHeight: 1920,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() {
//           attachedFile = File(image.path);
//           attachedFileName = image.name;
//         });
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Image attached successfully'),
//               backgroundColor: primaryBlue,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking image from gallery: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to attach image'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _pickDocument() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx'],
//         allowMultiple: false,
//       );
//
//       if (result != null && result.files.single.path != null) {
//         setState(() {
//           attachedFile = File(result.files.single.path!);
//           attachedFileName = result.files.single.name;
//         });
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Document attached successfully'),
//               backgroundColor: primaryBlue,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking document: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to attach document'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }
//
//   void _removeAttachment() {
//     setState(() {
//       attachedFile = null;
//       attachedFileName = null;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Attachment removed'),
//         backgroundColor: primaryBlue,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _submitLeaveRequest() {
//     // Validate and submit
//     if (fromDate.isAfter(toDate)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select valid dates'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }
//
//     // Here you can add logic to upload the file to your server
//     // For now, we'll just show a success message
//     debugPrint('Leave Request Details:');
//     debugPrint('Leave Type: $selectedLeaveType');
//     debugPrint('From Date: $fromDate');
//     debugPrint('To Date: $toDate');
//     debugPrint('Notes: ${notesController.text}');
//     debugPrint('Attached File: ${attachedFile?.path ?? "None"}');
//
//     // Show success message
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Row(
//             children: [
//               Icon(Icons.check_circle, color: Color(0xFF00897B), size: 28),
//               SizedBox(width: 12),
//               Text(
//                 'Success',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1A1A1A),
//                 ),
//               ),
//             ],
//           ),
//           content: const Text(
//             'Your leave request has been submitted successfully. You will be notified once it is approved.',
//             style: TextStyle(
//               color: Color(0xFF666666),
//             ),
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context); // Close dialog
//                 Navigator.pop(context); // Go back to previous screen
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryBlue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 minimumSize: const Size(double.infinity, 45),
//               ),
//               child: const Text(
//                 'OK',
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
//                     'Apply for Leave',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 24),
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
//                     // Leave Type
//                     const Text(
//                       'Leave type',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1A1A1A),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: selectedLeaveType,
//                           isExpanded: true,
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A1A1A)),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Color(0xFF1A1A1A),
//                             fontWeight: FontWeight.w500,
//                           ),
//                           items: leaveTypes.map((String type) {
//                             return DropdownMenuItem<String>(
//                               value: type,
//                               child: Text(type),
//                             );
//                           }).toList(),
//                           onChanged: (String? newValue) {
//                             if (newValue != null) {
//                               setState(() {
//                                 selectedLeaveType = newValue;
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Date Section
//                     const Text(
//                       'Date',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1A1A1A),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'From',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF1A1A1A),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               GestureDetector(
//                                 onTap: () => _selectDate(context, true),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.grey.shade300),
//                                   ),
//                                   child: Text(
//                                     DateFormat('dd MMM yyyy').format(fromDate),
//                                     style: const TextStyle(
//                                       fontSize: 15,
//                                       color: Color(0xFF1A1A1A),
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'To',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF1A1A1A),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               GestureDetector(
//                                 onTap: () => _selectDate(context, false),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.grey.shade300),
//                                   ),
//                                   child: Text(
//                                     DateFormat('dd MMM yyyy').format(toDate),
//                                     style: const TextStyle(
//                                       fontSize: 15,
//                                       color: Color(0xFF1A1A1A),
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Notes
//                     const Text(
//                       'Notes',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1A1A1A),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: TextField(
//                         controller: notesController,
//                         maxLines: 6,
//                         decoration: const InputDecoration(
//                           hintText: 'Optional',
//                           hintStyle: TextStyle(
//                             color: Color(0xFF999999),
//                             fontSize: 16,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(16),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Attach Document
//                     GestureDetector(
//                       onTap: _showAttachmentOptions,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 attachedFileName ?? 'Attach Image/ Document',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: attachedFileName != null
//                                       ? const Color(0xFF1A1A1A)
//                                       : const Color(0xFF666666),
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Icon(
//                               attachedFileName != null ? Icons.check_circle : Icons.chevron_right,
//                               color: attachedFileName != null
//                                   ? const Color(0xFF00897B)
//                                   : const Color(0xFF666666),
//                               size: 24,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     // Submit Button
//                     GestureDetector(
//                       onTap: _submitLeaveRequest,
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
//                           'Submit Request',
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);

  String selectedLeaveType = 'Vacation';
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController notesController = TextEditingController();
  String? attachedFileName;
  File? attachedFile;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> leaveTypes = [
    'Vacation',
    'Sick Leave',
    'Personal Leave',
    'Emergency Leave',
    'Maternity/Paternity',
    'Other'
  ];

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (fromDate ?? DateTime.now().add(const Duration(days: 1)))
          : (toDate ?? DateTime.now().add(const Duration(days: 2))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          // If toDate is before new fromDate, reset toDate
          if (toDate != null && toDate!.isBefore(fromDate!)) {
            toDate = null;
          }
        } else {
          // Ensure toDate is not before fromDate
          if (fromDate != null && picked.isBefore(fromDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End date cannot be before start date'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          toDate = picked;
        }
      });
    }
  }

  void _showAttachmentOptions() {
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
                'Choose Attachment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: primaryBlue),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: primaryBlue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file, color: primaryBlue),
                title: const Text('Choose Document (PDF)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
              if (attachedFile != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Attachment',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeAttachment();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          attachedFile = File(image.path);
          attachedFileName = image.name;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured successfully'),
              backgroundColor: primaryBlue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to capture photo'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          attachedFile = File(image.path);
          attachedFileName = image.name;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image attached successfully'),
              backgroundColor: primaryBlue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to attach image'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          attachedFile = File(result.files.single.path!);
          attachedFileName = result.files.single.name;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document attached successfully'),
              backgroundColor: primaryBlue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to attach document'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _removeAttachment() {
    setState(() {
      attachedFile = null;
      attachedFileName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attachment removed'),
        backgroundColor: primaryBlue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitLeaveRequest() {
    // Validate from date
    if (fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate to date
    if (toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select end date'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate end date is after start date
    if (fromDate!.isAfter(toDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after or equal to start date'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Calculate number of days
    final days = toDate!.difference(fromDate!).inDays + 1;

    // Log request details
    debugPrint('Leave Request Details:');
    debugPrint('Leave Type: $selectedLeaveType');
    debugPrint('From Date: ${DateFormat('dd MMM yyyy').format(fromDate!)}');
    debugPrint('To Date: ${DateFormat('dd MMM yyyy').format(toDate!)}');
    debugPrint('Number of Days: $days');
    debugPrint('Notes: ${notesController.text}');
    debugPrint('Attached File: ${attachedFile?.path ?? "None"}');

    // All validations passed - Show success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF00897B), size: 28),
              SizedBox(width: 12),
              Text(
                'Success',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          content: Text(
            'Your $selectedLeaveType leave request for $days ${days == 1 ? 'day' : 'days'} has been submitted successfully. You will be notified once it is approved.',
            style: const TextStyle(
              color: Color(0xFF666666),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                'OK',
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
                    'Apply for Leave',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
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
                    // Leave Type
                    const Text(
                      'Leave type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedLeaveType,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A1A1A)),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                          items: leaveTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedLeaveType = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Date Section
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: fromDate == null ? Colors.red.shade300 : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    fromDate != null
                                        ? DateFormat('dd MMM yyyy').format(fromDate!)
                                        : 'Select',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: fromDate == null ? Colors.red.shade300 : const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'To',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: toDate == null ? Colors.red.shade300 : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    toDate != null
                                        ? DateFormat('dd MMM yyyy').format(toDate!)
                                        : 'Select',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: toDate == null ? Colors.red.shade300 : const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Notes
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: notesController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Optional',
                          hintStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Attach Document
                    GestureDetector(
                      onTap: _showAttachmentOptions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                attachedFileName ?? 'Attach Image/ Document (Optional)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: attachedFileName != null
                                      ? const Color(0xFF1A1A1A)
                                      : const Color(0xFF666666),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              attachedFileName != null ? Icons.check_circle : Icons.chevron_right,
                              color: attachedFileName != null
                                  ? const Color(0xFF00897B)
                                  : const Color(0xFF666666),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    GestureDetector(
                      onTap: _submitLeaveRequest,
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
                          'Submit Request',
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