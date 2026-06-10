import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/presentation/pages/ChangePasswordScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/PermissionsInfoScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/signup_page.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/CustomInkWellItem.dart';

import '../../core/network/dio_client.dart';
import '../../utils/Constants.dart';
import '../../utils/SharedPreferencesHelper.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/UserDetailsViewModel.dart';
import '../widgets/CustomInkWellItem2.dart';
import 'EditProfileScreen.dart';
import 'LoginScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final UserDetailsViewModel viewModel;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel = Provider.of<UserDetailsViewModel>(context, listen: false);
    });
    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.light, // White icons
    //   statusBarBrightness: Brightness.dark,
    // ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DioClient dioClient = DioClient();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ));
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomInkWellItem2(
                    imagePath: "assets/backclick.png",
                    color: AppColors.black,
                    onTap: () {
                      Navigator.pop(context);
                      SystemChrome.setSystemUIOverlayStyle(
                          const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness:
                            Brightness.light, // White icons
                        statusBarBrightness: Brightness.dark,
                      ));
                    },
                  ),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Opacity(
                    opacity: 0.0, // Set to true to show it again
                    child: Image.asset("assets/backclick.png",
                        width: 20, height: 20),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        const Text("Accounts",
                            style: TextStyle(
                                fontSize: 22,
                                color: AppColors.black,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        CustomInkWellItem(
                            imagePath: "assets/profileicon.png",
                            title: "Profile",
                            onTap: () async {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(viewModel: viewModel),
                                ),
                              );
                            }),
                        CustomInkWellItem(
                            imagePath: "assets/passwordicon.png",
                            title: "Change Password",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChangePasswordScreen()));
                            }),
                        const SizedBox(height: 20),
                        const Text("Privacy Protection",
                            style: TextStyle(
                                fontSize: 22,
                                color: AppColors.black,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        // CustomInkWellItem(
                        //     imagePath: "assets/profileicon.png",
                        //     title: "Permissions",
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 PermissionsInfoScreen()),
                        //       );
                        //     }),
                        CustomInkWellItem(
                            imagePath: "assets/privacypolicy.png",
                            title: "Privacy",
                            onTap: () {
                              constants().launchPrivacyPolicy();
                            }),
                        const SizedBox(height: 20),
                        const Text("General",
                            style: TextStyle(
                                fontSize: 22,
                                color: AppColors.black,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        CustomInkWellItem(
                            imagePath: "assets/rate.png",
                            title: "Rate & Review",
                            onTap: () {
                              constants().launchRateUs();
                            }),
                        CustomInkWellItem(
                            imagePath: "assets/shareapp.png",
                            title: "Share",
                            onTap: () {
                              constants().shareApp();
                            }),
                        const SizedBox(height: 40),
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
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.red),
                            child: const Center(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                                    color: AppColors.green, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
