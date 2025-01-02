import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../Model/LocationClass.dart';
import '../LoginScreen/LoginScreen.dart';
import 'OfflineDetail.dart';
import 'OfflineHome.dart';

class SavedLocationsScreen extends StatefulWidget {
  @override
  _SavedLocationsScreenState createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  List<Location?> savedLocations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  // Method to list saved object IDs
  Future<List<String>> listSavedObjectIDs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final directoryPath = directory.path;

      final dir = Directory(directoryPath);
      final files = await dir.list().toList();

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
  @override
  void dispose() {
    //NetworkManager().stopMonitoring();
    super.dispose();
  }
  Future<void> _refresh()async {
    bool hasConnection = await checkConnection();
    if (hasConnection) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
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
  }
  // Method to load a location from file
  Future<Location?> loadLocationFromFile(String objectID) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/location_$objectID.json';
      final imageDirectory = Directory('${directory.path}/images_$objectID');

      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString);
        final location = Location.fromJson(jsonData);

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

  // Method to load saved locations
  Future<void> _loadSavedLocations() async {
    try {
      // Get list of saved object IDs
      final objectIDs = await listSavedObjectIDs();

      // Load locations for each object ID
      final locations = await Future.wait(
        objectIDs.map((objectID) => loadLocationFromFile(objectID)),
      );

      setState(() {
        savedLocations = locations.where((location) => location != null).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading saved locations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Locations'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : savedLocations.isEmpty
          ? Center(child: Text('No saved locations found.'))
          : RefreshIndicator(onRefresh: _refresh,child: ListView.builder(
        itemCount: savedLocations.length,
        itemBuilder: (context, index) {

          final location = savedLocations[index];
          if (location == null) return SizedBox.shrink();

          return ListTile(
            leading: location.imageURL.isNotEmpty
                ? Image.file(
              File(location.imageURL.first),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : Icon(Icons.location_on, size: 50),
            title: Text(location.name),
            subtitle: Text(location.address),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OfflineDetailScreen(location: location),
                ),
              );
            },
          );
        },
      ),
      )
    );
  }
}
