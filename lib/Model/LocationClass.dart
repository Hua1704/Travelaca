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
      state: json['state']??'',
      imageURL: (json['image_urls'] as List<dynamic>?)
          ?.map((url) => url.toString())
          .toList() ?? [], // Safely convert to List<String>
    );
  }
}