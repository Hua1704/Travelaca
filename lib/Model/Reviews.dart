import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String businessId;
  final String content;
  final DateTime date;
  final int dislikes;
  final int likes;
  final String locationAddress;
  final String locationCity;
  final List<String> locationImageUrls;
  final String locationName;
  final String locationState;
  final String reviewId;
  final int stars;
  final String userAvatarUrl;
  final String userId;

  Review({
    required this.businessId,
    required this.content,
    required this.date,
    required this.dislikes,
    required this.likes,
    required this.locationAddress,
    required this.locationCity,
    required this.locationImageUrls,
    required this.locationName,
    required this.locationState,
    required this.reviewId,
    required this.stars,
    required this.userAvatarUrl,
    required this.userId,
  });

  // Factory constructor for creating a Review object from Firestore data
  factory Review.fromFirestore(Map<String, dynamic> data) {
    return Review(
      businessId: data['business_id'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.parse(data['date'] ?? DateTime.now().toString()),
      dislikes: data['dislikes'] ?? 0,
      likes: data['likes'] ?? 0,
      locationAddress: data['location_address'] ?? '',
      locationCity: data['location_city'] ?? '',
      locationImageUrls: data['location_image_urls'] != null
          ? List<String>.from(data['location_image_urls'])
          : [],
      locationName: data['location_name'] ?? '',
      locationState: data['location_state'] ?? '',
      reviewId: data['review_id'] ?? '',
      stars: data['stars'] ?? 0,
      userAvatarUrl: data['user_avatar_url'] ?? '',
      userId: data['user_id'] ?? '',
    );
  }

  // Convert the Review object back to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'business_id': businessId,
      'content': content,
      'date': date.toIso8601String(),
      'dislikes': dislikes,
      'likes': likes,
      'location_address': locationAddress,
      'location_city': locationCity,
      'location_image_urls': locationImageUrls,
      'location_name': locationName,
      'location_state': locationState,
      'review_id': reviewId,
      'stars': stars,
      'user_avatar_url': userAvatarUrl,
      'user_id': userId,
    };
  }
}