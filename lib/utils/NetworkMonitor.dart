import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;

  NetworkManager._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  void startMonitoring(BuildContext context, Widget onlinePage, Widget offlinePage) {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        // Navigate to the offline page when there's no internet
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => offlinePage),
        );
      } else {
        // Check if the internet is really accessible
        bool hasInternet = await _checkInternetAccess();
        if (hasInternet) {
          // Navigate to the online page when internet is available
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => onlinePage),
          );
        }
      }
    });
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void stopMonitoring() {
    _connectivitySubscription?.cancel();
  }
}
