import 'package:flutter/material.dart';
import 'OfflineDetail.dart';
class SavedLocationsScreen extends StatelessWidget {
  final List<String> savedLocations = ['Dalat', 'London', 'Rome', 'Bangkok'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Locations'),
      ),
      body: ListView.builder(
        itemCount: savedLocations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(savedLocations[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OfflineDetailScreen(location: savedLocations[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
