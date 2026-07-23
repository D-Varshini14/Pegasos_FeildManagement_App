import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_home_screen.dart';
import 'manager_home_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // ✅ constructor made const

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }
  //
  // Future<void> _navigateToNextScreen() async {
  //   await Future.delayed(const Duration(seconds: 2));
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //
  //   if (token != null) {
  //     Navigator.pushReplacementNamed(context, '/home');
  //   } else {
  //     Navigator.pushReplacementNamed(context, '/login');
  //   }
  // }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userStr = prefs.getString('user');
      
      if (token != null && userStr != null) {
        final userData = jsonDecode(userStr);
        final role = userData['role'] ?? 'field_executive';
        
        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
          } else if (role == 'manager') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManagerHomeScreen()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          }
          return;
        }
      }
    } catch (_) {}
    
    // Always navigate to login page if no token
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F3A68),
      body: SafeArea(
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -30), // Move everything 30px upward
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                SizedBox(
                  width: size.width * 0.30,
                  child: Image.asset(
                    'assets/images/pegasus_logo.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(height: 5),

                // App Name
                Text(
                  'Pegasos',
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Tagline
                Text(
                  'INFORMATION TECHNOLOGY & SERVICES',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 2.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
