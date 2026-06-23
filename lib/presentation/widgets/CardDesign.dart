import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/App_Colors.dart';

class CardDesign extends StatelessWidget {
  final String message;

  const CardDesign({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Text(message, style: TextStyle(color: AppColors.white)),
          ),
        ),
      ),
    );
  }
}
