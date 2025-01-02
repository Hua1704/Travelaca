import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travelaca/Model/LocationClass.dart';
import 'package:travelaca/Model/Reviews.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/UserView/ViewScreen.dart';

import 'package:travelaca/Network/firebase_cloud_firesotre.dart';

import 'package:travelaca/ScreenPresentation//ViewScreen/UserView/AddReview.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // Firestore instance
  List<Map<String, dynamic>> userReviews = []; // List to hold user reviews
  bool isLoading = true; // Loading state
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserReviews();
    _fetchUserData();
  }

  Future<List<Location>> fetchLastViewedLocations() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in.");
        return [];
      }

      // Fetch the user's last viewed IDs from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final List<dynamic> lastViewedIds =
            userDoc.data()?['last_viewed_algolia_id'] ?? [];

        if (lastViewedIds.isEmpty) {
          return [];
        }
        // Fetch location details for these IDs from Algolia or Firestore
        final List<Location> locations = [];
        for (String id in lastViewedIds) {
          // Assuming you're fetching data from Algolia
          final Location? location = await fetchLocationById(id);
          if (location != null) {
            locations.add(location);
          }
        }
        return locations;
      } else {
        print("User document not found.");
        return [];
      }
    } catch (e) {
      print("Error fetching last viewed locations: $e");
      return [];
    }
  }

// Example function to fetch a location by ID
  Future<Location?> fetchLocationById(String id) async {
    // Replace this with your actual Algolia or Firestore fetch logic
    try {
      final response = await FirebaseFirestore.instance
          .collection('Locations')
          .doc(id)
          .get();

      if (response.exists) {
        return Location.fromJson(response.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching location by ID: $e");
      return null;
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('Users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data(); // Store the user data
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Fetch reviews for the current user
  Future<void> _fetchUserReviews() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Query Firestore for reviews of the logged-in user
        final querySnapshot = await _firestore
            .collection('Reviews')
            .where('user_id', isEqualTo: user.uid)
            .get();

        setState(() {
          userReviews = querySnapshot.docs.map((doc) => doc.data()).toList();
          isLoading = false; // Data is loaded
        });
      } else {
        setState(() {
          isLoading = false; // Data is loaded, but no user is logged in
        });
      }
    } catch (e) {
      print('Error fetching user reviews: $e');
      setState(() {
        isLoading = false; // Data loading failed
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section: Image and Title
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/Home.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient Overlay
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
                              Colors.white.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Title Text
                    Positioned(
                      top: 70,
                      left: 16,
                      child: Text(
                        'Review',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // User Info
                Row(
                  children: [
                    SizedBox(width: 10),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: userData?['photoURL'] != null
                          ? NetworkImage(userData!['photoURL'])
                          : null,
                      child: userData?['photoURL'] == null
                          ? Icon(Icons.person, size: 30)
                          : null,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['username'] ?? 'Guest',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight
                              .bold),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('Reviews')
                              .where('user_id', isEqualTo: userData?['user_id'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("Loading...");
                            }
                            final reviewsCount = snapshot.data?.docs.length ??
                                0;
                            return Text(
                              '$reviewsCount review(s)',
                              style: TextStyle(color: Colors.grey),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(),

                // User Reviews Section
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 16),
                    Text(
                      'Your review(s)',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('Reviews')
                      .where('user_id', isEqualTo: userData?['user_id'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                            color: Colors.teal,
                          ));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'You have not written any reviews yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }
                    final userReviews = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: userReviews.length,
                      itemBuilder: (context, index) {
                        final review = userReviews[index].data() as Map<
                            String,
                            dynamic>;
                        return _buildReviewCard(review);
                      },
                    );
                  },
                ),
                Divider(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16),
                        Text(
                          'Recently Viewed',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight
                              .bold),
                        ),
                      ],
                    ),
                    buildLastViewedLocations(),
                    // Call the dynamically built list
                  ],
                )
              ],
            ),
          ),
        ),
      );

  }

  Widget buildLastViewedLocations() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
          child: Text("Please log in to see recently viewed locations."));
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.data() != null) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final lastViewedIds = userData['last_viewed_algolia_id'] ?? [];

          if (lastViewedIds.isEmpty) {
            return Center(child: Text("No recently viewed locations."));
          }

          return FutureBuilder<List<Location>>(
            future: fetchLastViewedLocations(),
            builder: (context, locationSnapshot) {
              if (locationSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (locationSnapshot.hasError) {
                return Center(child: Text('Error: ${locationSnapshot.error}'));
              } else if (locationSnapshot.hasData &&
                  locationSnapshot.data!.isNotEmpty) {
                final locations = locationSnapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewScreenSearch(location: location),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: location.imageURL.isNotEmpty
                              ? Image.network(
                            location.imageURL[0],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.image, size: 60, color: Colors.grey),
                        ),
                        title: Text(location.name),
                        subtitle: Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < location.stars ? Icons.star : Icons
                                  .star_border,
                              color: Colors.teal,
                              size: 18,
                            );
                          }),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Text("No recently viewed locations."));
              }
            },
          );
        } else {
          return Center(child: Text("No recently viewed locations."));
        }
      },
    );
  }


  // Function to build individual review cards
  Widget _buildReviewCard(Map<String, dynamic> review) {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        final locationId = review["business_id"]; // Extract the business ID from the review
        if (locationId != null) {
          final location = await CloudFirestore.fetchLocation(
              locationId); // Fetch location details
          if (location != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewScreenSearch(location: location),
              ),
            );
          } else {
            // Handle the case where the location is not found
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Location details not found')),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Column
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: review["location_image_urls"] != null &&
                      review["location_image_urls"].isNotEmpty
                      ? Image.network(
                    review["location_image_urls"][0],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 60, color: Colors.grey),
                ),
                SizedBox(height: 5),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review["stars"] ? Icons.star : Icons.star_border,
                      color: Colors.teal,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            SizedBox(width: 10),
            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          review["location_name"] ?? "Unknown Location",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          _showReviewOptions(
                              context, review); // Show bottom sheet
                        },
                      ),
                    ],
                  ),
                  Text(
                    review["location_address"] ?? "",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Text(
                    review["content"] ?? "",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Function to show the bottom sheet for review options
  void _showReviewOptions(BuildContext context, Map<String, dynamic> review) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddReviewScreen(
                            businessID: review["business_id"],
                            // Pass business ID
                            name: review["location_name"] ?? "Unknown Name",
                            // Pass location name
                            address: review["location_address"] ??
                                "Unknown Address",
                            // Pass location address
                            locationImage: review["location_image_urls"] !=
                                null &&
                                review["location_image_urls"].isNotEmpty
                                ? review["location_image_urls"][0]
                                : "",
                            // Pass location image
                            city: review["location_city"] ?? "Unknown City",
                            // Pass city
                            state: review["location_state"] ?? "Unknown State",
                            // Pass state
                            existingReview: review, // Pass the entire review as a parameter
                          ),
                    ),
                  ); FocusScope.of(context).unfocus();
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                    'Edit your review', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);

                  // Delete the review from Firestore
                  final reviewId = review["review_id"];
                  if (reviewId != null) {
                    try {
                      // Fetch the review to get the business_id
                      final reviewDoc = await FirebaseFirestore.instance
                          .collection('Reviews')
                          .doc(reviewId)
                          .get();

                      if (reviewDoc.exists) {
                        final reviewData = reviewDoc.data() as Map<String, dynamic>;
                        final String businessId = reviewData['business_id'];

                        // Delete the review
                        await FirebaseFirestore.instance.collection('Reviews').doc(reviewId).delete();

                        // Update the review count in the corresponding location
                        final locationDocRef = FirebaseFirestore.instance.collection('Locations').doc(businessId);

                        await locationDocRef.update({
                          "review_count": FieldValue.increment(-1), // Decrement the review count by 1
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Review deleted successfully.")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Review not found.")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to delete review: $e")),
                      );
                    }
                  }
                  FocusScope.of(context).unfocus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Delete your review',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }


}