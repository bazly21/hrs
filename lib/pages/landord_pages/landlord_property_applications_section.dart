import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_rating_bar.dart';
import 'package:hrs/components/my_richtext.dart';
import 'package:hrs/pages/view_profile_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/application_service.dart';
import 'package:hrs/services/rental/rental_service.dart';
import 'package:hrs/style/app_style.dart';
import 'package:intl/intl.dart';

class PropertyApplicationsSection extends StatefulWidget {
  final String propertyID;

  const PropertyApplicationsSection({super.key, required this.propertyID});

  @override
  State<PropertyApplicationsSection> createState() =>
      _PropertyApplicationsSectionState();
}

class _PropertyApplicationsSectionState
    extends State<PropertyApplicationsSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApplicationService _applicationService = ApplicationService();
  late Future<Map<String, dynamic>> propertyApplicationsFuture;
  final TextEditingController _tenancyDateController = TextEditingController();
  bool _isApplicationAccepted = false;
  bool _containAcceptedApplication = false;
  bool _hasPropertyRented = false;
  String? tenancyDuration;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    propertyApplicationsFuture =
        _applicationService.getPropertyApplication(widget.propertyID);
  }

  @override
  void dispose() {
    _tenancyDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: FutureBuilder<Map<String, dynamic>>(
          future: propertyApplicationsFuture,
          builder: (context, snapshot) {
            // If snapshot contains data
            // Note that empty list also makes
            // snapshot.hasData equal to true
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // If there is data and the data is not empty
            else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              _hasPropertyRented = snapshot.data!['status'] == "Rented";

              return ListView.builder(
                  itemCount: snapshot.data!['applicationList'].length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> applicationData =
                        snapshot.data!['applicationList'][index];
                    final String applicationID =
                        applicationData["applicationID"];
                    _isApplicationAccepted =
                        applicationData['status'] == "Accepted";
                    _containAcceptedApplication = snapshot.data!['hasAccepted'];

                    return Stack(
                      children: _buildApplicantData(
                          index,
                          context,
                          applicationData,
                          _isApplicationAccepted,
                          applicationID),
                    );
                  });
            } else {
              // When there is no data
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: const Center(
                        child: Text('No applications found.'),
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }

  List<Widget> _buildApplicantData(
      int index,
      BuildContext context,
      Map<String, dynamic> applicationData,
      bool isAccepted,
      String applicationID) {
    return [
      _buildApplicantCard(
          index, isAccepted, applicationData, context, applicationID),
      if (index == 0)
        Positioned(
          top: 5,
          left: 45,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: const Text(
              "Best Match",
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8568F3),
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
    ];
  }

  Card _buildApplicantCard(
      int index,
      bool isAccepted,
      Map<String, dynamic> applicationData,
      BuildContext context,
      String applicationID) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: index == 0 ? const Color(0xFF8568F3) : Colors.grey[300]!,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Column(
            children: [
              Row(
                children: [
                  _buildProfileAndRating(applicationData["applicantID"]),

                  const SizedBox(width: 25),

                  // ********* Applicant Details Section (Start)  *********
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Applicant's Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(applicationData["applicantName"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 20)),

                            // If the application status is accepted,
                            // then show the 'Kebab' (three vertical dot) menu
                            if (isAccepted)
                              PopupMenuButton<String>(
                                position: PopupMenuPosition.under,
                                color: Colors.white,
                                onSelected: (String result) async {
                                  // Handle the menu item selected here
                                  if (result == "Undo Application") {
                                    showConfirmationAndUpdateStatus(
                                        context: context,
                                        confirmationTitle: "Confirm Undo",
                                        confirmationContent:
                                            "Are you sure you want to undo this application?",
                                        status: "Pending",
                                        applicationID: applicationID);
                                  }
                                  // If the user selects 'Start Tenancy'
                                  else if (result == "Start Tenancy") {
                                    showTenancyForm(context, applicationData);
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  // First PopupMenuItem
                                  if (!_hasPropertyRented) ...[
                                    const PopupMenuItem<String>(
                                      value: 'Start Tenancy',
                                      child: Text('Start Tenancy'),
                                    ),
                                    const PopupMenuDivider(),
                                  ],

                                  const PopupMenuItem<String>(
                                    value: 'Contact Tenant',
                                    child: Text('Contact Tenant'),
                                  ),

                                  if (!_hasPropertyRented) ...[
                                    const PopupMenuDivider(),
                                    const PopupMenuItem<String>(
                                      value: 'Undo Application',
                                      child: Text(
                                        'Undo Application',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  ]
                                ],
                                icon: const Icon(Icons
                                    .more_vert), // Icon for kebab menu (three vertical dots)
                              ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Applicant's Details
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Occupation
                                const Text("Occupation:",
                                    style: TextStyle(fontSize: 13)),
                                Text(applicationData["occupation"],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7D7F88))),

                                // Profile Type
                                const Text("Profile type:",
                                    style: TextStyle(fontSize: 13)),
                                Text(applicationData["profileType"],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7D7F88))),

                                // Number of Pax
                                const Text("No. of pax:",
                                    style: TextStyle(fontSize: 13)),
                                Text("${applicationData["numberOfPax"]} pax",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7D7F88))),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Container(
                                width: 1,
                                color: const Color(0xFF8568F3),
                                height: 110),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Occupation
                                const Text("Nationality:",
                                    style: TextStyle(fontSize: 13)),
                                Text(applicationData["nationality"],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7D7F88))),

                                // Profile Type
                                const Text("Move-in date:",
                                    style: TextStyle(fontSize: 13)),
                                Text("${applicationData["moveInDate"]}",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7D7F88))),

                                // Number of Pax
                                const Text("Tenancy duration:",
                                    style: TextStyle(fontSize: 13)),
                                Text(
                                    "${applicationData["tenancyDuration"]} months",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7D7F88))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  // ********* Applicant Details Section (End)  *********
                ],
              ),
              const SizedBox(height: 8),
              if (!isAccepted)
                _buildAcceptDeclineButtons(context, applicationID),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildProfileAndRating(String applicantID) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            NavigationUtils.pushPage(
              context,
              ProfileViewPage(userID: applicantID),
              SlideDirection.left
            ).then((message) {
              if (message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              }
            });
          },
          child: const CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            radius: 40,
          ),
        ),
        const SizedBox(height: 7),
        const CustomRatingBar(rating: 5.0),
        const SizedBox(height: 7),
        const CustomRichText(text1: "5.0", text2: " (3 Reviews)")
      ],
    );
  }

  Row _buildAcceptDeclineButtons(BuildContext context, String applicationID) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _containAcceptedApplication
                ? null
                : () {
                    showConfirmationAndUpdateStatus(
                        context: context,
                        confirmationTitle: "Confirm Decline",
                        confirmationContent:
                            "Are you sure you want to decline this application?",
                        status: "Declined",
                        applicationID: applicationID);
                  },
            style: AppStyles.declineButtonStyle,
            child: const Text("Decline"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _containAcceptedApplication
                ? null
                : () {
                    showConfirmationAndUpdateStatus(
                        context: context,
                        confirmationTitle: "Confirm Accept",
                        confirmationContent:
                            "Are you sure you want to accept this application?",
                        status: "Accepted",
                        applicationID: applicationID);
                  },
            style: AppStyles.acceptButtonStyle,
            child: const Text("Accept"),
          ),
        )
      ],
    );
  }

  Future<void> refreshData() async {
    await _applicationService
        .getPropertyApplication(widget.propertyID)
        .then((newData) {
      setState(() {
        propertyApplicationsFuture = Future.value(newData);
      });
    });
  }

  Future<void> showConfirmationAndUpdateStatus(
      {required BuildContext context,
      required String confirmationTitle,
      required String confirmationContent,
      required String status,
      required String applicationID}) async {
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(confirmationTitle),
          content: Text(confirmationContent),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (isConfirmed ?? false) {
      await _firestore
          .collection("properties")
          .doc(widget.propertyID)
          .collection("applications")
          .doc(applicationID)
          .update({
        "status": status,
      }).then((_) {
        refreshData();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something wrong happened. Please try again')),
        );
      });
    }
  }

  void showTenancyForm(BuildContext context, Map<String, dynamic> tenantData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          void updateEndDate() {
            // Only calculate endDate if both startDate and tenancyDuration are not null
            if (startDate != null && tenancyDuration != null) {
              setState(() {
                endDate = startDate!
                    .add(Duration(days: int.parse(tenancyDuration!) * 30));
              });
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tenancyDurationField(setState, updateEndDate),
                  const SizedBox(height: 20),
                  _tenancyDateField(context, setState, updateEndDate,
                      tenantData["moveInDate"]),
                  const SizedBox(height: 20),
                  // Caluculate the end date based on the start date and tenancy duration
                  if (endDate != null) _tenancyEndDateText(),
                  const SizedBox(height: 20),
                  // Submit button
                  ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      // Save tenancy information in database
                      RentalService.saveTenancyInfo(
                              propertyID: widget.propertyID,
                              tenantID: tenantData["applicantID"],
                              landlordID: _auth.currentUser!.uid,
                              duration: int.parse(tenancyDuration!),
                              startDate: startDate!,
                              endDate: endDate!)
                          .then((_) {
                        // Close the modal bottom sheet
                        Navigator.pop(context);

                        // Show success message if the saving operation is successful
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Tenancy information saved successfully.'),
                          ),
                        );

                        refreshData();
                      }).catchError(
                        (error) {
                          // Show error message if the saving operation is failed
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to save tenancy information. Please try again.'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Text _tenancyEndDateText() {
    return Text(
      'End Tenancy Date: ${DateFormat('dd/MM/yyyy').format(endDate!)}',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Column tenancyDurationField(
      StateSetter setState, void Function() updateEndDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tenancy Duration',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            hintText: 'Select one',
            hintStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          value: tenancyDuration,
          items: List.generate(6, (index) => (index + 1).toString())
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text('$value months',
                  style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.black)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              tenancyDuration = newValue;
            });

            updateEndDate();
          },
        ),
      ],
    );
  }

  Column _tenancyDateField(BuildContext context, StateSetter setState,
      void Function() updateEndDate, String tenancyDate) {
    DateFormat format = DateFormat('dd/MM/yyyy');
    DateTime parsedDate = format.parse(tenancyDate);

    // Check if the parsed date is after the current date
    if (parsedDate.isAfter(DateTime.now())) {
      _tenancyDateController.text = tenancyDate;
      startDate = parsedDate;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Tenancy Date',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _tenancyDateController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            hintText: 'Select date',
            hintStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
          ),
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          readOnly: true, // Keep the field readOnly to prevent keyboard pop-up
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                startDate = pickedDate;
                _tenancyDateController.text =
                    DateFormat('dd/MM/yyyy').format(startDate!);
              });
              updateEndDate();
            }
          },
        ),
      ],
    );
  }
}
