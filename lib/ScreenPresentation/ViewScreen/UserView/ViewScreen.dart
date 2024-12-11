import 'package:flutter/material.dart';
import 'package:travelaca/Model/LocationClass.dart';
class ViewScreenSearch extends StatefulWidget {
  final Location location;

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
  final String description =
      'The Golden Bridge (Cầu Vàng) in Da Nang City, Vietnam, is a world-renowned architectural marvel perched in the scenic Ba Na Hills. '
      'Completed in 2018, the bridge is celebrated for its unique design: a golden pedestrian walkway held aloft by two giant, weathered stone hands emerging from the hillside. '
      'Stretching 150 meters (490 feet) and situated at an elevation of over 1,400 meters (4,600 feet) above sea level, the bridge offers breathtaking panoramic views of lush mountains, '
      'verdant forests, and a surreal blend of nature and modern artistry. Its golden balustrades glisten under the sunlight, making it a photogenic and iconic landmark.';
  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  'assets/images/Home.png', // Replace with your image
                  fit: BoxFit.cover,
                ),
              ),
              // Back and Favorite Buttons
              Positioned(
                top: 40, // Adjust for better positioning
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
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
                    widget.location.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.location.address,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Rating Section
                  Row(
                    children: [
                      // Generate the stars dynamically
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.location.stars ? Icons.star : Icons.star_border,
                            color: index < widget.location.stars ? Color(0xFF17727F) : Colors.grey,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.location.stars.toString()

                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.location.reviewCount} reviews',
                        style: TextStyle(color: Colors.grey),
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
                        ? description // Full text when expanded
                        : '${description.substring(0, 150)}...', // Truncated text when collapsed
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
                  Text(
                    'Images',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF17727F)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Replace with actual number of images
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/beach1.jpg', // Replace with dynamic image
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                  children: [
                    Text(
                      widget.location.stars.toString(),
                      style: TextStyle(
                       fontWeight: FontWeight.bold,
                        fontSize: 24,
                      )
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
                              index < widget.location.stars ? Icons.star : Icons.star_border,
                              color: index < widget.location.stars ? Color(0xFF17727F) : Colors.grey,
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
                  // Reviews Section
                  Text(
                    'Reviews (${widget.location.reviewCount})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:Color(0xFF17727F)),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle the button action
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
