import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/App_Colors.dart';

class PasswordTextFieldSignUp extends StatefulWidget {
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final String label;
  final String? errorText;

  const PasswordTextFieldSignUp({
    super.key,
    required this.controller,
    this.inputFormatters,
    required this.label,
    this.errorText,
  });

  @override
  _PasswordTextFieldSignUpState createState() =>
      _PasswordTextFieldSignUpState();
}

class _PasswordTextFieldSignUpState extends State<PasswordTextFieldSignUp> {
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
          label: RichText(
            text: TextSpan(
              text: widget.label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          labelStyle: const TextStyle(color: AppColors.white),
          counterText: '${widget.controller.text.length}/$_maxLength',
          counterStyle: const TextStyle(color: AppColors.txtgray, fontSize: 12),
          errorText: widget.errorText,
          errorStyle: const TextStyle(color: AppColors.red, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.white), // White bottom line
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide:
                BorderSide(color: Appconst Color(0xFF2277BB)), // Blue bottom line on focus
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
