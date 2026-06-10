import 'package:flutter/services.dart';

class WifiConnector {
  static const MethodChannel _channel =
      MethodChannel('com.threepol.inverter/wifi');

  // Connect to open WiFi network
  static Future<bool> connectToWifi(String ssid) async {
    try {
      final bool result = await _channel.invokeMethod(
        'connectToWifi',
        {'ssid': ssid},
      );
      return result;
    } on PlatformException catch (e) {
      print('Failed to connect: ${e.message}');
      return false;
    }
  }

  // Scan for available WiFi networks
  static Future<List<Map<String, dynamic>>> scanWifiNetworks() async {
    try {
      final List<dynamic> networks =
          await _channel.invokeMethod('scanWifiNetworks');
      return networks.cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      print('Failed to scan: ${e.message}');
      return [];
    }
  }

  // Check if WiFi is enabled
  static Future<bool> isWifiEnabled() async {
    try {
      return await _channel.invokeMethod('isWifiEnabled');
    } on PlatformException catch (e) {
      print('Failed to check WiFi status: ${e.message}');
      return false;
    }
  }

  // Enable WiFi
  static Future<bool> enableWifi() async {
    try {
      return await _channel.invokeMethod('enableWifi');
    } on PlatformException catch (e) {
      print('Failed to enable WiFi: ${e.message}');
      return false;
    }
  }
}
