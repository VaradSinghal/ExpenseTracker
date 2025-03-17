import 'package:expense_tracker/core/services/auth_service.dart';
import 'package:expense_tracker/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<AuthService>(context, listen: false).signIn(
                  _emailController.text, _passwordController.text,
                );
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen())),
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
