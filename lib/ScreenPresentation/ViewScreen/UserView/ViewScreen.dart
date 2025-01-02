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
class ViewScreenSearch extends StatefulWidget {
  final Location? location;

  ViewScreenSearch({required this.location});

  @override
  _ViewScreenSearchState createState() => _ViewScreenSearchState();
}
class _ViewScreenSearchState extends State<ViewScreenSearch> {
  bool isReadMore = false;

  // Dummy review data
  final Map<int, int> reviewSummary = {
    5: 50, // 50 reviews with 5 stars
    4: 30, // 30 reviews with 4 stars
    3: 15, // 15 reviews with 3 stars
    2: 5,  // 5 reviews with 2 stars
    1: 10, // 10 reviews with 1 star
  };
  Future<List<String>> fetchLastViewedBusinesses() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (Auth().currentUser != null) {
        print("User not logged in.");
        return [];
      }

      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(user?.uid);
      // Get the user's last viewed businesses
      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        List<dynamic> lastViewedList = userDoc.data()?['last_viewed_algolia_id'] ?? [];
        return List<String>.from(lastViewedList); // Return as List<String>
      } else {
        print("User document does not exist.");
        return [];
      }
    } catch (e) {
      print("Error fetching last viewed businesses: $e");
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    if (widget.location == null) {
      return Scaffold(
        appBar: AppBar(

        ),
        body: Center(
          child: Text(
            "Location not found.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    final location = widget.location!;
    return Scaffold(
      body: Column(
        children: [
          // Top Section: Image with overlay buttons
          Stack(
            children: [
              // Background image
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: widget.location!.imageURL.isNotEmpty ? widget.location!.imageURL[0] : '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              // Back and Favorite Buttons
              Positioned(
                top: 40, // Adjust for better positioning
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    Navigator.pop(context);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: Icon(Icons.favorite_border_outlined, color: Colors.white),
                  onPressed: () {
                    // Handle favorite logic
                    saveLocationToFile(location);
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
                    widget.location!.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.location!.address,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Rating Section
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.location!.stars ? Icons.star : Icons.star_border,
                            color: index < widget.location!.stars ? Color(0xFF17727F) : Colors.grey,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Locations')
                            .doc(widget.location!.businessId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Row(
                              children: [
                                Text("Loading..."),
                                SizedBox(width: 8),
                                Text("Loading... reviews", style: TextStyle(color: Colors.grey)),
                              ],
                            );
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Row(
                              children: [
                                Text("No data"),
                                SizedBox(width: 8),
                                Text("No reviews", style: TextStyle(color: Colors.grey)),
                              ],
                            );
                          }
                          final locationData = snapshot.data!.data() as Map<String, dynamic>;

                          final stars = locationData['stars'] ?? 0.0; // Get the stars field
                          final reviewCount = locationData['review_count'] ?? 0; // Get the review_count field
                          return Row(
                            children: [
                              Text(
                                stars.toStringAsFixed(1),
                                style: TextStyle(fontSize: 16,),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '$reviewCount reviews',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          );
                        },
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
                          color: Colors.grey, // Set the color of the line
                          thickness: 1,       // Set the thickness of the line
                          indent: 10,         // Add some space before the line starts
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isReadMore
                        ? widget.location!.description // Full text when expanded
                        : '${widget.location!.description.substring(0, 150)}...', // Truncated text when collapsed
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
                  const SizedBox(height: 16),
                  ImageSection(imageUrls: widget.location!.imageURL,),
                  const SizedBox(height: 16),
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
                  ElevatedButton.icon(
                    onPressed: () async {
                      final existingReview = await FirebaseFirestore.instance
                          .collection("Reviews")
                          .where("business_id", isEqualTo: widget.location!.businessId)
                          .where("user_id", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                          .get()
                          .then((querySnapshot) => querySnapshot.docs.isNotEmpty
                          ? querySnapshot.docs.first.data()
                          : null);
                      Navigator.push(context,
                        MaterialPageRoute(
                        builder: (context) => AddReviewScreen(
                        businessID: this.widget.location!.businessId,  // ID of the location being reviewed
                        name: this.widget.location!.name,
                        address: this.widget.location!.address,
                        locationImage: this.widget.location!.imageURL[0],
                          city: this.widget.location!.city,
                          state: this.widget.location!.state,
                          existingReview: existingReview,
                        ),
                      ),);
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 20, // Change the size of the icon
                    ),
                    label: Text(
                      'Write a review',
                      style: TextStyle(fontSize: 16), // Change the size of the text
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF17727F), // Set the background color
                      foregroundColor: Colors.white,
                      minimumSize: Size(500, 40),// Set the text/icon color
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Adjust padding for size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Make the button rounded
                      ),
                    ),
                  ),
                  Text(
                    'Reviews (${widget.location?.reviewCount})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:Color(0xFF17727F)),
                  ),
                  const SizedBox(height: 8),
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
                                        backgroundImage: CachedNetworkImageProvider(review['user_avatar_url'] ?? ''),
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
      ),
    );
  }
}

class ImageGalleryScreen extends StatelessWidget {
  final List<String> imageUrls;
  const ImageGalleryScreen({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text("Image Gallery"),
      ),
      body: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        },
      ),
    );
  }
}

class ImageSection extends StatelessWidget {
  final List<String> imageUrls;
  const ImageSection({Key? key, required this.imageUrls}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Images',
              style: TextStyle(color: Color(0xFF17727F),
              fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 230),
            Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageGalleryScreen(imageUrls: imageUrls),
                ),
              );
            },
            child: Text(
              "View All",
              style: TextStyle(color: Color(0xFF17727F),
                fontSize: 12,
              ),
            ),
          ),
        ),]
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length-1, // Skip the first image
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageGalleryScreen(imageUrls: imageUrls),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrls[index + 1],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );
  }
}
