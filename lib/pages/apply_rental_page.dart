import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:hrs/components/my_appbar.dart";
import "package:hrs/model/application/application_model.dart";
import "package:hrs/services/property/application_service.dart";
import "package:intl/intl.dart";

class ApplyRentalPage extends StatefulWidget {
  final String rentalID;

  const ApplyRentalPage({super.key, required this.rentalID});

  @override
  ApplyRentalPageState createState() => ApplyRentalPageState();
}

class ApplyRentalPageState extends State<ApplyRentalPage> {
  final ApplicationService _applicationService = ApplicationService();
  final TextEditingController _occupationController = TextEditingController();

  String? _profileType;
  int? _numberOfPax;
  String? _nationality;
  DateTime? _moveInDate;
  int? _tenancyDuration;

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
      appBar: const CustomAppBar(text: "Apply Rent"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: "Occupation",
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _profileType,
              decoration: const InputDecoration(labelText: "Profile Type"),
              items: _profileTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _profileType = value;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _numberOfPax,
              decoration: const InputDecoration(labelText: "Number of Pax"),
              items: _paxNumbers
                  .map((number) => DropdownMenuItem(
                        value: number,
                        child: Text(number.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _numberOfPax = value;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _nationality,
              decoration: const InputDecoration(labelText: "Nationality"),
              items: _nationalities
                  .map((country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _nationality = value;
                });
              },
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  setState(() {
                    _moveInDate = selectedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Move-in Date"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_moveInDate != null
                        ? DateFormat("dd-MM-yyyy").format(_moveInDate!)
                        : ""),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _tenancyDuration,
              decoration:
                  const InputDecoration(labelText: "Tenancy Duration (Months)"),
              items: _tenancyDurations
                  .map((duration) => DropdownMenuItem(
                        value: duration,
                        child: Text("$duration months"),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _tenancyDuration = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _resetFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Reset button color
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitApplication,
                  child: const Text("Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetFields() {
    setState(() {
      _occupationController.clear();
      _profileType = null;
      _numberOfPax = null;
      _nationality = null;
      _moveInDate = null;
      _tenancyDuration = null;
    });
  }

  Future<void> _submitApplication() async {
    // Get the occupation from the text field
    String occupation = _occupationController.text.trim();

    // Validate all fields are filled in
    if (occupation.isEmpty ||
        _profileType == null ||
        _numberOfPax == null ||
        _nationality == null ||
        _moveInDate == null ||
        _tenancyDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill in all fields before submitting.")),
      );
      return; // Stop if any field is not filled in
    }

    // Create an application object
    Application application = Application(
      propertyID: widget.rentalID,
      applicantID: userUID!,
      occupation: occupation,
      profileType: _profileType!,
      numberOfPax: _numberOfPax!,
      nationality: _nationality!,
      moveInDate: _moveInDate!,
      tenancyDuration: _tenancyDuration!,
    );

    // Save data to Firestore
    await _applicationService.saveApplication(application).then(
      (_) {
        // Reset the form after successful submission
        _resetFields();

        Navigator.pop(context, "Application submitted successfully!");
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
