import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelaca/ScreenPresentation/LoginScreen/LoginScreen.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out using FirebaseAuth
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()),
    ); // Navigate to the login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true, // Back button
        title: Text(
          "Setting",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Navigate back
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // Notification Row
          ListTile(
            title: Text("Notification"),
            trailing: Icon(Icons.notifications, color: Colors.grey),
            onTap: () {
              // Add functionality here (optional)
            },
          ),
          Divider(),

          // Country Row
          ListTile(
            title: Text("Country"),
            trailing: Text(
              "Vietnam",
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Add functionality here (optional)
            },
          ),
          Divider(),

          // Currency Row
          ListTile(
            title: Text("Currency"),
            trailing: Text(
              "VND",
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Add functionality here (optional)
            },
          ),
          Divider(),

          // Terms of Service
          ListTile(
            title: Text("Terms of Service"),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // Add functionality here (optional)
            },
          ),
          Divider(),

          // Help Center
          ListTile(
            title: Text("Help Center"),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // Add functionality here (optional)
            },
          ),
          Divider(),

          // Give Feedback
          ListTile(
            title: Text("Give Feedback"),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // Add functionality here (optional)
            },
          ),
          Divider(),

          // Log Out
          ListTile(
            title: Text("Log out"),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () => _logOut(context), // Log out functionality
          ),
          Divider(),
        ],
      ),
    );
  }
}
