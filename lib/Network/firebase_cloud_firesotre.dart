import 'package:algolia_client_recommend/algolia_client_recommend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelaca/Model/LocationClass.dart';
import 'package:travelaca/Model/Reviews.dart';
final String algoliaAppId = dotenv.env['ALGOLIA_APPLICATION_ID']!;
final String algoliaApiKey = dotenv.env['ALGOLIA_API_KEY']!;
final String algoliaIndexName = dotenv.env['ALGOLIA_INDEX_NAME']!;
class CloudFirestore {
  final db = FirebaseFirestore.instance;

  FirebaseFirestore get instance => db;

  Future<void> addUser(User user) async {
    final userAsMap = <String, dynamic>{
      "uid": user.uid,
      "displayName": user.displayName,
      "email": user.email,
      "photoURL": user.photoURL,
    };
    db.collection("users").doc(user.uid).set(userAsMap);
  }
  Future<void> updateUserInfo({required User user}) async{
    final userAsMap = <String, dynamic>{
      "displayName": user.displayName,
      "email": user.email,
      "photoURL": user.photoURL,
    };
    db.collection("users").doc(user.uid).update(userAsMap);
  }
  Future<void> saveUserSearch(String locationId) async {
    try {
      // Get the current logged-in user
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userRef = firestore.collection('Users').doc(user.uid);
        await userRef.set({
          'last_10_searched': FieldValue.arrayUnion([locationId]),
        }, SetOptions(merge: true));
        // Optionally, keep the array size limited to the last 10 searches
        final snapshot = await userRef.get();
        if (snapshot.exists) {
          final data = snapshot.data();
          final List<dynamic>? searchHistory = data?['last_10_searched'];
          if (searchHistory != null && searchHistory.length > 10) {
            // Trim the array to the last 10 items
            final trimmedList = searchHistory.sublist(searchHistory.length - 10);
            await userRef.update({'last_10_searched': trimmedList});
          }
        }
      }
    } catch (e) {
      print('Error saving search history: $e');
    }
  }
  Future<List<Location>> fetchSearchHistory() async {
    try {
      // Get the current logged-in user
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userDoc = await firestore.collection('Users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data();
          final List<dynamic>? searchIds = data?['last_10_searched'];
          if (searchIds != null) {
            List<Location> locations = [];
            for (String id in searchIds) {
              // Fetch each location from Firestore
              final locationDoc = await firestore.collection('Locations').doc(id).get();
              if (locationDoc.exists) {
                final locationData = locationDoc.data();
                if (locationData != null) {
                  locations.add(Location.fromJson(locationData));
                }
              }
            }
            return locations;
          }
        }
      }
    } catch (e) {
      print('Error fetching search history: $e');
    }
    return [];
  }
  Future<String?> fetchUserName(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Users') // Firestore collection name
          .doc(userId) // Match the userId
          .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['username']; // Fetch the username field
      } else {
        return null; // User not found
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }
  Stream<List<Map<String, dynamic>>> streamReviews(String businessID) {
    final reviewsCollection = FirebaseFirestore.instance
        .collection('Reviews')
        .where('business_id', isEqualTo: businessID)
        .orderBy('date', descending: true);

    return reviewsCollection.snapshots().asyncMap((snapshot) async {
      List<Map<String, dynamic>> reviewsWithUserNames = [];

      for (var doc in snapshot.docs) {
        final reviewData = doc.data();
        final String? userName = await CloudFirestore().fetchUserName(reviewData['user_id']);
        reviewsWithUserNames.add({
          ...reviewData, // Include all review data
          'username': userName ?? 'Unknown', // Add username or default to 'Unknown'
        });
      }

      return reviewsWithUserNames;
    });
  }

  static Future<Location?> fetchLocation(String id) async {
    try {
      // Access the Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Query the "Locations" collection for the document with the given ID
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await firestore.collection('Locations').doc(id).get();

      // Check if the document exists and return a Location object
      if (snapshot.exists) {
        final Map<String, dynamic>? data = snapshot.data();
        if (data != null) {
          return Location.fromJson(data);
        }
      }
      print('No location found with ID: $id');
      return null;
    } catch (e) {
      print('Error fetching location by ID from Firestore: $e');
      return null;
    }
  }
  Future<void> saveLastViewedBusiness(String businessId) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in.");
        return;
      }
      // Reference to the user's Firestore document
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
      // Get the current last_viewed_algolia_id array
      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        List<dynamic> lastViewedList = userDoc.data()?['last_viewed_algolia_id'] ?? [];
        // Ensure it's a List<String>
        lastViewedList = List<String>.from(lastViewedList);
        // Check if the businessId already exists in the list
        if (lastViewedList.contains(businessId)) {
          // Remove the businessId if it already exists (to re-add it at the top)
          lastViewedList.remove(businessId);
        }

        lastViewedList.insert(0,businessId);

        if (lastViewedList.length > 3) {
          lastViewedList = lastViewedList.sublist(0, 3);
        }
        // Update Firestore
        await userDocRef.update({'last_viewed_algolia_id': lastViewedList});
      }
    } catch (e) {
      print("Error saving last viewed business: $e");
    }
  }

  Future<List<String>> fetchLastViewedAlgoliaIds() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Return default IDs for non-logged-in users
        return [
          "3c70fdf8-9423-4e8a-aa01-5ed861268cfd",
          "07e9fa69-8ec2-40d6-875a-a25c42488afc",
          "5ba39e01-1641-4d81-8bb7-a56e2c022396",
        ];
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

          return [
            "3c70fdf8-9423-4e8a-aa01-5ed861268cfd",
            "07e9fa69-8ec2-40d6-875a-a25c42488afc",
            "5ba39e01-1641-4d81-8bb7-a56e2c022396",
          ];
        }
        return List<String>.from(lastViewedIds); // Cast to List<String>
      } else {

        return [
          "3c70fdf8-9423-4e8a-aa01-5ed861268cfd",
          "07e9fa69-8ec2-40d6-875a-a25c42488afc",
          "5ba39e01-1641-4d81-8bb7-a56e2c022396",
        ];
      }
    } catch (e) {

      return [
        "3c70fdf8-9423-4e8a-aa01-5ed861268cfd",
        "07e9fa69-8ec2-40d6-875a-a25c42488afc",
        "5ba39e01-1641-4d81-8bb7-a56e2c022396",
      ];
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecommendationsWithDetails(List<String> lastViewedIds) async {
    try {
      // Initialize the Algolia Recommend Client
      final client = RecommendClient(
        appId: algoliaAppId,
        apiKey: algoliaApiKey,
      );

      // Create LookingSimilarQuery requests for each last viewed ID
      final List<LookingSimilarQuery> requests = lastViewedIds.map((id) {
        return LookingSimilarQuery(
          model: LookingSimilarModel.fromJson("looking-similar"),
          objectID: id,
          indexName: algoliaIndexName,
          threshold: 50,
          maxRecommendations: 3,
        );
      }).toList();

      // Fetch recommendations from Algolia
      final response = await client.getRecommendations(
        getRecommendationsParams: GetRecommendationsParams(requests: requests),
      );

      // Collect recommended hits directly from Algolia
      final List<Map<String, dynamic>> recommendations = [];
      for (final result in response.results) {
        recommendations.addAll(result.hits.map((hit) {
          return {
            'score': hit['_score'] ?? 0.0,
            'id': hit['objectID'] ?? '',
            'name': hit['name'] ?? 'Unknown Place',
            'longitude': hit['longitude'] ?? 'Unknown Distance',
            'image_urls': hit['image_urls'] ?? '', // Assuming 'image' contains the URL
            'stars': hit['stars'] ?? 0.0, // Assuming 'stars' is the rating
          };
        }).toList());
      }
      recommendations.sort((a, b) {
        final scoreA = a['score'] as double;
        final scoreB = b['score'] as double;
        return scoreB.compareTo(scoreA);
      });
      return recommendations;
    } catch (e) {
      print("Error fetching recommendations with details: $e");
      return [];
    }
  }


// Fetch individual location details from Firestore


  Future<List<Map<String, dynamic>>> fetchRecommendationsForUser() async {
    final lastViewedIds = await fetchLastViewedAlgoliaIds();
    return await fetchRecommendationsWithDetails(lastViewedIds);
  }

}
