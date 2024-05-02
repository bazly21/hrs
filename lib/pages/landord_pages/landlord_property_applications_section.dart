import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/ink_button.dart';
import 'package:hrs/components/my_richtext.dart';
import 'package:hrs/components/my_starrating.dart';
import 'package:hrs/services/property/application_service.dart';
import 'package:hrs/services/rental/rental_service.dart';
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
  final ApplicationService _applicationService = ApplicationService();
  late Future<List<Map<String, dynamic>>> propertyApplicationsFuture;
  final TextEditingController _tenancyDateController = TextEditingController();
  final RentalService _rentalService = RentalService();
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: refreshData,
      child: FutureBuilder<List<Map<String, dynamic>>>(
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
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> applicationData =
                        snapshot.data![index];
                    final bool isAccepted = applicationData['status'] ==
                        "Accepted"; // To check if the status of the application wether it is accepted or not
                    final String applicationID =
                        applicationData["applicationID"];

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: isAccepted ? 0 : 1.0,
                        child: Column(
                          children: [
                            // ********* Profile Picture and Rating Section (Start)  *********
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: const BorderSide(
                                        width: 0.3, color: Color(0xFF7D7F88)),
                                    left: const BorderSide(
                                        width: 0.3, color: Color(0xFF7D7F88)),
                                    right: const BorderSide(
                                        width: 0.3, color: Color(0xFF7D7F88)),
                                    bottom: isAccepted
                                        ? const BorderSide(
                                            width: 0.3,
                                            color: Color(0xFF7D7F88))
                                        : BorderSide.none,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(10.0).copyWith(
                                    bottomLeft: isAccepted ? null : Radius.zero,
                                    bottomRight:
                                        isAccepted ? null : Radius.zero,
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    15.0, 8.0, 0, 8.0),
                                child: Row(
                                  children: [
                                    // ********* Profile Picture and Rating Section (Start)  *********
                                    Column(
                                      children: [
                                        const CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              'https://via.placeholder.com/150'),
                                          radius: 40,
                                        ),
                                        SizedBox(height: height * 0.007),
                                        const StarRating(
                                            rating: 5.0, iconSize: 18),
                                        SizedBox(height: height * 0.007),
                                        const CustomRichText(
                                            text1: "5.0", text2: " (3 Reviews)")
                                      ],
                                    ),
                                    // ********* Profile Picture and Rating Section (End)  *********

                                    SizedBox(width: width * 0.05),

                                    // ********* Applicant Details Section (Start)  *********
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Applicant's Name
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  applicationData[
                                                      "applicantName"],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 20)),

                                              // If the application status is accepted,
                                              // then show the 'Kebab' (three vertical dot) menu
                                              if (isAccepted)
                                                PopupMenuButton<String>(
                                                  position:
                                                      PopupMenuPosition.under,
                                                  color: Colors.white,
                                                  onSelected:
                                                      (String result) async {
                                                    // Handle the menu item selected here
                                                    if (result ==
                                                        "Undo Application") {
                                                      showConfirmationAndUpdateStatus(
                                                          context: context,
                                                          confirmationTitle:
                                                              "Confirm Undo",
                                                          confirmationContent:
                                                              "Are you sure you want to undo this application?",
                                                          status: "Pending",
                                                          applicationID:
                                                              applicationID);
                                                    }
                                                    // If the user selects 'Start Tenancy'
                                                    else if (result ==
                                                        "Start Tenancy") {
                                                      showTenancyForm(
                                                          context,
                                                          applicationData[
                                                              "applicantID"]);
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext
                                                          context) =>
                                                      <PopupMenuEntry<String>>[
                                                    // First PopupMenuItem
                                                    const PopupMenuItem<String>(
                                                      value: 'Start Tenancy',
                                                      child:
                                                          Text('Start Tenancy'),
                                                    ),

                                                    // Add divider between PopupMenuItem
                                                    const PopupMenuDivider(),

                                                    const PopupMenuItem<String>(
                                                      value: 'Contact Tenant',
                                                      child: Text(
                                                          'Contact Tenant'),
                                                    ),

                                                    // Add divider between PopupMenuItem
                                                    const PopupMenuDivider(),

                                                    const PopupMenuItem<String>(
                                                      value: 'Undo Application',
                                                      child: Text(
                                                        'Undo Application',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  icon: const Icon(Icons
                                                      .more_vert), // Icon for kebab menu (three vertical dots)
                                                ),
                                            ],
                                          ),

                                          SizedBox(height: height * 0.005),

                                          // Applicant's Details
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Occupation
                                                  const Text("Occupation:",
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                  Text(
                                                      applicationData[
                                                          "occupation"],
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF7D7F88))),

                                                  // Profile Type
                                                  const Text("Profile type:",
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                  Text(
                                                      applicationData[
                                                          "profileType"],
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF7D7F88))),

                                                  // Number of Pax
                                                  const Text("No. of pax:",
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                  Text(
                                                      "${applicationData["numberOfPax"]} pax",
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF7D7F88))),
                                                ],
                                              ),
                                              SizedBox(width: width * 0.03),
                                              Container(
                                                  width: 1,
                                                  color:
                                                      const Color(0xFF8568F3),
                                                  height: 110),
                                              SizedBox(width: width * 0.03),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Occupation
                                                  const Text("Nationality:",
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                  Text(
                                                      applicationData[
                                                          "nationality"],
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF7D7F88))),

                                                  // Profile Type
                                                  const Text("Move-in date:",
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                  Text(
                                                      "${applicationData["moveInDate"]}",
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF7D7F88))),

                                                  // Number of Pax
                                                  const Text(
                                                      "Tenancy duration:",
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                  Text(
                                                      "${applicationData["tenancyDuration"]} months",
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF7D7F88))),
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
                              ),
                            ),
                            // ********* Profile Picture and Rating Section (End)  *********

                            // ********* Accept and Decline Buttons (Start)  *********
                            if (!isAccepted)
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Decline Button
                                    Expanded(
                                        child: InkButton(
                                      backgroundColor: Colors.red[400]!,
                                      onTap: () => showConfirmationAndUpdateStatus(
                                          context: context,
                                          confirmationTitle: "Confirm Decline",
                                          confirmationContent:
                                              "Are you sure you want to decline this application?",
                                          status: "Declined",
                                          applicationID: applicationID),
                                      textButton: "Decline",
                                      splashColor:
                                          Colors.red[700]!.withOpacity(0.5),
                                      highlightColor:
                                          Colors.red[900]!.withOpacity(0.5),
                                      borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10)),
                                    )),

                                    // Accept Button
                                    Expanded(
                                      child: InkButton(
                                          backgroundColor: Colors.green[400]!,
                                          onTap: () =>
                                              showConfirmationAndUpdateStatus(
                                                  context: context,
                                                  confirmationTitle:
                                                      "Confirm Accept",
                                                  confirmationContent:
                                                      "Are you sure you want to accept this application?",
                                                  status: "Accepted",
                                                  applicationID: applicationID),
                                          textButton: "Accept",
                                          splashColor: Colors.green[700]!
                                              .withOpacity(0.5),
                                          highlightColor: Colors.green[900]!
                                              .withOpacity(0.5)),
                                    ),
                                  ])
                            // ********* Accept and Decline Buttons (End)  *********
                          ],
                        ),
                      ),
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

  void showTenancyForm(BuildContext context, String tenantID) {
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
                  _tenancyDateField(context, setState, updateEndDate),
                  const SizedBox(height: 20),
                  // Caluculate the end date based on the start date and tenancy duration
                  if (endDate != null) _tenancyEndDateText(),
                  const SizedBox(height: 20),
                  // Submit button
                  ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      // Save tenancy information in database
                      _rentalService
                          .saveTenancyInfo(widget.propertyID, tenantID,
                              int.parse(tenancyDuration!), startDate!, endDate!)
                          .then((_) => Navigator.pop(context))
                          .catchError(
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
      void Function() updateEndDate) {
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
