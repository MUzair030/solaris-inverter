import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/App_Colors.dart';
import '../widgets/CustomInkWellItem2.dart';

class QrScannerForManualyScreen extends StatefulWidget {
  const QrScannerForManualyScreen({super.key});

  @override
  State<QrScannerForManualyScreen> createState() =>
      _QrScannerForManualyScreenState();
}

class _QrScannerForManualyScreenState extends State<QrScannerForManualyScreen> {
  // bool isDialogShowing = false; // Removed unused variable
  bool _isDialogOpen = false;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed
        .normal, // Changed from noDuplicates for better reliability
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
  );
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // White icons
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // Use the correct controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: (capture) async {
              if (_isDialogOpen) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final rawValue = barcodes.first.rawValue;
              if (rawValue != null) {
                final wifi = parseWifiQRCode(rawValue);
                if (wifi != null) {
                  final ssid = wifi.ssid;
                  final password = wifi.password ?? '';

                  setState(() {
                    _isDialogOpen = true;
                  });

                  // Stop scanning while dialog is open to prevent multiple detections
                  await _controller.stop();

                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Wi-Fi QR Detected'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text('SSID: $ssid'),
                            Text(
                                'Password: ${password.isNotEmpty ? password : "(none)"}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              setState(() {
                                _isDialogOpen = false;
                              });
                              // Resume scanning when dialog is closed
                              await _controller.start();
                            },
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context, {
                                'ssid': ssid,
                                'password': password,
                              }); // send back to bottom sheet
                            },
                            child: const Text('Use'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.red, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // dark background mask outside scanning area
          IgnorePointer(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Waiting for pairing devices...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomInkWellItem2(
                  imagePath: "assets/backclick.png",
                  color: AppColors.white,
                  onTap: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                Text(
                  "QR Scanner",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.flash_on,
                        color: AppColors.white,
                        size: 22,
                      ),
                      onPressed: () => _controller.toggleTorch(),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.cameraswitch,
                        color: AppColors.white,
                        size: 22,
                      ),
                      onPressed: () => _controller.switchCamera(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dummy parser for Wi-Fi QR
class WifiData {
  final String ssid;
  final String? password;
  final String? authType;
  final bool hidden;
  WifiData(this.ssid, this.password, this.authType, this.hidden);
}

WifiData? parseWifiQRCode(String raw) {
  if (!raw.startsWith('WIFI:')) return null;

  try {
    String ssid = '';
    String? password;
    String? authType;
    bool hidden = false;

    // Remove 'WIFI:' prefix
    String content = raw.substring(5);
    // Split by semicolon, but be careful with escaped characters if any (usually not in simple WiFi QRs)
    List<String> parts = content.split(';');

    for (var part in parts) {
      if (part.startsWith('S:')) {
        ssid = part.substring(2);
      } else if (part.startsWith('P:')) {
        password = part.substring(2);
      } else if (part.startsWith('T:')) {
        authType = part.substring(2);
      } else if (part.startsWith('H:')) {
        hidden = part.substring(2).toLowerCase() == 'true';
      }
    }

    if (ssid.isNotEmpty) {
      return WifiData(ssid, password, authType, hidden);
    }
  } catch (_) {}
  return null;
}
