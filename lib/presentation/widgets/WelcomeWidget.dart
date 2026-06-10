import 'package:flutter/cupertino.dart';
import '../../app/App_Colors.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Welcome to Smart Home!",
          style: TextStyle(
              fontSize: 22,
              color: Appconst Color(0xFF2277BB),
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2),
        Text(
          "Monitor & control your devices seamlessly.",
          style: TextStyle(fontSize: 11, color: AppColors.white),
        ),
      ],
    );
  }
}
