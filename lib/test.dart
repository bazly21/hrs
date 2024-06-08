import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormField extends StatefulWidget {
  @override
  _DateFormFieldState createState() => _DateFormFieldState();
}

class _DateFormFieldState extends State<DateFormField> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  bool _isDateFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isDateFocused = true;
                    });

                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _isDateFocused = false;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.calendar_today),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: _isDateFocused ? Colors.blue : const Color(0xFF606060)),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0))),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                                width: 2.0),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0))),
                        hintText: 'Select move-in date',
                        hintStyle: const TextStyle(
                            color: Color(0xFFA6A6A6),
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                        contentPadding: const EdgeInsets.all(10.0),
                        errorMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Here you can save the date value if needed
                      },
                      // Display the selected date in the TextFormField
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Date is valid')));
                    }
                  },
                  child: const Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                    setState(() {
                      _selectedDate = null;
                    });
                  },
                  child: const Text('Reset'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
