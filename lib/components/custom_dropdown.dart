// ignore_for_file: unnecessary_question_mark

import 'package:flutter/material.dart';

class CustomDropDownField extends StatelessWidget {
  const CustomDropDownField({
    super.key,
    required String label,
    required String hintText,
    dynamic value,
    required List<DropdownMenuItem<dynamic>>? items,
    required void Function(dynamic?)? onChanged,
    String? Function(dynamic?)? validator,
  })  : _label = label,
        _hintText = hintText,
        _value = value,
        _items = items,
        _validator = validator,
        _onChanged = onChanged;

  final String _label;
  final String _hintText;
  final dynamic _value;
  final List<DropdownMenuItem<dynamic>>? _items;
  final void Function(dynamic?)? _onChanged;
  final String? Function(dynamic?)? _validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _label,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<dynamic>(
          value: _value,
          items: _items,
          onChanged: _onChanged,
          validator: _validator,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF606060)),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2.0,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            hintText: _hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFA6A6A6),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            contentPadding: const EdgeInsets.all(10.0),
            errorMaxLines: 2,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}