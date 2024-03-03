import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ApplyRentalPage extends StatefulWidget {
  final String rentalID;

  const ApplyRentalPage({super.key, required this.rentalID});

  @override
  ApplyRentalPageState createState() => ApplyRentalPageState();
}

class ApplyRentalPageState extends State<ApplyRentalPage> {
  String? _occupation;
  String? _profileType;
  int? _numberOfPax;
  String? _nationality;
  DateTime _moveInDate = DateTime.now();
  int? _tenancyDuration;

  // Define dropdown list items
  final List<String> _profileTypes = ['Student', 'Working Adult', 'Family'];
  final List<int> _paxNumbers = List.generate(10, (index) => index + 1);
  final List<String> _nationalities = ['Malaysian', 'Foreigner'];
  final List<int> _tenancyDurations = List.generate(6, (index) => index + 1);

  void _resetFields() {
    setState(() {
      _occupation = null;
      _profileType = null;
      _numberOfPax = null;
      _nationality = null;
      _moveInDate = DateTime.now();
      _tenancyDuration = null;
    });
  }

  Future<void> _submitApplication() async {
    // Validate all fields are filled in
    if (_occupation == null ||
        _occupation!.isEmpty ||
        _profileType == null ||
        _numberOfPax == null ||
        _nationality == null ||
        _moveInDate == null ||
        _tenancyDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields before submitting.')),
      );
      return; // Stop if any field is not filled in
    }

    // Prepare data to be saved
    Map<String, dynamic> applicationData = {
      'rentalID': widget.rentalID,
      'occupation': _occupation,
      'profileType': _profileType,
      'numberOfPax': _numberOfPax,
      'nationality': _nationality,
      'moveInDate': Timestamp.fromDate(
          _moveInDate), // Convert DateTime to Timestamp for Firestore
      'tenancyDuration': _tenancyDuration,
      'submittedAt': FieldValue
          .serverTimestamp(), // Server timestamp for when the application is submitted
    };

    // Save data to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .add(applicationData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
      }

      // Optional: Clear the form or navigate to a different page after successful submission
      _resetFields();
    } catch (e) {
      print(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to submit application. Please try again later.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Apply Rent"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Occupation',
              ),
              onChanged: (value) {
                setState(() {
                  _occupation = value;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _profileType,
              decoration: const InputDecoration(labelText: 'Profile Type'),
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
              decoration: const InputDecoration(labelText: 'Number of Pax'),
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
              decoration: const InputDecoration(labelText: 'Nationality'),
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
                  initialDate: _moveInDate,
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
                decoration: const InputDecoration(labelText: 'Move-in Date'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd-MM-yyyy').format(_moveInDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _tenancyDuration,
              decoration:
                  const InputDecoration(labelText: 'Tenancy Duration (Months)'),
              items: _tenancyDurations
                  .map((duration) => DropdownMenuItem(
                        value: duration,
                        child: Text('$duration months'),
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
                    'Reset',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitApplication,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
