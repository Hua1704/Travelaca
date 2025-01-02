import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelaca/ScreenPresentation/HomePage/BusinessHomepage.dart';
import 'package:travelaca/ScreenPresentation/SearchScreen/SearchPage.dart';
import 'package:travelaca/ScreenPresentation/HomePage/HomepageScreen.dart';
import 'package:travelaca/ScreenPresentation/SplashScreen/SplashScreen.dart';
import 'package:travelaca/ScreenPresentation/ReviewScreen/ReviewScreen.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/UserView/ViewScreen.dart';
import 'package:travelaca/ScreenPresentation/AccountScreen/Account.dart';
import 'package:travelaca/utils/NetworkMonitor.dart';
import 'Model/LocationClass.dart';
import 'ScreenPresentation/AccountScreen/GuestSettings.dart';
import 'ScreenPresentation/OfflineScreen/OfflineHome.dart';
import 'ScreenPresentation/ViewScreen/BusinessView/BusinessViewScreen.dart';

class MainPage extends StatefulWidget {
  final String userId; // Firebase User ID
  final String role; // User role (Traveller, Business Owner, or Guest)

  MainPage({required this.userId, required this.role});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Track the selected tab index.
  final PageController _pageController = PageController(); // Controller for navigation
  Location? selectedLocation; // Store the selected location

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    if (widget.role.isEmpty || widget.userId.isEmpty) {
      _pages = [
        HomeScreen(onSearchTapped: () => onItemTapped(1)),
        SearchPage(),
        GuestSettingsScreen(),
      ];
    } else if (widget.role == "Traveller") {
      // Traveller
      _pages = [
        HomeScreen(onSearchTapped: () => onItemTapped(1)),
        SearchPage(),
        ReviewScreen(),
        AccountScreen(userId: widget.userId),
      ];
    } else if (widget.role == "Business Owner") {
      // Business Owner
      _pages = [
        BusinessHomePage(
          userId: widget.userId,
          onLocationSelected: (location) {
            setState(() {
              selectedLocation = location;
              _selectedIndex = 1; // Dashboard tab index
            });
            onItemTapped(1);
          },
        ),
        Builder(
          builder: (context) => BusinessDashboardScreen(location: selectedLocation),
        ),
        AccountScreen(userId: widget.userId),
      ];
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Prevent swiping between pages
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal.shade300,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
        items: [
          if (widget.role.isEmpty || widget.userId.isEmpty) ...[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
          ] else if (widget.role == "Traveller") ...[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: "Review"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
          ] else if (widget.role == "Business Owner") ...[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
          ]
        ],
      ),
    );
  }
}




// Dummy Location Class

