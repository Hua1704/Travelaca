import 'package:flutter/material.dart';
import 'package:travelaca/ScreenPresentation/SearchScreen/SearchPage.dart';
import 'package:travelaca/ScreenPresentation/HomePage/HomepageScreen.dart';
import 'package:travelaca/ScreenPresentation/SplashScreen/SplashScreen.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/UserView/ViewScreen.dart';
final GlobalKey<_MainPageState> mainPageKey = GlobalKey<_MainPageState>();
class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: mainPageKey);
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
  final List<Widget> _pages = [];
  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomeScreen(onSearchTapped: () => onItemTapped(1)),
      SearchPage(),
      ReviewScreen(),
      AccountScreen(),
    ]);
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
        children: [
          HomeScreen(onSearchTapped: () => onItemTapped(1)),
          SearchPage(),
          ReviewScreen(),
          AccountScreen(),
        ],
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
          BottomNavigationBarItem(icon: Icon(Icons.visibility), label: "View"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
        ],
      ),
    );
  }
}