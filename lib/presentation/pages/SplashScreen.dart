import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/pages/LoginScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/MainBottomNavigationView.dart';
import 'package:threepol_inverter_flutter/presentation/pages/signup_page.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/DeviceViewModel.dart';

import '../../../utils/SharedPreferencesHelper.dart';
import '../../app/App_Colors.dart';
import '../../services/DeviceMonitoringService.dart';
import '../../services/askForIgnoreBatteryOptimizations.dart';
import '../../utils/requestNotificationPermission.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/UserDetailsViewModel.dart';
import '../viewmodels/inverter_viewmodel.dart';
import '../viewmodels/inverter_viewmodel1.dart';
import 'BoardingScreen.dart';
import 'mainscreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final InverterViewModel1 inverterVM1;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    // checkBatteryOptimization();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await disableBatteryOptimization();
      await requestNotificationPermission();
      await DeviceMonitoringService.initialize();
      // await DeviceMonitoringService.startMonitoring();
    });
  }

  Future<void> disableBatteryOptimization() async {
    final isDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;

    if (!isDisabled!) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }
  }

  Future<void> _initialize() async {
    await _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await SharedPreferencesHelper.getToken();
    // bool isLoggedIn = await SharedPreferencesHelper.isLoggedIn();

    // print("splash: $token");

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // await _preloadInitialData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Mainbottomnavigationview()),
      );
      // Load data in background after navigation
      Future.delayed(Duration.zero, _preloadInitialData);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BoardingScreen()),
      );
    }
  }

  Future<void> _preloadInitialData() async {
    inverterVM1 = context.read<InverterViewModel1>();
    final selectedDeviceProvider =
        Provider.of<SelectedDeviceProvider>(context, listen: false);
    final deviceVM = context.read<DeviceViewModel>();
    final userVM = context.read<UserDetailsViewModel>();
    final inverterVM = context.read<InverterViewModel>();

    final currentMac = selectedDeviceProvider.mac;

    try {
      await Future.wait([
        deviceVM.fetchDevices(),
        userVM.fetchUserDetails(),
      ]);

      if (currentMac != null) {
        await inverterVM.fetchInverterData();
        // await inverterVM.startAutoRefresh();
        await inverterVM1.fetchInverterData("daily", macAddress: currentMac);
        // await inverterVM1.startAutoRefresh("daily", macAddress: currentMac);
      }
    } catch (e) {
      print("Data preload error: $e");
    }
  }

  Future<void> checkBatteryOptimization() async {
    final alreadyPrompted =
        await SharedPreferencesHelper.getBool('battery_prompted');
    if (alreadyPrompted == true) return; // Don't show again

    if (Platform.isAndroid) {
      final isIgnored = await isIgnoringBatteryOptimizations();
      if (!isIgnored && mounted) {
        _showBatteryBottomSheet(context);
        await SharedPreferencesHelper.setBool(
            'battery_prompted', true); // Mark as shown
      }
    }
  }

  // Future<void> checkBatteryOptimization() async {
  //   // final isRunning = await FlutterBackgroundService().isRunning();
  //   // if (isRunning && mounted) {
  //   //   _showBatteryDialog(context);
  //   // }
  //   if (Platform.isAndroid) {
  //     final isIgnored = await isIgnoringBatteryOptimizations();
  //     if (!isIgnored && mounted) {
  //       _showBatteryBottomSheet(context);
  //     }
  //   }
  // }

  void _showBatteryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.battery_alert, size: 40, color: Colors.orange),
              const SizedBox(height: 12),
              const Text(
                "Optimize Battery Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please disable battery optimization for this app to ensure alerts work even when the app is closed.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
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
                        Navigator.of(context).pop(false);
                      },
                      child: const Text("Later"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2277BB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await requestIgnoreBatteryOptimizations(); // open settings
                      },
                      child: const Text(
                        "Open Settings",
                        style: TextStyle(color: AppColors.black),
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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
