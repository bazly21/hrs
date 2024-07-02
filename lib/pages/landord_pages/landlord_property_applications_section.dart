import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/components/custom_rating_bar.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/model/application/application_model.dart';
import 'package:hrs/pages/chat_page.dart';
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
  late Future<Map<String, dynamic>> propertyApplicationsFuture;
  final TextEditingController _tenancyDateController = TextEditingController();
  bool _containAcceptedApplication = false;
  bool _hasPropertyRented = false;
  bool _hasTenantCriteria = false;
  bool _isLoading = false;
  String? tenancyDuration;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    propertyApplicationsFuture =
        ApplicationService.getPropertyApplication(widget.propertyID);
  }

  @override
  void dispose() {
    _tenancyDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : buildMainBody(context);
  }

  RefreshIndicator buildMainBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: FutureBuilder<Map<String, dynamic>>(
          future: propertyApplicationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // If there is data and the data is not empty
            else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              _hasPropertyRented = snapshot.data!['propertyStatus'] == "Rented";
              _containAcceptedApplication =
                  snapshot.data!['containsAcceptedApplication'];

              return ListView.builder(
                  itemCount: snapshot.data!['applicationList'].length,
                  itemBuilder: (context, index) {
                    final Application applicationData =
                        snapshot.data!['applicationList'][index];
                    _hasTenantCriteria = snapshot.data!['hasTenantCriteria'];

                    return Stack(
                      children:
                          _buildApplicantData(index, context, applicationData),
                    );
                  });
            }
            // When there is no data
            else {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: const Center(
                        child: Text('No applications found'),
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
    Application applicationData,
  ) {
    return [
      _buildApplicantCard(index, applicationData, context),

      // Only show the 'Best Match' label for the first applicant
      // and if there is tenant criteria
      if (index == 0 && _hasTenantCriteria)
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
    Application applicationData,
    BuildContext context,
  ) {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    String tenancyDate = dateFormat.format(applicationData.moveInDate!);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: index == 0 && _hasTenantCriteria
                ? const Color(0xFF8568F3)
                : Colors.grey[300]!,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  _buildProfileAndRating(applicationData),
                  const SizedBox(width: 25),
                  _buildApplicantInfo(applicationData, context, tenancyDate)
                ],
              ),
              const SizedBox(height: 8),
              if (applicationData.status != "Accepted")
                _buildAcceptDeclineButtons(
                    context, applicationData.applicationID!),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildApplicantInfo(
      Application applicationData, BuildContext context, String tenancyDate) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Applicant's Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(applicationData.applicantName!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 20)),

              // If the application status is accepted,
              // then show the 'Kebab' (three vertical dot) menu
              _buildKebabMenu(context, applicationData),
            ],
          ),

          const SizedBox(height: 4),

          // Applicant's Details
          _buildApplicantDetails(applicationData, tenancyDate),
        ],
      ),
    );
  }

  Row _buildApplicantDetails(Application applicationData, String tenancyDate) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Occupation
            const Text("Occupation:", style: TextStyle(fontSize: 13)),
            Text(applicationData.occupation!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),

            // Profile Type
            const Text("Profile type:", style: TextStyle(fontSize: 13)),
            Text(applicationData.profileType!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),

            // Number of Pax
            const Text("No. of pax:", style: TextStyle(fontSize: 13)),
            Text("${applicationData.numberOfPax} pax",
                style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
          ],
        ),
        const SizedBox(width: 14),
        Container(width: 1, color: const Color(0xFF8568F3), height: 110),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Occupation
            const Text("Nationality:", style: TextStyle(fontSize: 13)),
            Text(applicationData.nationality!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),

            // Profile Type
            const Text("Move-in date:", style: TextStyle(fontSize: 13)),
            Text(tenancyDate,
                style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),

            // Number of Pax
            const Text("Tenancy duration:", style: TextStyle(fontSize: 13)),
            Text("${applicationData.tenancyDuration!} months",
                style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
          ],
        ),
      ],
    );
  }

  PopupMenuButton<String> _buildKebabMenu(
      BuildContext context, Application applicationData) {
    bool isPropertyAvailableAndAccepted =
        !_hasPropertyRented && applicationData.status == "Accepted";

    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      color: Colors.white,
      onSelected: (String result) async {
        // Handle the menu item selected here
        if (result == "Undo Application") {
          showConfirmationAndUpdateStatus(
            confirmationTitle: "Confirm Undo",
            confirmationContent:
                "Are you sure you want to undo this application?",
            status: "Pending",
            applicationID: applicationData.applicationID!,
          );
        }
        // If the user selects 'Start Tenancy'
        else if (result == "Start Tenancy") {
          showTenancyForm(context, applicationData);
        } else if (result == "Contact Tenant") {
          // Go to the chat page
          NavigationUtils.pushPage(
              context,
              ChatPage(
                receiverID: applicationData.applicantID!,
                receiverName: applicationData.applicantName!,
              ),
              SlideDirection.left);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // First PopupMenuItem
        if (isPropertyAvailableAndAccepted) ...[
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

        if (isPropertyAvailableAndAccepted) ...[
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
      child: const Icon(Icons.more_vert),
    );
  }

  Column _buildProfileAndRating(Application applicationData) {
    bool hasRating = applicationData.applicantOverallRating! > 0 &&
        applicationData.applicantRatingCount! > 0;

    return Column(
      children: [
        InkWell(
          onTap: () {
            NavigationUtils.pushPage(
              context,
              ProfileViewPage(
                userID: applicationData.applicantID!,
                role: "Tenant",
              ),
              SlideDirection.left,
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
          child: CustomCircleAvatar(
            name: applicationData.applicantName!,
            imageURL: applicationData.applicantProfilePic,
            radius: 40,
            fontSize: 35,
          ),
        ),
        const SizedBox(height: 7),

        // Display the rating bar if the applicant has rating (greater than 0)
        if (hasRating) ...[
          CustomRatingBar(rating: applicationData.applicantOverallRating!),
          const SizedBox(height: 7)
        ],
        CustomRichText(
          mainText: hasRating
              ? "${applicationData.applicantOverallRating!}"
              : "No rating yet",
          subText: hasRating
              ? " (${applicationData.applicantRatingCount!} Reviews)"
              : "",
          mainFontSize: 14,
          mainFontWeight: FontWeight.normal,
          mainFontColor: hasRating ? Colors.black : Colors.black54,
        )
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
                      confirmationTitle: "Confirm Decline",
                      confirmationContent:
                          "Are you sure you want to decline this application?",
                      status: "Declined",
                      applicationID: applicationID,
                    );
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
                      confirmationTitle: "Confirm Accept",
                      confirmationContent:
                          "Are you sure you want to accept this application?",
                      status: "Accepted",
                      applicationID: applicationID,
                    );
                  },
            style: AppStyles.acceptButtonStyle,
            child: const Text("Accept"),
          ),
        )
      ],
    );
  }

  Future<void> refreshData() async {
    await ApplicationService.getPropertyApplication(widget.propertyID)
        .then((newData) {
      setState(() {
        propertyApplicationsFuture = Future.value(newData);
      });
    });
  }

  Future<void> showConfirmationAndUpdateStatus({
    required String confirmationTitle,
    required String confirmationContent,
    required String status,
    required String applicationID,
  }) async {
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext innerContext) {
        return AlertDialog(
          title: Text(confirmationTitle),
          content: Text(confirmationContent),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(innerContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(innerContext).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (isConfirmed ?? false) {
      // Show a loading indicator
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestore
            .collection("properties")
            .doc(widget.propertyID)
            .collection("applications")
            .doc(applicationID)
            .update({"status": status});

        // Refresh the application list
        await refreshData();

        // Hide the loading indicator
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Application successfully ${status == "Pending" ? "undo" : status.toLowerCase()}',
                ),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green[700],
              ),
            );
          });
        }
      } catch (error) {
        // Hide the loading indicator
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong. Please try again'),
            ),
          );
        }
      }
    }
  }

  void showTenancyForm(BuildContext context, Application tenantData) {
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
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tenancyDurationField(setState, updateEndDate),
                  const SizedBox(height: 20),
                  _tenancyDateField(
                      context, setState, updateEndDate, tenantData.moveInDate!),
                  const SizedBox(height: 20),
                  // Caluculate the end date based on the start date and tenancy duration
                  if (endDate != null) _tenancyEndDateText(),
                  const SizedBox(height: 20),
                  // Submit button
                  _buildSubmitTenancyButton(context, tenantData),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Row _buildSubmitTenancyButton(BuildContext context, Application tenantData) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext innerContext) {
                  return AlertDialog(
                    title: const Text('Confirm Submission'),
                    content: const Text(
                      'Are you sure you want to save this tenancy information? Once submitted, this action cannot be undone',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(innerContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Confirm'),
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(innerContext).pop();

                          // Save tenancy information in database
                          RentalService.saveTenancyInfo(
                            propertyID: widget.propertyID,
                            tenantID: tenantData.applicantID!,
                            landlordID: _auth.currentUser!.uid,
                            applicationID: tenantData.applicationID!,
                            duration: int.parse(tenancyDuration!),
                            startDate: startDate!,
                            endDate: endDate!,
                          ).then((_) {
                            // Close the modal bottom sheet
                            Navigator.pop(context);

                            // Show success message if the saving operation is successful
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Tenancy information saved successfully',
                                ),
                                duration: const Duration(seconds: 3),
                                backgroundColor: Colors.green[700],
                              ),
                            );

                            // Refresh the application list
                            refreshData();
                          }).catchError(
                            (_) {
                              // Show error message if the saving operation is failed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Failed to save tenancy information. Please try again',
                                  ),
                                  duration: const Duration(seconds: 3),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Submit'),
          ),
        ),
      ],
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
              child: Text(
                '$value months',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
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
      void Function() updateEndDate, DateTime tenancyDate) {
    DateFormat format = DateFormat('dd/MM/yyyy');
    String tenancyDateString =
        format.format(tenancyDate); // Convert DateTime to String

    DateTime parsedDate = format.parse(tenancyDateString);

    // Check if the parsed date is after the current date
    if (parsedDate.isAfter(DateTime.now())) {
      _tenancyDateController.text = tenancyDateString;
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
