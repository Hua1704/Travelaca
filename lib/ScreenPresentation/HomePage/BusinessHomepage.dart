import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelaca/Network/firebase_cloud_firesotre.dart';

import 'package:travelaca/ScreenPresentation/ViewScreen/BusinessView/BusinessViewScreen.dart';
import '../../Model/LocationClass.dart';
import '../ViewScreen/UserView/ViewScreen.dart';
class BusinessHomePage extends StatefulWidget {
  final String userId;
  final Function(Location location) onLocationSelected;

  BusinessHomePage({required this.userId, required this.onLocationSelected});

  @override
  _Businesshomepage createState() => _Businesshomepage();
}

class _Businesshomepage extends State<BusinessHomePage> {

  final User? user = FirebaseAuth.instance.currentUser;
  late List<String> locationID = [];
  bool _isLoading = true;
  Future<void> _fetchLocationIdsByOwnerId() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .where('owner_id', isEqualTo: widget.userId)
          .get();
      List<String> fetchedLocationIds = querySnapshot.docs
          .map((doc) => doc.id) // Fetch only the document ID
          .toList();
      setState(() {
        locationID = fetchedLocationIds; // Update the list of location IDs
        _isLoading = false; // Stop the loading indicator
      });
    } catch (e) {
      print('Error fetching location IDs: $e');
      setState(() {
        _isLoading = false; // Stop the loading indicator in case of an error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocationIdsByOwnerId();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/Home.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    radius: 25,

                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 18,
                  child: Text(
                    "How is \nyour business?",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white.withOpacity(0.9), // Light color at the bottom
                          Colors.transparent, // Fades out at the top
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjust the layout to place the button at the end
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "${locationID.length.toString()} locations available",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 19,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                      backgroundColor:  Color(0xFF17727F), // <-- Button color
                      foregroundColor: Colors.white, // <-- Splash color
                    ),
                    child: Icon(
                        Icons.add,
                        color: Colors.white,
                      size: 30  ,
                    ),
                  ),
                ),
              ],
            ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: locationID.length, // locationIDs is the list of IDs
        itemBuilder: (context, index) {
          final locationid = locationID[index]; // Fetch the current location ID

          return FutureBuilder<Location?>(
            future: CloudFirestore.fetchLocation(locationid), // Fetch location details
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show loading state
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                // Show error state
                return Center(
                  child: Text("Error fetching location"),
                );
              } else if (snapshot.hasData && snapshot.data != null) {

                final location = snapshot.data!;
                return GestureDetector(
                  onTap:() => widget.onLocationSelected(location),
                  child: _buildBusinesstCard(
                    location
                  ),
                );
              } else {
                // Return a fallback widget if data is null
                return SizedBox.shrink(); // An empty widget
              }
            },
          );
        },
      ),
      ],
        ),
      ),
    );
  }
  Widget _buildBusinesstCard(Location? result) {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        color: Colors.white,
        child: Row(
          children: [
            // Display the first image from the imageURL list
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: result!.imageURL.isNotEmpty ? result.imageURL.first : '',
                width: 70,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(), // Placeholder
                errorWidget: (context, url, error) => Icon(Icons.error),    // Error widget
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      result.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  }

}
