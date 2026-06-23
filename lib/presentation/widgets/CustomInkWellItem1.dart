import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';

class CustomInkWellItem1 extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const CustomInkWellItem1({
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
      splashColor: Colors.green.withOpacity(0.3), // Ripple effect color
      highlightColor:
          Colors.green.withOpacity(0.5), // Background color when pressed
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  imagePath,
                  color: AppColors.black,
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
