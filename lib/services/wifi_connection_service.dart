import 'dart:io';
import 'package:flutter/services.dart';

class WifiConnectionService {
  static const platform = MethodChannel('com.threepol.inverter/wifi');

  /// Connects to a WiFi network using native Android 10+ API
  /// Returns true if connection successful, false otherwise
  static Future<bool> connectToWifi(String ssid, String password) async {
    try {
      if (!Platform.isAndroid) {
        print('⚠️ [WifiService] Not on Android platform');
        return false;
      }

      print('🔗 [WifiService] Connecting to: $ssid');

      final String result = await platform.invokeMethod('connectToWifi', {
        'ssid': ssid,
        'password': password,
      });

      print('✅ [WifiService] Connection successful: $result');
      return true;
    } on PlatformException catch (e) {
      print('❌ [WifiService] Connection failed: ${e.message}');
      return false;
    } catch (e) {
      print('❌ [WifiService] Unexpected error: $e');
      return false;
    }
  }

  static Future<String?> getSSID() async {
    return await platform.invokeMethod('getCurrentSSID');
  }

  /// Disconnects from the current WiFi network
  static Future<void> disconnectWifi() async {
    try {
      if (!Platform.isAndroid) return;

      await platform.invokeMethod('disconnectWifi');
      print('🔌 [WifiService] Disconnected from WiFi');
    } catch (e) {
      print('❌ [WifiService] Disconnect error: $e');
    }
  }

  /// Gets the current connected SSID
  static Future<String?> getCurrentSSID() async {
    try {
      if (!Platform.isAndroid) return null;

      final String? ssid = await platform.invokeMethod('getCurrentSSID');
      return ssid;
    } catch (e) {
      print('❌ [WifiService] Get SSID error: $e');
      return null;
    }
  }

  /// Checks if WiFi is currently connected
  static Future<bool> isConnected() async {
    try {
      if (!Platform.isAndroid) return false;

      final bool connected = await platform.invokeMethod('isConnected');
      return connected;
    } catch (e) {
      print('❌ [WifiService] Check connection error: $e');
      return false;
    }
  }
}
