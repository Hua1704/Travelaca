import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelaca/Network/auth.dart';
import 'package:travelaca/Model/Reviews.dart';
class AddReviewScreen extends StatefulWidget {
  final String businessID; // ID of the location being reviewed
  final String name;
  final String address;
  final String locationImage;
  final String city;
  final String state;
  final Map<String, dynamic>? existingReview;

  AddReviewScreen({
    required this.businessID,
    required this.name,
    required this.address,
    required this.locationImage,
    required this.city,
    required this.state,
    this.existingReview,
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

  @override
  void initState() {
    super.initState();

    // Pre-fill fields if editing an existing review
    if (widget.existingReview != null) {
      reviewController.text = widget.existingReview?['content'] ?? ''; // Default to empty string if null
      selectedStars = widget.existingReview?['stars'] ?? 0.0; // Default to 0 stars if null
      selectedMonth = widget.existingReview?['visit_month'] ?? "December 2024"; // Default to the selected month
    }
  }

  Future<void> saveReview() async {
    final User? user = _auth.currentUser;
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
    if(reviewController.text.length > 200)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review cannot exceeds 200 words")),
      );
      return;
    }
    setState(() {
      isSaving = true; // Show loading indicator
    });

      try {
        final String reviewId = widget.existingReview?['review_id'] ??
            FirebaseFirestore.instance
                .collection("Reviews")
                .doc()
                .id; // Generate a unique review ID if not editing

        final List<String> imageURl = [
          widget.locationImage,
        ];

        final reviewData = {
          "business_id": widget.businessID,
          "review_id": reviewId,
          // Unique review ID
          "user_id": user.uid,
          // User ID of the logged-in user
          "user_avatar_url": user.photoURL ?? "",
          // User's avatar URL
          "location_name": widget.name,
          // Name of the location
          "location_address": widget.address,
          // Address of the location
          "location_city": widget.city,
          // Location city
          "location_state": widget.state,
          // Location state
          "location_image_urls": imageURl,
          // Location images
          "stars": selectedStars,
          // Star rating
          "content": reviewController.text.trim(),
          // Review content
          "month_of_visit": selectedMonth,
          // Month of visit
          "date": DateTime.now().toString(),
          // Current date
          "likes": widget.existingReview?['likes'] ?? 0,
          // Preserve likes if editing
          "dislikes": widget.existingReview?['dislikes'] ?? 0,
          // Preserve dislikes if editing
        };

        // Save review to Firestore
        await _firestore.collection("Reviews").doc(reviewId).set(reviewData);

        // Update the number of reviews for the location
        if (widget.existingReview == null) {
          final locationDocRef = _firestore.collection("Locations").doc(
              widget.businessID);
          final QuerySnapshot<Map<String, dynamic>> reviewsSnapshot = await _firestore
              .collection("Reviews")
              .where("business_id", isEqualTo: widget.businessID)
              .get();
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> reviews = reviewsSnapshot.docs;
           double totalStars = 0.0;
          for (var review in reviews) {
            totalStars += review.data()["stars"];
          }
          final double newAverageStars = totalStars / (reviews.length+1);
          await locationDocRef.update({
            "review_count": FieldValue.increment(1),
             "stars": newAverageStars
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Review ${widget.existingReview != null
              ? 'updated'
              : 'added'} successfully!")),
        );

        Navigator.pop(context); // Go back to the previous screen
      }
       catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save review: $e")),
        );
      }

    finally {
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
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Star Rating Section
            _buildStarRatingSection(),

            _buildMonthOfVisitSection(),
            _buildReviewContentSection(),
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
                    : Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRatingSection() {
    return Container(
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
    );
  }

  Widget _buildMonthOfVisitSection() {
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
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
                  child: Text(month),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContentSection() {
    return Container(
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
    );
  }
}
