import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threepol_inverter_flutter/presentation/pages/DeviceListScreen.dart';

import '../../../core/network/dio_client.dart';
import '../pages/LoginScreen.dart';
import '../pages/signup_page.dart';
import '../../../utils/SharedPreferencesHelper.dart';

class MyPopWidget {
  static void showPopupMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final DioClient dioClient = DioClient();

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & Size(40, 40), // Position near the button
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          value: "devices",
          child: Row(
            children: [
              Icon(Icons.device_hub, color: Colors.black),
              SizedBox(width: 10),
              Text("Devices"),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "profile",
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.black),
              SizedBox(width: 10),
              Text("Profile"),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "logout",
          child: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.red),
              SizedBox(width: 10),
              Text("Logout"),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == "devices") {
      } else if (value == "profile") {
        Fluttertoast.showToast(msg: "Profile Clicked");
      } else if (value == "logout") {
        await SharedPreferencesHelper.logout();
        await dioClient.refreshToken();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignupPage()),
        );
        Fluttertoast.showToast(msg: "Logout Success");
      }
    });
  }
}
