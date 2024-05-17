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
  final String? propertyID;
  final String? propertyName;
  final String? facilities;
  final String? landlordName;
  final int? landlordRatingCount;
  final double? landlordOverallRating;
  final bool? enableApplyButton;

  PropertyFullDetails({
    this.furnishing,
    this.image,
    this.address,
    this.description,
    this.landlordID,
    this.accessibilities,
    this.bathrooms,
    this.rentalPrice,
    this.bedrooms,
    this.size,
    this.propertyID,
    this.propertyName,
    this.facilities,
    this.landlordName,
    this.landlordRatingCount,
    this.landlordOverallRating,
    this.enableApplyButton,
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
      landlordName: data['landlordName'] ?? 'N/A',
      landlordRatingCount: data['landlordRatingCount'] ?? 0,
      landlordOverallRating: data['landlordOverallRating'] ?? 0.0,
      enableApplyButton: data['enableApplyButton'] ?? true,
    );
  }

  factory PropertyFullDetails.fromMapHalfDetails(Map<String, dynamic> data) {
    return PropertyFullDetails(
      propertyID: data['propertyID'],
      propertyName: data['name'] ?? 'N/A',
      address: data['address'] ?? 'N/A',
      rentalPrice: data['rent'] ?? 0.0,
      bathrooms: data['bathrooms'] ?? 0,
      bedrooms: data['bedrooms'] ?? 0,
      size: data['size'] ?? 0.0,
      image: List<String>.from(data['image']),
      landlordID: data['landlordID'],
      landlordName: data['landlordName'] ?? 'N/A',
      landlordRatingCount: data['landlordRatingCount'] ?? 0,
      landlordOverallRating: data['landlordOverallRating'] ?? 0.0,
    );
  }
}
