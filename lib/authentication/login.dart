import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../home.dart';
import 'signup.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser(BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = userCredential.user;
      if (user != null) {
        Fluttertoast.showToast(msg: "Login success");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(user: user)));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Screen"),
        backgroundColor: Colors.deepPurple,  // Adding color to the AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(20),  // Adds padding around the column
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,  // Stretches the column across the screen width
          children: <Widget>[
            Spacer(),  // Adds space between elements
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),  // Adds border to the TextFormField
                prefixIcon: Icon(Icons.email),  // Adds icon inside the text field
              ),
            ),
            SizedBox(height: 20),  // Adds space between text fields
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 40),  // Adds space between text field and button
            ElevatedButton(
              onPressed: () => loginUser(context),
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,  // Button color
                onPrimary: Colors.white,  // Text color
                padding: EdgeInsets.symmetric(vertical: 15),  // Button padding
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignUpPage())),
              child: Text('Sign Up'),
              style: TextButton.styleFrom(
                primary: Colors.deepPurple,  // Text color
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
