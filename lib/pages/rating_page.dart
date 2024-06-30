import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/model/rating/landlord_rating.dart';
import 'package:hrs/model/tenancy/tenant_ended_tenancy.dart';
import 'package:hrs/services/property/tenancy_service.dart';
import 'package:hrs/services/rating/rating_service.dart';
import 'package:hrs/style/app_style.dart';

class RatingPage extends StatefulWidget {
  final Map<String, String?> ratingInfo;

  const RatingPage({
    super.key,
    required this.ratingInfo,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _supportRating = 0;
  double _maintenanceRating = 0;
  double _communicationRating = 0;
  bool _isSubmitting = false;
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
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : _buildMainBody(context),
    );
  }

  SingleChildScrollView _buildMainBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyCard(),

            // Add space between elements
            const SizedBox(height: 20),

            // Add a divider
            const Divider(),

            // Add space between elements
            const SizedBox(height: 15),

            _buildLandlordInformation(),

            // Add space between elements
            const SizedBox(height: 25),

            // Support and assistance Rating Bar
            _buildRatingBar(
              'Support and assistance',
              _supportRating,
              'support',
            ),

            // Add space between elements
            const SizedBox(height: 10),

            // Maintenance Rating Bar
            _buildRatingBar(
              'Maintenance',
              _maintenanceRating,
              'maintenance',
            ),

            // Add space between elements
            const SizedBox(height: 10),

            // Communication Rating Bar
            _buildRatingBar(
              'Communication',
              _communicationRating,
              'communication',
            ),

            // Add space between elements
            const SizedBox(height: 20),

            // Comments TextField
            TextField(
              controller: _commentsController,
              maxLines: 4,
              style: AppStyles.textFieldText,
              decoration: InputDecoration(
                hintText: 'Share more thoughts on the landlord to help others',
                hintStyle: AppStyles.hintText,
                contentPadding: const EdgeInsets.all(10),
                border: const OutlineInputBorder(),
              ),
            ),

            // Add space between elements
            const SizedBox(height: 20),

            // Submit Button
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
                                'Are you sure you want to submit your rating? Once submitted, it cannot be changed',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Close the dialog
                                    Navigator.of(dialogContext).pop();

                                    // Close the keyboard, if open
                                    FocusScope.of(context).unfocus();

                                    // Set the submitting state to true,
                                    // to show the loading indicator
                                    setState(() {
                                      _isSubmitting = true;
                                    });

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
    );
  }

  Row _buildLandlordInformation() {
    return Row(
      children: [
        // Landlord Profile Picture
        CustomCircleAvatar(
          imageURL: widget.ratingInfo['landlordImageURL'],
          name: "Landlord Name",
          radius: 28,
          fontSize: 22,
        ),

        const SizedBox(width: 10),

        // Landlord Name and Role
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ratingInfo['landlordName']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            // ignore: prefer_const_constructors
            Text(
              'Property Owner',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Container _buildPropertyCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.ratingInfo['propertyImageURL']!,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ratingInfo['propertyName']!,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ratingInfo['propertyAddress']!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      // Submit the landlord rating
      await RatingService.submitLandlordRating(
        landlordRating: newRating,
        landlordID: widget.ratingInfo['landlordID']!,
        tenancyDocID: widget.ratingInfo['tenancyDocID']!,
        propertyID: widget.ratingInfo['propertyID']!,
      );

      // Fetch the updated ended tenancies
      // to reflect the new rating
      final List<TenantEndedTenancy> updatedEndedTenancies =
          await TenancyService.fetchTenantEndedTenancies();

      // If successful, navigate back to the previous page
      // with a success message and update the ended tenancies
      if (context.mounted) {
        Navigator.pop(context, {
          'success': true,
          'message': 'Rating submitted successfully',
          'updatedEndedTenancies': updatedEndedTenancies,
        });
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(
          content: const Text(
            'An error occurred while submitting rating. Please try again in a few moments',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
      print('Error submitting rating: $e');
    } finally {
      // Set the submitting state to false
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
