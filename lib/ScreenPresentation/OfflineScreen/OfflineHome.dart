import 'package:flutter/material.dart';
import '../../utils/NetworkMonitor.dart';
import 'package:travelaca/MainPage.dart'; // Your online page file

class OfflineHomeScreen extends StatefulWidget {
  @override
  _OfflineHomeScreenState createState() => _OfflineHomeScreenState();
}

class _OfflineHomeScreenState extends State<OfflineHomeScreen> {
  @override
  void initState() {
    super.initState();
    NetworkManager().startMonitoring(context, MainPage(userId: "", role: ""), OfflineHomeScreen());
  }

  @override
  void dispose() {
    NetworkManager().stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                // Force refresh to check connection
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
