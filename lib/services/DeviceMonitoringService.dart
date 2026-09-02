import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../core/network/dio_client.dart';
import '../data/repositories_impl/inverter_repository_impl.dart';
import '../domain/usecases/get_inverter_data_usecase.dart';
import 'NotificationService.dart';
import '../utils/SharedPreferencesHelper.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(DeviceMonitoringTaskHandler());
}

class DeviceMonitoringTaskHandler extends TaskHandler {
  String? _currentMac;
  String _lastStatus = "Starting";
  int? _lastErrorCode;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint("DeviceMonitoringTaskHandler onStart");
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    try {
      if (_currentMac == null) {
        await SharedPreferencesHelper.init();
        _currentMac = await SharedPreferencesHelper.getMacData();
      }

      if (_currentMac == null || _currentMac!.isEmpty) return;

      final dioClient = DioClient();
      await dioClient.init();
      final inverterRepository = InverterRepositoryImpl(dioClient);
      final useCase = FetchInverterDataUseCase(inverterRepository);

      final data = await useCase.execute("daily", _currentMac!);
      if (data.isEmpty) return;

      final inverter = data.last;
      final errorCode = inverter.error ?? 0;
      final apiTime = inverter.createdAt;
      final now = DateTime.now();

      final Duration timeDiff = now.difference(apiTime).abs();
      final bool isOffline = timeDiff >= const Duration(seconds: 62);

      String currentStatus =
          isOffline ? "Offline" : (errorCode == 0 ? "Online" : "Error");

      // Update foreground notification
      final timeStr =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      FlutterForegroundTask.updateService(
        notificationTitle: 'Voltis Monitoring Active',
        notificationText: '$currentStatus | Updated: $timeStr',
      );

      // Notification transition logic
      if (errorCode != 0) {
        if (errorCode != _lastErrorCode) {
          await NotificationService.showNotification(
              "Device Error", _getErrorMessage(errorCode));
          _lastErrorCode = errorCode;
          _lastStatus = "Error";
        }
      } else if (isOffline) {
        if (_lastStatus != "Offline") {
          await NotificationService.showNotification("Device Offline",
              "The inverter is not sending updated data.");
          _lastStatus = "Offline";
          _lastErrorCode = 0;
        }
      } else {
        if (_lastStatus == "Offline") {
          await NotificationService.showNotification(
              "Device Online", "The inverter is now online.");
        } else if (_lastStatus == "Error" || _lastStatus == "Starting") {
          await NotificationService.showNotification(
              "Device Stable", "System is working normally.");
        }
        _lastStatus = "Online";
        _lastErrorCode = 0;
      }
    } catch (e) {
      debugPrint("Background Loop Error: $e");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint("DeviceMonitoringTaskHandler onDestroy");
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map && data['mac'] != null) {
      _currentMac = data['mac'] as String;
      debugPrint("Received MAC update: $_currentMac");
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

class DeviceMonitoringService {
  static Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Voltis Inverter Service',
        channelDescription: 'Monitoring inverter status',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(15000),
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );

    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static Future<void> startMonitoring() async {
    await SharedPreferencesHelper.init();
    String? mac = await SharedPreferencesHelper.getMacData();

    final result = await FlutterForegroundTask.startService(
      serviceId: 25000,
      notificationTitle: 'Voltis Inverter',
      notificationText: 'Device Monitoring Service',
      serviceTypes: [ForegroundServiceTypes.specialUse],
      callback: startCallback,
    );

    if (result is ServiceRequestSuccess) {
      // Send MAC to the task handler
      if (mac != null && mac.isNotEmpty) {
        FlutterForegroundTask.sendDataToTask({'mac': mac});
      }
    } else if (result is ServiceRequestFailure) {
      debugPrint("Failed to start foreground service: ${result.error}");
    }
  }

  static Future<void> stopMonitoring() async {
    await FlutterForegroundTask.stopService();
  }

  static Future<bool> isRunning() async {
    return FlutterForegroundTask.isRunningService;
  }
}
