import 'package:flutter/cupertino.dart';

import '../../data/models/NotificationItem.dart';
import '../../utils/SharedPreferencesHelper.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  Future<void> loadNotifications() async {
    _notifications = await SharedPreferencesHelper.getNotifications();
    notifyListeners();
  }

  Future<void> addNotification(NotificationItem item) async {
    await SharedPreferencesHelper.addNotification(item);
    await loadNotifications(); // Refresh the list and notify UI
  }

  Future<void> deleteNotification(int index) async {
    await SharedPreferencesHelper.deleteNotificationAt(index);
    await loadNotifications();
  }

  Future<void> clearAll() async {
    await SharedPreferencesHelper.clearNotifications();
    await loadNotifications();
  }
}
