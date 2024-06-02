import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PropertyDetailsPriceTextField extends StatefulWidget {
  final String? rentalPrice;
  final Function(String) getText;
  
  const PropertyDetailsPriceTextField({
    super.key, 
    this.rentalPrice, 
    required this.getText, 
  });

  @override
  State<PropertyDetailsPriceTextField> createState() => _PropertyDetailsPriceTextFieldState();
}

class _PropertyDetailsPriceTextFieldState extends State<PropertyDetailsPriceTextField> {
  final TextEditingController rentalPriceTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If rentalPrice has value including 0.00
    if (widget.rentalPrice != null) {
      // Convert into double to use
      // toStringAsFixed(2) function
      // to ensure it always two decimals
      // points.
      double? dblRentalPrice = double.tryParse(widget.rentalPrice!);

      // If the conversion to double format is successfull
      if (dblRentalPrice != null) {
        rentalPriceTextController.text = dblRentalPrice.toStringAsFixed(2);
      }
      // Otherwise, returns empty string
      else {
        rentalPriceTextController.text = '';
      }   
    }
    else {
      rentalPriceTextController.text = '';
    }


    rentalPriceTextController.addListener(_handleTextChange);

    // Once PropertyDetailsTextField widget is fully created,
    // _invokeCallbackWithInitialText will automatically
    // invoke. This invoke will allows to get initial value
    // of the TextField.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _invokeCallbackWithInitialText();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: const Text(
            'Rent Price / Month',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
          ),
        ),
            
        // Add space between elements
        const SizedBox(height: 15.0),
            
        TextField(
          controller: rentalPriceTextController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 14.0),
          decoration: InputDecoration(
            prefixIcon:const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'RM',
                style: TextStyle(fontSize: 14),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.normal),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.all(10)
          ),
          // enableInteractiveSelection: false,
          showCursor: false,
          inputFormatters: [
            // Make sure only numeric characters can be entered.
            // This method will help preventing users from paste
            // non-numeric text
            CurrencyInputFormatter(),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    rentalPriceTextController.removeListener(_handleTextChange);
    rentalPriceTextController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    widget.getText(rentalPriceTextController.text); // Call the callback function with the current text
  }

  // Function to invoke the callback with the initial value
  void _invokeCallbackWithInitialText() {
    widget.getText(rentalPriceTextController.text);
  }
}



class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cleanInput = _cleanInput(newValue.text);
    final formattedValue = _formatValue(cleanInput);
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  String _cleanInput(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _formatValue(String cleanInput) {
    if (cleanInput.isEmpty) {
      return '';
    }

    final value = double.parse(cleanInput) / 100;

    if (value == 0.0) {
      // Return empty string when the value is 0.00
      return '';
    }

    return value.toStringAsFixed(2);
  }
}