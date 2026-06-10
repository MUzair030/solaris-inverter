import 'package:flutter/services.dart';

class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty string
    if (newValue.text.isEmpty) return newValue;

    // Disallow if first character is 0
    if (newValue.text.length == 1 && newValue.text == '0') {
      return oldValue;
    }

    // Allow only digits
    if (RegExp(r'^[1-9][0-9]*$').hasMatch(newValue.text) ||
        RegExp(r'^[1-9]?$').hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}
