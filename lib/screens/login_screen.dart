import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'admin_home_screen.dart';
import 'manager_home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _employeeIdFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  static const Color primaryBlue = Color(0xFF0F3A68);

  @override
  void initState() {
    super.initState();
    _employeeIdFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  Future<void> _handleLogin() async {
    if (_employeeIdController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter Employee ID and Password');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final response = await ApiService.login(
        '',
        _employeeIdController.text.trim(),
        _passwordController.text,
      );

      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['data']['token']);
        await prefs.setString('user', jsonEncode(response['data']['user']));

        if (mounted) {
          // REQ #2: Route based on role
          final userData = response['data']['user'];
          final role = userData['role'] ?? 'field_executive';

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                if (role == 'admin') return const AdminHomeScreen();
                if (role == 'manager') return const ManagerHomeScreen();
                return HomeScreen();
              },
            ),
          );
        }
      } else {
        setState(() => _errorMessage = response['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Please check your connection.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // REQ #1 — Forgot Password Dialog (2-step OTP flow)
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final otpController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool isLoading = false;
    String message = '';
    bool isSuccess = false;
    bool isError = false;
    int step = 1; // Step 1: email, Step 2: OTP + new password
    String resetEmail = '';
    bool obscureNew = true;
    bool obscureConfirm = true;
    Timer? countdownTimer;
    int secondsRemaining = 300;

    void startTimer(StateSetter setDialogState) {
      secondsRemaining = 300;
      countdownTimer?.cancel();
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (secondsRemaining > 0) {
          setDialogState(() {
            secondsRemaining--;
          });
        } else {
          timer.cancel();
        }
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  step == 1 ? Icons.email_outlined : Icons.lock_reset,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step == 1 ? 'Forgot Password' : 'Reset Password',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step == 1) ...[
                  // ── STEP 1: Enter Email ──
                  Text(
                    'Enter your registered email address. We\'ll send you a 6-digit reset code.',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ] else ...[
                  // ── STEP 2: Enter OTP + New Password ──
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: primaryBlue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Code sent to $resetEmail',
                                style: GoogleFonts.poppins(fontSize: 12, color: primaryBlue),
                              ),
                              if (secondsRemaining > 0)
                                Text(
                                  'Expires in: ${secondsRemaining ~/ 60}:${(secondsRemaining % 60).toString().padLeft(2, '0')}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade700, fontWeight: FontWeight.bold),
                                )
                              else
                                Text(
                                  'Code expired',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                ),
                              const SizedBox(height: 4),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () async {
                                  setDialogState(() { message = 'Resending...'; isError = false; });
                                  final res = await ApiService.resendOtp(resetEmail);
                                  setDialogState(() {
                                    message = res['message'] ?? 'Code resent';
                                    isError = res['success'] != true;
                                    if (!isError) startTimer(setDialogState);
                                  });
                                },
                                child: Text('Resend Code', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // OTP field
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '6-digit code',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.pin_outlined, color: Colors.grey),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // New password
                  TextField(
                    controller: newPassController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      hintText: 'New password (8+ chars, upper, lower, num, special)',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 10),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.grey[400], size: 20,
                        ),
                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  // Confirm password
                  TextField(
                    controller: confirmPassController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.grey[400], size: 20,
                        ),
                        onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],

                // ── Status message ──
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isError ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isError ? Colors.red.shade300 : Colors.green.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isError ? Icons.error_outline : Icons.check_circle_outline,
                          color: isError ? Colors.red : Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isError ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            // Back/Cancel button
            TextButton(
              onPressed: () {
                if (step == 2 && !isSuccess) {
                  setDialogState(() {
                    step = 1;
                    message = '';
                    isError = false;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                step == 2 && !isSuccess ? 'Back' : 'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            // Action button
            if (!isSuccess)
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (step == 1) {
                          // ── Step 1: Send OTP ──
                          if (emailController.text.trim().isEmpty) {
                            setDialogState(() { message = 'Please enter your email'; isError = true; });
                            return;
                          }
                          setDialogState(() { isLoading = true; message = ''; isError = false; });

                          final response = await ApiService.forgotPassword(
                            emailController.text.trim(),
                          );

                          if (response['success'] == true) {
                            resetEmail = emailController.text.trim();
                            // In dev mode, auto-fill OTP
                            final devOtp = response['data']?['otp'];
                            if (devOtp != null) {
                              otpController.text = devOtp.toString();
                            }
                            setDialogState(() {
                              isLoading = false;
                              step = 2;
                              message = response['message'] ?? 'Code sent!';
                              isError = false;
                              startTimer(setDialogState);
                            });
                          } else {
                            setDialogState(() {
                              isLoading = false;
                              message = response['message'] ?? 'Failed to send code';
                              isError = true;
                            });
                          }
                        } else {
                          // ── Step 2: Verify OTP + Reset Password ──
                          if (otpController.text.trim().isEmpty) {
                            setDialogState(() { message = 'Please enter the 6-digit code'; isError = true; });
                            return;
                          }
                          if (newPassController.text.isEmpty) {
                            setDialogState(() { message = 'Please enter a new password'; isError = true; });
                            return;
                          }
                          final RegExp pwdRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                          if (!pwdRegExp.hasMatch(newPassController.text)) {
                            setDialogState(() { message = 'Password must be 8+ chars with upper, lower, number, and special char'; isError = true; });
                            return;
                          }
                          if (newPassController.text != confirmPassController.text) {
                            setDialogState(() { message = 'Passwords do not match'; isError = true; });
                            return;
                          }
                          setDialogState(() { isLoading = true; message = ''; isError = false; });

                          final response = await ApiService.resetPassword(
                            resetEmail,
                            otpController.text.trim(),
                            newPassController.text,
                          );

                          setDialogState(() {
                            isLoading = false;
                            isSuccess = response['success'] == true;
                            isError = !isSuccess;
                            message = response['message'] ?? 'Something went wrong';
                          });

                          if (isSuccess) {
                            await Future.delayed(const Duration(seconds: 2));
                            if (context.mounted) Navigator.pop(context);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        step == 1 ? 'Send Code' : 'Reset Password',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
              ),
          ],
        ),
      ),
    ).then((_) {
      countdownTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          // Logo / Title area
          Positioned(
            top: size.height * 0.08,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(Icons.business_center, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Pegasos',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Field Management',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // White card area
          Positioned(
            top: size.height * 0.28,
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
                        'Welcome Back',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Error message
                      if (_errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: GoogleFonts.poppins(
                                    color: Colors.red.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Employee ID Field
                      _Field(
                        controller: _employeeIdController,
                        hint: 'Employee ID (e.g., EMP001)',
                        focusNode: _employeeIdFocus,
                        isPassword: false,
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      _Field(
                        controller: _passwordController,
                        hint: 'Password',
                        focusNode: _passFocus,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 8),

                      // REQ #1 — Forgot Password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : Text(
                                  'Log In',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Create account
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey.shade700),
                            children: [
                              TextSpan(
                                text: 'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: primaryBlue,
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
    _employeeIdController.dispose();
    _passwordController.dispose();
    _employeeIdFocus.dispose();
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
    this.prefixIcon,
    this.obscureText = false,
    this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode focusNode;
  final bool isPassword;
  final IconData? prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;

  static const Color primaryBlue = Color(0xFF0F3A68);

  @override
  Widget build(BuildContext context) {
    final bool isFocused = focusNode.hasFocus;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isFocused ? primaryBlue : Colors.grey.shade300,
          width: 1.6,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword ? obscureText : false,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  color: isFocused ? primaryBlue : Colors.grey[400], size: 20)
              : null,
          suffixIcon: isPassword && onToggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
      ..quadraticBezierTo(size.width * 0.5, edgeDrop - crownLift, size.width, edgeDrop)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
