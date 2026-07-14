import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/AddDevicesBottomSheet3.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/DataCollectionConsentDialog.dart';

import '../../app/App_Colors.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/WelcomeWidget1.dart';
import 'MainBottomNavigationView.dart';
import 'ap_provisioning_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  Future<bool> requestCameraAndLocationPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
      Permission.notification,
    ].request();

    // Check if all required permissions are granted
    bool allGranted = statuses[Permission.camera]!.isGranted &&
        statuses[Permission.location]!.isGranted &&
        statuses[Permission.notification]!.isGranted;

    return allGranted;
  }

  void handlePermissionsAndShowBottomSheet(BuildContext context) async {
    bool cameraGranted = await Permission.camera.isGranted;
    bool locationGranted = await Permission.location.isGranted;
    bool notificationGranted = await Permission.notification.isGranted;

    if (cameraGranted && locationGranted && notificationGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Ap_Provisioning_Screen(),
        ),
      );
    } else {
      final consented = await showDataCollectionConsentDialog(
        context,
        [Permission.camera, Permission.location, Permission.notification],
      );
      if (consented) {
        bool success = await requestCameraAndLocationPermissions();
        if (success) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Ap_Provisioning_Screen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Camera, location, and notification permissions are required.",
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Mainbottomnavigationview()),
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/splash_bg.png", fit: BoxFit.cover),
            Container(
              color: Colors.black.withOpacity(0.4), // Dark overlay
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const HeaderWidget(),
                    const SizedBox(height: 20),
                    const WelcomeWidget1(),
                    const SizedBox(height: 20),
                    Image.asset("assets/welcomescreen.png", fit: BoxFit.cover),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity, // Full-width button
                      child: ElevatedButton(
                        onPressed: () {
                          handlePermissionsAndShowBottomSheet(context);
                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => AddDevicePage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00), // Green background
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10), // Increase button height
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Center text & icon
                          children: [
                            const Text(
                              "Add New Device",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text color
                              ),
                            ),
                            const SizedBox(
                                width: 10), // Space between text and icon
                            Image.asset(
                                "assets/nextbtn.png", // Your custom icon
                                width: 24, // Adjust icon size
                                height: 24,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Mainbottomnavigationview()));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFF6B00), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "Voltis",
                            style: TextStyle(
                              color: const Color(0xFFFF6B00),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddDevicesBottomSheet3(),
    );
  }
}
