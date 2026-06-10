import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/App_Colors.dart';

class PasswordTextFieldAddDevice extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const PasswordTextFieldAddDevice({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  State<PasswordTextFieldAddDevice> createState() =>
      _PasswordTextFieldAddDeviceState();
}

class _PasswordTextFieldAddDeviceState
    extends State<PasswordTextFieldAddDevice> {
  bool _isPasswordVisible = false;
  static const int _maxLength = 30;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: TextField(
        controller: widget.controller,
        obscureText: !_isPasswordVisible,
        maxLength: _maxLength,
        style: const TextStyle(color: AppColors.black),
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: widget.label,
              style: const TextStyle(
                color: AppColors.black,
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
          labelStyle: const TextStyle(color: AppColors.black),
          counterText: '${widget.controller.text.length}/$_maxLength',
          counterStyle: const TextStyle(color: AppColors.black, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.white), // White bottom line
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.green), // Blue bottom line on focus
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.black,
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
