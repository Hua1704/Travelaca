import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddReviewScreen extends StatefulWidget {
  final String businessID; // ID of the location being reviewed
  final String name;
  final String address;
  final String locationImage;
  final String city;
  final String state;
  AddReviewScreen({
    required this.businessID,
    required this.name,
    required this.address,
    required this.locationImage,
    required this.city,
    required this.state,
  });

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int selectedStars = 0; // Rating in stars
  String selectedMonth = "December 2024"; // Default month of visit
  final TextEditingController reviewController = TextEditingController(); // Controller for the review text
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  bool isSaving = false; // Loading state for save button


  // List of months for dropdown
  final List<String> months = [
    "January 2024",
    "February 2024",
    "March 2024",
    "April 2024",
    "May 2024",
    "June 2024",
    "July 2024",
    "August 2024",
    "September 2024",
    "October 2024",
    "November 2024",
    "December 2024"
  ];

  Future<void> saveReview() async {
    final User? user = _auth.currentUser; // Get the logged-in user
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to add a review.")),
      );
      return;
    }

    if (selectedStars == 0 || reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide a star rating and review content.")),
      );
      return;
    }

    setState(() {
      isSaving = true; // Show loading indicator
    });

    try {
      final String reviewId =
          FirebaseFirestore.instance.collection("Reviews").doc().id; // Generate a unique review ID
      final List<String> imageURl = [
      widget.locationImage,
      ];
      final reviewData = {
        "review_id": reviewId, // Unique review ID
        "user_id": user.uid, // User ID of the logged-in user
        "user_avatar_url": user.photoURL ?? "", // User's avatar URL
        "location_name": widget.name, // Name of the location
        "location_address": widget.address, // Address of the location
        "location_city": widget.city, // Add location city (for this example)
        "location_state": "Hanoi", // Add location state (for this example)
        "location_image_urls": imageURl, // Add location image
        "stars": selectedStars, // Star rating
        "content": reviewController.text.trim(), // Review content
        "date": DateTime.now().toString(), // Current date
        "likes": 0, // Default value for likes
        "dislikes": 0 // Default value for dislikes
      };

      // Save review to Firestore
      await _firestore.collection("Reviews").doc(reviewId).set(reviewData);

      // Update the number of reviews for the location
      final locationDocRef = _firestore.collection("Locations").doc(widget.businessID);

      await locationDocRef.update({
        "review_count": FieldValue.increment(1), // Increment the review count by 1
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review added successfully!")),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save review: $e")),
      );
    } finally {
      setState(() {
        isSaving = false; // Hide loading indicator
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Details
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.locationImage),
                    radius: 30,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.address,
                        style: TextStyle(fontSize: 14, color: Colors.black)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How many stars would you rate your experience?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedStars ? Icons.star : Icons.star_border,
                          color: index < selectedStars ? Color(0xFF17727F) : Colors.grey,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedStars = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity, // Make the container span the full width of the screen
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "When did you visit?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8), // Add some spacing between text and dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 1.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      border: Border.all(color: Color(0xFF17727F), width: 3.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value!;
                          });
                        },
                        items: months.map((month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(
                              month,
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF17727F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Write review",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: reviewController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Please share your experience with us...",

                    ),
                  ),
                ],
              ),
            ),
            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: isSaving ? null : saveReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF17727F),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Save",
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
