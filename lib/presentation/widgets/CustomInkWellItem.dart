import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomInkWellItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const CustomInkWellItem({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7), // Rounded corners
      splashColor: const Color(0xFF2277BB).withOpacity(0.3), // Ripple effect color
      highlightColor:
          const Color(0xFF2277BB).withOpacity(0.5), // Background color when pressed
      child: Padding(
        padding: const EdgeInsets.only(top: 7, bottom: 7, left: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  imagePath,
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Image.asset("assets/forwardclick.png"),
          ],
        ),
      ),
    );
  }
}
