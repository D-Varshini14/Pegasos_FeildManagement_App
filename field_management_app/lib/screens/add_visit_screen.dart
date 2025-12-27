// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'client_summary_screen.dart' as summary;
//
// class AddVisitScreen extends StatefulWidget {
//   const AddVisitScreen({super.key});
//
//   @override
//   _AddVisitScreenState createState() => _AddVisitScreenState();
// }
//
// class _AddVisitScreenState extends State<AddVisitScreen> with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _clientNameController = TextEditingController();
//   final _purposeController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _notesController = TextEditingController();
//
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   bool _isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   final FocusNode _clientNameFocus = FocusNode();
//   final FocusNode _purposeFocus = FocusNode();
//   final FocusNode _locationFocus = FocusNode();
//   final FocusNode _phoneFocus = FocusNode();
//   final FocusNode _notesFocus = FocusNode();
//
//   final Map<String, bool> _fieldErrors = {
//     'clientName': false,
//     'purpose': false,
//     'location': false,
//     'phone': false,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _clientNameController.dispose();
//     _purposeController.dispose();
//     _locationController.dispose();
//     _phoneController.dispose();
//     _notesController.dispose();
//     _clientNameFocus.dispose();
//     _purposeFocus.dispose();
//     _locationFocus.dispose();
//     _phoneFocus.dispose();
//     _notesFocus.dispose();
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
//               primary: Color(0xFF0F3A68),
//               onPrimary: Colors.white,
//               surface: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() => _selectedDate = picked);
//       HapticFeedback.lightImpact();
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
//               primary: Color(0xFF0F3A68),
//               onPrimary: Colors.white,
//               surface: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() => _selectedTime = picked);
//       HapticFeedback.lightImpact();
//     }
//   }
//
//   void _saveVisit() async {
//     setState(() => _fieldErrors.updateAll((key, value) => false));
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
//       HapticFeedback.mediumImpact();
//       try {
//         final DateTime visitDateTime = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           _selectedTime.hour,
//           _selectedTime.minute,
//         );
//         final visit = summary.Visit(
//           clientName: _clientNameController.text.trim(),
//           purpose: _purposeController.text.trim(),
//           location: _locationController.text.trim(),
//           phoneNumber: _phoneController.text.trim(),
//           visitTime: visitDateTime,
//           status: 'pending',
//           notes: _notesController.text.trim(),
//         );
//         await Future.delayed(const Duration(milliseconds: 1500));
//         Navigator.pop(context, visit);
//         _showSuccessSnackBar();
//       } catch (e) {
//         _showErrorSnackBar('Error scheduling visit: $e');
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     } else {
//       setState(() {
//         _fieldErrors['clientName'] = _clientNameController.text.trim().isEmpty;
//         _fieldErrors['purpose'] = _purposeController.text.trim().isEmpty;
//         _fieldErrors['location'] = _locationController.text.trim().isEmpty;
//         _fieldErrors['phone'] = _phoneController.text.trim().isEmpty;
//       });
//       HapticFeedback.heavyImpact();
//     }
//   }
//
//   void _showSuccessSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
//             ),
//             const SizedBox(width: 12),
//             const Text('Visit scheduled successfully!', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//           ],
//         ),
//         backgroundColor: const Color(0xFF4CAF50),
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.error_outline, color: Colors.white, size: 16),
//             ),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
//           ],
//         ),
//         backgroundColor: const Color(0xFFE53E3E),
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return '${date.day} ${months[date.month - 1]}, ${date.year}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: _buildAppBar(),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 28),
//
//                 // CLIENT NAME
//                 _buildProfessionalInputField(
//                   controller: _clientNameController,
//                   focusNode: _clientNameFocus,
//                   nextFocusNode: _purposeFocus,
//                   label: 'Client Name',
//                   hint: 'Enter client full name',
//                   icon: Icons.person_outline,
//                   hasError: _fieldErrors['clientName']!,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) return 'Please enter client name';
//                     if (value.trim().length < 2) return 'Client name must be at least 2 characters';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//
//                 // PURPOSE
//                 _buildProfessionalInputField(
//                   controller: _purposeController,
//                   focusNode: _purposeFocus,
//                   nextFocusNode: _locationFocus,
//                   label: 'Purpose of Visit',
//                   hint: 'e.g., Meeting, Document Collection, Follow-up',
//                   icon: Icons.business_center_outlined,
//                   hasError: _fieldErrors['purpose']!,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) return 'Please enter purpose of visit';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//
//                 // LOCATION
//                 _buildProfessionalInputField(
//                   controller: _locationController,
//                   focusNode: _locationFocus,
//                   nextFocusNode: _phoneFocus,
//                   label: 'Location',
//                   hint: 'Enter visit location/address',
//                   icon: Icons.location_on_outlined,
//                   hasError: _fieldErrors['location']!,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) return 'Please enter location';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//
//                 // PHONE
//                 _buildProfessionalInputField(
//                   controller: _phoneController,
//                   focusNode: _phoneFocus,
//                   nextFocusNode: _notesFocus,
//                   label: 'Client Phone Number',
//                   hint: 'Enter 10-digit phone number',
//                   icon: Icons.phone_outlined,
//                   keyboardType: TextInputType.phone,
//                   hasError: _fieldErrors['phone']!,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) return 'Please enter phone number';
//                     String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
//                     if (cleanPhone.length != 10) return 'Please enter valid 10-digit phone number';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//
//                 // NOTES FIELD - Directly after phone number
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
//                     border: Border.all(color: const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(color: const Color(0xFF0F3A68).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
//                               child: const Icon(Icons.notes_outlined, color: Color(0xFF0F3A68), size: 18),
//                             ),
//                             const SizedBox(width: 12),
//                             const Text('Additional Notes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A202C), letterSpacing: -0.3)),
//                             const Spacer(),
//                             const Text('(Optional)', style: TextStyle(fontSize: 14, color: Color(0xFF718096), fontWeight: FontWeight.w500)),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _notesController,
//                           focusNode: _notesFocus,
//                           keyboardType: TextInputType.multiline,
//                           textInputAction: TextInputAction.newline,
//                           maxLines: 4,
//                           minLines: 3,
//                           maxLength: 500,
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A202C)),
//                           decoration: InputDecoration(
//                             hintText: 'Add any additional notes, instructions, or special requirements for this visit...',
//                             hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F3A68), width: 2)),
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             filled: true,
//                             fillColor: const Color(0xFFF8FAFC),
//                             counterStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 32),
//
//                 // DATE AND TIME SECTION
//                 _buildDateTimeSection(),
//
//                 const SizedBox(height: 40),
//                 _buildActionButtons(),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: const Color(0xFF0F3A68),
//       elevation: 0,
//       systemOverlayStyle: SystemUiOverlayStyle.light,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
//         onPressed: () {
//           HapticFeedback.lightImpact();
//           Navigator.pop(context);
//         },
//       ),
//       title: const Text('Schedule New Visit', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
//       centerTitle: true,
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 16),
//           child: IconButton(
//             icon: const Icon(Icons.info_outline, color: Colors.white, size: 22),
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               _showInfoDialog();
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
//         border: Border.all(color: const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(colors: [const Color(0xFF0F3A68), const Color(0xFF0F3A68).withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.3), spreadRadius: 0, blurRadius: 12, offset: const Offset(0, 4))],
//             ),
//             child: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 28),
//           ),
//           const SizedBox(width: 20),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Schedule New Visit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A202C), letterSpacing: -0.5)),
//                 SizedBox(height: 4),
//                 Text('Fill in the client details below', style: TextStyle(fontSize: 15, color: Color(0xFF718096), fontWeight: FontWeight.w500)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDateTimeSection() {
//     return Column(children: [_buildDateSelector(), const SizedBox(height: 20), _buildTimeSelector()]);
//   }
//
//   Widget _buildDateSelector() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
//         border: Border.all(color: const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(color: const Color(0xFF0F3A68).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
//                 child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF0F3A68), size: 18),
//               ),
//               const SizedBox(width: 12),
//               const Text('Visit Date', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A202C), letterSpacing: -0.3)),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () => _selectDate(context),
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                 decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12), color: const Color(0xFFF8FAFC)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(_formatDate(_selectedDate), style: const TextStyle(fontSize: 16, color: Color(0xFF1A202C), fontWeight: FontWeight.w500)),
//                     const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096), size: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTimeSelector() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
//         border: Border.all(color: const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(color: const Color(0xFF0F3A68).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
//                 child: const Icon(Icons.access_time_outlined, color: Color(0xFF0F3A68), size: 18),
//               ),
//               const SizedBox(width: 12),
//               const Text('Visit Time', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A202C), letterSpacing: -0.3)),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () => _selectTime(context),
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                 decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12), color: const Color(0xFFF8FAFC)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(_selectedTime.format(context), style: const TextStyle(fontSize: 16, color: Color(0xFF1A202C), fontWeight: FontWeight.w500)),
//                     const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096), size: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton(
//             onPressed: _isLoading ? null : _saveVisit,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0F3A68),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shadowColor: const Color(0xFF0F3A68).withOpacity(0.3),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             ),
//             child: _isLoading
//                 ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
//                 : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               Icon(Icons.event_available, size: 20),
//               SizedBox(width: 8),
//               Text('Schedule Visit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
//             ]),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: TextButton(
//             onPressed: _isLoading ? null : () {
//               HapticFeedback.lightImpact();
//               Navigator.pop(context);
//             },
//             style: TextButton.styleFrom(
//               foregroundColor: const Color(0xFF718096),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
//             ),
//             child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProfessionalInputField({
//     required TextEditingController controller,
//     required FocusNode focusNode,
//     FocusNode? nextFocusNode,
//     required String label,
//     required String hint,
//     required IconData icon,
//     bool hasError = false,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
//         border: Border.all(color: hasError ? const Color(0xFFE53E3E).withOpacity(0.3) : const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: hasError ? const Color(0xFFE53E3E).withOpacity(0.1) : const Color(0xFF0F3A68).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(icon, color: hasError ? const Color(0xFFE53E3E) : const Color(0xFF0F3A68), size: 18),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   label,
//                   style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: hasError ? const Color(0xFFE53E3E) : const Color(0xFF1A202C), letterSpacing: -0.3),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: controller,
//               focusNode: focusNode,
//               keyboardType: keyboardType,
//               inputFormatters: inputFormatters,
//               validator: validator,
//               textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
//               onFieldSubmitted: (value) {
//                 if (nextFocusNode != null) FocusScope.of(context).requestFocus(nextFocusNode);
//               },
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A202C)),
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F3A68), width: 2)),
//                 errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53E3E))),
//                 focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2)),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 filled: true,
//                 fillColor: const Color(0xFFF8FAFC),
//                 errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE53E3E)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showInfoDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Row(
//             children: [
//               Icon(Icons.info_outline, color: Color(0xFF0F3A68)),
//               SizedBox(width: 12),
//               Text('Visit Scheduling', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A202C))),
//             ],
//           ),
//           content: const Text(
//             'Fill in all the required fields to schedule a new visit. Make sure the phone number is valid and the visit time is in the future. Notes are optional but can be helpful for additional context.',


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'client_summary_screen.dart' as summary;

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  _AddVisitScreenState createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FocusNode _clientNameFocus = FocusNode();
  final FocusNode _purposeFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  final Map<String, bool> _fieldErrors = {
    'clientName': false,
    'purpose': false,
    'location': false,
    'phone': false,
    'notes': false,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _clientNameController.dispose();
    _purposeController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _clientNameFocus.dispose();
    _purposeFocus.dispose();
    _locationFocus.dispose();
    _phoneFocus.dispose();
    _notesFocus.dispose();
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
              primary: Color(0xFF0F3A68),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      HapticFeedback.lightImpact();
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
              primary: Color(0xFF0F3A68),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      HapticFeedback.lightImpact();
    }
  }

  void _saveVisit() async {
    setState(() => _fieldErrors.updateAll((key, value) => false));
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      HapticFeedback.mediumImpact();
      try {
        final DateTime visitDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        final visit = summary.Visit(
          clientName: _clientNameController.text.trim(),
          purpose: _purposeController.text.trim(),
          location: _locationController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          visitTime: visitDateTime,
          status: 'pending',
          notes: _notesController.text.trim(),
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pop(context, visit);
        _showSuccessSnackBar();
      } catch (e) {
        _showErrorSnackBar('Error scheduling visit: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() {
        _fieldErrors['clientName'] = _clientNameController.text.trim().isEmpty;
        _fieldErrors['purpose'] = _purposeController.text.trim().isEmpty;
        _fieldErrors['location'] = _locationController.text.trim().isEmpty;
        _fieldErrors['phone'] = _phoneController.text.trim().isEmpty;
        _fieldErrors['notes'] = _notesController.text.trim().isEmpty;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            const Text('Visit scheduled successfully!', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),

                // CLIENT NAME
                _buildProfessionalInputField(
                  controller: _clientNameController,
                  focusNode: _clientNameFocus,
                  nextFocusNode: _purposeFocus,
                  label: 'Client Name',
                  hint: 'Enter client full name',
                  icon: Icons.person_outline,
                  hasError: _fieldErrors['clientName']!,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter client name';
                    if (value.trim().length < 2) return 'Client name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // PURPOSE
                _buildProfessionalInputField(
                  controller: _purposeController,
                  focusNode: _purposeFocus,
                  nextFocusNode: _locationFocus,
                  label: 'Purpose of Visit',
                  hint: 'e.g., Meeting, Document Collection, Follow-up',
                  icon: Icons.business_center_outlined,
                  hasError: _fieldErrors['purpose']!,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter purpose of visit';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // LOCATION
                _buildProfessionalInputField(
                  controller: _locationController,
                  focusNode: _locationFocus,
                  nextFocusNode: _phoneFocus,
                  label: 'Location',
                  hint: 'Enter visit location/address',
                  icon: Icons.location_on_outlined,
                  hasError: _fieldErrors['location']!,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter location';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // PHONE
                _buildProfessionalInputField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocusNode: _notesFocus,
                  label: 'Client Phone Number',
                  hint: 'Enter 10-digit phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hasError: _fieldErrors['phone']!,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter phone number';
                    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (cleanPhone.length != 10) return 'Please enter valid 10-digit phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // NOTES FIELD - Now required
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
                    border: Border.all(
                      color: _fieldErrors['notes']! ? const Color(0xFFE53E3E).withOpacity(0.3) : const Color(0xFF0F3A68).withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _fieldErrors['notes']! ? const Color(0xFFE53E3E).withOpacity(0.1) : const Color(0xFF0F3A68).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.notes_outlined,
                                color: _fieldErrors['notes']! ? const Color(0xFFE53E3E) : const Color(0xFF0F3A68),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Additional Notes',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: _fieldErrors['notes']! ? const Color(0xFFE53E3E) : const Color(0xFF1A202C),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          focusNode: _notesFocus,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: 4,
                          minLines: 3,
                          maxLength: 500,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter notes for this visit';
                            }
                            return null;
                          },
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A202C)),
                          decoration: InputDecoration(
                            hintText: 'Add any additional notes, instructions, or special requirements for this visit...',
                            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F3A68), width: 2)),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53E3E))),
                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            counterStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                            errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE53E3E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // DATE AND TIME SECTION
                _buildDateTimeSection(),

                const SizedBox(height: 40),
                _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F3A68),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      title: const Text('Schedule New Visit', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showInfoDialog();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [const Color(0xFF0F3A68), const Color(0xFF0F3A68).withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.3), spreadRadius: 0, blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Schedule New Visit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A202C), letterSpacing: -0.5)),
                SizedBox(height: 4),
                Text('Fill in the client details below', style: TextStyle(fontSize: 15, color: Color(0xFF718096), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(children: [_buildDateSelector(), const SizedBox(height: 20), _buildTimeSelector()]);
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF0F3A68).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF0F3A68), size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Visit Date', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A202C), letterSpacing: -0.3)),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12), color: const Color(0xFFF8FAFC)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDate(_selectedDate), style: const TextStyle(fontSize: 16, color: Color(0xFF1A202C), fontWeight: FontWeight.w500)),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096), size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF0F3A68).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.access_time_outlined, color: Color(0xFF0F3A68), size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Visit Time', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A202C), letterSpacing: -0.3)),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectTime(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12), color: const Color(0xFFF8FAFC)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedTime.format(context), style: const TextStyle(fontSize: 16, color: Color(0xFF1A202C), fontWeight: FontWeight.w500)),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096), size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveVisit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F3A68),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: const Color(0xFF0F3A68).withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.event_available, size: 20),
              SizedBox(width: 8),
              Text('Schedule Visit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton(
            onPressed: _isLoading ? null : () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF718096),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool hasError = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0F3A68).withOpacity(0.08), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: hasError ? const Color(0xFFE53E3E).withOpacity(0.3) : const Color(0xFF0F3A68).withOpacity(0.08), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasError ? const Color(0xFFE53E3E).withOpacity(0.1) : const Color(0xFF0F3A68).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: hasError ? const Color(0xFFE53E3E) : const Color(0xFF0F3A68), size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: hasError ? const Color(0xFFE53E3E) : const Color(0xFF1A202C), letterSpacing: -0.3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
              onFieldSubmitted: (value) {
                if (nextFocusNode != null) FocusScope.of(context).requestFocus(nextFocusNode);
              },
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A202C)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F3A68), width: 2)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53E3E))),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE53E3E)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0F3A68)),
              SizedBox(width: 12),
              Text('Visit Scheduling', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A202C))),
            ],
          ),
          content: const Text(
              'Fill in all the required fields to schedule a new visit. Make sure the phone number is valid and the visit time is in the future. All fields including notes are required.',


          style: TextStyle(fontSize: 15, color: Color(0xFF718096)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it', style: TextStyle(color: Color(0xFF0F3A68), fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}