import 'package:flutter/cupertino.dart';
import '../../app/App_Colors.dart';

class WelcomeWidget1 extends StatelessWidget {
  const WelcomeWidget1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Welcome to Smart Home!",
                style: TextStyle(
                    fontSize: 22,
                    color: Appconst Color(0xFF2277BB),
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          "No matter how far you go, home will be your destination to return to. Let's make your home comfortable",
          style: TextStyle(fontSize: 11, color: AppColors.white),
        ),
      ],
    );
  }
}
