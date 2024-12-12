import 'package:flutter/material.dart';
import 'package:travelaca/MainPage.dart';
import 'package:travelaca/Model/SearchService.dart';
import 'package:travelaca/Model/LocationClass.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/UserView/ViewScreen.dart';
import 'package:travelaca/utils/FilterButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;
  int _state = 0; // 0 = Recommendations, 1 = Search History, 2 = Search with Filters
  final SearchService _searchService = SearchService();
  final List<Location> _searchHistory = [
    Location(
      objectID: "obj1",
      businessId: "1",
      name: "Sunny Beach",
      address: "123 Ocean Drive",
      city: "Beach City",
      latitude: 36.7783,
      longitude: -119.4179,
      stars: 4.5,
      reviewCount: 120,
      isOpen: true,
      categories: "Beach, Relaxation, Vacation",
      description: "A perfect spot to relax by the ocean and enjoy sunny weather.",
      imageURL: ['https://th.bing.com/th/id/OIP._XXipl6cr4pehzbEZxHyUgHaEo?rs=1&pid=ImgDetMain'],
    ),
    Location(
      objectID: "obj2",
      businessId: "2",
      name: "Mountain Escape",
      address: "456 Highland Ave",
      city: "Mountain Town",
      latitude: 34.0522,
      longitude: -118.2437,
      stars: 4.8,
      reviewCount: 200,
      isOpen: true,
      categories: "Hiking, Nature, Adventure",
      description: "An adventurous getaway for nature lovers and hikers.",
      imageURL: ['https://th.bing.com/th/id/OIP._XXipl6cr4pehzbEZxHyUgHaEo?rs=1&pid=ImgDetMain'],
    ),
    Location(
      objectID: "obj3",
      businessId: "3",
      name: "City Gallery",
      address: "789 Urban St",
      city: "Metro City",
      latitude: 40.7128,
      longitude: -74.0060,
      stars: 4.2,
      reviewCount: 90,
      isOpen: false,
      categories: "Art, Culture, Museum",
      description: "A cultural hub showcasing the best in modern art.",
      imageURL:['https://th.bing.com/th/id/OIP._XXipl6cr4pehzbEZxHyUgHaEo?rs=1&pid=ImgDetMain'],
    ),
  ];


  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _state = 0; // Reset state
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _searchResults = [];
      _state = 2; // Switch to Search with Filters
    });
    final results = await _searchService.performSearch(query);
    for (var result in results) {
      print('Location: ${result.name}');
      print('Address: ${result.address}');
      print('Stars: ${result.stars}');
      print('Review Count: ${result.reviewCount}');
      print('Images: ${result.imageURL}');
      // Separator for readability
    }
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _onSearchBarTapped() {
    setState(() {
      if (_state == 0) {
        _state = 1; // Move to Search History
      } else {
        _state = 2; // Move to Search with Filters
      }
    });
  }
  void _onCancelTapped() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();
    // Add a short delay to ensure the keyboard dismissal is complete
    await Future.delayed(Duration(milliseconds: 100));
    // Clear search and return to default state
    setState(() {
      _state = 0;
      _searchController.clear();
    });
  }

  void _onScreenTapped() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(Duration(milliseconds: 100));
    if (_state != 2) {
      setState(() {
        _state = 0; // Reset to default state if not in detail view
      });
    }
  }
    void _navigateToLocationDetails(Location result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewScreenSearch(location: result),
      ),
    ).then((_) {
      // Ensure we return to the Search with Filters state
      setState(() {
        _state = 2;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onScreenTapped,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  // Background Image
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Home.png'),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white.withOpacity(0.9), // Light color at the bottom
                            Colors.transparent, // Fades out at the top
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: 300, // Set your desired width
                            height: 60, // Set your desired height
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: "Search your destination",
                                prefixIcon: Icon(Icons.search, color: Colors.teal),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200]?.withOpacity(0.7),
                              ),
                              onChanged: _onSearchChanged,
                              onTap: _onSearchBarTapped,
                            ),
                          )
                        ),
                        SizedBox(width: 8),
                        TextButton(
                          onPressed: _onCancelTapped,
                          child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                        ),
                      ],
                    ),
                  ),
                  if (_state == 2)
                    Positioned(
                      bottom: 20,
                      child:
                    Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterButton(label: 'Restaurant', onPressed: _performSearch),
                            FilterButton(label: 'Coffee', onPressed: _performSearch),
                            FilterButton(label: 'Museum', onPressed: _performSearch),
                            FilterButton(label: 'Hotel', onPressed: _performSearch)
                          ],
                        ),
                      ),
                    ),
                    )
                ],
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
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
  Widget buildPopularPlace(String title, String imagePath) {
    return GestureDetector(
      onTap: () {}, // Handle navigation or any action here
      child: Container(
        width: 200, // Adjust width as per your design
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildBody() {
    if (_state == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(11.0),
            child: Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 220, // Set the height to fit the card
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  placeCard("Jimbaran Beach", "16.5 Km", "assets/images/beach1.jpg", 4.5),
                  placeCard("Muaya Beach", "19.5 Km", "assets/images/beach2.jpg", 4.5),
                  placeCard("Nusa Dua Beach", "25.5 Km", "assets/images/beach3.jpg", 4.0),
                  placeCard("Seminyak Beach", "12.5 Km", "assets/images/beach4.jpg", 5.0),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(11.0),
            child: Text(
              'Popular',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 220, // Set the height to fit the card
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildPopularPlace("Jimbaran Beach", "assets/images/beach1.jpg"),
                  buildPopularPlace("Muaya Beach", "assets/images/beach2.jpg"),
                  buildPopularPlace("Nusa Dua Beach", "assets/images/beach3.jpg"),
                  buildPopularPlace("Seminyak Beach", "assets/images/beach4.jpg"),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (_state == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'You Search For',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8.0),
              children: _searchHistory.map((location) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.text = location.name;
                      _state = 2;
                    });
                    _performSearch(location.name);
                  },
                  child: _buildResultCard(location), // Display the location as a card
                );
              }).toList(),
            ),
          ),
        ],
      );
    }
    else if (_state == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
            child: Text(
              _searchController.text.isNotEmpty
                  ? 'You searched for "${_searchController.text}"'
                  : 'Search Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isSearching)
            Center(child: CircularProgressIndicator()),
          if (!_isSearching && _searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4.0),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return GestureDetector(
                    onTap: () => _navigateToLocationDetails(result),
                    child: _buildResultCard(result),
                  );
                },
              ),
            ),
          if (!_isSearching && _searchResults.isEmpty && _searchController.text.isNotEmpty)
            Center(child: Text('No results found.')),
        ],
      );
    }
    return SizedBox.shrink();
  }
  Widget _buildFilterButton(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
        ),
        onPressed: () => _performSearch(label),
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildResultCard(Location result) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      color: Colors.white,
      child: Row(
        children: [
          // Display the first image from the imageURL list
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: result.imageURL.isNotEmpty ? result.imageURL.first : '',
              width: 70,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(), // Placeholder
              errorWidget: (context, url, error) => Icon(Icons.error),    // Error widget
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    result.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
