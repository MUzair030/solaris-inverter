import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

class CustomInkWellItem4 extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const CustomInkWellItem4({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4), // Rounded corners
        splashColor: Colors.red.withOpacity(0.3), // Ripple effect color
        highlightColor:
            Colors.red.withOpacity(0.5), // Background color when pressed
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 6, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
