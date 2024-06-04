import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_dropdown.dart';
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
  final ApplicationService _applicationService = ApplicationService();
  final _formKey = GlobalKey<FormState>();
  final _profileTypeKey = GlobalKey<FormFieldState<String>>();
  final _numberOfPaxKey = GlobalKey<FormFieldState<String>>();
  final _nationalityKey = GlobalKey<FormFieldState<String>>();
  final _tenancyDurationKey = GlobalKey<FormFieldState<String>>();

  String? selectedProfileType;
  String? selectedNumberOfPax;
  String? selectedNationality;
  String? selectedTenancyDuration;

  final List<String> profileTypes = [
    'Student',
    'Working Adult',
    'Family',
    'None'
  ];
  final List<String> numberOfPaxOptions = [
    'Single or Couple',
    'Small Family (1 to 4 pax)',
    'Large Family (5+ pax)',
    'None'
  ];
  final List<String> nationalities = ['Malaysian', 'Non-Malaysian', 'None'];
  final List<String> tenancyDurations = [
    'Short term (< 4 Months)',
    'Mid term (4-9 Months)',
    'Long term (10-12 months)',
    'None'
  ];

  void saveTenantCriteria(BuildContext context) async {
    // Create a map with the criteria data
    try {
      if (_formKey.currentState!.validate()) {
        // If all fields are 'None', save tenantCriteria as null
        if (selectedProfileType == 'None' &&
            selectedNumberOfPax == 'None' &&
            selectedNationality == 'None' &&
            selectedTenancyDuration == 'None') {
          await _applicationService.saveTenantCriteria(widget.propertyID, null);
        } else {
          TenantCriteria criteriaData = TenantCriteria(
            profileType:
                selectedProfileType == 'None' ? null : selectedProfileType,
            numberOfPax:
                selectedNumberOfPax == 'None' ? null : selectedNumberOfPax,
            nationality:
                selectedNationality == 'None' ? null : selectedNationality,
            tenancyDuration: selectedTenancyDuration == 'None'
                ? null
                : selectedTenancyDuration,
          );

          // Save the criteria data to Firestore
          await _applicationService.saveTenantCriteria(
              widget.propertyID, criteriaData);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tenant criteria saved successfully'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green[700],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save tenant criteria'),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Set Tenant Criteria'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropDownField(
                  formFieldKey: _profileTypeKey,
                  label: 'Profile Type',
                  hintText: 'Select desired profile type',
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
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a profile type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                CustomDropDownField(
                  formFieldKey: _numberOfPaxKey,
                  label: 'Number of Pax',
                  hintText: 'Select number of pax',
                  items: numberOfPaxOptions.map((pax) {
                    return DropdownMenuItem<String>(
                      value: pax,
                      child: Text(pax),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedNumberOfPax = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select number of pax';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                CustomDropDownField(
                  formFieldKey: _nationalityKey,
                  label: 'Nationality',
                  hintText: 'Select desired tenant nationality',
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
                  validator: (value) {
                    if (value == null) {
                      return 'Please select desired tenant nationality';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                CustomDropDownField(
                  formFieldKey: _tenancyDurationKey,
                  label: 'Tenancy Duration',
                  hintText: 'Select desired tenancy duration',
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
                  validator: (value) {
                    if (value == null) {
                      return 'Please select desired tenancy duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: resetFormFields,
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.red[400],
                        // foregroundColor: Colors.white,
                        fixedSize: const Size(130, 42),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: () => saveTenantCriteria(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8568F3),
                        foregroundColor: Colors.white,
                        fixedSize: const Size(130, 42),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save Criteria'),
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

  void resetFormFields() {
    setState(() {
      selectedProfileType = null;
      selectedNumberOfPax = null;
      selectedNationality = null;
      selectedTenancyDuration = null;
      _profileTypeKey.currentState?.reset();
      _numberOfPaxKey.currentState?.reset();
      _nationalityKey.currentState?.reset();
      _tenancyDurationKey.currentState?.reset();

      // // Remove the focus
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }
}
