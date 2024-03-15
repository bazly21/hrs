import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PropertyDetailsPriceTextField extends StatefulWidget {
  final String? rentalPrice;
  
  const PropertyDetailsPriceTextField({
    super.key, 
    this.rentalPrice, 
  });

  @override
  State<PropertyDetailsPriceTextField> createState() => _PropertyDetailsPriceTextFieldState();
}

class _PropertyDetailsPriceTextFieldState extends State<PropertyDetailsPriceTextField> {
  final TextEditingController rentalPriceTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.rentalPrice != null) {
      if (widget.rentalPrice!.contains('.')) {
        rentalPriceTextController.text = widget.rentalPrice!;
      } else {
        rentalPriceTextController.text = '${widget.rentalPrice!}.00';
      }
    } else {
      rentalPriceTextController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rent Price / Month',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
            
        // Add space between elements
        const SizedBox(height: 8.0),
            
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
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.all(10)
          ),
          enableInteractiveSelection: false,
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
    rentalPriceTextController.dispose(); // Dispose the controller
    super.dispose();
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