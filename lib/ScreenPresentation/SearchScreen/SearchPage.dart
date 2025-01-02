import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:travelaca/MainPage.dart';
import 'package:travelaca/Model/SearchService.dart';
import 'package:travelaca/Model/LocationClass.dart';
import 'package:travelaca/ScreenPresentation/ViewScreen/UserView/ViewScreen.dart';
import 'package:travelaca/utils/FilterButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Network/auth.dart';
import '../../Network/firebase_cloud_firesotre.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  List<Location> _filteredResults = [];
  List<String> _selectedFilters = [];
  bool _isSearching = false;
  Timer? _searchDebounce;
  int _state = 0; // 0 = Recommendations, 1 = Search History, 2 = Search with Filters
  final SearchService _searchService = SearchService();
  final CloudFirestore _locationService = CloudFirestore();
  late Future<List<Map<String, dynamic>>> _recommendationsFuture;
  void initState() {
    final User? user = FirebaseAuth.instance.currentUser;
    super.initState();
    _recommendationsFuture = CloudFirestore().fetchRecommendationsForUser();
    if(Auth().currentUser==null)
      {
        _loadSearchHistoryForGuest();
      }
    else {
    _loadSearchHistory();
  }
  }
  Future<void> saveSearchToCache(String locationId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch the existing search history from cache
    List<String> searchHistory = prefs.getStringList('guest_search_history') ?? [];

    // Add the new locationId to the history
    searchHistory.add(locationId);

    // Keep only the last 10 searches
    if (searchHistory.length > 10) {
      searchHistory = searchHistory.sublist(searchHistory.length - 10);
    }

    // Save the updated search history back to cache
    await prefs.setStringList('guest_search_history', searchHistory);
    print('save to cache');
  }
  Future<List<Location>> _fetchCachedSearchHistory() async {
    try {
      // Get the cached IDs
      final prefs = await SharedPreferences.getInstance();
      final cachedHistory = prefs.getStringList('guest_search_history') ?? [];

      if (cachedHistory.isEmpty) {
        return [];
      }

      // Fetch the location details for each ID from Firestore
      final List<Location> locations = [];
      for (final id in cachedHistory) {
        final location = await CloudFirestore.fetchLocation(id);
        if (location != null) {
          locations.add(location);
        }
      }

      return locations;
    } catch (e) {
      print("Error fetching cached search history: $e");
      return [];
    }
  }
  late final List<Location> _searchHistory;
  void _loadSearchHistory() async {
    final history = await CloudFirestore().fetchSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }
  Future<void> saveLastViewedBusiness(String businessId) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (isGuestUser()) {
        print("User not logged in.");
        return;
      }
      // Reference to the user's Firestore document
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(user?.uid);

      // Get the current last_viewed_algolia_id array
      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        List<dynamic> lastViewedList = userDoc.data()?['last_viewed_algolia_id'] ?? [];
        lastViewedList = List<String>.from(lastViewedList);
        lastViewedList.insert(0, businessId);
        if (lastViewedList.length > 3) {
          lastViewedList = lastViewedList.sublist(0, 3);
        }
        await userDocRef.update({'last_viewed_algolia_id': lastViewedList});
        print("Last viewed business updated: $lastViewedList");
      } else {
        // If the user document does not exist, create one with the business ID
        await userDocRef.set({
          'last_viewed_algolia_id': [businessId],
        });
        print("New user document created with last viewed business.");
      }
    } catch (e) {
      print("Error saving last viewed business: $e");
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });
    if(query.isEmpty == false) {
      try {
        _searchResults = await _searchService.performSearch(query);
        setState(() {
          _filteredResults = List.from(_searchResults);
          _isSearching = false;
          if (Auth().currentUser != null) {
            CloudFirestore().saveUserSearch(_filteredResults[0].businessId);
            CloudFirestore().saveUserSearch(_filteredResults[1].businessId);
            CloudFirestore().saveUserSearch(_filteredResults[2].businessId);
          }
          else {
            saveSearchToCache(_filteredResults[0].businessId);
            saveSearchToCache(_filteredResults[1].businessId);
            saveSearchToCache(_filteredResults[2].businessId);
          }
        });
      }
      catch (e) {
        print("Error during search: $e");
        setState(() {
          _isSearching = false;
          _searchResults = [];
          _filteredResults = [];
        });
      }
    }

  }
  void _applyFilters(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        // If filter is already selected, remove it
        _selectedFilters.remove(filter);
      } else {
        // Add the filter in order
        _selectedFilters.add(filter);
      }

      // Start with the original search results
      List<Location> filtered = List.from(_searchResults);

      // Apply filters in the order they are in _selectedFilters
      for (String selectedFilter in _selectedFilters) {
        filtered = filtered.where((location) {
          return location.categories.toLowerCase().contains(selectedFilter.toLowerCase());
        }).toList();
      }

      // Update the filtered results
      _filteredResults = filtered;
      // If no filters are selected, reset to original search results
      if (_selectedFilters.isEmpty) {
        _filteredResults = List.from(_searchResults);
      }
    });
  }


  void _loadSearchHistoryForGuest() async {
    final location = await _fetchCachedSearchHistory();
    final List<Location> history = [];
    for (final id in location) {
      final location = await CloudFirestore.fetchLocation(id.objectID); // Fetch location details
      if (location != null) {
        history.add(location);
      }
        print(location?.businessId);

    }
    setState(() {
      _searchHistory = history; // Update the state with the fetched history
    });
  }


  void _onSearchChanged(String query) {
    // Cancel any ongoing debounce timer
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 100), () {
      // Perform search if query is not empty
      if (query.isNotEmpty) {
        _performSearch(query);
        setState(() {
          _state = 2;
        });
      } else {
        setState(() {
          _searchResults = [];
          _filteredResults =[];
          _state = 1; // Reset state
        });
      }
    });
  }

  void _onSearchBarTapped() {
    setState(() {
      if (_state == 0) {
        _state = 1; // Move to Search History
      } else if(_state ==1)
      {
        _state = 2; // Move to Search with Filters
      }

    });
  }

  void _onCancelTapped() async {
    // Dismiss the keyboard and reset state
    FocusScope.of(context).unfocus();
    await Future.delayed(Duration(milliseconds: 150));
    // Clear search field and reset everything
    setState(() {
      _state = 0; // Default state
      _searchController.clear(); // Clear text field
      _searchResults = []; // Clear search results
      if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel(); // Cancel debounce
    });
  }

  void _onScreenTapped() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(Duration(milliseconds: 150));
    if (_state != 2) {
      setState(() {
        _state = 0; // Reset to default state if not in detail view
      });
    }
  }
    Future<void> _navigateToLocationDetails(Location? result) async {
    final location = await CloudFirestore.fetchLocation(result!.objectID);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewScreenSearch(location: location),
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
                      bottom: 10,
                      left: 0, // Add this to ensure the scrollable area starts from the left
                      right: 0, // Add this to ensure the scrollable area stretches across the screen
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding for spacing
                        child: Container(
                          height: 50, // Ensure the row has a fixed height for scrolling
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterButton(label: 'Historical', onPressed: _applyFilters),
                                FilterButton(label: 'Religious', onPressed: _applyFilters),
                                FilterButton(label: 'Nature', onPressed: _applyFilters),
                                FilterButton(label: 'Entertainment', onPressed: _applyFilters),
                                FilterButton(label: 'Beach', onPressed: _applyFilters),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }
  Widget placeCard(String title, String address, String imagePath, double stars, String id) {
    return GestureDetector(
      onTap: () async {
        saveLastViewedBusiness(id);
        final location = await CloudFirestore.fetchLocation(id);
        if (location != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewScreenSearch(location: location),
            ),
          );
        }

      },
      child: Container(
        width: 180,
        height: 202,
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: imagePath.isNotEmpty
                ? NetworkImage(imagePath)
                : AssetImage('assets/images/default_image.jpg') as ImageProvider,
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
                          size: 12,
                        ),
                        Text(
                          address,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
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
          Container(
            height: 180, // Height of the horizontal list
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _recommendationsFuture, // Fetch recommendations dynamically
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Show loading spinner
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}')); // Show error message
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final recommendations = snapshot.data!;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final location = recommendations[index];
                      return placeCard(
                        location['name'] ?? 'Unknown Place', // Name of the location
                        location['address'] ?? 'Unknown place', // Distance from the user
                        location['image_urls'] != null && location['image_urls'].isNotEmpty
                            ? location['image_urls'][0] // Use the first image in the list
                            : 'assets/images/default_image.jpg',
                        (location['stars'] ?? 0.0).toDouble(),
                        location['id'] ?? '',
                        //location['stars'] ?? 0
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No recommendations found.')); // No data available
                }
              },
            ),
          ),


        ],
      );
    }
    else if (_state == 1) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (Auth().currentUser == null) {
        // Guest user: Use local cache
        return FutureBuilder<List<Location>>(
          future: _fetchCachedSearchHistory(), // Fetch cached search history
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Show loading indicator
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final searchHistory = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Your Search History (Guest)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0),
                      itemCount: searchHistory.length,
                      itemBuilder: (context, index) {
                        final location = searchHistory[index];
                        return GestureDetector(
                          onTap: () {
                            saveSearchToCache(location.objectID); // Save to cache
                            _navigateToLocationDetails(location);
                          },
                          child: _buildResultCard(location), // Build result card with Location data
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text("You have no search history (Guest)."));
            }
          },
        );
      } else {
        // Logged-in user: Use Firestore
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('Users').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Show loading indicator
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.data() != null) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final List<dynamic> searchHistoryIds = userData['last_10_searched'] ?? [];
              if (searchHistoryIds.isEmpty) {
                return Center(child: Text("You have no search history."));
              }
              return FutureBuilder<List<Location>>(
                future: CloudFirestore().fetchSearchHistory(), // Fetch search history for logged-in user
                builder: (context, historySnapshot) {
                  if (historySnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (historySnapshot.hasError) {
                    return Center(child: Text('Error: ${historySnapshot.error}'));
                  } else if (historySnapshot.hasData && historySnapshot.data!.isNotEmpty) {
                    final searchHistory = historySnapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Your Search History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8.0),
                            itemCount: searchHistory.length,
                            itemBuilder: (context, index) {
                              final location = searchHistory[index];
                              return GestureDetector(
                                onTap: () {
                                  CloudFirestore().saveLastViewedBusiness(location.objectID);
                                  _navigateToLocationDetails(location);
                                },
                                child: _buildResultCard(location), // Build result card with Location data
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text("You have no search history."));
                  }
                },
              );
            } else {
              return Center(child: Text("You have no search history."));
            }
          },
        );
      }
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
          if (!_isSearching && _filteredResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4.0),
                itemCount: _filteredResults.length,
                itemBuilder: (context, index) {
                  final result = _filteredResults[index];
                  return GestureDetector(
                    onTap: () => {
                      saveLastViewedBusiness(result.businessId),
                      _navigateToLocationDetails(result),},
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
