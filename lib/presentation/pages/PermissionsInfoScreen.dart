import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/App_Colors.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/WelcomeWidget.dart';

class PermissionsInfoScreen extends StatefulWidget {
  const PermissionsInfoScreen({super.key});

  @override
  State<PermissionsInfoScreen> createState() => _PermissionsInfoScreenState();
}

class _PermissionsInfoScreenState extends State<PermissionsInfoScreen> {
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    _checkPermissions();
    super.initState();
  }

  final List<Permission> _permissions = [
    Permission.location,
    Permission.camera,
  ];

  Future<void> _checkPermissions() async {
    final statuses = await _permissions.request();
    setState(() {
      _permissionStatuses = statuses;
    });
  }

  Widget _buildPermissionTile(
      Permission permission, String title, String description) {
    final status = _permissionStatuses[permission];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          status?.isGranted == true ? Icons.check_circle : Icons.cancel,
          color: status?.isGranted == true ? const Color(0xFFFF6B00) : Colors.red,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: status?.isGranted == true
            ? null // No button if granted
            : ElevatedButton(
                onPressed: () async {
                  await permission.request();
                  _checkPermissions();
                },
                child: const Text("Allow"),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/backclick.png",
                    width: 20,
                    height: 20,
                    color: AppColors.black,
                  ),
                ),
                const Text(
                  "Permissions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Opacity(
                  opacity: 0.0, // Set to true to show it again
                  child: Image.asset("assets/backclick.png",
                      width: 20, height: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "To continue, please grant the following permissions:",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // _buildPermissionTile(
                  //   Permission.location,
                  //   "Location",
                  //   "Used to access your GPS location.",
                  // ),
                  // _buildPermissionTile(
                  //   Permission.camera,
                  //   "Camera",
                  //   "Used to take or scan QR codes/Bar codes.",
                  // ),
                  // _buildPermissionTile(
                  //   Permission.storage,
                  //   "Storage",
                  //   "Needed to read and save media files.",
                  // ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
