// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_core/firebase_core.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'screens/splash_screen.dart';
// // // import 'screens/login_screen.dart';
// // // import 'screens/home_screen.dart';
// // // import 'utils/constants.dart';
// // //
// // // void main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   await Firebase.initializeApp();
// // //   runApp(MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: 'Pegasos Field Management',
// // //       debugShowCheckedModeBanner: false,
// // //       theme: ThemeData(
// // //         primarySwatch: Colors.blue,
// // //         primaryColor: AppColors.primaryBlue,
// // //         fontFamily: 'SF Pro Display',
// // //       ),
// // //       home: SplashScreen(),
// // //       routes: {
// // //         '/login': (context) => LoginScreen(),
// // //         '/home': (context) => HomeScreen(),
// // //       },
// // //     );
// // //   }
// // // }
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:google_fonts/google_fonts.dart';
// //
// // // Screens
// // import 'screens/splash_screen.dart';
// // import 'screens/login_screen.dart';
// // import 'screens/home_screen.dart';
// //
// // // Utils
// // import 'utils/constants.dart';
// //
// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   // ✅ Initialize Firebase
// //   await Firebase.initializeApp();
// //
// //   // ✅ Make status bar transparent
// //   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
// //     statusBarColor: Colors.transparent,
// //     statusBarIconBrightness: Brightness.light,
// //     statusBarBrightness: Brightness.dark,
// //   ));
// //
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Pegasos Field Management',
// //       debugShowCheckedModeBanner: false,
// //
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //         primaryColor: AppColors.primaryBlue,
// //         textTheme: GoogleFonts.poppinsTextTheme(),
// //         fontFamily: 'SF Pro Display',
// //       ),
// //
// //       home: const SplashScreen(),
// //
// //       routes: {
// //         '/login': (context) => const LoginScreen(),
// //         '/home': (context) => const HomeScreen(),
// //       },
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// // Screens
// import 'screens/splash_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';
//
// // Utils
// import 'utils/constants.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // ✅ Initialize Firebase
//   await Firebase.initializeApp();
//
//   // ✅ Make status bar transparent
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.light,
//     statusBarBrightness: Brightness.dark,
//   ));
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Pegasos Field Management',
//       debugShowCheckedModeBanner: false,
//       //
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         primaryColor: AppColors.primaryBlue,
//         textTheme: GoogleFonts.poppinsTextTheme(),
//         fontFamily: 'SF Pro Display',
//       ),
//
//       home: const SplashScreen(),
//
//       routes: {
//         '/login': (context) => const LoginScreen(),
//         '/home': (context) => HomeScreen(), // Removed const keyword
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// Utils
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Make status bar transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pegasos Field Management',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primaryBlue,
        textTheme: GoogleFonts.poppinsTextTheme(),
        fontFamily: 'SF Pro Display',
      ),

      home: const SplashScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}