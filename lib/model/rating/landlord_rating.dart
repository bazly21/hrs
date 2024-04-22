class LandlordRating {
  final String reviewerID;
  final String landlordID;
  final double supportRating;
  final double maintenanceRating;
  final double communicationRating;
  final String comments;

  LandlordRating({
    required this.reviewerID,
    required this.landlordID,
    required this.supportRating,
    required this.maintenanceRating,
    required this.communicationRating,
    required this.comments,
  });

  // Convert a rating object into a map
  Map<String, dynamic> toMap() {
    return {
      'reviewerID': reviewerID,
      'landlordID': landlordID,
      'supportRating': supportRating,
      'maintenanceRating': maintenanceRating,
      'communicationRating': communicationRating,
      'comments': comments,
    };
  }
}