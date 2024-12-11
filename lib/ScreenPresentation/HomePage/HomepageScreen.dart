import 'package:flutter/material.dart';
import 'package:travelaca/ScreenPresentation/SearchScreen/SearchPage.dart';
class HottestTrend {
  final String? imageLink;
  final String? title;
  HottestTrend({this.imageLink, this.title});
}

class HomeScreen extends StatelessWidget{
  final VoidCallback onSearchTapped;
  HomeScreen({required this.onSearchTapped});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Home.png'), // Replace with your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    radius: 25,// Replace with your profile image
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.white.withOpacity(0.9), // Light color at the bottom
                          Colors.transparent, // Fades out at the top
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30), // Ensures ripple effect respects shape
                      onTap: onSearchTapped,
                      child: TextField(
                        enabled: false, // Disable the text field so it doesn't open the keyboard
                        decoration: InputDecoration(
                          hintText: "Search your destination",
                          prefixIcon: Icon(Icons.search, color:  Color(0xFF17727F) ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recommended Places",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("See All",
                    style: TextStyle(
                        color: Color(0xFF17727F),
                    ),),
                  ),
                ],
              ),
            ),
            Container(
              height: 180, // Height of the horizontal list
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  placeCard("Jimbaran Beach", "16.5 Km", "assets/images/beach1.jpg",4.5),
                  placeCard("Muaya Beach", "19.5 Km", "assets/images/beach2.jpg",4.5),
                  placeCard("Nusa Dua Beach", "25.5 Km", "assets/images/beach3.jpg",4.0),  // Add more places here
                  placeCard("Seminyak Beach", "12.5 Km", "assets/images/beach4.jpg",5.0),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Hottest Trend Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Promotion",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("See All",
                    style: TextStyle(
                      color: Color(0xFF17727F),
                    )),
                  ),
                ],
              ),
            ),
            _buildHottestTrend(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Future<List<HottestTrend>> fetchDummyHottestTrend() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate a network delay
    return List.generate(
      4,
          (index) => HottestTrend(
        imageLink: 'assets/images/beach$index.jpg',
        title: 'Promotion $index',
      ),
    );
  }
  Widget _buildHottestTrend() {
    return FutureBuilder(
      future: fetchDummyHottestTrend(), // Using dummy data
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: 160, // Adjust based on card height
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Image Section
                      ClipRRect(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
                        child: Image.asset(
                          snapshot.data![index].imageLink!,
                          width: 120,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Information Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data![index].title ?? "Promotion",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Sample description goes here.",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "4.5", // Example rating
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 14),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget placeCard(String title, String distance, String imagePath,double stars) {
    return GestureDetector(
      onTap: (){}, // Handle the navigation here
      child: Container(
        width: 180,
        height: 202,
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8), // White transparent background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                            Icons.location_on,
                        ),
                        Text(
                          distance,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: index < stars ? Color(0xFF17727F) : Colors.grey,
                          size: 12,
                        );
                      }),
                    ),
                  ],

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Review Page"),
    );
  }
}
class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Account Page"),
    );
  }
}