import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../app/App_Colors.dart';

class ErrorScreen extends StatelessWidget {
  final String? error;
  final String? status;
  const ErrorScreen({super.key, required this.error, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 15, bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  error ?? "Unknown Error",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.red2,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: status == "Online" ? const Color(0xFF2277BB) : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status ?? "Unknown",
                      style: TextStyle(
                        color: status == "Online" ? const Color(0xFF2277BB) : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Image.asset(
            "assets/caution.png",
            height: 80,
            width: 80,
          ),
        ),

        const SizedBox(height: 16),

        // Friendly Error Message
        // const Text(
        //   "Oops! Something went wrong.",
        //   style: TextStyle(
        //     color: Colors.black,
        //     fontSize: 20,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),

        const SizedBox(height: 12),

        Text(
          error ??
              "We’re having trouble connecting to your device. Please check your device’s power or internet connection and try again.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(
                  child: Text(
                    "Kindly Check your System and Retry...",
                    style: TextStyle(color: AppColors.black, fontSize: 16),
                  ),
                ),
                duration: Duration(seconds: 3),
                backgroundColor: AppColors.red1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 0.6),
            backgroundColor: AppColors.red1,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh,
                color: AppColors.black,
              ),
              SizedBox(width: 6),
              Text(
                "Retry",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
