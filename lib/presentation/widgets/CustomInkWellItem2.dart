import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

class CustomInkWellItem2 extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final Color color;

  const CustomInkWellItem2({
    super.key,
    required this.imagePath,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4), // Rounded corners
        splashColor: Colors.green.withOpacity(0.3), // Ripple effect color
        highlightColor:
            Colors.green.withOpacity(0.5), // Background color when pressed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 6),
              child: Row(
                children: [
                  Image.asset(
                    imagePath,
                    height: 25,
                    width: 25,
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
