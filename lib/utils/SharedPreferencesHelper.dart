import 'dart:convert';
import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/NotificationItem.dart';

class SharedPreferencesHelper {
  static const String keyUserid = "userid";
  static const String keyUserpass = "userpass";
  static const String keyUsername = "username";
  static const String keyUseremail = "useremail";
  static const String keyToken = "auth_token";
  static const String keyVersion = "inverter_version";
  static const String keyMAC = "mac_data";
  static const String keyName = "inv_name";
  static const String keypower = "inv_power";
  static const String keyIsLoggedIn = "is_logged_in";
  static const String _notificationKey = 'notifications_list';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save new user login data (automatically clears previous user data)
  static Future<void> saveLoginData(int userid, String username,
      String useremail, String userpass, String token) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear ALL previous user data to ensure fresh state
    await clearAllUserData();

    await prefs.setInt(keyUserid, userid);
    await prefs.setString(keyUsername, username);
    await prefs.setString(keyUseremail, useremail);
    await prefs.setString(keyUserpass, userpass);
    await prefs.setString(keyToken, token);
    await prefs.setBool(keyIsLoggedIn, true);
  }

  // COMPLETE LOGOUT - Removes ALL user-specific data
  static Future<void> logout() async {
    await clearAllUserData();
  }

  // Clear ALL user-specific data from SharedPreferences
  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear user authentication data
    await prefs.remove(keyUserid);
    await prefs.remove(keyUsername);
    await prefs.remove(keyUseremail);
    await prefs.remove(keyUserpass);
    await prefs.remove(keyToken);
    await prefs.remove(keyIsLoggedIn);

    // Clear device/inverter data (if user-specific)
    await prefs.remove(keyMAC);
    await prefs.remove(keyName);
    await prefs.remove(keypower);

    // Clear notifications (if user-specific)
    await prefs.remove(_notificationKey);

    // You can also clear version data if it's user-specific
    await prefs.remove(keyVersion);
  }

  // Alternative: Selective logout (only authentication data)
  static Future<void> logoutAuthOnly() async {
    final prefs = await SharedPreferences.getInstance();

    // Only clear authentication-related data
    await prefs.remove(keyUserid);
    await prefs.remove(keyUsername);
    await prefs.remove(keyUseremail);
    await prefs.remove(keyUserpass);
    await prefs.remove(keyToken);
    await prefs.remove(keyIsLoggedIn);
  }

  // Save version data
  static Future<void> saveVersionData(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyVersion, version);
  }

  static Future<String?> getVersionData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyVersion);
  }

  // Save mac data
  static Future<void> saveMacData(
      String macaddress, String invname, int invpower) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyMAC, macaddress);
    await prefs.setString(keyName, invname);
    await prefs.setInt(keypower, invpower);
  }

  static Future<void> clearMacData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyMAC);
    await prefs.remove(keyName);
    await prefs.remove(keypower);
  }

  static Future<String?> getMacData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyMAC);
  }

  static Future<String?> getnameData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyName);
  }

  static Future<int?> getpowerData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keypower);
  }

  static Future<int?> getUserid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyUserid);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUsername);
  }

  static Future<String?> getUseremail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUseremail);
  }

  static Future<String?> getUserpass() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserpass);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(keyToken);
    print("Retrieved Token from SharedPreferences: $token");
    return token;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  // Notification methods
  static Future<void> addNotification(NotificationItem item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existing = prefs.getStringList(_notificationKey) ?? [];

    final now = DateTime.now();
    final existingItems = existing
        .map((jsonString) => NotificationItem.fromJson(jsonDecode(jsonString)))
        .toList();

    final recentSame = existingItems.firstWhere(
      (n) => n.title == item.title,
      orElse: () => NotificationItem(
          title: '',
          message: '',
          timestamp: DateTime.fromMillisecondsSinceEpoch(0)),
    );

    final timeDiff = now.difference(recentSame.timestamp).inSeconds;
    if (recentSame.title == item.title && timeDiff < 10) return;

    existing.insert(0, jsonEncode(item.toJson()));
    await prefs.setStringList(_notificationKey, existing);
  }

  static Future<List<NotificationItem>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList(_notificationKey) ?? [];

    final seen = <String, DateTime>{};
    final result = <NotificationItem>[];

    for (final jsonString in data) {
      final item = NotificationItem.fromJson(jsonDecode(jsonString));
      final title = item.title;
      final timestamp = item.timestamp;

      if (seen.containsKey(title)) {
        final timeDiff = seen[title]!.difference(timestamp).inSeconds;
        if (timeDiff < 10) continue;
      }

      seen[title] = timestamp;
      result.add(item);
    }

    return result;
  }

  static Future<NotificationItem?> getLastNotification() async {
    final notifications = await getNotifications();
    if (notifications.isNotEmpty) {
      return notifications.last;
    }
    return null;
  }

  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationKey);
  }

  static Future<void> deleteNotificationAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_notificationKey) ?? [];

    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList(_notificationKey, list);
    }
  }
}

// class SharedPreferencesHelper {
//   static const String keyUserid = "userid";
//   static const String keyUserpass = "userpass";
//   static const String keyUsername = "username";
//   static const String keyUseremail = "useremail";
//   static const String keyToken = "auth_token";
//   static const String keyVersion = "inverter_version";
//   static const String keyMAC = "mac_data";
//   static const String keyName = "inv_name";
//   static const String keypower = "inv_power";
//   static const String keyIsLoggedIn = "is_logged_in";
//   static late SharedPreferences _prefs;
//
//   static Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//   }
//
//   static Future<void> saveLoginData(int userid, String username,
//       String useremail, String userpass, String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(keyUserid, userid);
//     await prefs.setString(keyUsername, username);
//     await prefs.setString(keyUseremail, useremail);
//     await prefs.setString(keyUserpass, userpass);
//     await prefs.setString(keyToken, token);
//     await prefs.setBool(keyIsLoggedIn, true);
//   }
//
//   // Save version data
//   static Future<void> saveVersionData(String version) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(keyVersion, version);
//   }
//
//   static Future<String?> getVersionData() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? version = prefs.getString(keyVersion);
//     return version;
//   }
//
//   // Save mac data
//   static Future<void> saveMacData(
//       String macaddress, String invname, int invpower) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(keyMAC, macaddress);
//     await prefs.setString(keyName, invname);
//     await prefs.setInt(keypower, invpower);
//   }
//
//   static Future<void> clearMacData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(keyMAC);
//     await prefs.remove(keyName);
//     await prefs.remove(keypower);
//   }
//
//   static Future<String?> getMacData() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? mac = prefs.getString(keyMAC);
//     return mac;
//   }
//
//   static Future<String?> getnameData() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? name = prefs.getString(keyName);
//     return name;
//   }
//
//   static Future<int?> getpowerData() async {
//     final prefs = await SharedPreferences.getInstance();
//     int? power = prefs.getInt(keypower);
//     return power;
//   }
//   // static Future<Map<String, dynamic>> getMacData() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final macAddress = prefs.getString(keyMAC) ?? '';
//   //   final invName = prefs.getString(keyName) ?? '';
//   //   final invPower = prefs.getInt(keypower) ?? 0;
//   //
//   //   return {
//   //     'macAddress': macAddress,
//   //     'invName': invName,
//   //     'invPower': invPower,
//   //   };
//   // }
//
//   // Retrieve userid as int
//   static Future<int?> getUserid() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt(keyUserid);
//   }
//
//   // Retrieve username
//   static Future<String?> getUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(keyUsername);
//   }
//
//   // Retrieve useremail
//   static Future<String?> getUseremail() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(keyUseremail);
//   }
//
//   // Retrieve useremail
//   static Future<String?> getUserpass() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(keyUserpass);
//   }
//
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString(keyToken);
//     print("Retrieved Token from SharedPreferences: $token");
//     return token;
//   }
//
//   // Check if user is logged in
//   static Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(keyIsLoggedIn) ?? false;
//   }
//
//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     // await prefs.remove(keyIsLoggedIn);
//     // await prefs.setBool(keyIsLoggedIn, false);
//     // await prefs.clear();
//     await prefs.remove(keyIsLoggedIn); // or setBool(keyIsLoggedIn, false);
//     await prefs.remove(keyToken); // if you store a token
//   }
//
//   // Logout user
//   // static Future<void> logout() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   await prefs.remove(keyUsername);
//   //   await prefs.remove(keyToken);
//   //   await prefs.setBool(keyIsLoggedIn, false);
//   // }
//   static Future<void> setBool(String key, bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(key, value);
//   }
//
//   // Retrieve a boolean value
//   static Future<bool?> getBool(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(key);
//   }
//
//   static const String _notificationKey = 'notifications_list';
//
//   static Future<void> addNotification(NotificationItem item) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> existing = prefs.getStringList(_notificationKey) ?? [];
//
//     final now = DateTime.now();
//
//     final existingItems = existing
//         .map((jsonString) => NotificationItem.fromJson(jsonDecode(jsonString)))
//         .toList();
//
//     // Find the most recent notification with the same title
//     final recentSame = existingItems.firstWhere(
//       (n) => n.title == item.title,
//       orElse: () => NotificationItem(
//           title: '',
//           message: '',
//           timestamp: DateTime.fromMillisecondsSinceEpoch(0)),
//     );
//
//     final timeDiff = now.difference(recentSame.timestamp).inSeconds;
//
//     // If same title and within 10 seconds, skip storing
//     if (recentSame.title == item.title && timeDiff < 10) return;
//
//     // Insert new notification at the top
//     existing.insert(0, jsonEncode(item.toJson()));
//     await prefs.setStringList(_notificationKey, existing);
//   }
//
//   static Future<List<NotificationItem>> getNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> data = prefs.getStringList(_notificationKey) ?? [];
//
//     final seen = <String, DateTime>{};
//     final result = <NotificationItem>[];
//
//     for (final jsonString in data) {
//       final item = NotificationItem.fromJson(jsonDecode(jsonString));
//       final title = item.title;
//       final timestamp = item.timestamp;
//
//       if (seen.containsKey(title)) {
//         final timeDiff = seen[title]!.difference(timestamp).inSeconds;
//         if (timeDiff < 10) continue; // Skip too-close duplicates
//       }
//
//       seen[title] = timestamp;
//       result.add(item);
//     }
//
//     return result;
//   }
//
//   static Future<NotificationItem?> getLastNotification() async {
//     final notifications = await getNotifications();
//     if (notifications.isNotEmpty) {
//       return notifications.last;
//     }
//     return null;
//   }
//
//   // Clear all notifications (optional utility)
//   static Future<void> clearNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_notificationKey);
//   }
//
//   static Future<void> deleteNotificationAt(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> list = prefs.getStringList(_notificationKey) ?? [];
//
//     if (index >= 0 && index < list.length) {
//       list.removeAt(index);
//       await prefs.setStringList(_notificationKey, list);
//     }
//   }
//
// }
