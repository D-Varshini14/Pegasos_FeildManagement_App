// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart';
// import 'home_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _nameController = TextEditingController();
//   final _userIdController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   final FocusNode _nameFocus = FocusNode();
//   final FocusNode _userFocus = FocusNode();
//   final FocusNode _passFocus = FocusNode();
//
//   bool _isLoading = false;
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _nameFocus.addListener(() => setState(() {}));
//     _userFocus.addListener(() => setState(() {}));
//     _passFocus.addListener(() => setState(() {}));
//   }
//
//   Future<void> _handleLogin() async {
//     if (_nameController.text.isEmpty ||
//         _userIdController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please enter Name, User ID and Password';
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
//       final response = await ApiService.login(
//         _nameController.text.trim(),
//         _userIdController.text.trim(),
//         _passwordController.text,
//       );
//
//       if (response['success'] == true) {
//         // Store token and user data
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', response['data']['token']);
//         await prefs.setString('user', jsonEncode(response['data']['user']));
//
//         // Navigate to home screen
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomeScreen(),
//             ),
//           );
//         }
//       } else {
//         setState(() {
//           _errorMessage = response['message'] ?? 'Login failed';
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
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F3A68),
//       body: Stack(
//         children: [
//           Positioned(
//             top: size.height * 0.12,
//             left: 0,
//             right: 0,
//             child: Text(
//               'Welcome Back',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 fontSize: 30,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           Positioned(
//             top: size.height * 0.20,
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: ClipPath(
//               clipper: _WideShallowDome(),
//               child: Container(
//                 color: const Color(0xFFEDEEEF),
//                 padding: const EdgeInsets.fromLTRB(24, 80, 24, 24), // Reduced top padding to fit all fields
//                 child: SingleChildScrollView( // Added scrollview to prevent overflow
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Log in',
//                         style: GoogleFonts.poppins(
//                           fontSize: 26,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//
//                       // Error message
//                       if (_errorMessage.isNotEmpty)
//                         Container(
//                           padding: const EdgeInsets.all(12),
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
//                       if (_errorMessage.isNotEmpty) const SizedBox(height: 20),
//
//                       // Name Field
//                       _Field(
//                         controller: _nameController,
//                         hint: 'Full Name',
//                         focusNode: _nameFocus,
//                         isPassword: false,
//                       ),
//                       const SizedBox(height: 22),
//
//                       // User ID Field
//                       _Field(
//                         controller: _userIdController,
//                         hint: 'User ID',
//                         focusNode: _userFocus,
//                         isPassword: false,
//                       ),
//                       const SizedBox(height: 22),
//
//                       // Password Field
//                       _Field(
//                         controller: _passwordController,
//                         hint: 'Password',
//                         focusNode: _passFocus,
//                         isPassword: true,
//                       ),
//                       const SizedBox(height: 36),
//
//                       // Login Button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 58,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _handleLogin,
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
//                             'Log in',
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               letterSpacing: 0,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 40), // Bottom spacing
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
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _userIdController.dispose();
//     _passwordController.dispose();
//     _nameFocus.dispose();
//     _userFocus.dispose();
//     _passFocus.dispose();
//     super.dispose();
//   }
// }
//
// class _Field extends StatelessWidget {
//   const _Field({
//     required this.controller,
//     required this.hint,
//     required this.focusNode,
//     required this.isPassword,
//   });
//
//   final TextEditingController controller;
//   final String hint;
//   final FocusNode focusNode;
//   final bool isPassword;
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isFocused = focusNode.hasFocus;
//
//     return Container(
//       height: 58,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(
//           color: isFocused ? const Color(0xFF0F3A68) : Colors.grey.shade400,
//           width: 1.6,
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextField(
//         controller: controller,
//         focusNode: focusNode,
//         obscureText: isPassword,
//         autocorrect: false,
//         enableSuggestions: false,
//         textCapitalization: isPassword ? TextCapitalization.none : TextCapitalization.words,
//         textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: isFocused ? Colors.black : const Color(0xFF9CA3AF),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }
// }
//
// class _WideShallowDome extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     const double edgeDrop = 92.0;
//     const double crownLift = 52.0;
//
//     final path = Path()
//       ..moveTo(0, edgeDrop)
//       ..quadraticBezierTo(
//         size.width * 0.5,
//         edgeDrop - crownLift,
//         size.width,
//         edgeDrop,
//       )
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(_) => false;
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _userFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  Future<void> _handleLogin() async {
    if (_nameController.text.isEmpty ||
        _userIdController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter Name, User ID and Password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.login(
        _nameController.text.trim(),
        _userIdController.text.trim(),
        _passwordController.text,
      );

      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['data']['token']);
        await prefs.setString('user', jsonEncode(response['data']['user']));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Login failed';
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F3A68),
      body: Stack(
        children: [
          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.20,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _WideShallowDome(),
              child: Container(
                color: const Color(0xFFEDEEEF),
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Log in',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
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
                      if (_errorMessage.isNotEmpty) const SizedBox(height: 20),

                      _Field(
                        controller: _nameController,
                        hint: 'Full Name',
                        focusNode: _nameFocus,
                        isPassword: false,
                      ),
                      const SizedBox(height: 22),

                      _Field(
                        controller: _userIdController,
                        hint: 'User ID',
                        focusNode: _userFocus,
                        isPassword: false,
                      ),
                      const SizedBox(height: 22),

                      _Field(
                        controller: _passwordController,
                        hint: 'Password',
                        focusNode: _passFocus,
                        isPassword: true,
                      ),
                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
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
                            'Log in',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Create Account Link
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF0F3A68),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.focusNode,
    required this.isPassword,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode focusNode;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    final bool isFocused = focusNode.hasFocus;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isFocused ? const Color(0xFF0F3A68) : Colors.grey.shade400,
          width: 1.6,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: isPassword ? TextCapitalization.none : TextCapitalization.words,
        textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isFocused ? Colors.black : const Color(0xFF9CA3AF),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _WideShallowDome extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double edgeDrop = 92.0;
    const double crownLift = 52.0;

    final path = Path()
      ..moveTo(0, edgeDrop)
      ..quadraticBezierTo(
        size.width * 0.5,
        edgeDrop - crownLift,
        size.width,
        edgeDrop,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
