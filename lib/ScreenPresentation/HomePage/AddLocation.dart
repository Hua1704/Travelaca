import 'package:algoliasearch/algoliasearch.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../Network/storage.dart';

class AddLocationScreen extends StatefulWidget {
  final String userID; // User ID to associate the location with the business owner

  AddLocationScreen({required this.userID});

  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final TextEditingController locationDetailsController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController categoriesController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isSaving = false;
  List<String> selectedCategories = []; // Store selected categories
  List<File> selectedImages = [];
  Future<void> saveLocationDetails() async {
    // Validate fields
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Title must be filled.")),
      );
      return;
    }
    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Address must be filled.")),
      );
      return;
    }
    if (locationDetailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location details must be filled.")),
      );
      return;
    }
    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("At least one category must be selected.")),
      );
      return;
    }
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("At least one image must be uploaded.")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final Storage storage = Storage(); // Create an instance of the Storage class
      final newLocationRef = _firestore.collection('Locations').doc();
      List<String> imageURLs = [];
      for (var image in selectedImages) {
        final imageUrl = await storage.uploadImageToStorage(
          childPath: "Locations/${newLocationRef.id}",
          file: image,
          id: newLocationRef.id,
        );
        imageURLs.add(imageUrl);
      }
      // Save location details in Firestore
      await newLocationRef.set({
        'name': titleController.text.trim(),
        'address': addressController.text.trim(),
        'description': locationDetailsController.text.trim(),
        'categories': selectedCategories,
        'image_urls': imageURLs,
        'business_id': newLocationRef.id,
        'review_count': 0,
        'stars': 0,
        'owner_id': widget.userID
      });

      final algoliaResponse = await addToAlgoliaIndex(
        objectID: newLocationRef.id,
        body: {
          'name': titleController.text.trim(),
          'address': addressController.text.trim(),
          'description': locationDetailsController.text.trim(),
          'categories': selectedCategories,
          'business_id': newLocationRef.id,
          'image_urls': imageURLs,
        },
      );

      if (algoliaResponse) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location added successfully!")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Failed to add location to Algolia.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save location details: $e")),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }



  Future<bool> addToAlgoliaIndex({
    required String objectID,
    required Map<String, dynamic> body,
  }) async {
    try {
      final client = SearchClient(
        appId: dotenv.env['ALGOLIA_APPLICATION_ID']!,
        apiKey: dotenv.env['ALGOLIA_API_KEY']!,
      );

      final response = await client.addOrUpdateObject(
        indexName: dotenv.env['ALGOLIA_INDEX_NAME']!,
        objectID: objectID,
        body: body,
      );

      // Check if the response is successful
      if (response.objectID != null) {
        print("Successfully added/updated location in Algolia: ${response.objectID}");
        return true;
      } else {
        print("Failed to add/update location in Algolia.");
        return false;
      }
    } catch (e) {
      print("Error adding location to Algolia: $e");
      return false;
    }
  }



  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        selectedImages.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
      });
    }
  }

  void addCategory(String category) {
    if (category.isNotEmpty && !selectedCategories.contains(category)) {
      setState(() {
        selectedCategories.add(category);
      });
      categoriesController.clear();
    }
  }

  void removeCategory(String category) {
    setState(() {
      selectedCategories.remove(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Location"),
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
            // Title and Address Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editable Title
                  TextField(
                    controller: titleController,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "Enter location title",
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Editable Address
                  TextField(
                    controller: addressController,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    decoration: InputDecoration(
                      hintText: "Enter location address",
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Location Details Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Location Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: locationDetailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter location details here...",
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Categories Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: categoriesController,
                    decoration: InputDecoration(
                      hintText: "Enter a category and press 'Add'",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => addCategory(categoriesController.text.trim()),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: selectedCategories
                        .map((category) => Chip(
                      label: Text(category),
                      onDeleted: () => removeCategory(category),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Images Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Images",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                         selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: Icon(Icons.camera_alt),
                    label: Text("Upload Images"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: isSaving ? null : saveLocationDetails,
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
}
