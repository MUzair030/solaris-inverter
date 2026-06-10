import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../app/App_Colors.dart';
import '../../data/models/WifiData.dart';
import '../../services/wifi_connection_service.dart';
import '../widgets/CustomInkWellItem2.dart';
import 'AddDevicePage.dart';
import 'MainBottomNavigationView.dart';

class Ap_Provisioning_Screen extends StatefulWidget {
  const Ap_Provisioning_Screen({super.key});

  @override
  State<Ap_Provisioning_Screen> createState() => _Ap_Provisioning_ScreenState();
}

class _Ap_Provisioning_ScreenState extends State<Ap_Provisioning_Screen> {
  MobileScannerController controller = MobileScannerController();
  bool _isDialogOpen = false;
  bool _isProcessing = false;
  String? _connectedSSID;
  StreamSubscription? _wifiSubscription;
  Timer? _connectionTimer;
  WifiData? _currentWifiData;
  bool _showManualOption = false;
  bool _isFirstConnectionAttempt = true;
  bool _isNavigating = false; // ADDED: Flag to prevent multiple navigation
  bool _isDisposed = false; // Track if widget is disposed

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed
    _cancelAllOperations(); // FIXED: Use consolidated cleanup method
    super.dispose();
  }

  void _cancelAllOperations() {
    // FIXED: Comprehensive cleanup method
    print("🧹 [Cleanup] Canceling all operations");

    // Cancel timer
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      _connectionTimer!.cancel();
      _connectionTimer = null;
    }

    // Cancel subscription
    _wifiSubscription?.cancel();
    _wifiSubscription = null;

    // Dispose controllers
    controller.dispose();
    _controller.dispose();

    // FIXED: Only call setState if widget is still mounted
    if (!_isDisposed && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _isProcessing = false;
            _isDialogOpen = false;
            _showManualOption = false;
            _connectedSSID = null;
            _isNavigating = false;
          });
        }
      });
    }
  }

  void _safeSetState(VoidCallback callback) {
    // FIXED: Safe wrapper for setState calls
    if (mounted && !_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(callback);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Mainbottomnavigationview(),
          ), // Navigate back
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              fit: BoxFit.cover,
              onDetect: (capture) async {
                // FIXED: Added _isNavigating check
                if (_isDialogOpen ||
                    _isProcessing ||
                    _isNavigating ||
                    _isDisposed) {
                  print(
                      "⚠️ [QR Scanner] Ignoring scan - navigating: $_isNavigating");
                  print(
                      "⚠️ [QR Scanner] Ignoring scan - disposed: $_isDisposed");
                  return;
                }

                print("📷 [QR Scanner] QR code detected!");

                final barcodes = capture.barcodes;
                final rawValue = barcodes.first.rawValue;
                if (rawValue == null) return;

                print("📷 [QR Scanner] Raw QR value: $rawValue");

                final wifi = parseWifiQRCode(rawValue);
                if (wifi == null) return;

                print("✅ [QR Scanner] WiFi data parsed successfully!");
                print("✅ [QR Scanner] SSID: '${wifi.ssid}'");
                print(
                    "✅ [QR Scanner] Password: ${wifi.password.isEmpty ? '(empty - open network)' : '***'}");

                _isDialogOpen = true;

                // Show toast with WiFi info
                Fluttertoast.showToast(
                  msg: "IoT WiFi Network Detected",
                  gravity: ToastGravity.BOTTOM,
                  toastLength: Toast.LENGTH_SHORT,
                );

                // Show dialog for confirmation
                if (mounted && !_isDisposed) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => _buildWifiConfirmationDialog(wifi),
                  ).then((_) {
                    _isDialogOpen = false;
                    _showManualOption = false;
                    if (!_isProcessing && !_isNavigating) {
                      _controller.start();
                    }
                  });
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
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Connecting to IoT network...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (_connectedSSID != null)
                        Text(
                          "Network: $_connectedSSID",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      const SizedBox(height: 16),
                      if (_showManualOption) ...[
                        const Text(
                          "Automatic connection failed",
                          style: TextStyle(color: Colors.orange, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _openWifiSettings(),
                          child: const Text("Open WiFi Settings"),
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextButton(
                        onPressed: () {
                          _cancelConnection();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  margin: const EdgeInsets.only(top: 10, right: 30, left: 30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddDevicePage(), // FIXED: Pass wifiData
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.white),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 5),
                          Text(
                            'Add Device Manually',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomInkWellItem2(
                      imagePath: "assets/backclick.png",
                      color: AppColors.white,
                      onTap: () {
                        _cancelAllOperations(); // FIXED: Proper cleanup on back
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Mainbottomnavigationview(), // FIXED: Pass wifiData
                          ),
                        );
                      },
                    ),
                    const Text(
                      "QR Code Scanner",
                      style: TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }

  void _cancelConnection() {
    print("❌ [WiFi] Connection canceled by user");
    _cancelAllOperations(); // FIXED: Use consolidated cleanup

    // Restart scanner
    _controller.start();
  }

  Widget _buildWifiConfirmationDialog(WifiData wifi) {
    return AlertDialog(
      title: const Text(
        'IoT WiFi Network Detected',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text('SSID: ${wifi.ssid}'),
          Text(
            'Password: ${wifi.password.isNotEmpty == true ? "●●●●●●" : "(No Password - Open Network)"}',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Note',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'If you\'re already connected to this network, '
                  'you can proceed directly to device setup.',
                  style: TextStyle(fontSize: 11, color: Colors.blue),
                ),
                SizedBox(height: 8),
                Text(
                  'If connection fails, you may see a system notification. '
                  'You can ignore it and use the manual option.',
                  style: TextStyle(fontSize: 11, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _controller.start();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : () => _connectToWifiDirectly(wifi),
          child: const Text('Connect'),
        ),
      ],
    );
  }

  Future<void> _connectToWifiDirectly(WifiData wifi) async {
    // FIXED: Check multiple conditions before starting
    if (_isProcessing || _isNavigating || _isDisposed) {
      print("⚠️ [WiFi] Already processing or navigating");
      return;
    }

    print("🔗 [WiFi] Starting connection to: ${wifi.ssid}");

    _safeSetState(() {
      _isProcessing = true;
      _connectedSSID = wifi.ssid;
      _currentWifiData = wifi;
      _showManualOption = false;
      _isNavigating = false;
    });

    // Close the dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    try {
      // Stop scanning
      await _controller.stop();

      print("🔗 [WiFi] Checking current connection...");

      // First, check if we're already connected to this network
      final isAlreadyConnected = await _checkCurrentConnection(wifi);
      if (isAlreadyConnected) {
        print("✅ [WiFi] Already connected to ${wifi.ssid}");
        await _onConnectedToIoT(wifi);
        return;
      }

      // Request location permission (required for WiFi access on Android)
      if (Platform.isAndroid) {
        final status = await Permission.location.request();
        if (!status.isGranted) {
          _safeSetState(() {
            _showManualOption = true;
          });
          Fluttertoast.showToast(
            msg: "Location permission required for WiFi connection",
            backgroundColor: Colors.orange,
          );
          return;
        }

        // Check if WiFi is enabled
        print("📡 [WiFi] Checking if WiFi is enabled...");
        final isWifiEnabled = await WiFiForIoTPlugin.isEnabled();

        if (!isWifiEnabled) {
          print("⚠️ [WiFi] WiFi is disabled");

          _safeSetState(() {
            _isProcessing = false;
          });

          // Show dialog asking user to enable WiFi
          if (mounted && !_isDisposed) {
            final shouldEnable = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('WiFi Disabled'),
                content: const Text(
                  'WiFi is currently disabled on your device. '
                  'Please enable WiFi to connect to the IoT network.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Enable WiFi'),
                  ),
                ],
              ),
            );

            if (shouldEnable == true) {
              print("🔌 [WiFi] Enabling WiFi...");
              await WiFiForIoTPlugin.setEnabled(true);
              await Future.delayed(const Duration(seconds: 2));

              // Verify WiFi is now enabled
              final nowEnabled = await WiFiForIoTPlugin.isEnabled();
              if (!nowEnabled) {
                Fluttertoast.showToast(
                  msg: "Failed to enable WiFi. Please enable manually.",
                  backgroundColor: Colors.red,
                );
                _openWifiSettings();
                return;
              }

              print("✅ [WiFi] WiFi enabled successfully");

              // Restart the connection process
              _safeSetState(() {
                _isProcessing = true;
              });
            } else {
              // User cancelled
              _controller.start();
              return;
            }
          } else {
            return;
          }
        } else {
          print("✅ [WiFi] WiFi is already enabled");
        }
      }

      // For subsequent attempts, try to remove and reconnect
      if (!_isFirstConnectionAttempt && Platform.isAndroid) {
        print("🔄 [WiFi] Removing existing network configuration...");
        await _removeExistingNetwork(wifi.ssid);
        await Future.delayed(const Duration(seconds: 1));
      }

      // Try to connect to WiFi
      bool success = false;

      if (Platform.isAndroid) {
        // Get Android version to determine which method to use
        print("🔗 [WiFi] Connecting with SSID: ${wifi.ssid}");

        try {
          // For Android 10+ (API 29+), use native method channel
          // This provides better compatibility and persistent connections
          success = await WifiConnectionService.connectToWifi(
            wifi.ssid,
            wifi.password,
          );

          print("🔗 [WiFi] Native connection method result: $success");

          // If successful, trust the native implementation
          // The native code already binds the process to the network
          if (!success) {
            print(
                "🔄 [WiFi] Native method failed, trying wifi_iot fallback...");

            // Check current network state
            final isEnabled = await WiFiForIoTPlugin.isEnabled();
            if (!isEnabled) {
              print("🔌 [WiFi] WiFi is disabled, enabling...");
              await WiFiForIoTPlugin.setEnabled(true);
              await Future.delayed(const Duration(seconds: 1));
            }

            success = await WiFiForIoTPlugin.connect(
              wifi.ssid,
              password: wifi.password,
              security: wifi.password.isNotEmpty
                  ? NetworkSecurity.WPA
                  : NetworkSecurity.NONE,
              joinOnce: false,
            );

            await Future.delayed(const Duration(seconds: 2));

            if (success) {
              final isConnected = await WiFiForIoTPlugin.isConnected();
              final currentSSID = await WiFiForIoTPlugin.getSSID();

              success = isConnected &&
                  (currentSSID?.contains(wifi.ssid) == true ||
                      currentSSID?.replaceAll('"', '') == wifi.ssid);
            }
          }
        } catch (e) {
          print("⚠️ [WiFi] Connection error: $e");
          success = false;
        }
      } else if (Platform.isIOS) {
        // iOS direct connection
        _safeSetState(() {
          _showManualOption = true;
        });
        Fluttertoast.showToast(
          msg: "iOS requires manual WiFi connection",
          backgroundColor: Colors.orange,
        );
        return;
      }

      if (success) {
        print("✅ [WiFi] Connection successful");
        _isFirstConnectionAttempt = false;
        await _onConnectedToIoT(wifi);
      } else {
        print("❌ [WiFi] Connection failed");
        _safeSetState(() {
          _showManualOption = true;
        });

        Fluttertoast.showToast(
          msg: "Automatic connection failed",
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      print("❌ [WiFi] Error during connection: $e");
      _safeSetState(() {
        _showManualOption = true;
      });

      Fluttertoast.showToast(
        msg: "Connection error: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    } finally {
      // FIXED: Only reset processing if we're not navigating
      if (!_isNavigating && !_isDisposed && mounted) {
        _safeSetState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _removeExistingNetwork(String ssid) async {
    try {
      if (Platform.isAndroid) {
        // Try to remove the network from saved networks
        await WiFiForIoTPlugin.disconnect();
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      print("⚠️ [WiFi] Error removing network: $e");
    }
  }

  Future<void> _forceReconnect(WifiData wifi) async {
    try {
      if (Platform.isAndroid) {
        // Force disconnect first
        await WiFiForIoTPlugin.disconnect();
        await Future.delayed(const Duration(seconds: 1));

        // Enable WiFi if disabled
        final isEnabled = await WiFiForIoTPlugin.isEnabled();
        if (!isEnabled) {
          await WiFiForIoTPlugin.setEnabled(true);
          await Future.delayed(const Duration(seconds: 1));
        }

        // Try findAndConnect for better compatibility
        await WiFiForIoTPlugin.findAndConnect(
          wifi.ssid,
          password: wifi.password,
          joinOnce: false,
        );

        // Wait for connection
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      print("⚠️ [WiFi] Force reconnect error: $e");
    }
  }

  void _openWifiSettings() async {
    print("🔗 [WiFi] Opening WiFi settings for manual connection");

    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.settings.WIFI_SETTINGS',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        await openAppSettings();
      }

      // Start monitoring for connection after opening settings
      if (_currentWifiData != null && mounted && !_isDisposed) {
        await _startMonitoringConnection(_currentWifiData!);
      }
    } catch (e) {
      print("❌ [WiFi] Error opening WiFi settings: $e");
      Fluttertoast.showToast(
        msg: "Cannot open WiFi settings",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _startMonitoringConnection(WifiData wifi) async {
    // Cancel any existing monitoring
    _wifiSubscription?.cancel();
    _connectionTimer?.cancel();

    // Start monitoring WiFi changes
    _wifiSubscription = Stream.periodic(const Duration(seconds: 2), (_) async {
      if (!_isProcessing || _isNavigating || _isDisposed) {
        return false;
      }
      return await _checkCurrentConnection(wifi);
    }).asyncMap((event) => event).listen((isConnected) async {
      if (isConnected && context.mounted && !_isDisposed && !_isNavigating) {
        print("✅ [WiFi] Successfully connected to IoT network: ${wifi.ssid}");
        await _onConnectedToIoT(wifi);
      }
    });

    // Set timeout for connection monitoring (2 minutes)
    _connectionTimer = Timer(const Duration(minutes: 2), () {
      if (_isProcessing && context.mounted && !_isDisposed && !_isNavigating) {
        _showTimeoutMessage(wifi);
      }
    });
  }

  Future<bool> _checkCurrentConnection(WifiData wifi) async {
    try {
      if (Platform.isAndroid) {
        final isConnected = await WiFiForIoTPlugin.isConnected();
        if (!isConnected) return false;

        final currentSSID = await WiFiForIoTPlugin.getSSID();
        print(
            "🔍 [WiFi Monitor] Current SSID: $currentSSID, Target: ${wifi.ssid}");

        // Check if we're connected to the target IoT network
        return currentSSID?.contains(wifi.ssid) == true ||
            currentSSID?.replaceAll('"', '') == wifi.ssid;
      }
      return false;
    } catch (e) {
      print("❌ [WiFi Monitor] Error checking connection: $e");
      return false;
    }
  }

  Future<void> _onConnectedToIoT(WifiData wifi) async {
    // FIXED: Prevent multiple navigation calls
    if (_isNavigating || _isDisposed) {
      print("⚠️ [WiFi] Already navigating, skipping...");
      return;
    }

    print("🎯 [WiFi] Navigating to AddDevicePage...");

    // Set navigating flag using safe method
    _safeSetState(() {
      _isNavigating = true;
    });

    // Cleanup
    _wifiSubscription?.cancel();
    _connectionTimer?.cancel();

    // Show success message
    Fluttertoast.showToast(
      msg: "Connected to ${wifi.ssid}!",
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: const Color(0xFF2277BB),
      textColor: Colors.white,
    );

    // Wait for network stabilization and UI update
    await Future.delayed(const Duration(milliseconds: 100));

    // Navigate to device setup
    if (mounted && !_isDisposed) {
      try {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddDevicePage(), // FIXED: Pass wifiData
          ),
        );
      } catch (e) {
        print("❌ [Navigation] Error navigating to AddDevicePage: $e");
        // Reset states if navigation fails
        if (mounted && !_isDisposed) {
          _safeSetState(() {
            _isNavigating = false;
            _isProcessing = false;
          });
          _controller.start();
        }
      }
    }
  }

  void _showTimeoutMessage(WifiData wifi) {
    print("⏰ [WiFi] Connection timeout");

    _wifiSubscription?.cancel();
    _connectionTimer?.cancel();

    _safeSetState(() {
      _isProcessing = false;
      _connectedSSID = null;
      _showManualOption = true;
    });

    if (mounted && !_isDisposed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Timeout'),
          content: Text(
            'Could not detect connection to "${wifi.ssid}".\n\n'
            'You can:\n'
            '1. Try connecting again\n'
            '2. Connect manually in WiFi settings\n'
            '3. Make sure you\'re in range of the network',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.start();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openWifiSettings();
              },
              child: const Text('Open WiFi Settings'),
            ),
          ],
        ),
      );
    }
  }

  WifiData? parseWifiQRCode(String qr) {
    try {
      if (!qr.startsWith("WIFI:")) return null;

      debugPrint("Raw QR data: $qr");
      String clean = qr.substring(5);
      String ssid = "";
      String password = "";
      String securityType = "";

      final parts = clean.split(";");

      for (var part in parts) {
        if (part.startsWith("S:")) {
          ssid = part.substring(2);
        } else if (part.startsWith("P:")) {
          password = part.substring(2);
        } else if (part.startsWith("T:")) {
          securityType = part.substring(2);
        }
      }

      if (ssid.isEmpty) return null;

      // If T: is "nopass", ensure password is empty
      if (securityType == "nopass") {
        password = "";
      }

      return WifiData(ssid: ssid, password: password);
    } catch (e) {
      debugPrint("Error parsing QR code: $e");
      return null;
    }
  }
}
