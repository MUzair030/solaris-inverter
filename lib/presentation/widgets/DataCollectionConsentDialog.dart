import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> showDataCollectionConsentDialog(
  BuildContext context,
  List<Permission> permissions,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Data Collection Consent",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Before proceeding, please review how Voltis Inverter uses your data:",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            if (permissions.contains(Permission.camera))
              _buildDataItem(
                Icons.camera_alt,
                "Camera",
                "Used to scan QR codes on your inverter device for quick WiFi setup.",
              ),
            if (permissions.contains(Permission.location))
              _buildDataItem(
                Icons.location_on,
                "Location",
                "Required to scan for nearby WiFi networks so the app can discover and connect your inverter to your home WiFi. Location data is only used for WiFi scanning and is not stored or shared.",
              ),
            if (permissions.contains(Permission.notification))
              _buildDataItem(
                Icons.notifications,
                "Notifications",
                "Used to send alerts about inverter status, power updates, and important service messages.",
              ),
            const SizedBox(height: 20),
            const Text(
              "Your data will not be sold. You can revoke permissions anytime in device settings. See Privacy Policy for full details.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Deny"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      "I Consent",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

Widget _buildDataItem(IconData icon, String title, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: const Color(0xFFFF6B00)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
