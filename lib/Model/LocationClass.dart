import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Location {
  final String objectID;
  final String businessId;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double stars;
  late final int reviewCount;
  final bool isOpen;
  final String categories;
  final String description;
  final List<String> imageURL;
  final String state;

  Location({
    required this.objectID,
    required this.businessId,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.stars,
    required this.reviewCount,
    required this.isOpen,
    required this.categories,
    required this.description,
    required this.imageURL,
    required this.state,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      businessId: json['business_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      address: json['address'] ?? 'Unknown',
      city: json['city'] ?? 'Unknown',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      stars: (json['stars'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isOpen: json['is_open'] == 1, // Convert 1/0 to boolean
      categories: (json['categories'] as String?) ?? 'Unknown',
      objectID: json['objectID'] ?? '',
      description: json['description'] ?? '',
      state: json['state'] ?? '',
      imageURL: (json['image_urls'] as List<dynamic>?)
          ?.map((url) => url.toString())
          .toList() ??
          [], // Safely convert to List<String>
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectID': objectID,
      'business_id': businessId,
      'name': name,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'stars': stars,
      'review_count': reviewCount,
      'is_open': isOpen ? 1 : 0, // Convert boolean to 1/0
      'categories': categories,
      'description': description,
      'image_urls': imageURL,
      'state': state,
    };
  }
}

Future<void> saveLocationToFile(Location location) async {
  try {
    // Get the directory for storing app data
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/location_${location.objectID}.json';
    final imageDirectory = Directory('${directory.path}/images_${location.objectID}');

    if (!await imageDirectory.exists()) {
      await imageDirectory.create();
    }

    // Download and save images
    for (String imageUrl in location.imageURL) {
      final uri = Uri.parse(imageUrl);
      final imageName = uri.pathSegments.last;
      final imageFile = File('${imageDirectory.path}/$imageName');

      if (!await imageFile.exists()) {
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          await imageFile.writeAsBytes(response.bodyBytes);
        } else {
          print('Failed to download image: $imageUrl');
        }
      }
    }

    // Serialize the Location object to JSON
    final jsonString = jsonEncode(location.toJson());

    // Write the JSON string to a file
    final file = File(filePath);
    await file.writeAsString(jsonString);

    print('Location and images saved to $filePath');
  } catch (e) {
    print('Error saving location: $e');
  }
}

Future<Location?> loadLocationFromFile(String objectID) async {
  try {
    // Get the directory for storing app data
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/location_$objectID.json';
    final imageDirectory = Directory('${directory.path}/images_${objectID}');

    // Read the file content
    final file = File(filePath);
    if (await file.exists()) {
      final jsonString = await file.readAsString();

      // Deserialize the JSON string to a Location object
      final jsonData = jsonDecode(jsonString);
      final location = Location.fromJson(jsonData);

      // Check if images exist and add local paths
      final localImagePaths = <String>[];
      if (await imageDirectory.exists()) {
        final imageFiles = await imageDirectory.list().toList();
        for (var imageFile in imageFiles) {
          if (imageFile is File) {
            localImagePaths.add(imageFile.path);
          }
        }
      }

      location.imageURL.clear();
      location.imageURL.addAll(localImagePaths);

      return location;
    } else {
      print('File not found: $filePath');
      return null;
    }
  } catch (e) {
    print('Error loading location: $e');
    return null;
  }
}

Future<List<String>> listSavedObjectIDs() async {
  try {
    // Get the directory for storing app data
    final directory = await getApplicationDocumentsDirectory();
    final directoryPath = directory.path;

    // List all files in the directory
    final dir = Directory(directoryPath);
    final files = await dir.list().toList();

    // Filter and extract objectIDs from filenames
    final objectIDs = files
        .where((file) => file is File && file.path.endsWith('.json'))
        .map((file) {
      final fileName = file.uri.pathSegments.last;
      return fileName
          .replaceFirst('location_', '')
          .replaceFirst('.json', '');
    })
        .toList();

    return objectIDs;
  } catch (e) {
    print('Error listing saved object IDs: $e');
    return [];
  }
}
