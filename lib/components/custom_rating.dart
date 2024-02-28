import 'package:flutter/material.dart';
import 'package:hrs/components/criteria_rating.dart';

class CustomRating extends StatelessWidget {
  final String criteria1, criteria2, criteria3, position;
  final double rating1, rating2, rating3, spacing, fontSize, iconSize;
  final int numReview;
  final bool hasTitle;

  const CustomRating({
    super.key, 
    this.criteria1 = "Support and assistance", 
    this.criteria2 = "Maintenance", 
    this.criteria3 = "Communication", 
    this.rating1 = 0.0, 
    this.rating2 = 0.0, 
    this.rating3 = 0.0, 
    this.position = "Landlord",
    this.numReview = 0, 
    this.hasTitle = false, 
    this.spacing = 0.01, 
    this.fontSize = 18.0, 
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(hasTitle) ...[
          Row(
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600), // Default text style
                  children: [
                    TextSpan(text: "$position Rating"),
                    TextSpan(
                      text: numReview > 1 ? " ($numReview Reviews)" : " ($numReview Review)",
                      style: const TextStyle(
                        color: Color(0xFF7D7F88),
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Add spaces between elements
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        ],

        CriteriaRating(criteria: criteria1, rating: rating1, fontSize: fontSize, iconSize: iconSize),

        // Add spaces between elements
        SizedBox(height: MediaQuery.of(context).size.height * spacing),

        CriteriaRating(criteria: criteria2, rating: rating2, fontSize: fontSize, iconSize: iconSize),

        // Add spaces between elements
        SizedBox(height: MediaQuery.of(context).size.height * spacing),

        CriteriaRating(criteria: criteria3, rating: rating3, fontSize: fontSize, iconSize: iconSize),

      ],

    );
  }
}