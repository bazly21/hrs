import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged
  })  : _label = label,
        _hintText = hintText,
        _controller = controller,
        _keyboardType = keyboardType,
        _prefixIcon = prefixIcon,
        _inputFormatters = inputFormatters,
        _validator = validator,
        _onChanged = onChanged;

  final String _label;
  final String _hintText;
  final TextEditingController _controller;
  final TextInputType _keyboardType;
  final Widget? _prefixIcon;
  final List<TextInputFormatter>? _inputFormatters;
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
          controller: _controller,
          keyboardType: _keyboardType,
          validator: _validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: _prefixIcon,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF606060)),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            errorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error),
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            focusedErrorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            hintText: _hintText,
            hintStyle: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 14, fontWeight: FontWeight.normal),
            contentPadding: const EdgeInsets.all(10.0),
            errorMaxLines: 2,
          ),
          maxLines: null,
          onChanged: _onChanged,
          inputFormatters: _inputFormatters,
        ),
      ],
    );
  }
}
