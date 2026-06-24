import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../app/App_Colors.dart';

class UpdateChecker {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String packageName = packageInfo.packageName;

      print("Current app version: $currentVersion");
      print("Package name: $packageName");

      String? playStoreVersion = await _getPlayStoreVersion(packageName);

      print("Play Store version: $playStoreVersion");

      if (playStoreVersion != null &&
          _isNewVersionAvailable(currentVersion, playStoreVersion)) {
        print("New version available! Showing update dialog...");
        _showUpdateDialog(context, playStoreVersion, packageName);
      } else {
        print("No new version available.");
      }
    } catch (e) {
      print("Update check failed: $e");
    }
  }

  static Future<String?> _getPlayStoreVersion(String packageName) async {
    final url = Uri.parse(
        "https://play.google.com/store/apps/details?id=$packageName&hl=en");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("Play Store HTML fetched successfully.");
      // Optional: Print some HTML for debugging
      // print(response.body.substring(0, 1000));

      final regex = RegExp(r'\[\[\["([0-9]+(?:\.[0-9]+)+)"\]\]');
      final match = regex.firstMatch(response.body);
      if (match != null) {
        print("Regex matched version: ${match.group(1)}");
        return match.group(1);
      } else {
        print("Play Store version regex did not match.");
      }
    } else {
      print(
          "Failed to fetch Play Store page. Status code: ${response.statusCode}");
    }
    return null;
    // return "1.0.9";
  }

  static bool _isNewVersionAvailable(String current, String store) {
    List<String> currentParts = current.split('.');
    List<String> storeParts = store.split('.');
    for (int i = 0; i < currentParts.length; i++) {
      int currentNum = int.parse(currentParts[i]);
      int storeNum = int.parse(storeParts[i]);
      if (storeNum > currentNum) return true;
      if (storeNum < currentNum) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
      BuildContext context, String newVersion, String packageName) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.system_update, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                "Update Available",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const Text(
                "A new version is available. Please update the app from Play Store.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final url =
                            "https://play.google.com/store/apps/details?id=$packageName";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // dismiss bottom sheet
                      },
                      child: const Text("Ignore"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
