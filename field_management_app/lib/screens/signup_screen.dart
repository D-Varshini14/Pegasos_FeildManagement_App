//
// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart';
// import 'login_screen.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _zoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   String _selectedRole = 'field_executive';
//   File? _profileImage;
//   bool _isLoading = false;
//   String _errorMessage = '';
//
//   final List<String> _roles = [
//     'field_executive',
//     'manager',
//     'admin',
//   ];
//
//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 512,
//       maxHeight: 512,
//       imageQuality: 75,
//     );
//
//     if (image != null) {
//       setState(() {
//         _profileImage = File(image.path);
//       });
//     }
//   }
//
//   Future<void> _handleSignup() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     if (_passwordController.text != _confirmPasswordController.text) {
//       setState(() {
//         _errorMessage = 'Passwords do not match';
//       });
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//
//     try {
//       final response = await ApiService.signup(
//         name: _nameController.text.trim(),
//         email: _emailController.text.trim(),
//         phone: _phoneController.text.trim(),
//         zone: _zoneController.text.trim(),
//         role: _selectedRole,
//         password: _passwordController.text,
//         profileImage: _profileImage,
//       );
//
//       if (response['success'] == true) {
//         final employeeId = response['data']['employeeId'];
//
//         // Ensure all data is saved properly
//         final userData = {
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'phone': _phoneController.text.trim(),
//           'zone': _zoneController.text.trim(),
//           'role': _selectedRole,
//           'employeeId': employeeId,
//           ...response['data'], // Include any additional data from API
//         };
//
//         // Save user data to SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('user', jsonEncode(userData));
//         await prefs.setBool('isLoggedIn', true);
//
//         if (mounted) {
//           // Show professional success toast at the top
//           final overlay = Overlay.of(context);
//           OverlayEntry? overlayEntry;
//
//           overlayEntry = OverlayEntry(
//             builder: (context) => Positioned(
//               top: MediaQuery.of(context).padding.top + 16,
//               left: 20,
//               right: 20,
//               child: Material(
//                 color: Colors.transparent,
//                 child: TweenAnimationBuilder(
//                   duration: const Duration(milliseconds: 400),
//                   tween: Tween<double>(begin: 0, end: 1),
//                   builder: (context, double value, child) {
//                     return Transform.translate(
//                       offset: Offset(0, -50 * (1 - value)),
//                       child: Opacity(
//                         opacity: value,
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           const Color(0xFF0F3A68),
//                           const Color(0xFF1a4d7d),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF0F3A68).withOpacity(0.4),
//                           blurRadius: 20,
//                           offset: const Offset(0, 8),
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Stack(
//                         children: [
//                           // Decorative pattern
//                           Positioned(
//                             right: -20,
//                             top: -20,
//                             child: Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(0.05),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             left: -30,
//                             bottom: -30,
//                             child: Container(
//                               width: 120,
//                               height: 120,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(0.03),
//                               ),
//                             ),
//                           ),
//                           // Close button
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: GestureDetector(
//                               onTap: () {
//                                 overlayEntry?.remove();
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.close,
//                                   color: Colors.white,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Content
//                           Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white.withOpacity(0.2),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: const Icon(
//                                         Icons.check_circle,
//                                         color: Colors.white,
//                                         size: 24,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Text(
//                                         'Account Created Successfully!',
//                                         style: GoogleFonts.poppins(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 16,
//                                           color: Colors.white,
//                                           letterSpacing: 0.3,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Container(
//                                   padding: const EdgeInsets.all(14),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 8,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.badge,
//                                             color: const Color(0xFF0F3A68),
//                                             size: 20,
//                                           ),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             'Your Employee ID',
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 13,
//                                               color: Colors.grey.shade700,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 16,
//                                           vertical: 10,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFF0F3A68).withOpacity(0.08),
//                                           borderRadius: BorderRadius.circular(8),
//                                           border: Border.all(
//                                             color: const Color(0xFF0F3A68).withOpacity(0.2),
//                                             width: 1.5,
//                                           ),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             employeeId,
//                                             style: GoogleFonts.robotoMono(
//                                               fontSize: 20,
//                                               fontWeight: FontWeight.bold,
//                                               letterSpacing: 3,
//                                               color: const Color(0xFF0F3A68),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.info_outline,
//                                       size: 14,
//                                       color: Colors.white.withOpacity(0.9),
//                                     ),
//                                     const SizedBox(width: 6),
//                                     Expanded(
//                                       child: Text(
//                                         'Please save this ID for future login',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 12,
//                                           color: Colors.white.withOpacity(0.95),
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//
//           overlay.insert(overlayEntry);
//
//           // Remove the toast after 6 seconds and navigate
//           await Future.delayed(const Duration(seconds: 6));
//           overlayEntry.remove();
//
//           await Future.delayed(const Duration(milliseconds: 500));
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const LoginScreen()),
//           );
//         }
//       } else {
//         setState(() {
//           _errorMessage = response['message'] ?? 'Registration failed';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Network error. Please check your connection.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F3A68),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0F3A68),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: Text(
//               'Create Account',
//               style: GoogleFonts.poppins(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Color(0xFFEDEEEF),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 20),
//
//                       // Profile Image Picker
//                       GestureDetector(
//                         onTap: _pickImage,
//                         child: Container(
//                           width: 120,
//                           height: 120,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.grey.shade300,
//                             border: Border.all(
//                               color: const Color(0xFF0F3A68),
//                               width: 3,
//                             ),
//                           ),
//                           child: _profileImage != null
//                               ? ClipOval(
//                             child: Image.file(
//                               _profileImage!,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                               : const Icon(
//                             Icons.add_a_photo,
//                             size: 40,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Tap to upload profile photo',
//                         style: GoogleFonts.poppins(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//
//                       if (_errorMessage.isNotEmpty)
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           margin: const EdgeInsets.only(bottom: 20),
//                           decoration: BoxDecoration(
//                             color: Colors.red.shade50,
//                             border: Border.all(color: Colors.red.shade300),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             _errorMessage,
//                             style: GoogleFonts.poppins(
//                               color: Colors.red.shade700,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//
//                       _buildTextField(
//                         controller: _nameController,
//                         label: 'Full Name',
//                         icon: Icons.person,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your name';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//
//                       _buildTextField(
//                         controller: _emailController,
//                         label: 'Email',
//                         icon: Icons.email,
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter email';
//                           }
//                           if (!value.contains('@')) {
//                             return 'Please enter a valid email';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//
//                       _buildTextField(
//                         controller: _phoneController,
//                         label: 'Phone Number',
//                         icon: Icons.phone,
//                         keyboardType: TextInputType.phone,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter phone number';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//
//                       _buildTextField(
//                         controller: _zoneController,
//                         label: 'Zone',
//                         icon: Icons.location_on,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter zone';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//
//                       // Role Dropdown
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: DropdownButtonFormField<String>(
//                           value: _selectedRole,
//                           decoration: InputDecoration(
//                             labelText: 'Role',
//                             labelStyle: GoogleFonts.poppins(
//                               color: const Color(0xFF0F3A68),
//                               fontWeight: FontWeight.w500,
//                             ),
//                             border: InputBorder.none,
//                             prefixIcon: const Icon(
//                               Icons.work,
//                               color: Color(0xFF0F3A68),
//                             ),
//                           ),
//                           items: _roles.map((role) {
//                             return DropdownMenuItem(
//                               value: role,
//                               child: Text(
//                                 role.replaceAll('_', ' ').toUpperCase(),
//                                 style: GoogleFonts.poppins(),
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedRole = value!;
//                             });
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//
//                       _buildTextField(
//                         controller: _passwordController,
//                         label: 'Password',
//                         icon: Icons.lock,
//                         isPassword: true,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter password';
//                           }
//                           if (value.length < 6) {
//                             return 'Password must be at least 6 characters';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//
//                       _buildTextField(
//                         controller: _confirmPasswordController,
//                         label: 'Confirm Password',
//                         icon: Icons.lock_outline,
//                         isPassword: true,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please confirm password';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 30),
//
//                       SizedBox(
//                         width: double.infinity,
//                         height: 58,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _handleSignup,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF0F3A68),
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: _isLoading
//                               ? const CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           )
//                               : Text(
//                             'Create Account',
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
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
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isPassword = false,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: isPassword,
//         keyboardType: keyboardType,
//         validator: validator,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: GoogleFonts.poppins(
//             color: const Color(0xFF0F3A68),
//             fontWeight: FontWeight.w500,
//           ),
//           prefixIcon: Icon(icon, color: const Color(0xFF0F3A68)),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _zoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'field_executive';
  File? _profileImage;
  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> _roles = [
    'field_executive',
    'manager',
    'admin',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        zone: _zoneController.text.trim(),
        role: _selectedRole,
        password: _passwordController.text,
        profileImage: _profileImage,
      );

      if (response['success'] == true) {
        final employeeId = response['data']['employeeId'];

        // Ensure all data is saved properly
        final userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'zone': _zoneController.text.trim(),
          'role': _selectedRole,
          'employeeId': employeeId,
          ...response['data'], // Include any additional data from API
        };

        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(userData));
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          // Show professional success toast at the top
          final overlay = Overlay.of(context);
          OverlayEntry? overlayEntry;

          overlayEntry = OverlayEntry(
            builder: (context) => Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  overlayEntry?.remove();
                },
                child: Material(
                  color: Colors.transparent,
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, -50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0F3A68),
                            const Color(0xFF1a4d7d),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F3A68).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Decorative pattern
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -30,
                              bottom: -30,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.03),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Account Created Successfully!',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.badge,
                                              color: const Color(0xFF0F3A68),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Your Employee ID',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F3A68).withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFF0F3A68).withOpacity(0.2),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              employeeId,
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 3,
                                                color: const Color(0xFF0F3A68),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Please save this ID for future login',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.95),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          overlay.insert(overlayEntry);

          // Remove the toast after 4 seconds and navigate
          await Future.delayed(const Duration(seconds: 4));
          overlayEntry.remove();

          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Registration failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3A68),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3A68),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Create Account',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEDEEEF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Image Picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                            border: Border.all(
                              color: const Color(0xFF0F3A68),
                              width: 3,
                            ),
                          ),
                          child: _profileImage != null
                              ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload profile photo',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage,
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _zoneController,
                        label: 'Zone',
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter zone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Role Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            labelStyle: GoogleFonts.poppins(
                              color: const Color(0xFF0F3A68),
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.work,
                              color: Color(0xFF0F3A68),
                            ),
                          ),
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(
                                role.replaceAll('_', ' ').toUpperCase(),
                                style: GoogleFonts.poppins(),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F3A68),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                              : Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: const Color(0xFF0F3A68),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF0F3A68)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _zoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}