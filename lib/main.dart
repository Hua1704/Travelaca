import 'package:flutter/material.dart';
import 'package:travelaca/ScreenPresentation/SplashScreen/SplashScreen.dart';
import 'MainPage.dart';
import 'package:algoliasearch/algoliasearch_lite.dart';
import 'dart:convert';
void main() async {
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



