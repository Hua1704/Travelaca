import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../utils/NetworkMonitor.dart';
import 'package:travelaca/MainPage.dart';
import 'package:travelaca/MainPage.dart';

import 'OfflineSavedLocation.dart'; // Your online page file

import '../LoginScreen/LoginScreen.dart'; // Your online page file
Future<bool> checkConnection() async {
  try {
    // Check the connectivity status
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No network detected
      return false;
    }
    // Check actual internet access
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } catch (e) {
    // Handle exceptions, such as no network or DNS issues
    print("Error checking internet connection: $e");
  }
  return false; // Default to no connection if checks fail
}
class OfflineHomeScreen extends StatefulWidget {
  @override
  _OfflineHomeScreenState createState() => _OfflineHomeScreenState();
}

class _OfflineHomeScreenState extends State<OfflineHomeScreen> {
  @override
  void initState() {
    super.initState();
    //NetworkManager().startMonitoring(context, MainPage(userId: "", role: ""), OfflineHomeScreen());
  }

  @override
  void dispose() {
    //NetworkManager().stopMonitoring();
    super.dispose();
  }
  Future<void> _refresh()async {
    bool hasConnection = await checkConnection();
    if (hasConnection) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OfflineHomeScreen(), // Replace with OfflineHomepage
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Mode'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Icon(Icons.wifi_off, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No Internet Connection!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Please check your internet connection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedLocationsScreen(),
                  ),
                );
              },
              child: Text('See Saved'),
            ),
            ElevatedButton(
              onPressed: () {

                setState(() {});
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
