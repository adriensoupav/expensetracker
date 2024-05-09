import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expensetracker/authentication/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyAskiJZy8uwvv_ys2sXOC-KwtxZKTL8R88',
          appId: '1:1084371519631:android:1c205d8955f7c7958048fa',
          messagingSenderId: '1084371519631',
          projectId: 'expensetracker-c97ca',
          storageBucket: 'expensetracker-c97ca.appspot.com',
      )

  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      home: SignUpPage(),
    );
  }
}