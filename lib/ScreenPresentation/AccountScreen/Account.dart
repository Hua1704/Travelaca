import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelaca/ScreenPresentation/AccountScreen/Settings.dart';
class AccountScreen extends StatelessWidget {
  final String userId; // Firebase user ID

  AccountScreen({required this.userId});

  Future<Map<String, dynamic>> _getUserData() async {
    final DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection("Users").doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception("User not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(), // Fetch user data from Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Loading state
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}")); // Error state
        }

        if (!snapshot.hasData) {
          return Center(child: Text("No user data available")); // No data state
        }

        // Extract user data from Firestore
        final userData = snapshot.data!;
        final String username = userData["username"] ?? "User";
        final String avatarUrl = userData["avatar_url"] ?? "";
        final String email = userData["email"] ?? "";
        final String phone = userData["phone"] ?? "";

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () {
                  FirebaseAuth.instance.signOut(); // Logout logic
                  Navigator.pushReplacementNamed(context, "/login");
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username, // Display the username
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            // Handle edit profile logic here
                          },
                          child: Row(
                            children: [
                              Text(
                                "View and edit your profile",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.edit, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 40,
                      //backgroundImage: NetworkImage(avatarUrl), // Display the user's avatar
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Menu Options
                ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.teal),
                  title: Text("Change password"),
                  onTap: () {
                    // Handle change password logic here
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.payment_outlined, color: Colors.teal),
                  title: Text("Payment"),
                  onTap: () {
                    // Handle payment logic here
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.favorite_border, color: Colors.teal),
                  title: Text("Saved Locations"),
                  onTap: () {
                    // Handle saved locations logic here
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings_outlined, color: Colors.teal),
                  title: Text("Settings"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(), // Navigate to the Settings Screen
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
