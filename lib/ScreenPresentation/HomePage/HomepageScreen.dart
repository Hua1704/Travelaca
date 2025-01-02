import 'dart:async';

import 'package:algolia_client_recommend/algolia_client_recommend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelaca/ScreenPresentation/SearchScreen/SearchPage.dart';
import 'package:travelaca/Network/firebase_cloud_firesotre.dart';
import 'package:geolocator/geolocator.dart';
import '../../Model/LocationClass.dart';
import '../OfflineScreen/OfflineHome.dart';
import '../ViewScreen/UserView/ViewScreen.dart';
import 'package:travelaca/utils/NetworkMonitor.dart';
  class HottestTrend {
    final String? imageLink;
    final String? title;
    HottestTrend({this.imageLink, this.title});
  }
class HomeScreen extends StatefulWidget {
  late final VoidCallback onSearchTapped;
  HomeScreen({required this.onSearchTapped});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>{
  late Future<List<Map<String, dynamic>>> _recommendationsFuture;
  final CloudFirestore _locationService = CloudFirestore();
  bool isOnline = true; // Tracks online/offline state
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  void initState() {
    super.initState();
    _recommendationsFuture = CloudFirestore().fetchRecommendationsForUser();
  }
  Future<void> saveLastViewedBusiness(String businessId) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      // Reference to the user's Firestore document
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
      // Get the current last_viewed_algolia_id array
      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        List<dynamic> lastViewedList = userDoc.data()?['last_viewed_algolia_id'] ?? [];
        lastViewedList = List<String>.from(lastViewedList); // Cast to List<String>

        // Add the new business ID and trim the list to the last 3 items
        lastViewedList.insert(0, businessId); // Add the new business ID at the start
        if (lastViewedList.length > 3) {
          lastViewedList = lastViewedList.sublist(0, 3); // Keep only the last 3
        }

        // Update Firestore
        await userDocRef.update({'last_viewed_algolia_id': lastViewedList});
      } else {
        // If the user document does not exist, create one with the business ID
        await userDocRef.set({
          'last_viewed_algolia_id': [businessId],
        });
      }
    } catch (e) {
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Home.png'), // Replace with your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    radius: 25,// Replace with your profile image
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.white.withOpacity(0.9), // Light color at the bottom
                          Colors.transparent, // Fades out at the top
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30), // Ensures ripple effect respects shape
                      onTap: widget.onSearchTapped,
                      child: TextField(
                        enabled: false, // Disable the text field so it doesn't open the keyboard
                        decoration: InputDecoration(
                          hintText: "Search your destination",
                          prefixIcon: Icon(Icons.search, color:  Color(0xFF17727F) ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recommended Places",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("See All",
                    style: TextStyle(
                        color: Color(0xFF17727F),
                    ),),
                  ),
                ],
              ),
            ),
            Container(
              height: 180, // Height of the horizontal list
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _recommendationsFuture, // Fetch recommendations dynamically
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show loading spinner
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}')); // Show error message
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final recommendations = snapshot.data!;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final location = recommendations[index];
                        return placeCard(
                          location['name'] ?? 'Unknown Place',
                          location['address'] ?? 'Unknown place',
                          // Distance from the user
                          location['image_urls'] != null && location['image_urls'].isNotEmpty
                              ? location['image_urls'][0] // Use the first image in the list
                              : 'assets/images/default_image.jpg',
                            (location['stars'] ?? 0.0).toDouble(),
                          location['id'] ?? '',

                          //location['stars'] ?? 0
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No recommendations found.')); // No data available
                  }
                },
              ),
            ),

            SizedBox(height: 20),
            // Hottest Trend Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Promotion",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("See All",
                    style: TextStyle(
                      color: Color(0xFF17727F),
                    )),
                  ),
                ],
              ),
            ),
            _buildHottestTrend(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Future<List<HottestTrend>> fetchDummyHottestTrend() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate a network delay
    return List.generate(
      4,
          (index) => HottestTrend(
        imageLink: 'assets/images/beach$index.jpg',
        title: 'Promotion $index',
      ),
    );
  }
  Widget _buildHottestTrend() {
    return FutureBuilder(
      future: fetchDummyHottestTrend(), // Using dummy data
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: 160, // Adjust based on card height
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Image Section
                      ClipRRect(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
                        child: Image.asset(
                          snapshot.data![index].imageLink!,
                          width: 120,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Information Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data![index].title ?? "Promotion",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Sample description goes here.",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "4.5", // Example rating
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 14),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget placeCard(String title,String address, String imagePath, double stars, String id) {
        return GestureDetector(
          onTap: () async {
            bool hasConnection = await checkConnection();
            if (hasConnection) {
              saveLastViewedBusiness(id);
              final location = await CloudFirestore.fetchLocation(id);
              if (location != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewScreenSearch(location: location),
                  ),
                );
              }
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OfflineHomeScreen(), // Replace with OfflineHomepage
                ),
              );
            }

          },
          child: Container(
            width: 180,
            height: 202,
            margin: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: imagePath.isNotEmpty
                    ? NetworkImage(imagePath)
                    : AssetImage('assets/images/default_image.jpg') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8), // White transparent background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                            ),

                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < stars ? Icons.star : Icons.star_border,
                              color: index < stars ? Color(0xFF17727F) : Colors.grey,
                              size: 12,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );


  }

}


