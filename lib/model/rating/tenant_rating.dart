class TenantRating {
  final String reviewerID;
  final double paymentRating;
  final double maintenanceRating;
  final double communicationRating;
  final String comments;

  TenantRating({
    required this.reviewerID,
    required this.paymentRating,
    required this.maintenanceRating,
    required this.communicationRating,
    required this.comments,
  });

  // Convert a rating object into a map
  Map<String, dynamic> toMap() {
    return {
      "reviewerID": reviewerID,
      "reviewedAs": "Tenant",
      "paymentRating": paymentRating,
      "maintenanceRating": maintenanceRating,
      "communicationRating": communicationRating,
      "comments": comments,
    };
  }
}