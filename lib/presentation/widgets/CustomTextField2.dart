import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/App_Colors.dart';

class CustomTextField2 extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLength;
  final Widget? suffixIcon;

  const CustomTextField2({
    Key? key,
    required this.controller,
    this.label = "Enter text",
    this.keyboardType = TextInputType.text,
    required this.readOnly,
    this.inputFormatters,
    required this.maxLength,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<CustomTextField2> createState() => _CustomTextField2State();
}

class _CustomTextField2State extends State<CustomTextField2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType, // Set input type here
        readOnly: widget.readOnly,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
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
          labelStyle: const TextStyle(color: AppColors.white, fontSize: 13),
          counterText: '${widget.controller.text.length}/${widget.maxLength}',
          counterStyle: const TextStyle(color: AppColors.white, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Appconst Color(0xFF2277BB)),
          ),
          suffixIcon: widget.suffixIcon,
        ),
        onChanged: (_) {
          setState(() {}); // Refresh to update live counter
        },
      ),
    );
  }
}
