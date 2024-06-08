import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:hrs/components/custom_appbar.dart";
import "package:hrs/components/custom_dropdown.dart";
import "package:hrs/components/custom_textformfield.dart";
import "package:hrs/model/application/application_model.dart";
import "package:hrs/services/property/application_service.dart";
import "package:intl/intl.dart";

class ApplyRentalPage extends StatefulWidget {
  final String propertyID;

  const ApplyRentalPage({super.key, required this.propertyID});

  @override
  ApplyRentalPageState createState() => ApplyRentalPageState();
}

class ApplyRentalPageState extends State<ApplyRentalPage> {
  final ApplicationService _applicationService = ApplicationService();
  final _formKey = GlobalKey<FormState>();

  String? _occupation;
  String? _selectedProfileType;
  String? _selectedNationality;
  int? _selectedNumberOfPax;
  int? _selectedTenancyDuration;
  DateTime? _moveInDate;

  // Get user ID
  final String? userUID = FirebaseAuth.instance.currentUser?.uid;

  // Define dropdown list items
  final List<String> _profileTypes = ["Student", "Working Adult", "Family"];
  final List<int> _paxNumbers = List.generate(10, (index) => index + 1);
  final List<String> _nationalities = ["Malaysian", "Non-Malaysian"];
  final List<int> _tenancyDurations = List.generate(12, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Apply Rent"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2), // Shadow color.
                  spreadRadius: 3,
                  blurRadius: 2, // Shadow blur radius.
                  offset: const Offset(0, 2), // Vertical offset for the shadow.
                ),
              ]),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextFormField(
                  label: "Occupation",
                  hintText: "Enter your occupation",
                  // controller: _occupationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your occupation";
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _occupation = value;
                  },
                ),
                const SizedBox(height: 20),
                CustomDropDownField(
                  label: "Profile Type",
                  hintText: "Select your profile type",
                  items: _profileTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProfileType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a profile type";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomDropDownField(
                  label: "Number of Pax",
                  hintText: "Select number of pax",
                  items: _paxNumbers.map((pax) {
                    return DropdownMenuItem<int>(
                      value: pax,
                      child: Text(pax.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNumberOfPax = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select number of pax";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomDropDownField(
                  label: "Nationality",
                  hintText: "Select your nationality",
                  items: _nationalities.map((nationality) {
                    return DropdownMenuItem<String>(
                      value: nationality,
                      child: Text(nationality),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNationality = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select nationality";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: "Date time",
                  hintText: "dd-mm-YYYY",
                  controller: TextEditingController(
                    text: _moveInDate == null
                        ? ""
                        : DateFormat("dd-MM-yyyy").format(_moveInDate!),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            _moveInDate = value;
                          });
                        }
                      });
                    },
                    icon: const Icon(Icons.calendar_today),
                  ),
                  validator: validateDate,
                  onChanged: (value) {
                    // If value entered is valid date, save it
                    if (validateDate(value) == null) {
                      _moveInDate = DateFormat("dd-MM-yyyy").parse(value, true);
                    }
                  },
                ),
                const SizedBox(height: 20),
                CustomDropDownField(
                  label: "Tenancy Duration (months)",
                  hintText: "Select tenancy duration",
                  items: _tenancyDurations.map((duration) {
                    return DropdownMenuItem<int>(
                      value: duration,
                      child: Text("$duration months"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTenancyDuration = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select tenancy duration";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35.0),
                // Submit and Reset buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _resetFields,
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(130, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8568F3),
                        foregroundColor: Colors.white,
                        fixedSize: const Size(130, 42),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetFields() {
    setState(() {
      _formKey.currentState?.reset();

      _selectedProfileType = null;
      _selectedNumberOfPax = null;
      _selectedNationality = null;
      _selectedTenancyDuration = null;
      _moveInDate = null;

      // Remove the focus
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future<void> _submitApplication() async {
    // Get the occupation from the text field
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create an application object
      Application application = Application(
        applicantID: userUID!,
        occupation: _occupation,
        profileType: _selectedProfileType,
        numberOfPax: _selectedNumberOfPax,
        nationality: _selectedNationality,
        moveInDate: _moveInDate,
        tenancyDuration: _selectedTenancyDuration,
      );

      // Save data to Firestore
      await _applicationService
          .saveApplication(widget.propertyID, application)
          .then(
        (_) {
          // Reset the form after successful submission
          _resetFields();

          Navigator.pop(context, "Application submitted successfully");
        },
      ).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit application. Error: $error"),
          ),
        );
      });
    }
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter move-in date";
    }

    // Regular expression to check for "dd-mm-yyyy" format
    RegExp regExp = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!regExp.hasMatch(value)) {
      return "Please enter the date in 'dd-mm-yyyy' format";
    }

    // Split the date string into components
    List<String> components = value.split('-');
    int day = int.parse(components[0]);
    int month = int.parse(components[1]);
    int year = int.parse(components[2]);

    // Check if the day is within the valid range
    if (day < 1 || day > 31) {
      return "Invalid day entered";
    }

    // Check if the month is within the valid range
    if (month < 1 || month > 12) {
      return "Invalid month entered";
    }

    // Check if the year is valid (assuming a valid range of 1900-2100)
    if (year < 1900 || year > 2100) {
      return "Invalid year entered";
    }

    // Create a DateTime object from the entered date
    DateTime enteredDate = DateTime(year, month, day);

    // Get the current date
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Check if the entered date is before today
    if (enteredDate.isBefore(currentDate)) {
      return "Please enter today's date or a future date";
    }

    return null;
  }
}
