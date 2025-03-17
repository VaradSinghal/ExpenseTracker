import 'package:expense_tracker/core/services/auth_service.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    checkEmailVerification();
  }

  Future<void> checkEmailVerification() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    bool verified = await authService.isEmailVerified();
    setState(() {
      isVerified = verified;
    });
    if (isVerified) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Center(
        child: isVerified
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Please verify your email before continuing.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: checkEmailVerification,
                    child: Text('I have verified'),
                  ),
                ],
              ),
      ),
    );
  }
}