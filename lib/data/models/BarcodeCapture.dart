import 'dart:core';

class WifiInfo {
  final String ssid;
  final String? password;
  final String? authType;
  final bool hidden;

  WifiInfo({
    required this.ssid,
    this.password,
    this.authType,
    this.hidden = false,
  });

  @override
  String toString() =>
      'WifiInfo(ssid: $ssid, password: $password, auth: $authType, hidden: $hidden)';
}

WifiInfo? parseWifiQRCode(String raw) {
  if (raw.trim().isEmpty) return null;
  final data = raw.trim();

  // Only handle the standard WIFI: format here
  if (!data.toUpperCase().startsWith('WIFI:')) return null;

  // Remove the leading "WIFI:"
  String body = data.substring(5);

  // Trim trailing semicolons that many generators append (e.g. ";;")
  body = body.replaceAll(RegExp(r';+$'), '');

  // Split on semicolons into tokens like "S:Rapidev_Guest", "P:pass"
  final tokens = body.split(';');

  String? ssid;
  String? password;
  String? authType;
  bool hidden = false;

  for (final t in tokens) {
    if (t.isEmpty) continue;
    final idx = t.indexOf(':');
    if (idx == -1) continue;
    final key = t.substring(0, idx).trim().toUpperCase();
    var value = t.substring(idx + 1);

    // Some generators percent-encode values — attempt decode safely
    try {
      value = Uri.decodeComponent(value);
    } catch (_) {}

    if (key == 'S') {
      ssid = value;
    } else if (key == 'P') {
      password = value;
    } else if (key == 'T') {
      authType = value;
    } else if (key == 'H') {
      hidden = value.toLowerCase() == 'true' || value == '1';
    }
  }

  if (ssid != null && ssid.isNotEmpty) {
    return WifiInfo(
        ssid: ssid, password: password, authType: authType, hidden: hidden);
  }

  return null;
}
