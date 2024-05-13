import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:hrs/components/my_appbar.dart";
import "package:hrs/model/rating/tenant_rating.dart";
import "package:hrs/services/rating/rating_service.dart";
import "package:hrs/style/app_style.dart";

class LandlordRatingPage extends StatefulWidget {
  final String tenantID;
  final String tenancyDocID;

  const LandlordRatingPage({
    super.key,
    required this.tenantID,
    required this.tenancyDocID
  });

  @override
  State<LandlordRatingPage> createState() => _LandlordRatingPageState();
}

class _LandlordRatingPageState extends State<LandlordRatingPage> {
  double _paymentRating = 0;
  double _maintenanceRating = 0;
  double _communicationRating = 0;
  final TextEditingController _commentsController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _setRating(String category, double rating) {
    setState(() {
      if (category == "payment") {
        _paymentRating = rating;
      } else if (category == "maintenance") {
        _maintenanceRating = rating;
      } else if (category == "communication") {
        _communicationRating = rating;
      }
    });
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Rate Tenant"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildRatingBar(
                  "Payment History", _paymentRating, "payment"),
              const SizedBox(height: 10),
              _buildRatingBar("Maintenance", _maintenanceRating, "maintenance"),
              const SizedBox(height: 10),
              _buildRatingBar(
                  "Communication", _communicationRating, "communication"),
              const SizedBox(height: 20),
              TextField(
                controller: _commentsController,
                maxLines: 4,
                style: AppStyles.textFieldText,
                decoration: InputDecoration(
                  hintText:
                      "Share more thoughts on the landlord to help others",
                  hintStyle: AppStyles.hintText,
                  contentPadding: const EdgeInsets.all(10),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text("Submit Rating"),
                        content: const Text(
                            "Are you sure you want to submit your rating?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              // Save the ratings and thoughts or perform any desired action
                              submitRating(context);
                            },
                            child: const Text("Submit"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(String title, double rating, String category) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 22,
          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            _setRating(category, rating);
          },
        ),
      ],
    );
  }

  void submitRating(BuildContext context) async {
    // Remove any leading or trailing whitespaces from the comments
    final String comments = _commentsController.text.trim();
    // Get the ScaffoldMessengerState for the current context
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);

    final TenantRating newRating = TenantRating(
      reviewerID: _auth.currentUser!.uid,
      paymentRating: _paymentRating,
      maintenanceRating: _maintenanceRating,
      communicationRating: _communicationRating,
      comments: comments,
    );

    try {
      await RatingService.submitTenantRating(newRating, widget.tenantID, widget.tenancyDocID);

      // Go back to the previous page
      if (context.mounted) {
        Navigator.pop(context, "Rating submitted successfully");
      }

    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Error submitting rating: ${e.toString()}")),
      );
      print("Error submitting rating: $e");
    }
  }
}
