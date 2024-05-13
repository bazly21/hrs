class PropertyFullDetails {
  final String? furnishing;
  final List<String>? image;
  final String? address;
  final String? description;
  final String? landlordID;
  final String? accessibilities;
  final int? bathrooms;
  final num? rentalPrice;
  final int? bedrooms;
  final num? size;
  final String? propertyName;
  final String? facilities;
  final String? landlordName;
  final int? landlordRatingCount;
  final double? landlordOverallRating;
  final bool? hasApplied;

  PropertyFullDetails({
    required this.furnishing,
    required this.image,
    required this.address,
    required this.description,
    required this.landlordID,
    required this.accessibilities,
    required this.bathrooms,
    required this.rentalPrice,
    required this.bedrooms,
    required this.size,
    required this.propertyName,
    required this.facilities,
    required this.landlordName,
    required this.landlordRatingCount,
    required this.landlordOverallRating,
    required this.hasApplied,
  });

  factory PropertyFullDetails.fromMapFullDetails(Map<String, dynamic> data) {
    return PropertyFullDetails(
      furnishing: data['furnishing'],
      image: List<String>.from(data['image']),
      address: data['address'],
      description: data['description'],
      landlordID: data['landlordID'],
      accessibilities: data['accessibilities'],
      bathrooms: data['bathrooms'] ?? 0,
      rentalPrice: data['rent'] ?? 0.0,
      bedrooms: data['bedrooms'] ?? 0,
      size: data['size'] ?? 0.0,
      propertyName: data['name'] ?? 'N/A',
      facilities: data['facilities'],
      landlordName: data['landlordName'],
      landlordRatingCount: data['landlordRatingCount'] ?? 0,
      landlordOverallRating: data['landlordOverallRating'] ?? 0.0,
      hasApplied: data['hasApplied'] ?? false,
    );
  }
}
