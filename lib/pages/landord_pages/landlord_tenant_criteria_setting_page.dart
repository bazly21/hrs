import 'package:flutter/material.dart';
import 'package:hrs/model/tenant_criteria/tenant_criteria.dart';
import 'package:hrs/services/property/application_service.dart';

class TenantCriteriaSettingPage extends StatefulWidget {
  final String propertyID;
  const TenantCriteriaSettingPage({super.key, required this.propertyID});

  @override
  State<TenantCriteriaSettingPage> createState() =>
      _TenantCriteriaSettingPageState();
}

class _TenantCriteriaSettingPageState extends State<TenantCriteriaSettingPage> {
  String? selectedProfileType;
  String? selectedNumberOfPax;
  String? selectedNationality;
  String? selectedTenancyDuration;

  final ApplicationService _applicationService = ApplicationService();

  final List<String> profileTypes = ['Student', 'Working Adult', 'Family'];
  final List<String> numberOfPaxOptions = [
    'Single or Couple',
    'Small Family (1 to 4 pax)',
    'Large Family (5+ pax)'
  ];
  final List<String> nationalities = ['Malaysian', 'Non-Malaysian'];
  final List<String> tenancyDurations = [
    'Short term (< 4 Months)',
    'Mid term (4-9 Months)',
    'Long term (10-12 months)'
  ];

  void saveTenantCriteria() async {
    // Create a map with the criteria data
    TenantCriteria criteriaData = TenantCriteria(
      profileType: selectedProfileType,
      numberOfPax: selectedNumberOfPax,
      nationality: selectedNationality,
      tenancyDuration: selectedTenancyDuration,
    );

    // Save the criteria data to Firestore
    await _applicationService
        .saveTenantCriteria(widget.propertyID, criteriaData)
        .catchError((error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save tenant criteria')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Tenant Criteria'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile Type'),
            DropdownButtonFormField<String>(
              value: selectedProfileType,
              items: profileTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProfileType = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text('Number of Pax'),
            DropdownButtonFormField<String>(
              value: selectedNumberOfPax,
              items: numberOfPaxOptions.map((number) {
                return DropdownMenuItem<String>(
                  value: number,
                  child: Text(number.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedNumberOfPax = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text('Nationality'),
            DropdownButtonFormField<String>(
              value: selectedNationality,
              items: nationalities.map((nationality) {
                return DropdownMenuItem<String>(
                  value: nationality,
                  child: Text(nationality),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedNationality = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text('Tenancy Duration'),
            DropdownButtonFormField<String>(
              value: selectedTenancyDuration,
              items: tenancyDurations.map((duration) {
                return DropdownMenuItem<String>(
                  value: duration,
                  child: Text(duration),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTenancyDuration = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: saveTenantCriteria,
              child: const Text('Save Criteria'),
            ),
          ],
        ),
      ),
    );
  }
}
