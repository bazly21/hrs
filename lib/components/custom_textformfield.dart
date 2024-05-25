import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required String label,
    required String hintText,
    required TextEditingController nameController,
    String? Function(String?)? validator,
    void Function(String)? onChanged
  })  : _label = label,
        _hintText = hintText,
        _nameController = nameController,
        _validator = validator,
        _onChanged = onChanged;

  final String _label;
  final String _hintText;
  final TextEditingController _nameController;
  final String? Function(String?)? _validator;
  final void Function(String)? _onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name textfield label
        Text(_label,
            style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.w500)),

        // Add space between elements
        const SizedBox(height: 10),

        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          validator: _validator,
          // textCapitalization: _textCapitalization,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8568F3)),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            errorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error),
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            focusedErrorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error),
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            hintText: _hintText,
            hintStyle: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 14),
            contentPadding: const EdgeInsets.all(10.0),
          ),
          onChanged: _onChanged,
        ),
      ],
    );
  }
}
