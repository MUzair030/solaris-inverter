import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/presentation/pages/AddDevicePage.dart';

class AddDevicesBottomSheet5 extends StatelessWidget {
  const AddDevicesBottomSheet5({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16, right: 26, left: 26),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.gray,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Device Not Unique!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1).",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.red,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Your Devices Mac is not Unique, click ok and check your device.",
                  style: TextStyle(fontSize: 14),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, // Full width button
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Green background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding:
                    EdgeInsets.symmetric(vertical: 5), // Increase button height
              ),
              child: Text(
                "Ok",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
