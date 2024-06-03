import 'package:flutter/material.dart';

class CustomDropDownField extends StatelessWidget {
  const CustomDropDownField({
    super.key,
    required String label,
    required String hintText,
    required List<DropdownMenuItem<String>>? items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
    required GlobalKey<FormFieldState<String>> formFieldKey,
  })  : _label = label,
        _hintText = hintText,
        _items = items,
        _validator = validator,
        _onChanged = onChanged,
        _formFieldKey = formFieldKey;

  final String _label;
  final String _hintText;
  final List<DropdownMenuItem<String>>? _items;
  final void Function(String?)? _onChanged;
  final String? Function(String?)? _validator;
  final GlobalKey<FormFieldState<String>> _formFieldKey;

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

        // Add space between elements
        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          key: _formFieldKey,
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
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error, width: 2.0),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            hintText: _hintText,
            hintStyle: const TextStyle(
                color: Color(0xFFA6A6A6),
                fontSize: 14,
                fontWeight: FontWeight.normal),
            contentPadding: const EdgeInsets.all(10.0),
            errorMaxLines: 2,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
