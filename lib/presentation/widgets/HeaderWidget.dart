import 'package:flutter/material.dart';

import '../../app/App_Colors.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("assets/app_logo.png", width: 60, height: 60),
        const Text(
          "Solaris",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white),
        ),
      ],
    );
  }
}
