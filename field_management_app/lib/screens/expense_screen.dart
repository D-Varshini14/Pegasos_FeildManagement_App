// // import 'package:flutter/material.dart';
// //
// // class ExpenseScreen extends StatefulWidget {
// //   const ExpenseScreen({super.key});
// //
// //   @override
// //   State<ExpenseScreen> createState() => _ExpenseScreenState();
// // }
// //
// // class _ExpenseScreenState extends State<ExpenseScreen> {
// //   // Colors to match the UI
// //   static const Color primaryBlue = Color(0xFF0F3A68);
// //   static const Color lightGray = Color(0xFFF1F5F9);
// //   static const Color cardBackground = Colors.white;
// //
// //   // Controllers for dynamic input
// //   final TextEditingController _totalAmountController = TextEditingController();
// //   final TextEditingController _amountInProgressController = TextEditingController();
// //   final TextEditingController _amountClaimedController = TextEditingController();
// //   final TextEditingController _amountPendingController = TextEditingController();
// //
// //   // List to store attached files
// //   List<Map<String, String>> _attachedFiles = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize with default values or load from your data source
// //     _loadInitialData();
// //   }
// //
// //   void _loadInitialData() {
// //     // Initialize with empty values - user will enter their own amounts
// //     _totalAmountController.text = '';
// //     _amountInProgressController.text = '';
// //     _amountClaimedController.text = '';
// //     _amountPendingController.text = '';
// //
// //     // Start with empty attachments list
// //     _attachedFiles = [];
// //   }
// //
// //   @override
// //   void dispose() {
// //     _totalAmountController.dispose();
// //     _amountInProgressController.dispose();
// //     _amountClaimedController.dispose();
// //     _amountPendingController.dispose();
// //     super.dispose();
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
// //           'Expense',
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w600,
// //             color: Colors.white,
// //           ),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
// //             onPressed: () {
// //               // Add notification functionality
// //             },
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Total Amount Request
// //             _buildAmountField(
// //               label: 'Total Amount Request',
// //               controller: _totalAmountController,
// //             ),
// //
// //             const SizedBox(height: 24),
// //
// //             // Amount Request in progress
// //             _buildAmountField(
// //               label: 'Amount Request in progress',
// //               controller: _amountInProgressController,
// //             ),
// //
// //             const SizedBox(height: 24),
// //
// //             // Amount Claimed
// //             _buildAmountField(
// //               label: 'Amount Claimed',
// //               controller: _amountClaimedController,
// //             ),
// //
// //             const SizedBox(height: 24),
// //
// //             // Amount Pending
// //             _buildAmountField(
// //               label: 'Amount Pending',
// //               controller: _amountPendingController,
// //             ),
// //
// //             const SizedBox(height: 32),
// //
// //             // Attached Files Section
// //             _buildAttachedFilesSection(),
// //
// //             const SizedBox(height: 40),
// //
// //             // Submit Button
// //             SizedBox(
// //               width: double.infinity,
// //               height: 56,
// //               child: ElevatedButton(
// //                 onPressed: _submitExpense,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: primaryBlue,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   elevation: 0,
// //                 ),
// //                 child: const Text(
// //                   'Submit Expense',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       bottomNavigationBar: _buildBottomNavigationBar(),
// //     );
// //   }
// //
// //   Widget _buildAmountField({
// //     required String label,
// //     required TextEditingController controller,
// //     bool enabled = true,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w600,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         Container(
// //           decoration: BoxDecoration(
// //             color: cardBackground,
// //             borderRadius: BorderRadius.circular(8),
// //             border: Border.all(color: Colors.grey.shade300),
// //           ),
// //           child: Row(
// //             children: [
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey.shade100,
// //                   borderRadius: const BorderRadius.only(
// //                     topLeft: Radius.circular(8),
// //                     bottomLeft: Radius.circular(8),
// //                   ),
// //                 ),
// //                 child: const Text(
// //                   '₹',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.black87,
// //                   ),
// //                 ),
// //               ),
// //               Expanded(
// //                 child: TextField(
// //                   controller: controller,
// //                   enabled: enabled,
// //                   keyboardType: TextInputType.number,
// //                   onChanged: (value) {
// //                     // Optional: Add any validation or formatting here
// //                   },
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.black87,
// //                   ),
// //                   decoration: InputDecoration(
// //                     border: InputBorder.none,
// //                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //                     hintText: 'Enter amount',
// //                     hintStyle: TextStyle(
// //                       color: Colors.grey[500],
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.normal,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildAttachedFilesSection() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             const Text(
// //               'Attachments',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w600,
// //                 color: Colors.black87,
// //               ),
// //             ),
// //             TextButton.icon(
// //               onPressed: _pickFile,
// //               icon: const Icon(Icons.add, size: 16),
// //               label: const Text('Add'),
// //               style: TextButton.styleFrom(
// //                 foregroundColor: primaryBlue,
// //               ),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 12),
// //         ..._attachedFiles.asMap().entries.map((entry) {
// //           int index = entry.key;
// //           Map<String, String> file = entry.value;
// //           return Padding(
// //             padding: const EdgeInsets.only(bottom: 8),
// //             child: _buildAttachmentItem(index + 1, 'Attached'),
// //           );
// //         }).toList(),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildAttachmentItem(int index, String displayText) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: cardBackground,
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border.all(color: Colors.grey.shade200),
// //       ),
// //       child: Row(
// //         children: [
// //           Text(
// //             '$index.',
// //             style: const TextStyle(
// //               fontSize: 14,
// //               fontWeight: FontWeight.w500,
// //               color: Colors.black87,
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //             decoration: BoxDecoration(
// //               color: Colors.red,
// //               borderRadius: BorderRadius.circular(4),
// //             ),
// //             child: const Text(
// //               'PDF',
// //               style: TextStyle(
// //                 fontSize: 10,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Text(
// //               displayText,
// //               style: const TextStyle(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w500,
// //                 color: Colors.black87,
// //               ),
// //             ),
// //           ),
// //           IconButton(
// //             onPressed: () => _removeFile(index - 1),
// //             icon: const Icon(Icons.close, size: 16, color: Colors.grey),
// //             constraints: const BoxConstraints(),
// //             padding: EdgeInsets.zero,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBottomNavigationBar() {
// //     return Container(
// //       height: 80,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 8,
// //             offset: const Offset(0, -2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceAround,
// //         children: [
// //           _buildNavItem(Icons.home_outlined, 'Home', false),
// //           _buildNavItem(Icons.assignment_outlined, 'Task', true),
// //           _buildNavItem(Icons.calendar_today_outlined, 'Calendar', false),
// //           _buildNavItem(Icons.person_outline, 'Profile', false),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildNavItem(IconData icon, String label, bool isSelected) {
// //     return Column(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Icon(
// //           icon,
// //           color: isSelected ? primaryBlue : Colors.grey,
// //           size: 24,
// //         ),
// //         const SizedBox(height: 4),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 12,
// //             color: isSelected ? primaryBlue : Colors.grey,
// //             fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   void _updateCalculations() {
// //     // Remove auto-calculation since user should enter all amounts manually
// //     // This method can be used for validation or other purposes if needed
// //   }
// //
// //   Future<void> _pickFile() async {
// //     // Simulate file picker (replace with actual implementation)
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Add Attachment'),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Text('Select file type:'),
// //             const SizedBox(height: 16),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _attachedFiles.add({
// //                     'name': 'Document_${_attachedFiles.length + 1}.pdf',
// //                     'size': '1.5 KB',
// //                   });
// //                 });
// //                 Navigator.pop(context);
// //               },
// //               child: const Text('PDF Document'),
// //             ),
// //             const SizedBox(height: 8),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _attachedFiles.add({
// //                     'name': 'Image_${_attachedFiles.length + 1}.jpg',
// //                     'size': '2.3 KB',
// //                   });
// //                 });
// //                 Navigator.pop(context);
// //               },
// //               child: const Text('Image'),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('Cancel'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _removeFile(int index) {
// //     setState(() {
// //       if (index >= 0 && index < _attachedFiles.length) {
// //         _attachedFiles.removeAt(index);
// //       }
// //     });
// //   }
// //
// //   void _submitExpense() {
// //     // Validate input
// //     if (_totalAmountController.text.isEmpty) {
// //       _showError('Please enter total amount');
// //       return;
// //     }
// //
// //     if (_attachedFiles.isEmpty) {
// //       _showError('Please attach at least one document');
// //       return;
// //     }
// //
// //     // Create expense data object
// //     Map<String, dynamic> expenseData = {
// //       'totalAmount': double.tryParse(_totalAmountController.text) ?? 0,
// //       'amountInProgress': double.tryParse(_amountInProgressController.text) ?? 0,
// //       'amountClaimed': double.tryParse(_amountClaimedController.text) ?? 0,
// //       'amountPending': double.tryParse(_amountPendingController.text) ?? 0,
// //       'attachments': _attachedFiles.map((file) => file['name']).toList(),
// //       'submissionDate': DateTime.now().toIso8601String(),
// //     };
// //
// //     // TODO: Submit to your backend/database
// //     _submitToBackend(expenseData);
// //
// //     // Show success message
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(
// //         content: Text('Expense submitted successfully!'),
// //         backgroundColor: Colors.green,
// //       ),
// //     );
// //
// //     // Navigate back or to success page
// //     Navigator.pop(context);
// //   }
// //
// //   Future<void> _submitToBackend(Map<String, dynamic> expenseData) async {
// //     // TODO: Implement your backend submission logic here
// //     // Example:
// //     // try {
// //     //   final response = await http.post(
// //     //     Uri.parse('your-api-endpoint'),
// //     //     headers: {'Content-Type': 'application/json'},
// //     //     body: json.encode(expenseData),
// //     //   );
// //     //   // Handle response
// //     // } catch (e) {
// //     //   // Handle error
// //     // }
// //
// //     print('Submitting expense data: $expenseData');
// //   }
// //
// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ExpenseScreen extends StatefulWidget {
//   const ExpenseScreen({super.key});
//
//   @override
//   State<ExpenseScreen> createState() => _ExpenseScreenState();
// }
//
// class _ExpenseScreenState extends State<ExpenseScreen> {
//   // Colors to match the UI
//   static const Color primaryBlue = Color(0xFF0F3A68);
//   static const Color lightGray = Color(0xFFF1F5F9);
//   static const Color cardBackground = Colors.white;
//
//   // Controllers for dynamic input
//   final TextEditingController _totalAmountController = TextEditingController();
//   final TextEditingController _amountInProgressController = TextEditingController();
//   final TextEditingController _amountClaimedController = TextEditingController();
//   final TextEditingController _amountPendingController = TextEditingController();
//
//   // List to store attached files with full details
//   List<Map<String, dynamic>> _attachedFiles = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }
//
//   void _loadInitialData() {
//     // Initialize with empty values
//     _totalAmountController.text = '';
//     _amountInProgressController.text = '';
//     _amountClaimedController.text = '';
//     _amountPendingController.text = '';
//     _attachedFiles = [];
//   }
//
//   @override
//   void dispose() {
//     _totalAmountController.dispose();
//     _amountInProgressController.dispose();
//     _amountClaimedController.dispose();
//     _amountPendingController.dispose();
//     super.dispose();
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
//           'Expense',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
//             onPressed: () {
//               // Add notification functionality
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Total Amount Request
//             _buildAmountField(
//               label: 'Total Amount Request',
//               controller: _totalAmountController,
//             ),
//
//             const SizedBox(height: 24),
//
//             // Amount Request in progress
//             _buildAmountField(
//               label: 'Amount Request in progress',
//               controller: _amountInProgressController,
//             ),
//
//             const SizedBox(height: 24),
//
//             // Amount Claimed
//             _buildAmountField(
//               label: 'Amount Claimed',
//               controller: _amountClaimedController,
//             ),
//
//             const SizedBox(height: 24),
//
//             // Amount Pending
//             _buildAmountField(
//               label: 'Amount Pending',
//               controller: _amountPendingController,
//             ),
//
//             const SizedBox(height: 32),
//
//             // Attached Files Section - DYNAMIC
//             _buildAttachedFilesSection(),
//
//             const SizedBox(height: 40),
//
//             // Submit Button
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: _submitExpense,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryBlue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Submit Expense',
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
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }
//
//   Widget _buildAmountField({
//     required String label,
//     required TextEditingController controller,
//     bool enabled = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           decoration: BoxDecoration(
//             color: cardBackground,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(8),
//                     bottomLeft: Radius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   '₹',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   enabled: enabled,
//                   keyboardType: TextInputType.number,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     hintText: 'Enter amount',
//                     hintStyle: TextStyle(
//                       color: Colors.grey[500],
//                       fontSize: 16,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAttachedFilesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Attachments',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             TextButton.icon(
//               onPressed: _showFilePickerOptions,
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add'),
//               style: TextButton.styleFrom(
//                 foregroundColor: primaryBlue,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//
//         // Display message if no files attached
//         if (_attachedFiles.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: const Row(
//               children: [
//                 Icon(Icons.info_outline, color: Colors.grey, size: 20),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'No attachments added yet. Tap "Add" to attach files.',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//         // Display attached files
//         ..._attachedFiles.asMap().entries.map((entry) {
//           int index = entry.key;
//           Map<String, dynamic> file = entry.value;
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: _buildAttachmentItem(index, file),
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   Widget _buildAttachmentItem(int index, Map<String, dynamic> file) {
//     String fileName = file['name'] ?? 'Unknown File';
//     String fileType = file['type'] ?? 'FILE';
//     String? filePath = file['path'];
//
//     // Determine badge color and text based on file type
//     Color badgeColor;
//     String badgeText;
//
//     if (fileName.toLowerCase().endsWith('.pdf')) {
//       badgeColor = Colors.red;
//       badgeText = 'PDF';
//     } else if (fileName.toLowerCase().endsWith('.jpg') ||
//         fileName.toLowerCase().endsWith('.jpeg') ||
//         fileName.toLowerCase().endsWith('.png')) {
//       badgeColor = Colors.blue;
//       badgeText = 'IMG';
//     } else if (fileName.toLowerCase().endsWith('.doc') ||
//         fileName.toLowerCase().endsWith('.docx')) {
//       badgeColor = Colors.indigo;
//       badgeText = 'DOC';
//     } else {
//       badgeColor = Colors.grey;
//       badgeText = 'FILE';
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: cardBackground,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Text(
//             '${index + 1}.',
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: badgeColor,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               badgeText,
//               style: const TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//
//           // Preview for images
//           if (filePath != null && (fileName.toLowerCase().endsWith('.jpg') ||
//               fileName.toLowerCase().endsWith('.jpeg') ||
//               fileName.toLowerCase().endsWith('.png'))) ...[
//             ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: Image.file(
//                 File(filePath),
//                 width: 40,
//                 height: 40,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     width: 40,
//                     height: 40,
//                     color: Colors.grey.shade200,
//                     child: const Icon(Icons.image, size: 20, color: Colors.grey),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(width: 12),
//           ],
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   fileName,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (file['size'] != null)
//                   Text(
//                     file['size'],
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: () => _removeFile(index),
//             icon: const Icon(Icons.close, size: 18, color: Colors.red),
//             constraints: const BoxConstraints(),
//             padding: const EdgeInsets.all(8),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBottomNavigationBar() {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavItem(Icons.home_outlined, 'Home', false),
//           _buildNavItem(Icons.assignment_outlined, 'Task', true),
//           _buildNavItem(Icons.calendar_today_outlined, 'Calendar', false),
//           _buildNavItem(Icons.person_outline, 'Profile', false),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, bool isSelected) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           icon,
//           color: isSelected ? primaryBlue : Colors.grey,
//           size: 24,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: isSelected ? primaryBlue : Colors.grey,
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // NEW: Show file picker options dialog
//   void _showFilePickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Add Attachment',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ListTile(
//                   leading: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(Icons.picture_as_pdf, color: Colors.red),
//                   ),
//                   title: const Text('PDF Document'),
//                   subtitle: const Text('Select PDF file'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickPDFFile();
//                   },
//                 ),
//                 ListTile(
//                   leading: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(Icons.image, color: Colors.blue),
//                   ),
//                   title: const Text('Image'),
//                   subtitle: const Text('Select image from gallery'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImageFile();
//                   },
//                 ),
//                 ListTile(
//                   leading: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.indigo.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(Icons.description, color: Colors.indigo),
//                   ),
//                   title: const Text('Document'),
//                   subtitle: const Text('Select Word or other documents'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickDocumentFile();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // NEW: Pick PDF file from device
//   Future<void> _pickPDFFile() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf'],
//         allowMultiple: false,
//       );
//
//       if (result != null && result.files.isNotEmpty) {
//         PlatformFile file = result.files.first;
//
//         // Get file size in human readable format
//         String fileSize = _formatFileSize(file.size);
//
//         setState(() {
//           _attachedFiles.add({
//             'name': file.name,
//             'path': file.path,
//             'size': fileSize,
//             'type': 'pdf',
//           });
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('PDF "${file.name}" attached successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error picking PDF file: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Error selecting PDF file'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   // NEW: Pick image file from device
//   Future<void> _pickImageFile() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.image,
//         allowMultiple: false,
//       );
//
//       if (result != null && result.files.isNotEmpty) {
//         PlatformFile file = result.files.first;
//
//         String fileSize = _formatFileSize(file.size);
//
//         setState(() {
//           _attachedFiles.add({
//             'name': file.name,
//             'path': file.path,
//             'size': fileSize,
//             'type': 'image',
//           });
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Image "${file.name}" attached successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error picking image file: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Error selecting image'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   // NEW: Pick document file from device
//   Future<void> _pickDocumentFile() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['doc', 'docx', 'txt', 'xlsx', 'xls'],
//         allowMultiple: false,
//       );
//
//       if (result != null && result.files.isNotEmpty) {
//         PlatformFile file = result.files.first;
//
//         String fileSize = _formatFileSize(file.size);
//
//         setState(() {
//           _attachedFiles.add({
//             'name': file.name,
//             'path': file.path,
//             'size': fileSize,
//             'type': 'document',
//           });
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Document "${file.name}" attached successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error picking document file: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Error selecting document'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   // Helper function to format file size
//   String _formatFileSize(int bytes) {
//     if (bytes < 1024) return '$bytes B';
//     if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
//     return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//   }
//
//   void _removeFile(int index) {
//     setState(() {
//       if (index >= 0 && index < _attachedFiles.length) {
//         String fileName = _attachedFiles[index]['name'];
//         _attachedFiles.removeAt(index);
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Removed "$fileName"'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     });
//   }
//
//   Future<void> _submitExpense() async {
//     // Validate input
//     if (_totalAmountController.text.isEmpty) {
//       _showError('Please enter total amount');
//       return;
//     }
//
//     if (_attachedFiles.isEmpty) {
//       _showError('Please attach at least one document');
//       return;
//     }
//
//     // Create expense data object
//     Map<String, dynamic> expenseData = {
//       'totalAmount': double.tryParse(_totalAmountController.text) ?? 0,
//       'amountInProgress': double.tryParse(_amountInProgressController.text) ?? 0,
//       'amountClaimed': double.tryParse(_amountClaimedController.text) ?? 0,
//       'amountPending': double.tryParse(_amountPendingController.text) ?? 0,
//       'attachments': _attachedFiles.map((file) => {
//         'name': file['name'],
//         'path': file['path'],
//         'type': file['type'],
//         'size': file['size'],
//       }).toList(),
//       'submissionDate': DateTime.now().toIso8601String(),
//     };
//
//     // Save to SharedPreferences
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> expenseSubmissions = prefs.getStringList('expense_submissions') ?? [];
//       expenseSubmissions.add(jsonEncode(expenseData));
//       await prefs.setStringList('expense_submissions', expenseSubmissions);
//
//       debugPrint('Expense submitted: $expenseData');
//     } catch (e) {
//       debugPrint('Error saving expense submission: $e');
//     }
//
//     // Show success message
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Expense submitted successfully!'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
//         ),
//       );
//
//       // Navigate back after a short delay
//       Future.delayed(const Duration(seconds: 1), () {
//         if (mounted) {
//           Navigator.pop(context, true);
//         }
//       });
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }
//
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // Colors to match the UI
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color cardBackground = Colors.white;

  // Controllers for dynamic input
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _amountInProgressController = TextEditingController();
  final TextEditingController _amountClaimedController = TextEditingController();
  final TextEditingController _amountPendingController = TextEditingController();

  // List to store attached files with full details
  List<Map<String, dynamic>> _attachedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Initialize with empty values
    _totalAmountController.text = '';
    _amountInProgressController.text = '';
    _amountClaimedController.text = '';
    _amountPendingController.text = '';
    _attachedFiles = [];
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _amountInProgressController.dispose();
    _amountClaimedController.dispose();
    _amountPendingController.dispose();
    super.dispose();
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
          'Expense',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
            onPressed: () {
              // Add notification functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount Request
            _buildAmountField(
              label: 'Total Amount Request',
              controller: _totalAmountController,
            ),

            const SizedBox(height: 24),

            // Amount Request in progress
            _buildAmountField(
              label: 'Amount Request in progress',
              controller: _amountInProgressController,
            ),

            const SizedBox(height: 24),

            // Amount Claimed
            _buildAmountField(
              label: 'Amount Claimed',
              controller: _amountClaimedController,
            ),

            const SizedBox(height: 24),

            // Amount Pending
            _buildAmountField(
              label: 'Amount Pending',
              controller: _amountPendingController,
            ),

            const SizedBox(height: 32),

            // Attached Files Section - DYNAMIC
            _buildAttachedFilesSection(),

            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Expense',
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAmountField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachedFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attachments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: _showFilePickerOptions,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Display message if no files attached
        if (_attachedFiles.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No attachments added yet. Tap "Add" to attach files.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Display attached files
        ..._attachedFiles.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> file = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildAttachmentItem(index, file),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAttachmentItem(int index, Map<String, dynamic> file) {
    String fileName = file['name'] ?? 'Unknown File';
    String fileType = file['type'] ?? 'FILE';
    String? filePath = file['path'];

    // Determine badge color and text based on file type
    Color badgeColor;
    String badgeText;

    if (fileName.toLowerCase().endsWith('.pdf')) {
      badgeColor = Colors.red;
      badgeText = 'PDF';
    } else if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png')) {
      badgeColor = Colors.blue;
      badgeText = 'IMG';
    } else if (fileName.toLowerCase().endsWith('.doc') ||
        fileName.toLowerCase().endsWith('.docx')) {
      badgeColor = Colors.indigo;
      badgeText = 'DOC';
    } else {
      badgeColor = Colors.grey;
      badgeText = 'FILE';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            '${index + 1}.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Preview for images
          if (filePath != null && (fileName.toLowerCase().endsWith('.jpg') ||
              fileName.toLowerCase().endsWith('.jpeg') ||
              fileName.toLowerCase().endsWith('.png'))) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(filePath),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 20, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (file['size'] != null)
                  Text(
                    file['size'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeFile(index),
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.assignment_outlined, 'Task', true),
          _buildNavItem(Icons.calendar_today_outlined, 'Calendar', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? primaryBlue : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? primaryBlue : Colors.grey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // NEW: Show file picker options dialog
  void _showFilePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Attachment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  title: const Text('PDF Document'),
                  subtitle: const Text('Select PDF file'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPDFFile();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.blue),
                  ),
                  title: const Text('Image'),
                  subtitle: const Text('Select image from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFile();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description, color: Colors.indigo),
                  ),
                  title: const Text('Document'),
                  subtitle: const Text('Select Word or other documents'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocumentFile();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NEW: Pick PDF file from device
  Future<void> _pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Get file size in human readable format
        String fileSize = _formatFileSize(file.size);

        setState(() {
          _attachedFiles.add({
            'name': file.name,
            'path': file.path,
            'size': fileSize,
            'type': 'pdf',
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF "${file.name}" attached successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking PDF file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting PDF file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Pick image file from device
  Future<void> _pickImageFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        String fileSize = _formatFileSize(file.size);

        setState(() {
          _attachedFiles.add({
            'name': file.name,
            'path': file.path,
            'size': fileSize,
            'type': 'image',
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image "${file.name}" attached successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Pick document file from device
  Future<void> _pickDocumentFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx', 'txt', 'xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        String fileSize = _formatFileSize(file.size);

        setState(() {
          _attachedFiles.add({
            'name': file.name,
            'path': file.path,
            'size': fileSize,
            'type': 'document',
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document "${file.name}" attached successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking document file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting document'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper function to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _removeFile(int index) {
    setState(() {
      if (index >= 0 && index < _attachedFiles.length) {
        String fileName = _attachedFiles[index]['name'];
        _attachedFiles.removeAt(index);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "$fileName"'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _submitExpense() async {
    // Validate input
    if (_totalAmountController.text.isEmpty) {
      _showError('Please enter total amount');
      return;
    }

    if (_attachedFiles.isEmpty) {
      _showError('Please attach at least one document');
      return;
    }

    // Create expense data object
    Map<String, dynamic> expenseData = {
      'totalAmount': double.tryParse(_totalAmountController.text) ?? 0,
      'amountInProgress': double.tryParse(_amountInProgressController.text) ?? 0,
      'amountClaimed': double.tryParse(_amountClaimedController.text) ?? 0,
      'amountPending': double.tryParse(_amountPendingController.text) ?? 0,
      'attachments': _attachedFiles.map((file) => {
        'name': file['name'],
        'path': file['path'],
        'type': file['type'],
        'size': file['size'],
      }).toList(),
      'submissionDate': DateTime.now().toIso8601String(),
    };

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save the expense submission
      List<String> expenseSubmissions = prefs.getStringList('expense_submissions') ?? [];
      expenseSubmissions.add(jsonEncode(expenseData));
      await prefs.setStringList('expense_submissions', expenseSubmissions);

      // ⭐ IMPORTANT: Mark expenses as submitted for today
      await prefs.setBool('expenses_submitted_today', true);

      // Also save the submission date to track when it was submitted
      await prefs.setString('last_expense_submission_date', DateTime.now().toIso8601String());

      debugPrint('Expense submitted: $expenseData');
      debugPrint('Expenses marked as submitted for today');
    } catch (e) {
      debugPrint('Error saving expense submission: $e');
    }

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Expense submitted successfully!')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // ⭐ Return true to indicate successful submission
          Navigator.pop(context, true);
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}