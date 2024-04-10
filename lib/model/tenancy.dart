class Tenancy {
  final String propertyID;
  final String tenantID;
  final int duration;
  final DateTime startDate;
  final DateTime endDate;

  Tenancy({
    required this.propertyID,
    required this.tenantID,
    required this.duration,
    required this.startDate,
    required this.endDate,
  });

  // Convert a message object into a map
  Map<String, dynamic> toMap() {
    return {
      'propertyID': propertyID,
      'tenantID': tenantID,
      'duration': duration,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
