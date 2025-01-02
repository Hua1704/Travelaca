import 'package:flutter/material.dart';
import 'package:travelaca/ScreenPresentation/HomePage/HomepageScreen.dart';
import 'package:travelaca/ScreenPresentation/SearchScreen/SearchPage.dart';
import 'package:travelaca/MainPage.dart';
import 'package:travelaca/ScreenPresentation/LoginScreen/LoginScreen.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/Splash.png', // Replace with your image path
            fit: BoxFit.cover,
          ),
          // Gradient overlay (optional, for better text visibility)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Text and button overlay
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 250), // Adjust top padding
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white, // First color
                        Colors.blueGrey,  // Second color
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Travelaca',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Required by ShaderMask
                      fontFamily: 'OleoScriptSwashCaps', // Your custom font
                    ),
                  ),
                ),
              ),
              // Add other components or spacers here if needed
            ],
          ),
          Container(
            width: 300,
            height: 600,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  Colors.white.withOpacity(0.8), // Light color at the bottom
                  Colors.transparent, // Fades out at the top
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 600,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Ready to explore\nbeyond boundaries?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 8,
                              offset: Offset(0, 0),
                            ),
                          ]
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                      },
                      icon: const Icon(Icons.flight_takeoff),
                      label: const Text('Your Journey Starts Here'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

