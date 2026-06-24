import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

class CustomInkWellItem3 extends StatelessWidget {
  final IconData imagePath;
  final VoidCallback onTap;
  final Color color;

  const CustomInkWellItem3({
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
        splashColor: const Color(0xFFFF6B00).withOpacity(0.3), // Ripple effect color
        highlightColor:
            const Color(0xFFFF6B00).withOpacity(0.5), // Background color when pressed
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 6),
              child: Row(
                children: [
                  Icon(
                    imagePath,
                    size: 25,
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
