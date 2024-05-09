import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();

  void signUpUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        if (passwordController.text == confirmPasswordController.text) {
          UserCredential newUser = await _auth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
          User? user = newUser.user;
          if (user != null) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'email': emailController.text.trim(),
              'displayName': displayNameController.text.trim(),
            });
            Fluttertoast.showToast(msg: "User register success");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          }
        } else {
          Fluttertoast.showToast(msg: "Passwords do not match");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  InputDecoration getDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      fillColor: Colors.white,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up Screen"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: emailController,
                decoration: getDecoration('Email'),
                validator: (value) => value!.isEmpty ? 'Email cannot be empty' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: getDecoration('Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Password cannot be empty' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: confirmPasswordController,
                decoration: getDecoration('Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Confirm Password cannot be empty';
                  }
                  if (passwordController.text != value) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: displayNameController,
                decoration: getDecoration('Display Name'),
                validator: (value) => value!.isEmpty ? 'Display Name cannot be empty' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUpUser,
                child: Text('Sign Up'),
                style: TextButton.styleFrom(
                  primary: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())),
                child: Text('Back to Login'),
                style: TextButton.styleFrom(
                  primary: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
