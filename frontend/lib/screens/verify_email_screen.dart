// import 'package:expense_tracker/core/services/auth_service.dart';
// import 'package:expense_tracker/screens/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   @override
//   _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   bool _isVerified = false;
//   bool _isChecking = true;
//   bool _isResending = false;

//   @override
//   void initState() {
//     super.initState();
//     checkEmailVerification();
//   }

//   Future<void> checkEmailVerification() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     bool verified = await authService.isEmailVerified();
//     setState(() {
//       _isVerified = verified;
//       _isChecking = false;
//     });

//     if (_isVerified) {
//       Navigator.pushReplacement(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(opacity: animation, child: child);
//           },
//         ),
//       );
//     }
//   }

//   Future<void> resendVerificationEmail() async {
//     setState(() => _isResending = true);
//     await Provider.of<AuthService>(context, listen: false).currentUser?.sendEmailVerification();
//     setState(() => _isResending = false);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Verification email sent! Please check your inbox.'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF1E1E2C), 
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.0),
//           child: Card(
//             color: Color(0xFF2A2A3A),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             elevation: 10,
//             child: Padding(
//               padding: EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.email, size: 80, color: Colors.greenAccent),
//                   SizedBox(height: 20),
//                   _isChecking
//                       ? Column(
//                           children: [
//                             CircularProgressIndicator(color: Colors.greenAccent),
//                             SizedBox(height: 10),
//                             Text(
//                               "Checking email verification...",
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
//                             ),
//                           ],
//                         )
//                       : Column(
//                           children: [
//                             Text(
//                               "Please verify your email before continuing.",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//                             ),
//                             SizedBox(height: 20),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.greenAccent,
//                                 minimumSize: Size(double.infinity, 50),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               ),
//                               onPressed: checkEmailVerification,
//                               child: Text(
//                                 "I have verified",
//                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//                               ),
//                             ),
//                             SizedBox(height: 15),
//                             TextButton(
//                               onPressed: _isResending ? null : resendVerificationEmail,
//                               child: _isResending
//                                   ? CircularProgressIndicator(color: Colors.greenAccent)
//                                   : Text(
//                                       "Resend verification email",
//                                       style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
//                                     ),
//                             ),
//                           ],
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
