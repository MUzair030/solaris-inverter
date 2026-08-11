import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// Use the generic ty pes from the main package to avoid isolate conflicts
import 'package:flutter_background_service/flutter_background_service.dart'
    as service_type;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../core/network/dio_client.dart';
import '../data/repositories_impl/inverter_repository_impl.dart';
import '../domain/usecases/get_inverter_data_usecase.dart';
import 'package:threepol_inverter_flutter/services/NotificationService.dart';
import '../presentation/viewmodels/inverter_viewmodel.dart';
import '../utils/SharedPreferencesHelper.dart';

// class DeviceMonitoringService {
//   static final _plugin = FlutterLocalNotificationsPlugin();
//   static final _service = FlutterBackgroundService();
//   static int? _lastErrorCode;
//
//   static InverterViewModel? viewModel;
//
//   static Future<void> initialize() async {
//     // UI Isolate Init
//     await NotificationService.init();
//
//     await _service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: _backgroundEntryPoint,
//         isForegroundMode: true,
//         autoStart: true,
//         notificationChannelId: 'error_channel', // 🔥 Match existing channel
//         initialNotificationTitle: 'Voltis Inverter Status',
//         initialNotificationContent: 'Monitoring active...',
//         foregroundServiceNotificationId: 999,
//         // foregroundServiceType: AndroidForegroundServiceType.dataSync,
//       ),
//       iosConfiguration: IosConfiguration(
//         autoStart: true,
//         onForeground: _backgroundEntryPoint,
//         onBackground: (service) => true,
//       ),
//     );
//
//     await _service.startService();
//
//     // Sync initial MAC to background
//     await _syncConfigToBackground();
//     InverterViewModel.isBackgroundServiceActive = await _service.isRunning();
//   }
//
//   static Future<void> _syncConfigToBackground() async {
//     await SharedPreferencesHelper.init();
//     String? mac = await SharedPreferencesHelper.getMacData();
//     if (mac != null && mac.isNotEmpty) {
//       _service.invoke('updateConfig', {'mac': mac});
//     }
//   }
//
//   static String _getMessage(int code) {
//     switch (code) {
//       case 1:
//         return "Solar Over Voltage";
//       case 2:
//         return "Solar Under Voltage";
//       case 4:
//         return "Overload";
//       case 5:
//         return "Over Temperature";
//       case 6:
//         return "Short Circuit";
//       case 0:
//         return "Device Stable";
//       default:
//         return "Unknown Error";
//     }
//   }
//
//   @pragma('vm:entry-point')
//   static void _backgroundEntryPoint(ServiceInstance service) async {
//     WidgetsFlutterBinding.ensureInitialized();
//     InverterViewModel.isBackgroundServiceActive = true;
//     DartPluginRegistrant.ensureInitialized();
//
//     // Background Isolate Init
//     await NotificationService.init();
//
//     String? currentMac;
//
//     // Listen for configuration updates from the UI
//     service.on('updateConfig').listen((event) {
//       if (event != null && event['mac'] != null) {
//         currentMac = event['mac'] as String;
//       }
//     });
//
//     // Automatically reset the flag if service is stopped
//     service.on('stopService').listen((event) {
//       InverterViewModel.isBackgroundServiceActive = false;
//       service.stopSelf();
//     });
//
//     // Initialize Production UseCase
//     final dioClient = DioClient();
//     await dioClient.init();
//     final inverterRepository = InverterRepositoryImpl(dioClient);
//     final useCase = FetchInverterDataUseCase(inverterRepository);
//
//     String lastStatus = "Starting";
//     int? lastErrorCode;
//
//     Timer.periodic(const Duration(seconds: 15), (timer) async {
//       try {
//         // Fallback: Read MAC from Storage
//         if (currentMac == null) {
//           await SharedPreferencesHelper.init();
//           currentMac = await SharedPreferencesHelper.getMacData();
//         }
//
//         if (currentMac == null || currentMac!.isEmpty) return;
//
//         final data = await useCase.execute("daily", currentMac!);
//         if (data.isEmpty) return;
//
//         final inverter = data.last;
//         final errorCode = inverter.error;
//         final apiTime = inverter.createdAt;
//         final now = DateTime.now();
//
//         // Calc Offline status
//         final Duration timeDiff = now.difference(apiTime).abs();
//         final bool isOffline = timeDiff >= const Duration(seconds: 70);
//
//         String currentStatus =
//             isOffline ? "Offline" : (errorCode == 0 ? "Online" : "Error");
//
//         // --- Notification Transition Logic using Unified Service ---
//         if (errorCode != 0) {
//           if (errorCode != lastErrorCode) {
//             await NotificationService.showNotification(
//               "🔴 Device Error",
//               _getMessage(errorCode),
//             );
//             lastErrorCode = errorCode;
//             lastStatus = "Error";
//           }
//         } else if (isOffline) {
//           if (lastStatus != "Offline") {
//             await NotificationService.showNotification(
//               "⚠️ Device Offline",
//               "The inverter is not sending updated data.",
//             );
//             lastStatus = "Offline";
//             lastErrorCode = 0;
//           }
//         } else {
//           if (lastStatus == "Offline") {
//             await NotificationService.showNotification(
//               "🟢 Device Online",
//               "The inverter is now online.",
//             );
//           } else if (lastStatus == "Error" || lastStatus == "Starting") {
//             await NotificationService.showNotification(
//               "✅ Device Stable",
//               "System is working normally.",
//             );
//           }
//           lastStatus = "Online";
//           lastErrorCode = 0;
//         }
//
//         // Update persistent notification
//         if (service is AndroidServiceInstance) {
//           final timeStr =
//               "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
//           service.setForegroundNotificationInfo(
//             title: 'Voltis Inverter Status: $currentStatus',
//             content: "Last Update: $timeStr",
//           );
//         }
//       } catch (e) {
//         debugPrint("Background Loop Error: $e");
//       }
//     });
//   }
// }

class DeviceMonitoringService {
  static Timer? _backgroundTimer;
  static String _lastStatus = "Starting";
  static int? _lastErrorCode;

  static InverterViewModel? viewModel;

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Configure Android and iOS
    // await service.configure(
    //   androidConfiguration: AndroidConfiguration(
    //     onStart: _backgroundEntryPoint,
    //     autoStart: true,
    //     isForegroundMode: true,
    //     notificationChannelId: 'foreground_service',
    //     initialNotificationTitle: 'Voltis Inverter',
    //     initialNotificationContent: 'Device Monitoring Service',
    //     foregroundServiceNotificationId: 999,
    //   ),
    //   iosConfiguration: IosConfiguration(
    //     autoStart: true,
    //     onForeground: _backgroundEntryPoint,
    //   ),
    // );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'foreground_service',
      'Voltis Inverter Service',
      description: 'Monitoring inverter status',
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _backgroundEntryPoint,
        isForegroundMode: true,
        autoStart: true,
        notificationChannelId: 'foreground_service',
        initialNotificationTitle: 'Voltis Inverter',
        initialNotificationContent: 'Device Monitoring Service',
        foregroundServiceNotificationId: 999,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _backgroundEntryPoint,
      ),
    );

    // Initial check - Always try to start or sync
    await _syncConfigToBackground(service);

    // 🔥 ALWAYS ensure service is running to fulfill "don't stop service if no mac"
    if (!(await service.isRunning())) {
      await service.startService();
    }
  }

  static Future<void> _syncConfigToBackground(
      FlutterBackgroundService service) async {
    await SharedPreferencesHelper.init();
    String? mac = await SharedPreferencesHelper.getMacData();
    if (mac != null && mac.isNotEmpty) {
      service.invoke('updateConfig', {'mac': mac});
    }

    // Always start service if it's not already running
    if (!(await service.isRunning())) {
      await service.startService();
    }
  }

  static Future<void> startMonitoring() async {
    final service = FlutterBackgroundService();
    await _syncConfigToBackground(service);
  }

  @pragma('vm:entry-point')
  static void _backgroundEntryPoint(ServiceInstance service) async {
    // 🔥 MANDATORY: Wait for system bindings
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    try {
      // 1. Initial UI Feedback
      if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
        service.setForegroundNotificationInfo(
          title: 'Voltis Inverter',
          content: 'Monitoring Booting... (Please wait)',
        );
      }

      // 2. Allow plugins to warm up (Crucial for Release APKs)
      await Future.delayed(const Duration(seconds: 3));

      // 3. Init Services
      await NotificationService.init();

      // Notify health
      await NotificationService.showNotification(
          "Service Booted", "Voltis Background monitoring is now active.");

      if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
        service.setForegroundNotificationInfo(
          title: 'Voltis Monitoring Active',
          content: 'Isolate initialized. Syncing data...',
        );

        service
            .on('setAsForeground')
            .listen((event) => service.setAsForegroundService());
        service
            .on('setAsBackground')
            .listen((event) => service.setAsBackgroundService());
      }

      service.on('stopService').listen((event) => service.stopSelf());

      // Track configuration in background isolate memory
      String? currentMac;

      // Listen for configuration updates from the UI
      service.on('updateConfig').listen((event) {
        try {
          if (event != null && event['mac'] != null) {
            final newMac = event['mac'] as String;
            if (newMac != currentMac) {
              currentMac = newMac;
              _startMonitoringLoop(service, currentMac!);
            }
          }
        } catch (e) {
          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: 'Config Update Error',
              content: e.toString(),
            );
          }
        }
      });

      // Also try to read from SharedPreferences as fallback
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        try {
          if (currentMac == null) {
            await SharedPreferencesHelper.init();
            final mac = await SharedPreferencesHelper.getMacData();
            if (mac != null && mac.isNotEmpty) {
              currentMac = mac;
              _startMonitoringLoop(service, currentMac!);
            }
          }
        } catch (e) {
          if (service is AndroidServiceInstance) {
            service.setAsForegroundService();
            service.setForegroundNotificationInfo(
              title: 'Fallback Sync Error',
              content: e.toString(),
            );
          }
        }
      });
    } catch (e) {
      if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
        service.setForegroundNotificationInfo(
          title: 'Background Engine Fatal Error',
          content: e.toString(),
        );
      }
    }
  }

  static void _startMonitoringLoop(ServiceInstance service, String mac) async {
    // Prevent multiple loops
    _backgroundTimer?.cancel();

    // final inverterViewModel =
    // Provider.of<InverterViewModel>(context,
    //     listen: false);
    // inverterViewModel.fetchInverterData();
    // Fluttertoast.showToast(msg: "inverter viewmodel: $errorCode");

    final dioClient = DioClient();
    try {
      // Use a simpler init if possible, or ensure it's isolate-safe
      await dioClient.init();
      final inverterRepository = InverterRepositoryImpl(dioClient);
      final useCase = FetchInverterDataUseCase(inverterRepository);
      int? lastErrorCode;

      _backgroundTimer =
          Timer.periodic(const Duration(seconds: 10), (timer) async {
        try {
          debugPrint("Background Loop: Fetching data for $mac");
          final data = await useCase.execute("daily", mac);

          if (data.isNotEmpty) {
            final inverter = data.last;
            // `error` is absent (null) on newer-firmware payloads - treat
            // that as "no known error" (same as an explicit 0) rather than
            // fabricating an error state the device never reported.
            final errorCode = inverter.error ?? 0;
            final apiTime = inverter.createdAt;
            final now = DateTime.now();

            // Fluttertoast.showToast(msg: "service foreground: $errorCode");

            // Calc Offline status (mirroring ViewModel logic)
            final Duration timeDiff = now.difference(apiTime).abs();
            final bool isOffline = timeDiff >= const Duration(seconds: 62);

            String currentStatus =
                isOffline ? "Offline" : (errorCode == 0 ? "Online" : "Error");

            // Update Foreground Service Info with status and LIVE CLOCK
            if (service is AndroidServiceInstance) {
              final timeStr =
                  "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
              String statusText = (errorCode != 0)
                  ? "Error: ${_getErrorMessage(errorCode)}"
                  : (isOffline ? "Offline (Old data)" : "System Normal (Live)");

              // service.setForegroundNotificationInfo(
              //   title: 'Voltis Monitoring Active',
              //   content: "$statusText | Updated: $timeStr",
              // );
            }

            // --- Notification Logic ---
            if (errorCode != 0) {
              if (errorCode != lastErrorCode) {
                await NotificationService.showNotification(
                    "🔴 Device Error", _getErrorMessage(errorCode));
                lastErrorCode = errorCode;
                _lastStatus = "Error";
              }
            } else if (isOffline) {
              if (_lastStatus != "Offline") {
                await NotificationService.showNotification("⚠️ Device Offline",
                    "The inverter is not sending updated data.");
                _lastStatus = "Offline";
                lastErrorCode = 0;
              }
            } else {
              if (_lastStatus == "Offline") {
                await NotificationService.showNotification(
                    "🟢 Device Online", "The inverter is now online.");
              } else if (_lastStatus == "Error" || _lastStatus == "Starting") {
                await NotificationService.showNotification(
                    "✅ Device Stable", "System is working normally.");
              }
              _lastStatus = "Online";
              lastErrorCode = 0;
            }
          } else {
            if (service is AndroidServiceInstance) {
              service.setForegroundNotificationInfo(
                title: 'Voltis Inverter Monitoring',
                content: "No data records found on server.",
              );
            }
          }
        } catch (e) {
          debugPrint("Background Loop Error: $e");
          if (service is AndroidServiceInstance) {
            // service.setForegroundNotificationInfo(
            //   title: 'Voltis Loop Error',
            //   content: "Fail: ${e.toString().split('\n')[0]}",
            // );
          }
        }
      });
    } catch (e) {
      debugPrint("Init Monitoring Loop Failed: $e");
      if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
        service.setForegroundNotificationInfo(
          title: 'Voltis Init Error',
          content: e.toString(),
        );
      }
    }
  }

  static String _getErrorMessage(int code) {
    switch (code) {
      case 1:
        return "Solar Over Voltage";
      case 2:
        return "Solar Under Voltage";
      case 4:
        return "Overload";
      case 5:
        return "Over Temperature";
      case 6:
        return "Short Circuit";
      default:
        return "Unknown Device Error";
    }
  }
}
