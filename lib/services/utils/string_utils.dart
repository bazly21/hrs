String getInitials(String fullName) {
  List<String> names = fullName.split(" ");
  String initials = "";

  // Check if the full name contains at least one part
  if (names.isNotEmpty) {
    // Get the first character of the first name
    initials += names.first[0];
    
    // Check if there are more than one part to get the last name initial
    if (names.length > 1) {
      // Get the first character of the last name
      initials += names.last[0];
    }
  }

  // Return the initials in uppercase
  // in case the initials is not uppercase
  return initials.toUpperCase();
}
