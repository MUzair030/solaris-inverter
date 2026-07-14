import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/pages/LoginScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/NotificationsScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/PrivacyPolicyScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/SettingsScreen.dart';

import '../../app/App_Colors.dart';
import '../../core/network/dio_client.dart';
import '../../utils/SharedPreferencesHelper.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../widgets/CustomInkWellItem1.dart';

class ProfileScreen extends StatefulWidget {
  final String? username;
  final String? lastname;
  final String? email;

  ProfileScreen(
      {Key? key,
      required this.username,
      required this.lastname,
      required this.email})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.dark,
    //   statusBarBrightness: Brightness.light,
    // ));
  }

  @override
  void dispose() {
    super.dispose();

    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.light,
    //   statusBarBrightness: Brightness.dark,
    // ));
  }

  @override
  Widget build(BuildContext context) {
    final DioClient dioClient = DioClient();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Dim background
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              // 80% width
              height: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image.asset("assets/profilepic.png"),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 7.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${widget.username} ",
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                // Text(
                                //   "${widget.lastname} ",
                                //   style: const TextStyle(
                                //       fontSize: 17,
                                //       color: AppColors.black,
                                //       fontWeight: FontWeight.bold),
                                // ),
                              ],
                            ),
                            Text(
                              "${widget.email}",
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            CustomInkWellItem1(
                                imagePath: "assets/settings.png",
                                title: "Settings",
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen(),
                                    ),
                                  );
                                }),
                            CustomInkWellItem1(
                                imagePath: "assets/notifications.png",
                                title: "Notifications",
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NotificationsScreen(),
                                    ),
                                  );
                                }),
                            CustomInkWellItem1(
                                imagePath: "assets/privacy.png",
                                title: "Privacy",
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Privacypolicyscreen()));
                                }),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              onTap: () async {
                                await SharedPreferencesHelper.logout();
                                await dioClient.refreshToken();
                                // 2. Clear SelectedDeviceProvider
                                final selectedProvider =
                                    Provider.of<SelectedDeviceProvider>(context,
                                        listen: false);
                                selectedProvider.clearDevice();

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                                Fluttertoast.showToast(msg: "Logout Success");
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/logout.png",
                                    color: AppColors.black,
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("Logout"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20), // Add some spacing
                            const SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center text horizontally
                                children: [
                                  Text(
                                    "Powered by 3pol",
                                    style: TextStyle(
                                        color: AppColors.blue, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
