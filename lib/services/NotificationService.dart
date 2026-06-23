import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../data/models/NotificationItem.dart';
import '../presentation/viewmodels/NotificationProvider.dart';
import '../utils/SharedPreferencesHelper.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      debugPrint("NotificationService: Initializing...");
      // Use proper icon in res/drawable/ic_notification.png
      const androidSettings = AndroidInitializationSettings('ic_notification');
      // Use consistent working icon
      await _plugin
          .initialize(const InitializationSettings(android: androidSettings));

      const channel = AndroidNotificationChannel(
        'error_channel',
        'Device Errors',
        importance: Importance.max,
        playSound: false,
        enableVibration: false,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      _initialized = true;
      debugPrint("NotificationService: Channel created.");
    } catch (e) {
      debugPrint("NotificationService: Failed to init: $e");
    }
  }

  static Future<void> showNotification(String title, String body,
      {BuildContext? context}) async {
    debugPrint("NotificationService: Showing notification: $title - $body");
    const androidDetails = AndroidNotificationDetails(
      'error_channel',
      'Device Errors',
      importance: Importance.max, // 🔥 Force pop-up
      priority: Priority.high,
      showWhen: true,
      playSound: false,
      enableVibration: false,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
    debugPrint("NotificationService: show() called.");

    // ✅ Update Provider ONLY when context exists (UI)
    if (context != null) {
      try {
        Provider.of<NotificationProvider>(context, listen: false)
            .addNotification(
          NotificationItem(
            title: title,
            message: body,
            timestamp: DateTime.now(),
          ),
        );
      } catch (_) {
        // ignore (context may be disposed)
      }
    }
  }

  static Future<void> showTestNotification() async {
    await showNotification("Monitoring Test", "Background isolate is active!");
  }
}
