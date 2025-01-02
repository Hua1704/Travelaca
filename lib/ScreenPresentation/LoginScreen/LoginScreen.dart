import 'package:flutter/material.dart';
import 'package:travelaca/MainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Network/auth.dart';
import '../../Network/firebase_cloud_firesotre.dart';
import '../OfflineScreen/OfflineHome.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(); // Controller for email
  final _passwordController = TextEditingController(); // Controller for password
  final Auth _auth = Auth(); // Instance of your Auth class
  bool _isLoading = false; // Loading state

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Sign in using email and password
      await _auth.signInWithEmalAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the logged-in user's Firebase UID
      final User? user = _auth.currentUser;

      if (user != null) {
        // Fetch user data from Firestore
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final String role = data["role"] ?? "Traveller";

          // Navigate to the MainPage with the userId and role
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainPage(
                userId: user.uid, // Pass the user ID
                role: role, // Pass the user role
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("User data not found. Please contact support."),
          ));
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? "An error occurred"),
      ));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }
  // For loading indicator
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              Row (
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Log in',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),],
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Background color of the TextField
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color with opacity
                      spreadRadius: 2, // How far the shadow spreads
                      blurRadius: 5, // How blurry the shadow is
                      offset: Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Mail",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white, // Fill color inside the TextField
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Background color of the TextField
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color with opacity
                      spreadRadius: 2, // How far the shadow spreads
                      blurRadius: 5, // How blurry the shadow is
                      offset: Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                ),
                child: _buildTextField(controller: _passwordController,
                    hintText: 'Password', obscureText: true
                )
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor:  Color(0xFF17727F),
                ),
                child: Text(
                  'Log in',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Or log in using',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/google.png', // Path to your Google icon image
                      height: 24, // Adjust the size of the icon
                      width: 24,
                    ),
                    label: Text('Google',
                      style: TextStyle(
                        color: Colors.black,
                      ),),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(170, 50), // Width: 170, Height: 50
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.facebook_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    label: Text('Facebook',
                      style: TextStyle(
                        color: Colors.white,
                      ),),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(170, 50), // Width: 120, Height: 50
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        backgroundColor: Colors.blueAccent// Adjust padding
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  bool hasConnection = await checkConnection();
                  if (hasConnection) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen()));
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OfflineHomeScreen(), // Replace with OfflineHomepage
                      ),
                    );
                  }

                },
                child: Text("Don't have an account yet? Sign up",
                  style: TextStyle(
                      color: Color(0xFF17727F)
                  ),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool hasConnection = await checkConnection();
                  if (hasConnection) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(
                          userId: "", // Pass the user ID
                          role: "", // Pass the user role
                        ),
                      ),);
                  }
                  else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OfflineHomeScreen(), // Replace with OfflineHomepage
                      ),
                    );
                  }

                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
                child: Text('Continue as Guest',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String selectedRole = ""; // Role (Traveller or Business Owner)

  final Auth _auth = Auth(); // Instance of Auth class
  final CloudFirestore _firestore = CloudFirestore(); // Instance of CloudFirestore class

  bool _isLoading = false; // For loading indicator

  // Function to sign up
  Future<void> _signUp() async {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select a role before signing up."),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with email and password
      await _auth.createUserWithEmalAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user details to Firestore
      final User? user = _auth.currentUser;
      if (user != null) {
        final userData = {
          "address": "", // Empty by default
          "avatar_url": user.photoURL ?? "",
          "date_of_birth": "",
          "email": user.email ?? "",
          "last_10_searched": [],
          "last_viewed_algolia_id": [],
          "phone": "",
          "user_id": user.uid,
          "username": '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}', // Full name as username
          "role": selectedRole,
        };

        // Save userData to Firestore
        await _firestore.db.collection("Users").doc(user.uid).set(userData);

        // Navigate to the main page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage(
            userId: user.uid,
            role: selectedRole,
          )), // Replace with your main screen
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? "An error occurred"),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the login screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Sign up',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 30),
              _buildTextField(
                controller: _firstNameController,
                hintText: "First Name",
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _lastNameController,
                hintText: "Last Name",
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                hintText: "Mail",
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Choose your role'),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text('Traveller'),
                    selected: selectedRole == "Traveller",
                    onSelected: (selected) {
                      setState(() {
                        selectedRole = selected ? "Traveller" : "";
                      });
                    },
                    selectedColor: Color(0xFF17727F),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selectedRole == "Traveller" ? Colors.white : Color(0xFF17727F),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(width: 20),
                  ChoiceChip(
                    label: Text('Business Owner'),
                    selected: selectedRole == "Business Owner",
                    onSelected: (selected) {
                      setState(() {
                        selectedRole = selected ? "Business Owner" : "";
                      });
                    },
                    selectedColor: Color(0xFF17727F),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selectedRole == "Business Owner" ? Colors.white : Color(0xFF17727F),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Color(0xFF17727F),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Link your account with'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Google sign-up
                    },
                    icon: Image.asset(
                      'assets/images/google.png',
                      height: 24,
                      width: 24,
                    ),
                    label: Text(
                      'Google',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(170, 50),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Facebook sign-up
                    },
                    icon: Icon(
                      Icons.facebook_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    label: Text(
                      'Facebook',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(170, 50),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the login screen
                },
                child: Text(
                  'Already have an account? Sign in',
                  style: TextStyle(
                    color: Color(0xFF17727F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}