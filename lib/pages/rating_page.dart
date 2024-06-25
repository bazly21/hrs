import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/model/rating/landlord_rating.dart';
import 'package:hrs/services/rating/rating_service.dart';
import 'package:hrs/style/app_style.dart';

class RatingPage extends StatefulWidget {
  final String landlordID;
  final String tenancyDocID;
  final String propertyID;

  const RatingPage({
    super.key,
    required this.landlordID,
    required this.tenancyDocID,
    required this.propertyID,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _supportRating = 0;
  double _maintenanceRating = 0;
  double _communicationRating = 0;
  final TextEditingController _commentsController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _setRating(String category, double rating) {
    setState(() {
      if (category == 'support') {
        _supportRating = rating;
      } else if (category == 'maintenance') {
        _maintenanceRating = rating;
      } else if (category == 'communication') {
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
      appBar: const CustomAppBar(title: 'Rate Landlord'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildRatingBar(
                  'Support and assistance', _supportRating, 'support'),
              const SizedBox(height: 10),
              _buildRatingBar('Maintenance', _maintenanceRating, 'maintenance'),
              const SizedBox(height: 10),
              _buildRatingBar(
                  'Communication', _communicationRating, 'communication'),
              const SizedBox(height: 20),
              TextField(
                controller: _commentsController,
                maxLines: 4,
                style: AppStyles.textFieldText,
                decoration: InputDecoration(
                  hintText:
                      'Share more thoughts on the landlord to help others',
                  hintStyle: AppStyles.hintText,
                  contentPadding: const EdgeInsets.all(10),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Check if all ratings are provided
                        bool isRatingComplete = _supportRating > 0 &&
                            _maintenanceRating > 0 &&
                            _communicationRating > 0;

                        // If all ratings are provided,
                        // show a dialog to confirm the submission
                        if (isRatingComplete) {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Submit Rating'),
                                content: const Text(
                                    'Are you sure you want to submit your rating?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      // Save the ratings and thoughts or perform any desired action
                                      submitRating(context);
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        // Otherwise, show a snackbar to inform the user
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Please provide ratings for all categories',
                              ),
                              duration: const Duration(seconds: 3),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
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

    final LandlordRating newRating = LandlordRating(
      reviewerID: _auth.currentUser!.uid,
      supportRating: _supportRating,
      maintenanceRating: _maintenanceRating,
      communicationRating: _communicationRating,
      comments: comments,
    );

    try {
      await RatingService.submitLandlordRating(
          landlordRating: newRating,
          landlordID: widget.landlordID,
          tenancyDocID: widget.tenancyDocID,
          propertyID: widget.propertyID);

      // Go back to the previous page
      if (context.mounted) {
        Navigator.pop(context, 'Rating submitted successfully');
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error submitting rating: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
      print('Error submitting rating: $e');
    }
  }
}
