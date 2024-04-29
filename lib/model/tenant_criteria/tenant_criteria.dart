class TenantCriteria {
  final String? profileType;
  final String? numberOfPax;
  final String? nationality;
  final String? tenancyDuration;

  TenantCriteria({
    required this.profileType,
    required this.numberOfPax,
    required this.nationality,
    required this.tenancyDuration,
  });

  // Convert TenantCriteria object to map
  Map<String, dynamic> toMap() {
    return {
      'profileType': profileType,
      'numberOfPax': numberOfPax,
      'nationality': nationality,
      'tenancyDuration': tenancyDuration,
    };
  }
}
