
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelaca/ScreenPresentation/SplashScreen/SplashScreen.dart';
import 'MainPage.dart';
import 'package:algoliasearch/algoliasearch_lite.dart';
import 'dart:convert';
import 'firebase_options.dart';
Future<bool> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false; // Permissions are denied
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever
    return false;
  }
  return true;
}
void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  bool hasPermission = await requestLocationPermission();
  if (!hasPermission) {
    print("Location permission not granted. The app might not function correctly.");
  }// Ensures all bindings are initialized before app start
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  SplashScreen(), // Set SplashScreen as the home widget
    );
  }
}



