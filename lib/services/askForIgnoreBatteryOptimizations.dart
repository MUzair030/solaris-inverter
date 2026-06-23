import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<bool> isIgnoringBatteryOptimizations() async {
  const platform = MethodChannel('battery_optimization_channel');
  try {
    final bool isIgnoring =
        await platform.invokeMethod('isIgnoringBatteryOptimizations');
    return isIgnoring;
  } catch (e) {
    return false;
  }
}

Future<void> requestIgnoreBatteryOptimizations() async {
  final info = await PackageInfo.fromPlatform();
  final packageName = info.packageName;

  final intent = AndroidIntent(
    action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
    data: 'package:$packageName',
  );
  await intent.launch();
}

// void askForIgnoreBatteryOptimizations() async {
//   final service = FlutterBackgroundService();
//
//   if (await service.isRunning()) {
//     final androidService = service as AndroidServiceInstance;
//
//     androidService.setAutoStartOnBootMode(true); // 🌀 Auto-start after reboot
//     androidService
//         .setAutoStartOnForeground(true); // 🔁 Auto-resume when app opens
//     androidService.setNotificationInfo(
//       title: 'Monitoring Active',
//       content: 'Device is being monitored in background',
//     );
//   }
// }
