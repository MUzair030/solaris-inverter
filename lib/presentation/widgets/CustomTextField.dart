import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/App_Colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label = "Enter text",
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    required this.maxLength,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
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
          counterText: '${widget.controller.text.length}/${widget.maxLength}',
          counterStyle: const TextStyle(color: AppColors.txtgray, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.green),
          ),
        ),
        onChanged: (_) {
          setState(() {}); // Refresh to update live counter
        },
      ),
    );
  }
}
