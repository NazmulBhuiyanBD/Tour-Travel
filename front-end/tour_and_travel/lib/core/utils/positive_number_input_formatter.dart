import 'package:flutter/services.dart';

class PositiveIntegerInputFormatter extends TextInputFormatter {
  final RegExp _pattern = RegExp(r'^[1-9][0-9]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class PositiveDecimalInputFormatter extends TextInputFormatter {
  final RegExp _pattern = RegExp(r'^(?=.*[1-9])\d+(\.\d*)?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
