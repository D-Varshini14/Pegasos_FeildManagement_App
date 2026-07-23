// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// //
// // class ExpenseFormScreen extends StatefulWidget {
// //   const ExpenseFormScreen({super.key});
// //
// //   @override
// //   State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
// // }
// //
// // class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _titleController = TextEditingController();
// //   final _amountController = TextEditingController();
// //   final _descriptionController = TextEditingController();
// //
// //   String _selectedCategory = 'Transport';
// //   DateTime _selectedDate = DateTime.now();
// //
// //   // Colors to match the UI
// //   static const Color primaryBlue = Color(0xFF0F3A68);
// //   static const Color lightGray = Color(0xFFF1F5F9);
// //   static const Color cardBackground = Colors.white;
// //
// //   final List<String> _categories = [
// //     'Transport',
// //     'Food',
// //     'Office',
// //     'Business',
// //     'Accommodation',
// //     'Communication',
// //     'Other',
// //   ];
// //
// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _amountController.dispose();
// //     _descriptionController.dispose();
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
// //           'Add Expense',
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w600,
// //             color: Colors.white,
// //           ),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.save, color: Colors.white, size: 24),
// //             onPressed: _saveExpense,
// //           ),
// //         ],
// //       ),
// //       body: Form(
// //         key: _formKey,
// //         child: ListView(
// //           padding: const EdgeInsets.all(16),
// //           children: [
// //             // Title Field
// //             _buildFormCard(
// //               title: 'Expense Title',
// //               child: TextFormField(
// //                 controller: _titleController,
// //                 decoration: const InputDecoration(
// //                   hintText: 'Enter expense title',
// //                   border: OutlineInputBorder(),
// //                   prefixIcon: Icon(Icons.title),
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'Please enter expense title';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Amount Field
// //             _buildFormCard(
// //               title: 'Amount',
// //               child: TextFormField(
// //                 controller: _amountController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: const InputDecoration(
// //                   hintText: 'Enter amount',
// //                   border: OutlineInputBorder(),
// //                   prefixIcon: Icon(Icons.currency_rupee),
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'Please enter amount';
// //                   }
// //                   if (double.tryParse(value) == null) {
// //                     return 'Please enter valid amount';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Category Field
// //             _buildFormCard(
// //               title: 'Category',
// //               child: DropdownButtonFormField<String>(
// //                 value: _selectedCategory,
// //                 decoration: const InputDecoration(
// //                   border: OutlineInputBorder(),
// //                   prefixIcon: Icon(Icons.category),
// //                 ),
// //                 items: _categories.map((category) {
// //                   return DropdownMenuItem(
// //                     value: category,
// //                     child: Text(category),
// //                   );
// //                 }).toList(),
// //                 onChanged: (value) {
// //                   setState(() {
// //                     _selectedCategory = value!;
// //                   });
// //                 },
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Date Field
// //             _buildFormCard(
// //               title: 'Date',
// //               child: InkWell(
// //                 onTap: _selectDate,
// //                 child: Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     border: Border.all(color: Colors.grey),
// //                     borderRadius: BorderRadius.circular(4),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       const Icon(Icons.calendar_today),
// //                       const SizedBox(width: 12),
// //                       Text(
// //                         DateFormat('dd/MM/yyyy').format(_selectedDate),
// //                         style: const TextStyle(fontSize: 16),
// //                       ),
// //                       const Spacer(),
// //                       const Icon(Icons.arrow_drop_down),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Description Field
// //             _buildFormCard(
// //               title: 'Description (Optional)',
// //               child: TextFormField(
// //                 controller: _descriptionController,
// //                 maxLines: 3,
// //                 decoration: const InputDecoration(
// //                   hintText: 'Enter description or notes',
// //                   border: OutlineInputBorder(),
// //                   prefixIcon: Icon(Icons.notes),
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(height: 32),
// //
// //             // Save Button
// //             ElevatedButton(
// //               onPressed: _saveExpense,
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: primaryBlue,
// //                 foregroundColor: Colors.white,
// //                 padding: const EdgeInsets.symmetric(vertical: 16),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //               ),
// //               child: const Text(
// //                 'Save Expense',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Cancel Button
// //             OutlinedButton(
// //               onPressed: () => Navigator.pop(context),
// //               style: OutlinedButton.styleFrom(
// //                 foregroundColor: primaryBlue,
// //                 side: const BorderSide(color: primaryBlue),
// //                 padding: const EdgeInsets.symmetric(vertical: 16),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //               ),
// //               child: const Text(
// //                 'Cancel',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFormCard({required String title, required Widget child}) {
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
// //           Text(
// //             title,
// //             style: const TextStyle(
// //               fontSize: 14,
// //               fontWeight: FontWeight.w600,
// //               color: primaryBlue,
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           child,
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> _selectDate() async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       builder: (context, child) {
// //         return Theme(
// //           data: Theme.of(context).copyWith(
// //             colorScheme: const ColorScheme.light(
// //               primary: primaryBlue,
// //             ),
// //           ),
// //           child: child!,
// //         );
// //       },
// //     );
// //     if (picked != null && picked != _selectedDate) {
// //       setState(() {
// //         _selectedDate = picked;
// //       });
// //     }
// //   }
// //
// //   void _saveExpense() {
// //     if (_formKey.currentState!.validate()) {
// //       // Here you would typically save the expense to your database/storage
// //       // For now, we'll just show a success message
// //
// //       final expense = {
// //         'title': _titleController.text,
// //         'amount': double.parse(_amountController.text),
// //         'category': _selectedCategory,
// //         'date': _selectedDate,
// //         'description': _descriptionController.text,
// //       };
// //
// //       // TODO: Save expense to your storage/database
// //       print('Saving expense: $expense');
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Expense saved successfully!'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //
// //       // Return to previous screen
// //       Navigator.pop(context);
// //     }
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class ExpenseFormScreen extends StatefulWidget {
//   const ExpenseFormScreen({super.key});
//
//   @override
//   State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
// }
//
// class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _notesController = TextEditingController();
//   final _locationController = TextEditingController();
//
//   String _selectedExpenseType = 'Travel';
//   DateTime _selectedDate = DateTime.now();
//
//   // Colors to match the UI
//   static const Color primaryBlue = Color(0xFF0F3A68);
//   static const Color lightGray = Color(0xFFF1F5F9);
//   static const Color cardBackground = Colors.white;
//
//   final List<String> _expenseTypes = [
//     'Travel',
//     'Transport',
//     'Food',
//     'Office',
//     'Business',
//     'Accommodation',
//     'Communication',
//     'Other',
//   ];
//
//   @override
//   void dispose() {
//     _amountController.dispose();
//     _notesController.dispose();
//     _locationController.dispose();
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
//           'Add Expense',
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
//               // Handle notification action
//             },
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   // Expense Type Field
//                   _buildFormField(
//                     label: 'Expense Type',
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.white,
//                       ),
//                       child: DropdownButtonFormField<String>(
//                         value: _selectedExpenseType,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         ),
//                         items: _expenseTypes.map((type) {
//                           return DropdownMenuItem(
//                             value: type,
//                             child: Text(type),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedExpenseType = value!;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Amount Field
//                   _buildFormField(
//                     label: 'Amount',
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.white,
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                             decoration: BoxDecoration(
//                               border: Border(
//                                 right: BorderSide(color: Colors.grey.shade300),
//                               ),
//                             ),
//                             child: const Text(
//                               '₹',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: TextFormField(
//                               controller: _amountController,
//                               keyboardType: TextInputType.number,
//                               decoration: const InputDecoration(
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                 hintText: 'Enter amount',
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter amount';
//                                 }
//                                 if (double.tryParse(value) == null) {
//                                   return 'Please enter valid amount';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Date Field
//                   _buildFormField(
//                     label: 'Date of Expense',
//                     child: InkWell(
//                       onTap: _selectDate,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(8),
//                           color: Colors.white,
//                         ),
//                         child: Row(
//                           children: [
//                             Text(
//                               DateFormat('MMM d, yyyy').format(_selectedDate),
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             const Spacer(),
//                             const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Add Photo Section
//                   _buildFormField(
//                     label: 'Add Photo of Bill / Receipt',
//                     child: Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: InkWell(
//                         onTap: _selectPhoto,
//                         child: const Icon(
//                           Icons.add,
//                           size: 32,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Notes Field
//                   _buildFormField(
//                     label: 'Notes (Optional)',
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.white,
//                       ),
//                       child: TextFormField(
//                         controller: _notesController,
//                         maxLines: 3,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(16),
//                           hintText: 'Enter notes',
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Location Field
//                   _buildFormField(
//                     label: 'Location (Optional)',
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.white,
//                       ),
//                       child: TextFormField(
//                         controller: _locationController,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                           hintText: 'Enter location',
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//
//             // Bottom Submit Button
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _saveExpense,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryBlue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Submit Expense',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Bottom Navigation Bar
//             _buildBottomNavigationBar(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFormField({required String label, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         child,
//       ],
//     );
//   }
//
//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildBottomNavItem(Icons.home_outlined, 'Home', false),
//               _buildBottomNavItem(Icons.assignment_outlined, 'Task', true),
//               _buildBottomNavItem(Icons.calendar_today_outlined, 'Calendar', false),
//               _buildBottomNavItem(Icons.person_outline, 'Profile', false),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
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
//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: primaryBlue,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   void _selectPhoto() {
//     // TODO: Implement photo selection from gallery or camera
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Photo selection feature to be implemented'),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
//
//   void _saveExpense() {
//     if (_formKey.currentState!.validate()) {
//       final expense = {
//         'expenseType': _selectedExpenseType,
//         'amount': double.parse(_amountController.text),
//         'date': _selectedDate,
//         'notes': _notesController.text,
//         'location': _locationController.text,
//       };
//
//       // TODO: Save expense to your storage/database
//       print('Saving expense: $expense');
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Expense submitted successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       // Return to previous screen
//       Navigator.pop(context);
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedExpenseType = 'Travel';
  DateTime _selectedDate = DateTime.now();
  String? _attachedPhotoPath;
  String? _attachedPhotoName;

  // Colors to match the UI
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color cardBackground = Colors.white;

  final List<String> _expenseTypes = [
    'Travel',
    'Transport',
    'Food',
    'Office',
    'Business',
    'Accommodation',
    'Communication',
    'Other',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _locationController.dispose();
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
          'Add Expense',
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
              // Handle notification action
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Expense Type Field
                  _buildFormField(
                    label: 'Expense Type',
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedExpenseType,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _expenseTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedExpenseType = value!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Amount Field
                  _buildFormField(
                    label: 'Amount',
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: const Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                hintText: 'Enter amount',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date Field
                  _buildFormField(
                    label: 'Date of Expense',
                    child: InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('MMM d, yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add Photo Section - DYNAMIC
                  _buildFormField(
                    label: 'Add Photo of Bill / Receipt',
                    child: Row(
                      children: [
                        // Add Photo Button
                        InkWell(
                          onTap: _showPhotoOptionsDialog,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _attachedPhotoPath != null
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: _attachedPhotoPath != null
                                ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_attachedPhotoPath!),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : const Icon(
                              Icons.add,
                              size: 32,
                              color: Colors.blue,
                            ),
                          ),
                        ),

                        if (_attachedPhotoPath != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _attachedPhotoName ?? 'Photo attached',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: _showPhotoOptionsDialog,
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Change'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: primaryBlue,
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _attachedPhotoPath = null;
                                          _attachedPhotoName = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, size: 16),
                                      label: const Text('Remove'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notes Field
                  _buildFormField(
                    label: 'Notes (Optional)',
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Enter notes',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location Field
                  _buildFormField(
                    label: 'Location (Optional)',
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: 'Enter location',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Bottom Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home_outlined, 'Home', false),
              _buildBottomNavItem(Icons.assignment_outlined, 'Task', true),
              _buildBottomNavItem(Icons.calendar_today_outlined, 'Calendar', false),
              _buildBottomNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
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

  // NEW: Show options to select photo from camera or gallery
  void _showPhotoOptionsDialog() {
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
                  'Add Photo',
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
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: primaryBlue),
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library, color: primaryBlue),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.insert_drive_file, color: primaryBlue),
                  ),
                  title: const Text('Choose PDF Document'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPDFFile();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NEW: Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _attachedPhotoPath = image.path;
          _attachedPhotoName = image.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error capturing photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _attachedPhotoPath = image.path;
          _attachedPhotoName = image.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Pick PDF file
  Future<void> _pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        setState(() {
          _attachedPhotoPath = file.path;
          _attachedPhotoName = file.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF "${file.name}" selected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = {
        'expenseType': _selectedExpenseType,
        'amount': double.parse(_amountController.text),
        'date': _selectedDate.toIso8601String(),
        'notes': _notesController.text,
        'location': _locationController.text,
        'attachedPhoto': _attachedPhotoPath,
        'attachedPhotoName': _attachedPhotoName,
        'submittedAt': DateTime.now().toIso8601String(),
      };

      // Save to SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        List<String> expenses = prefs.getStringList('expenses') ?? [];
        expenses.add(jsonEncode(expense));
        await prefs.setStringList('expenses', expenses);

        debugPrint('Expense saved: $expense');
      } catch (e) {
        debugPrint('Error saving expense: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    }
  }
}