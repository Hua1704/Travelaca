import 'package:algoliasearch/algoliasearch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelaca/Network/firebase_cloud_firesotre.dart';
import 'package:travelaca/ScreenPresentation/HomePage/AddLocation.dart';

import 'package:travelaca/ScreenPresentation/ViewScreen/BusinessView/BusinessViewScreen.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/BusinessView/EditLocation.dart';
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
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Locations').where('owner_id', isEqualTo: widget.userId).snapshots(), // Real-time updates from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, show a placeholder or loading indicator
            return Text(
              "Loading locations...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 19,
              ),
            );
          } else if (snapshot.hasError) {
            // Show error message if there's an error
            return Text(
              "Error fetching locations",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 19,
              ),
            );
          } else if (snapshot.hasData) {
            // Display the number of locations based on the query snapshot
            final locationCount = snapshot.data!.docs.length;
            return Text(
              "$locationCount locations available",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 19,
              ),
            );
          } else {
            // Fallback text if no data is available
            return Text(
              "No locations available",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 19,
              ),
            );
          }
        },
      ),
    ),

            Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddLocationScreen(userID: widget.userId), // Navigate to the Settings Screen
                        ),
                      );
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

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Locations') // Your Firestore collection name
                .doc(locationid) // Use the current location ID
                .snapshots(), // Get real-time updates
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
              } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                // Parse the real-time location data
                final locationData = snapshot.data!.data() as Map<String, dynamic>;
                final location = Location.fromJson(locationData); // Convert Firestore data to your Location model

                return GestureDetector(
                  onTap: () => widget.onLocationSelected(location),
                  child: _buildBusinessCard(
                    location,
                  ),
                );
              } else {
                // Return a fallback widget if data is null or document does not exist
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
  Widget _buildBusinessCard(Location? result) {
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                  // Three-dots menu button
                  IconButton(
                    icon: Icon(Icons.more_vert), // Three dots icon
                    onPressed: () => _showOptions(context, result), // Trigger the options menu
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Define the _showOptions function
  void _showOptions(BuildContext parentContext, Location location) {
    showModalBottomSheet(
      context: parentContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the bottom sheet first
                  Navigator.push(
                    parentContext, // Use the parentContext for navigation
                    MaterialPageRoute(
                      builder: (context) => EditLocationScreen(location: location),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Edit Location',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the bottom sheet first
                  try {
                    // Step 1: Delete location from Algolia
                    final String locationId = location.businessId;
                    final client = SearchClient(
                      appId: dotenv.env['ALGOLIA_APPLICATION_ID']!,
                      apiKey: dotenv.env['ALGOLIA_API_KEY_DELETE']!,
                    );
                    final response=await client.deleteObject(
                      indexName: dotenv.env['ALGOLIA_INDEX_NAME']!,
                      objectID: locationId,
                    );
                    print("Location deleted from Algolia.");

                    // Step 2: Delete location from Firestore
                    await FirebaseFirestore.instance
                        .collection('Locations')
                        .doc(locationId)
                        .delete();
                    print("Location deleted from Firestore.");

                    // Step 3: Remove the location ID from the business owner's record
                    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(widget.userId);
                    final userDoc = await userDocRef.get();
                    if (userDoc.exists) {
                      final List<dynamic> locationIds = userDoc.data()?['own'] ;
                      locationIds.remove(locationId);

                      await userDocRef.update({'own': locationIds});
                      print("Location ID removed from business owner's record.");
                    }

                    // Step 4: Delete all reviews associated with the location
                    final reviewsQuery = await FirebaseFirestore.instance
                        .collection('Reviews')
                        .where('business_id', isEqualTo: locationId)
                        .get();
                    final batch = FirebaseFirestore.instance.batch();
                    for (final reviewDoc in reviewsQuery.docs) {
                      batch.delete(reviewDoc.reference);
                    }
                    await batch.commit();
                    print("All reviews associated with the location deleted.");

                    // Show success message using the parent context
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(content: Text("Location and associated data deleted successfully.")),
                    );
                  } catch (e) {
                    // Show error message using the parent context
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(content: Text("Failed to delete location: $e")),
                    );
                    print("Error deleting location: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Delete Location',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
