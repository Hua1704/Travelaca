import 'package:flutter/material.dart';
import 'package:travelaca/ScreenPresentation/SearchScreen/SearchPage.dart';
import 'package:travelaca/ScreenPresentation/HomePage/HomepageScreen.dart';
import 'package:travelaca/ScreenPresentation/SplashScreen/SplashScreen.dart';
import 'package:travelaca/ScreenPresentation/ReviewScreen//ReviewScreen.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/UserView/ViewScreen.dart';
import 'package:travelaca/ScreenPresentation/AccountScreen/Account.dart';

import 'ScreenPresentation/AccountScreen/GuestSettings.dart';
final GlobalKey<_MainPageState> mainPageKey = GlobalKey<_MainPageState>();
class MainPage extends StatefulWidget {
  final String userId; // Firebase User ID
  final String role; // User role (Traveller or Business)

  MainPage({required this.userId, required this.role});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Track the selected tab index.
  final List<int> _history = []; // Track the navigation history.
  String selectedName = '';
  String selectedAddress = '';
  String selectedCategory = '';
  double selectedStars = 0.0;
  int selectedReviewCount = 0;
  bool selectedStatus = false;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Dynamically initialize pages based on role or guest
    if (widget.role == "" || widget.userId == "") {
      // Guest user: Limited access
      _pages = [
        HomeScreen(onSearchTapped: () => onItemTapped(1)),
        SearchPage(),
        GuestSettingsScreen(), // Navigate to Guest Settings Screen
      ];
    }
    else if (widget.role == "Traveller") {
      // Traveller role
      _pages = [
        HomeScreen(onSearchTapped: () => onItemTapped(1)),
        SearchPage(),
        ReviewScreen(),
        AccountScreen(userId: widget.userId!), // Pass userId to AccountScreen
      ];
    } else if (widget.role == "Business Owner") {
      // Business role
      _pages = [
        HomeScreen(onSearchTapped: () => onItemTapped(1)),
        SearchPage(),
        //BusinessDashboardScreen(), // Custom page for Business role
        AccountScreen(userId: widget.userId!), // Pass userId to AccountScreen
      ];
    }
  }

  void onItemTapped(int index) {
    // Add the current index to the history before switching tabs.
    if (_selectedIndex != index) {
      _history.add(_selectedIndex);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateBack() {
    if (_history.isNotEmpty) {
      setState(() {
        _selectedIndex = _history.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Use dynamically configured pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal.shade300,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          if (widget.role == "Traveller")
            BottomNavigationBarItem(icon: Icon(Icons.visibility), label: "View")
          else if(widget.role=="Business Owner")
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
        ],
      ),
    );
  }
}
