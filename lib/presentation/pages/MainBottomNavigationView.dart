import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/presentation/pages/DeviceListScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/ProfileScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/StatisticsScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/ap_provisioning_screen.dart';

import '../../di/update_checker.dart';
import '../viewmodels/DeviceViewModel.dart';
import '../viewmodels/NetworkMonitor.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/UserDetailsViewModel.dart';
import '../widgets/AddDevicesBottomSheet.dart';
import '../widgets/showExitConfirmationDialog.dart';
import 'AddDevicePage.dart';
import 'mainscreen.dart';
import 'mainscreen1.dart';

class Mainbottomnavigationview extends StatefulWidget {
  const Mainbottomnavigationview({super.key});

  @override
  State<Mainbottomnavigationview> createState() =>
      _MainbottomnavigationviewState();
}

class _MainbottomnavigationviewState extends State<Mainbottomnavigationview> {
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  bool isDataLoaded = false;

  String? user_name;
  String? last_name;
  String? user_email;
  late final UserDetailsViewModel viewModel;
  // late final InverterViewModel1 inverterVM1;

  Timer? _debounce;
  bool _isInit = true;
  String? lastLoadedMac;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker.checkForUpdate(context);
    });

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    // One-time data loading after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel = Provider.of<UserDetailsViewModel>(context, listen: false);
      viewModel.fetchUserDetails();
      // final selectedDeviceProvider =
      //     Provider.of<SelectedDeviceProvider>(context, listen: false);
      // final currentMac = selectedDeviceProvider.mac;
      // final deviceVM = context.read<DeviceViewModel>();
      // final userVM = context.read<UserDetailsViewModel>();
      // final inverterVM = context.read<InverterViewModel>();
      // inverterVM.setContext(context);
      // inverterVM1 = context.read<InverterViewModel1>();
      // // Add listener for toast messages
      // // inverterVM1.toastMessage.addListener(_onToastMessage);
      //
      // // deviceVM.fetchDevices();
      // // userVM.fetchUserDetails();
      // inverterVM.startAutoRefresh();
      // if (currentMac != null && currentMac != lastLoadedMac) {
      //   lastLoadedMac = currentMac;
      //   inverterVM1.startAutoRefresh("daily", macAddress: currentMac);
      // }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      _isInit = false;

      final networkMonitor = Provider.of<NetworkMonitor>(context);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        networkMonitor.addListener(() {
          if (!mounted) return;

          if (!networkMonitor.isConnected) {
            _showSnackBar("🔴 Network disconnected", Colors.red);
          } else {
            // Debounce reconnection logic
            _debounce?.cancel();
            _debounce = Timer(const Duration(seconds: 2), () async {
              if (!mounted) return;
              _showSnackBar("🟢 Network connected", const Color(0xFF2277BB));
              await _reloadAllDataOnReconnect();
            });
          }
        });
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _reloadAllDataOnReconnect() async {
    try {
      final selectedDeviceProvider =
          Provider.of<SelectedDeviceProvider>(context, listen: false);
      final currentMac = selectedDeviceProvider.mac;

      await context.read<UserDetailsViewModel>().fetchUserDetails();
      await context.read<DeviceViewModel>().fetchDevices();

      // final inverterViewModel = context.read<InverterViewModel>();
      // inverterViewModel.setContext(context);
      // await inverterViewModel.fetchInverterData();
      // inverterViewModel.startAutoRefresh();

      if (currentMac != null && currentMac != lastLoadedMac) {
        lastLoadedMac = currentMac;

        // final inverterViewModel1 =
        //     Provider.of<InverterViewModel1>(context, listen: false);
        //
        // await inverterViewModel1.fetchInverterData("daily",
        //     macAddress: currentMac);
        // inverterViewModel1.startAutoRefresh("daily", macAddress: currentMac);
      }
    } catch (e) {
      debugPrint("❌ Error reloading on reconnect: $e");
      // _showSnackBar("⚠️ Failed to reload data", Colors.orange);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // inverterVM1.toastMessage.removeListener(_onToastMessage);
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndexNotifier.value != 0) {
          _selectedIndexNotifier.value = 0;
          return false;
        } else {
          bool exitApp =
              await ExitConfirmationDialog.showExitConfirmationDialog(context);
          return exitApp;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, child) {
                return IndexedStack(
                  index: selectedIndex,
                  children: _screens,
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.navigationColor,
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _selectedIndexNotifier,
                  builder: (context, selectedIndex, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBottomMenuItem(
                            "assets/home.png", "Home", 0, selectedIndex),
                        _buildBottomMenuItem("assets/statistics.png",
                            "Statistic", 1, selectedIndex),
                        const SizedBox(
                            width: 60), // Space for the floating Add button
                        _buildBottomMenuItem(
                            "assets/devices.png", "Devices", 2, selectedIndex),
                        _buildBottomMenuItem(
                            "assets/profile.png", "Profile", 3, selectedIndex),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 45, // Adjust height to float above the bottom bar
              left: MediaQuery.of(context).size.width / 2 -
                  30, // Center horizontally
              child: ElevatedButton(
                onPressed: () {
                  // _showDeviceDetailBottomSheet(context);
                  handlePermissionsAndShowBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(), // Maintains circular shape
                ),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Image.asset(
                    "assets/addbtn.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      // _showDeviceDetailBottomSheet(context);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => AddDevicePage(), // FIXED: Pass wifiData
      //   ),
      // );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Ap_Provisioning_Screen(),
        ),
      );
    } else {
      showPermissionsDisclosureDialog(context);
    }
  }

  void showPermissionsDisclosureDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Permissions Required",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "This app requires access to your camera, location, and notifications to function properly.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2277BB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close the bottom sheet
                        bool success =
                            await requestCameraAndLocationPermissions();
                        if (success) {
                          // _showDeviceDetailBottomSheet(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Ap_Provisioning_Screen(),
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
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Define your different screens here
  final List<Widget> _screens = [
    const Mainscreen(),
    // MainScreen1(),
    const Statisticsscreen(),
    const Devicelistscreen(),
    // SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      _navigateToProfile();
    } else {
      if (_selectedIndexNotifier.value == index) return;
      _selectedIndexNotifier.value = index;
    }
  }

  void _navigateToProfile() {
    final userDetails = viewModel.userDetails;

    if (userDetails == null) {
      Fluttertoast.showToast(
          msg: "User details are still loading, please wait...");
      // return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Allows transparency
        pageBuilder: (_, __, ___) => ProfileScreen(
          // username: viewModel.userDetails!.username,
          // lastname: viewModel.userDetails!.lastName,
          // email: viewModel.userDetails!.email
          username: userDetails?.username ?? 'loading',
          lastname: userDetails?.lastName ?? '...',
          email: userDetails?.email ?? 'loading...',
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildBottomMenuItem(
      String iconPath, String label, int index, int selectedIndex) {
    bool isSelected = selectedIndex == index;
    return ElevatedButton(
      onPressed: () => _onItemTapped(index),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? AppColors.green.withOpacity(0.2) : Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 23,
            height: 23,
            color: isSelected ? AppColors.green : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
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
      builder: (context) => const AddDevicesBottomSheet(),
    );
  }
}
