import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/App_Colors.dart';

class CustomTextField1 extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? assetIcon;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLength;

  const CustomTextField1({
    super.key,
    required this.controller,
    this.label = "Enter text",
    this.keyboardType = TextInputType.text,
    this.assetIcon,
    required this.readOnly,
    this.inputFormatters,
    required this.maxLength,
  });

  @override
  State<CustomTextField1> createState() => _CustomTextField1State();
}

class _CustomTextField1State extends State<CustomTextField1> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType, // Set input type here
        readOnly: widget.readOnly,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
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
          labelStyle: const TextStyle(color: AppColors.black, fontSize: 13),
          counterText: '${widget.controller.text.length}/${widget.maxLength}',
          counterStyle: const TextStyle(color: AppColors.black2, fontSize: 12),
          prefixIcon: widget.assetIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    widget.assetIcon!,
                    color: AppColors.blue,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 35,
            minHeight: 35,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.black),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.blue),
          ),
        ),
        onChanged: (_) {
          setState(() {}); // Refresh to update live counter
        },
      ),
    );
  }
}
