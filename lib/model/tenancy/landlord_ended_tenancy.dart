class LandlordEndedTenancy {
  final String propertyID;
  final String propertyName;
  final String propertyAddress;
  final double rentalPrice;
  final String propertyImageURL;
  final String tenantID;
  final String tenantName;
  final String? tenantImageURL;
  final int tenantRatingCount;
  final double tenantRatingAverage;
  final String tenancyDocID;
  final String tenancyStatus;
  final bool isRated;

  LandlordEndedTenancy({
    required this.propertyID,
    required this.propertyName,
    required this.propertyAddress,
    required this.rentalPrice,
    required this.propertyImageURL,
    required this.tenantID,
    required this.tenantName,
    this.tenantImageURL,
    required this.tenantRatingCount,
    required this.tenantRatingAverage,
    required this.tenancyDocID,
    required this.tenancyStatus,
    required this.isRated,
  });

  factory LandlordEndedTenancy.fromMap(Map<String, dynamic> data) {
    return LandlordEndedTenancy(
      propertyID: data['propertyID'],
      propertyName: data['propertyName'],
      propertyAddress: data['propertyAddress'],
      rentalPrice: data['rentalPrice'],
      propertyImageURL: data['propertyImageURL'],
      tenantID: data['tenantID'],
      tenantName: data['tenantName'],
      tenantImageURL: data['tenantImageURL'],
      tenantRatingCount: data['tenantRatingCount'],
      tenantRatingAverage: data['tenantRatingAverage'],
      tenancyDocID: data['tenancyDocID'],
      tenancyStatus: data['tenancyStatus'],
      isRated: data['isRated'],
    );
  }

  // Convert a message object into a map
  Map<String, dynamic> toMap() {
    return {
      'propertyID': propertyID,
      'propertyName': propertyName,
      'propertyAddress': propertyAddress,
      'rentalPrice': rentalPrice,
      'propertyImageURL': propertyImageURL,
      'tenantID': tenantID,
      'tenantImageURL': tenantImageURL,
      'tenantRatingCount': tenantRatingCount,
      'tenantRatingAverage': tenantRatingAverage,
      'tenancyDocID': tenancyDocID,
      'tenancyStatus': tenancyStatus,
      'isRated': isRated,
    };
  }
}
