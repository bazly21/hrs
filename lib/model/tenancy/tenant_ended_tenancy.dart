class TenantEndedTenancy {
  final String propertyID;
  final String propertyName;
  final String propertyAddress;
  final double rentalPrice;
  final String propertyImageURL;
  final String landlordID;
  final String landlordImageURL;
  final int landlordRatingCount;
  final double landlordRatingAverage;
  final String tenancyDocID;
  final String tenancyStatus;
  final bool isRated;

  TenantEndedTenancy({
    required this.propertyID,
    required this.propertyName,
    required this.propertyAddress,
    required this.rentalPrice,
    required this.propertyImageURL,
    required this.landlordID,
    required this.landlordImageURL,
    required this.landlordRatingCount,
    required this.landlordRatingAverage,
    required this.tenancyDocID,
    required this.tenancyStatus,
    required this.isRated,
  });

  factory TenantEndedTenancy.fromMap(Map<String, dynamic> data) {
    return TenantEndedTenancy(
      propertyID: data['propertyID'],
      propertyName: data['propertyName'],
      propertyAddress: data['propertyAddress'],
      rentalPrice: data['rentalPrice'],
      propertyImageURL: data['propertyImageURL'],
      landlordID: data['landlordID'],
      landlordImageURL: data['landlordImageURL'],
      landlordRatingCount: data['landlordRatingCount'],
      landlordRatingAverage: data['landlordRatingAverage'],
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
      'tenantID': landlordID,
      'tenantImageURL': landlordImageURL,
      'tenantRatingCount': landlordRatingCount,
      'tenantRatingAverage': landlordRatingAverage,
      'tenancyDocID': tenancyDocID,
      'tenancyStatus': tenancyStatus,
      'isRated': isRated,
    };
  }
}
