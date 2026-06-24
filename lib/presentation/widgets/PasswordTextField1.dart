import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/App_Colors.dart';

class PasswordTextField1 extends StatefulWidget {
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final String label;
  final String? errorText;

  const PasswordTextField1({
    Key? key,
    required this.controller,
    this.inputFormatters,
    required this.label,
    this.errorText,
  }) : super(key: key);

  @override
  _PasswordTextFieldState1 createState() => _PasswordTextFieldState1();
}

class _PasswordTextFieldState1 extends State<PasswordTextField1> {
  bool _isPasswordVisible = false;
  static const int _maxLength = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: TextField(
        controller: widget.controller,
        obscureText: !_isPasswordVisible,
        inputFormatters: widget.inputFormatters,
        maxLength: _maxLength,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: AppColors.white),
          counterText: '${widget.controller.text.length}/$_maxLength',
          counterStyle: const TextStyle(color: AppColors.gray2, fontSize: 12),
          errorText: widget.errorText,
          errorStyle: const TextStyle(color: AppColors.red, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.white), // White bottom line
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.blue), // Blue bottom line on focus
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.white,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        onChanged: (_) {
          setState(() {}); // Refresh to update live counter
        },
      ),
    );
  }
}
