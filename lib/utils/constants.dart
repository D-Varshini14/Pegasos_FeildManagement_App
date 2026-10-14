// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
//
// class AppColors {
//   static const primaryBlue = Color(0xFF1E3A8A); // Deep blue from UI
//   static const lightGray = Color(0xFFF5F5F5);
//   static const darkGray = Color(0xFF6B7280);
//   static const green = Color(0xFF10B981);
//   static const orange = Color(0xFFF59E0B);
//   static const red = Color(0xFFEF4444);
// }
//
// class AppStrings {
//   static const appName = 'Pegasos';
//   static const tagline = 'INFORMATION TECHNOLOGY & SERVICES';
//
//   static String get baseUrl {
//     if (kIsWeb) return 'http://localhost:3000/api';
//     if (Platform.isAndroid)
//       return 'http://52.65.195.252:3000/api'; // Changed to PC's local IP for physical phone
//     return 'http://52.65.195.252:3000/api';
//   }
// }

import 'package:flutter/material.dart';

class AppColors {
static const primaryBlue = Color(0xFF1E3A8A);
static const lightGray = Color(0xFFF5F5F5);
static const darkGray = Color(0xFF6B7280);
static const green = Color(0xFF10B981);
static const orange = Color(0xFFF59E0B);
static const red = Color(0xFFEF4444);
}

class AppStrings {
static const appName = 'Pegasos';
static const tagline = 'INFORMATION TECHNOLOGY & SERVICES';

static const String baseUrl =
'http://52.65.195.252:3000/api';
}
