import 'package:expensetracker/analytics.dart';
import 'package:expensetracker/expenses.dart';
import 'package:expensetracker/viewer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/authentication/login.dart';

class HomePage extends StatelessWidget {
  final User user;

  HomePage({required this.user});

  Future<String?> getDisplayName() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    var userData = userDoc.data() as Map<String, dynamic>?;
    return userData?['displayName'];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String?>(
            future: getDisplayName(),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Text("Welcome, ${snapshot.data ?? 'User'}", style: TextStyle(fontWeight: FontWeight.bold));
              } else {
                return Text("Loading...", style: TextStyle(fontStyle: FontStyle.italic));
              }
            },
          ),
          backgroundColor: Colors.deepPurple,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.account_balance_wallet), text: "Add Expenses"),
              Tab(icon: Icon(Icons.visibility), text: "Viewer"),
              Tab(icon: Icon(Icons.analytics), text: "Analytics"),
            ],
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            expenses(user: user),
            Viewer(user: user),
            Analytics(user: user),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.deepPurple[50],
          padding: EdgeInsets.symmetric(vertical: 8),

            child: Text(
              "Connected as ${user.email}",
              style: TextStyle(fontSize: 16, color: Colors.deepPurple),
            ),

        ),
      ),
    );
  }
}
