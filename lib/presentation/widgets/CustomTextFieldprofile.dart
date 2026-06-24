import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/App_Colors.dart';

class CustomTextFieldprofile extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String title;
  final TextInputType keyboardType;
  final String? assetIcon;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLength;
  final Function(String)? onChanged;

  const CustomTextFieldprofile({
    Key? key,
    required this.controller,
    required this.title,
    this.label = "Enter text",
    this.keyboardType = TextInputType.text,
    this.assetIcon,
    required this.readOnly,
    this.inputFormatters,
    required this.maxLength,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextFieldprofile> createState() => _CustomTextFieldprofileState();
}

class _CustomTextFieldprofileState extends State<CustomTextFieldprofile> {
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

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(widget.title,
//             style: const TextStyle(color: AppColors.black, fontSize: 13)),
//         const SizedBox(height: 3),
//         AbsorbPointer(
//           absorbing: widget.readOnly,
//           child: TextFormField(
//             controller: widget.controller,
//             keyboardType: widget.keyboardType,
//             // readOnly: widget.readOnly,
//             maxLength: widget.maxLength,
//             inputFormatters: widget.inputFormatters,
//             style: const TextStyle(color: AppColors.black, fontSize: 16),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: AppColors.white,
//               hintText: widget.label,
//               hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
//               counterText:
//                   '${widget.controller.text.length}/${widget.maxLength}',
//               counterStyle:
//                   const TextStyle(color: AppColors.black, fontSize: 10),
//               // labelText: label,
//               // labelStyle: const TextStyle(color: AppColors.gray3),
//               // floatingLabelStyle: const TextStyle(color: AppColors.red1),
//
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//
//               enabledBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.black),
//               ),
//               focusedBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.blue),
//               ),
//             ),
//             onChanged: (value) {
//               setState(() {});
//               if (widget.onChanged != null) {
//                 widget.onChanged!(value);
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
