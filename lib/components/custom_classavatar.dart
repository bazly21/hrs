import 'package:flutter/material.dart';
import 'package:hrs/services/utils/string_utils.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({
    super.key,
    required String? imageURL,
    required String name,
    double radius = 50.0,
  })  : _imageURL = imageURL,
        _name = name,
        _radius = radius;

  final String? _imageURL;
  final String _name;
  final double _radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: _radius,
      backgroundImage: _imageURL != null ? NetworkImage(_imageURL) : null,
      backgroundColor: Theme.of(context).primaryColor,
      child: _imageURL == null
          ? Text(
              getInitials(_name),
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}