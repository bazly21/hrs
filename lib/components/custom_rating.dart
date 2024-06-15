import 'package:flutter/material.dart';
import 'package:hrs/components/criteria_rating.dart';
import 'package:hrs/components/custom_richtext.dart';

class CustomRating extends StatelessWidget {
  final String _criteria1;
  final String _criteria2;
  final String _criteria3;
  final String _position;
  final double _rating1;
  final double _rating2;
  final double _rating3;
  final double _spacing;
  final double _fontSize;
  final double _iconSize;
  final int _numReview;
  final bool _hasTitle;

  const CustomRating({
    super.key,
    String criteria1 = "Support and assistance",
    String criteria2 = "Maintenance",
    String criteria3 = "Communication",
    double rating1 = 0.0,
    double rating2 = 0.0,
    double rating3 = 0.0,
    String position = "Landlord",
    int numReview = 0,
    bool hasTitle = false,
    double spacing = 0.01,
    double fontSize = 18.0,
    double iconSize = 24.0,
  })  : _criteria1 = criteria1,
        _criteria2 = criteria2,
        _criteria3 = criteria3,
        _rating1 = rating1,
        _rating2 = rating2,
        _rating3 = rating3,
        _position = position,
        _numReview = numReview,
        _hasTitle = hasTitle,
        _spacing = spacing,
        _fontSize = fontSize,
        _iconSize = iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_hasTitle) ...[
          Row(
            children: [
              CustomRichText(
                mainText: "$_position Rating",
                subText: _numReview == 0
                    ? " (No Review)"
                    : _numReview > 1
                        ? " ($_numReview Reviews)"
                        : " ($_numReview Review)",
                subFontSize: 16.0,
              ),
            ],
          ),

          // Add spaces between elements
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        ],

        // Display rating criteria if there is at least one review
          CustomCriteriaRating(
            criteria: _criteria1,
            rating: _rating1,
            fontSize: _fontSize,
            iconSize: _iconSize,
          ),

          // Add spaces between elements
          SizedBox(height: MediaQuery.of(context).size.height * _spacing),

          CustomCriteriaRating(
            criteria: _criteria2,
            rating: _rating2,
            fontSize: _fontSize,
            iconSize: _iconSize,
          ),

          // Add spaces between elements
          SizedBox(height: MediaQuery.of(context).size.height * _spacing),

          CustomCriteriaRating(
            criteria: _criteria3,
            rating: _rating3,
            fontSize: _fontSize,
            iconSize: _iconSize,
          ),
        ]
    );
  }
}
