import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelaca/Model/LocationClass.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:travelaca/Network/firebase_cloud_firesotre.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/UserView/AddReview.dart';
import 'package:geolocator/geolocator.dart';
import '../../../Model/Reviews.dart';
import '../../../Network/auth.dart';
import 'package:travelaca/MainPage.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/BusinessView/EditLocation.dart';

import '../../LoginScreen/LoginScreen.dart';
import '../../OfflineScreen/OfflineHome.dart';
class BusinessDashboardScreen extends StatefulWidget {
  final Location? location;

  BusinessDashboardScreen({required this.location});

  @override
  _BusinessDashboardScreen createState() => _BusinessDashboardScreen();
}
final Map<int, int> reviewSummary = {
  5: 50, // 50 reviews with 5 stars
  4: 30, // 30 reviews with 4 stars
  3: 15, // 15 reviews with 3 stars
  2: 5,  // 5 reviews with 2 stars
  1: 10, // 10 reviews with 1 star
};
class _BusinessDashboardScreen extends State<BusinessDashboardScreen> {
  bool isReadMore = false;

  @override
  Widget build(BuildContext context) {
    if (widget.location == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            "Location not found.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        // Listen for updates to the location document in Firestore
        stream: FirebaseFirestore.instance
            .collection('Locations')
            .doc(widget.location!.businessId)
            .snapshots(),
        builder: (context, locationSnapshot) {
          if (locationSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!locationSnapshot.hasData || !locationSnapshot.data!.exists) {
            return Center(
              child: Text(
                "Location not found or deleted.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Parse location data
          final locationData = locationSnapshot.data!.data() as Map<String, dynamic>;
          final location = Location.fromJson(locationData);

          return Column(
            children: [
              // Top Section: Image with overlay buttons
              Stack(
                children: [
                  // Background image
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: location.imageURL.isNotEmpty ? location.imageURL[0] : '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  // Edit Button
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      icon: Icon(Icons.mode_edit_outline_outlined, color: Colors.white),
                      onPressed: () async {
                        bool hasConnection = await checkConnection();
                        if (hasConnection) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditLocationScreen(location: location),
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

                      },
                    ),
                  ),
                ],
              ),

              // Details Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hotel Name and Address
                      Text(
                        location.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        location.address,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // Rating Section
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < location.stars ? Icons.star : Icons.star_border,
                                color: index < location.stars ? Color(0xFF17727F) : Colors.grey,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text('${location.stars.toStringAsFixed(1)}'),
                          const SizedBox(width: 8),
                          Text(
                            '${location.reviewCount} reviews',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Location Details',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF17727F),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                              indent: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ReadMoreText(text: location.description),

                      // Images
                      const SizedBox(height: 16),
                      Text(
                        'Images',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF17727F)),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: location.imageURL.length - 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: location.imageURL[index + 1],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Reviews',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF17727F)),
                          ),
                          SizedBox(width: 10,),
                          Text(
                              '(${location.reviewCount.toString()})',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF17727F)),
                          )
                        ],

                      ),
                      Row(
                          children: [
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Locations')
                                  .doc(widget.location!.businessId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text(
                                    "Loading...",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );
                                }

                                if (!snapshot.hasData || !snapshot.data!.exists) {
                                  return Text(
                                    "No data",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );
                                }

                                final locationData = snapshot.data!.data() as Map<String, dynamic>;
                                final stars = locationData['stars'] ?? 0; // Get the stars field

                                return Text(
                                  stars.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                              },
                            ),

                            SizedBox(width: 16,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Review Summary',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < widget.location!.stars ? Icons.star : Icons.star_border,
                                      color: index < widget.location!.stars ? Color(0xFF17727F) : Colors.grey,
                                      size: 12,
                                    );
                                  }),
                                ),
                              ],
                            )
                          ]
                      ),
                      SizedBox(height: 16),
                      ...reviewSummary.entries.map((entry) {
                        final int star = entry.key;
                        final int count = entry.value;
                        final double percentage =
                            (count / reviewSummary.values.reduce((a, b) => a + b)) * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                star.toString(),
                              ),
                              Icon(
                                Icons.star,
                                color: Color(0xFF17727F),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              // Progress Indicator
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0), // Make the line rounded
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.transparent, // Remove grey line
                                    color: Color(0xFF17727F),
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Review Count and Percentage
                            ],
                          ),
                        );
                      }).toList(),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: CloudFirestore().streamReviews(widget.location!.businessId), // Use the new stream function
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("Error: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text("No reviews yet."));
                          }

                          final reviews = snapshot.data!;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(review['user_avatar_url'] ?? ''),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review['username'], // Display the fetched username
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              Text(
                                                review['date'].toString(),
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        review['content'],
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: List.generate(
                                              review['stars'],
                                                  (index) => Icon(Icons.star,
                                                  color: Colors.amber, size: 16),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.thumb_up, size: 16, color: Colors.green),
                                              SizedBox(width: 5),
                                              Text("${review['likes']}"),
                                              SizedBox(width: 10),
                                              Icon(Icons.thumb_down, size: 16, color: Colors.red),
                                              SizedBox(width: 5),
                                              Text("${review['dislikes']}"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
class ReadMoreText extends StatefulWidget {
  final String text;

  ReadMoreText({required this.text});

  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isReadMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isReadMore
              ? widget.text // Full text when expanded
              : '${widget.text.substring(0, 150)}...', // Truncated text when collapsed
          style: const TextStyle(fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isReadMore = !isReadMore;
            });
          },
          child: Text(
            isReadMore ? 'Read Less' : 'Read More',
            style: TextStyle(color: Color(0xFF17727F)),
          ),
        ),
      ],
    );
  }
}