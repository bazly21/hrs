import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PropertyDetailsTextField extends StatefulWidget {
  final String title, hintText;
  final String? initialValue;
  final TextInputType textInputType;
  final Function(String) getText;
  
  const PropertyDetailsTextField({
    super.key, 
    required this.title, 
    this.initialValue,
    required this.hintText, 
    this.textInputType = TextInputType.text, 
    required this.getText
  });

  @override
  State<PropertyDetailsTextField> createState() => _PropertyDetailsTextFieldState();
}

class _PropertyDetailsTextFieldState extends State<PropertyDetailsTextField> {
  final TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textFieldController.text = widget.initialValue ?? '';
    textFieldController.addListener(_handleTextChange);

    // Once PropertyDetailsTextField widget is fully created,
    // _invokeCallbackWithInitialText will automatically
    // invoke. This invoke will allows to get initial value
    // of the TextField.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _invokeCallbackWithInitialText();
    });
  }

  @override
  void dispose() {
    textFieldController.removeListener(_handleTextChange);
    textFieldController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
    
        // Add space between elements
        const SizedBox(height: 8),
    
        TextFormField(
          maxLines: null,
          keyboardType: widget.textInputType,
          style: const TextStyle(fontSize: 14),
          controller: textFieldController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFA6A6A6),
              ),
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.normal),
            isDense: true,
            contentPadding: const EdgeInsets.all(10),
          ),
          inputFormatters: [
            // If textInputType equals to TextInputType.number,
            // then only allows numeric characters.
            if(widget.textInputType == TextInputType.number)
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
          ],
        ),
      ],
    );
  }

  void _handleTextChange() {
    widget.getText(textFieldController.text); // Call the callback function with the current text
  }

  // Function to invoke the callback with the initial value
  void _invokeCallbackWithInitialText() {
    widget.getText(widget.initialValue ?? '');
  }
}