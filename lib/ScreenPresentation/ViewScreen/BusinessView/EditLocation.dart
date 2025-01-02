import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelaca/Model/LocationClass.dart';

class EditLocationScreen extends StatefulWidget {
  final Location location;
  EditLocationScreen({required this.location});

  @override
  _EditLocationScreenState createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  final TextEditingController locationDetailsController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the controllers with data
    titleController.text = widget.location.name;
    addressController.text = widget.location.address;
    locationDetailsController.text = widget.location.description ?? '';
  }
  Future<void> saveLocationDetails() async {
    // Check if any of the fields are empty
    if (titleController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        locationDetailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields must be filled")),
      );
      return; // Exit the method without proceeding further
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _firestore.collection('Locations').doc(widget.location.businessId).update({
        'name': titleController.text.trim(),
        'address': addressController.text.trim(),
        'description': locationDetailsController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location details saved successfully!")),
      );
      Navigator.pop(context);
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
            // Title, Address, and Image Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  // Display the first image of the location
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.location.imageURL.isNotEmpty
                          ? widget.location.imageURL.first
                          : 'https://via.placeholder.com/80',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
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
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: widget.location.imageURL.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.location.imageURL[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),

                  // Upload Images Button
                  ElevatedButton.icon(
                    onPressed: () {

                    },
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
