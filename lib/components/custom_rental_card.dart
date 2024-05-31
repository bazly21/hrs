import 'package:flutter/material.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/pages/property_details_page.dart';
import 'package:hrs/provider/wishlist_provider.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:provider/provider.dart';

class RentalCard extends StatelessWidget {
  const RentalCard({
    super.key,
    required PropertyFullDetails propertyData,
    required bool isLastIndex,
    bool requiresConsumer = false,
    required void Function() iconOnPressed,
  })  : _propertyData = propertyData,
        _isLastIndex = isLastIndex,
        _requiresConsumer = requiresConsumer,
        _iconOnPressed = iconOnPressed;

  final PropertyFullDetails _propertyData;
  final bool _isLastIndex;
  final bool _requiresConsumer;
  final void Function() _iconOnPressed;

  @override
  Widget build(BuildContext context) {
    num rentalPrice = _propertyData.rentalPrice!;
    String formattedRentalPrice = rentalPrice != rentalPrice.toInt()
        ? rentalPrice.toStringAsFixed(2)
        : rentalPrice.toStringAsFixed(0);
    String propertyID = _propertyData.propertyID!;

    return Container(
      margin: EdgeInsets.only(
          left: 16, right: 16, top: 16, bottom: _isLastIndex ? 16 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Go to property details page
          NavigationUtils.pushPage(
                  context,
                  PropertyDetailsPage(propertyID: propertyID),
                  SlideDirection.left)
              .then((errorMessage) {
            // Show an error message if there's an error
            if (errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            }
          });
        }, // Go to property details page
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                    image: DecorationImage(
                        image: NetworkImage(_propertyData.image![0]),
                        fit: BoxFit.cover)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to the left
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //////// Property Name Section (Start) //////
                          Text(
                            _propertyData.propertyName!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //////// Property Name Section (End) //////

                          //////// Property Location Section (Start) //////
                          Text(
                            _propertyData.address!,
                            style: const TextStyle(fontSize: 15),
                          ),
                          //////// Property Location Section (End) //////

                          // Add space between elements
                          const SizedBox(height: 4.0),

                          //////// Profile and Rating Sections (Start) //////
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile picture
                              InkWell(
                                onTap: () {},
                                child: const CircleAvatar(
                                  radius: 9,
                                  backgroundImage: NetworkImage(
                                      'https://via.placeholder.com/150'),
                                ),
                              ),

                              // Add space between elements
                              SizedBox(
                                  width: _propertyData.landlordOverallRating! >
                                              0 &&
                                          _propertyData.landlordRatingCount! > 0
                                      ? 2
                                      : 5),

                              // If the landlord has a rating
                              if (_propertyData.landlordOverallRating! > 0 &&
                                  _propertyData.landlordRatingCount! > 0) ...[
                                // Star icon
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 16,
                                ),

                                // Add space between elements
                                const SizedBox(width: 2),

                                CustomRichText(
                                    mainText: _propertyData
                                        .landlordOverallRating!
                                        .toString(),
                                    subText:
                                        " (${_propertyData.landlordRatingCount})",
                                    mainFontSize: 14,
                                    mainFontWeight: FontWeight.normal)
                              ],

                              // If the landlord has no rating
                              if (_propertyData.landlordOverallRating! == 0 &&
                                  _propertyData.landlordRatingCount! == 0)
                                const Text("No rating",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54)),
                            ],
                          ),
                          //////// Profile and Rating Sections (End) //////

                          // Add space between elements
                          const SizedBox(height: 4.0),

                          //////// Property Brief Information Section (Start) //////
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ////// Bed Information (Start) //////
                              const Icon(
                                Icons.bed,
                                size: 18,
                                color: Colors.grey,
                              ),

                              // Add space between elements
                              const SizedBox(width: 4),

                              Text(
                                "${_propertyData.bathrooms!} Rooms",
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF7D7F88)),
                              ),
                              ////// Bed Information (End) //////

                              // Add space between elements
                              const SizedBox(width: 10),

                              ////// Property Size Information (Start) //////
                              const Icon(
                                Icons.house_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),

                              // Add space between elements
                              const SizedBox(width: 4),

                              Text(
                                "${_propertyData.size!} m\u00B2",
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF7D7F88)),
                              )
                              ////// Property Size Information (End) //////
                            ],
                          ),
                        ],
                      ),
                      //////// Property Brief Information Section (End) //////

                      // Add space between elements
                      const SizedBox(height: 15),

                      //////// Rental Property's Price and Wishlist Section (Start) //////
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rental price
                          CustomRichText(
                              mainText: "RM$formattedRentalPrice",
                              subText: " /month"),

                          // Wishlist Icon
                          InkWell(onTap: _iconOnPressed, child: _buildIcon())
                        ],
                      ),
                      //////// Rental Property's Price and Wishlist Section (End) //////
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (_requiresConsumer) {
      return Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          bool isWishlisted = wishlistProvider.wishlistPropertyIDs
              .contains(_propertyData.propertyID);
          return Icon(
            isWishlisted
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            size: 20.0,
            color: isWishlisted ? Colors.red : const Color(0xFF7D7F88),
          );
        },
      );
    } else {
      return const Icon(
        Icons.delete,
        size: 20.0,
        color: Color(0xFF7D7F88),
      );
    }
  }
}
