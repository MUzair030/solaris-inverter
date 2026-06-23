import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/presentation/pages/AddDevicePage.dart';

class AddDevicesBottomSheet1 extends StatelessWidget {
  const AddDevicesBottomSheet1({super.key});

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
            "Steps to Add New Device",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1).",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.green,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Fill SSID and Password Field with your Home Wi-Fi Network",
                  style: TextStyle(fontSize: 14),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "2).",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.green,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Click Connect Inverter and wait for Status Message, Inverter Response",
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
                backgroundColor: Colors.green, // Green background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding:
                    EdgeInsets.symmetric(vertical: 5), // Increase button height
              ),
              child: Text(
                "ok",
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
