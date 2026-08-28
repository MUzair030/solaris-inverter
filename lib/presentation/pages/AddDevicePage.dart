import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/AddDevicesBottomSheet1.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/CustomTextField2.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/DataCollectionConsentDialog.dart';

import '../../../../../../app/App_Colors.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:permission_handler/permission_handler.dart';
// import 'package:wifi_info_flutter/wifi_info_flutter.dart';

import '../../services/DeviceMonitoringService.dart';
import '../../utils/SharedPreferencesHelper.dart';
import '../viewmodels/DeviceViewModel.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/inverter_viewmodel.dart';
import '../viewmodels/inverter_viewmodel1.dart';
import '../viewmodels/provisioning_provider.dart';
import '../widgets/AddDevicesBottomSheet2.dart';
import '../widgets/AddDevicesBottomSheet4.dart';
import '../widgets/AddDevicesBottomSheet5.dart';
import '../widgets/CustomInkWellItem2.dart';
import '../widgets/HeaderWidget.dart';
import '../viewmodels/MacViewModel.dart';
import '../widgets/PasswordTextField.dart';
import '../widgets/PasswordTextFieldAddDevice.dart';
import 'MainBottomNavigationView.dart';
import 'QrScannerForManualyScreen.dart';

class AddDevicePage extends StatefulWidget {
  AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  // final AddDevices viewModel = AddDevices();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool _isObscure = true;

  final TextEditingController _conssidController = TextEditingController();
  final TextEditingController _conbssidController = TextEditingController();
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _status = 'Not connected';
  Socket? _socket;
  int serverPort = 5005;
  late String _message = '';

  List<WiFiAccessPoint> _accessPoints = [];
  bool _isScanning = false;
  bool _isManualSsid = false;

  late MacViewModel viewModel;

  @override
  void initState() {
    super.initState();
    _buildDevicesBottomSheet(context);
    // viewModel = Provider.of<MacViewModel>(context);
    viewModel = Provider.of<MacViewModel>(context, listen: false);
    _getWifiInfo();
    _scanWifiNetworks();
  }

  void _buildDevicesBottomSheet(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Allows height to adjust dynamically
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const AddDevicesBottomSheet1(),
      );
    });
  }

  void _buildDevicesBottomSheet1(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows height to adjust dynamically
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddDevicesBottomSheet1(),
    );
  }

  void _buildDevicesBottomSheet2(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows height to adjust dynamically
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddDevicesBottomSheet2(),
    );
  }

  void _buildDevicesBottomSheet4(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows height to adjust dynamically
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddDevicesBottomSheet4(),
    );
  }

  void _buildDevicesBottomSheet5(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows height to adjust dynamically
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddDevicesBottomSheet5(),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Services Disabled"),
        content: const Text(
            "Location services are required to scan for WiFi networks. Please enable them in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openLocationSettings();
            },
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _openLocationSettings() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',
      );
      await intent.launch();
    }
  }

  Future<void> _scanWifiNetworks() async {
    setState(() => _isScanning = true);
    try {
      if (await Permission.location.isGranted) {
        await _doScan();
      } else {
        final consented = await showDataCollectionConsentDialog(
          context,
          [Permission.location],
        );
        if (consented && await Permission.location.request().isGranted) {
          await _doScan();
        } else {
          Fluttertoast.showToast(
            msg: "Location permission required for WiFi scanning",
          );
        }
      }
    } catch (e) {
      print("Error scanning WiFi: $e");
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _doScan() async {
    try {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        await Future.delayed(const Duration(seconds: 2));
        final canGet = await WiFiScan.instance.canGetScannedResults();
        if (canGet == CanGetScannedResults.yes) {
          final results = await WiFiScan.instance.getScannedResults();
          setState(() {
            _accessPoints = results;
            if (results.isNotEmpty &&
                !_isManualSsid &&
                _ssidController.text.isEmpty) {
              String? firstSsid;
              for (var ap in results) {
                if (ap.ssid.isNotEmpty) {
                  firstSsid = ap.ssid;
                  break;
                }
              }
              if (firstSsid != null) {
                _ssidController.text = firstSsid;
              }
            }
          });
          if (results.isEmpty) {
            Fluttertoast.showToast(
                msg: "No WiFi networks found. You may need to enter manually.");
          }
        } else {
          Fluttertoast.showToast(msg: "Cannot get scan results: $canGet");
        }
      } else if (canScan == CanStartScan.noLocationServiceDisabled) {
        _showLocationServiceDialog();
      } else {
        Fluttertoast.showToast(msg: "Cannot start scan: $canScan");
      }
    } catch (e) {
      print("Error scanning WiFi: $e");
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _getWifiInfo() async {
    try {
      if (await Permission.locationWhenInUse.isGranted) {
        await _doGetWifiInfo();
      } else {
        final consented = await showDataCollectionConsentDialog(
          context,
          [Permission.location],
        );
        if (consented && await Permission.locationWhenInUse.request().isGranted) {
          await _doGetWifiInfo();
        } else {
          setState(() {
            _conssidController.text = "Permission required";
            _conbssidController.text = "Permission required";
          });
        }
      }
    } catch (e) {
      print("Error getting WiFi info: $e");
    }
  }

  Future<void> _doGetWifiInfo() async {
    try {
      final info = NetworkInfo();
      String? ssid = await info.getWifiName();
      String? bssid = await info.getWifiBSSID();
      setState(() {
        _conssidController.text = ssid ?? "Unknown SSID";
        _conbssidController.text = bssid ?? "Unknown BSSID";
      });
    } catch (e) {
      print("Error getting WiFi info: $e");
    }
  }

  Future<void> _connectToServer() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
      _status = 'Connecting...';
    });

    try {
      await _disconnect();

      print('Attempting to connect to 192.168.4.1 & $serverPort');
      _socket = await Socket.connect("192.168.4.1", 5005,
          timeout: const Duration(seconds: 10));

      setState(() {
        _status =
            'Connected to: ${_socket?.remoteAddress.address}:${_socket?.remotePort}';
      });

      _socket?.listen(
        (data) async {
          String received = String.fromCharCodes(data).trim();
          print("Received data: $received");

          setState(() {
            _message = received;
          });

          if (received.isEmpty) {
            Fluttertoast.showToast(msg: 'Empty MAC Address, please try again');
          } else {
            // Split by comma — new firmware sends: mac,version,rated_power
            List<String> parts = received.split(',');

            String macAddress = parts[0];
            String version = parts.length > 1 ? parts[1] : "";
            String ratedPower = parts.length > 2 ? parts[2] : "";

            print("MAC Address: ${macAddress.trim()}");
            print("Version: $version");

            // CRITICAL: Disconnect socket BEFORE disconnecting WiFi
            await _disconnect();

            // Force release any network binding
            await WiFiForIoTPlugin.forceWifiUsage(false);
            await WiFiForIoTPlugin.disconnect();
            await Future.delayed(const Duration(seconds: 1));

            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              showMacDialog(context, macAddress, version, ratedPower);
            }
          }
        },
        onDone: () {
          print('Server closed connection');
          if (mounted) {
            setState(() {
              _status = 'Server closed connection';
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          print('Socket Error: $error');
          if (mounted) {
            setState(() {
              _status = 'Connection error: $error';
              _isLoading = false;
            });
          }
        },
        cancelOnError: true,
      );

      _sendData(_ssidController.text.trim(), _passwordController.text.trim());
    } catch (e) {
      print('Catch block executed: $e');
      if (mounted) {
        setState(() {
          _status = 'Failed to connect: $e';
          _isLoading = false;
        });
      }
    } finally {
      // Note: We don't set _isLoading = false here because
      // the connection might still be active and waiting for data.
      // We set it to false in onError/onDone or after successful data processing if needed.
      // However, to allow retry on failed connection (timeout/refusal):
      if (_socket == null && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String capitalizeMacAddress(String macAddress) {
    return macAddress.toUpperCase();
  }

  void _sendData(String message1, String message2) {
    if (_socket != null) {
      _socket?.write('$message1,$message2');
    }
  }

  Future<void> _disconnect() async {
    if (_socket != null) {
      try {
        // Use destroy() for all cases to ensure immediate cleanup of OS resources.
        // It's safer than close() especially when the connection might be broken.
        _socket!.destroy();
        _socket = null;
        if (mounted) {
          setState(() {
            _status = 'Disconnected';
          });
        }
      } catch (e) {
        print('Error destroying socket: $e');
        _socket = null;
      }
    }
  }

  @override
  void dispose() {
    // _socket?.close();
    _disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        // Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Mainbottomnavigationview(),
          ), // Navigate back
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/bg.png", fit: BoxFit.cover),
            Container(
              color: Colors.black.withOpacity(0.1), // Dark overlay
            ),
            Padding(
              padding: const EdgeInsets.only(top: 13.0, right: 15, left: 2),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomInkWellItem2(
                        imagePath: "assets/backclick.png",
                        color: AppColors.white,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Mainbottomnavigationview(),
                            ), // Navigate back
                          );
                        },
                      ),
                      const Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _buildDevicesBottomSheet1(context);
                        },
                        child: const Icon(
                          Icons.info,
                          color: AppColors.white,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2, left: 15),
                        child: Column(
                          children: [
                            const Column(
                              children: [
                                HeaderWidget(),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text(
                                  'SSID: ',
                                  style: TextStyle(
                                      fontSize: 15.0, color: AppColors.white),
                                ),
                                Text(
                                  _conssidController.text,
                                  style: const TextStyle(
                                      fontSize: 14.0, color: AppColors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text(
                                  'BSSID: ',
                                  style: TextStyle(
                                      fontSize: 15.0, color: AppColors.white),
                                ),
                                Text(
                                  _conbssidController.text,
                                  style: const TextStyle(
                                      fontSize: 14.0, color: AppColors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '* Type your WI-FI name and password of your home network to connect.',
                              style: TextStyle(
                                  fontSize: 14.0, color: AppColors.white),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 30, left: 30),
                              child: CustomTextField2(
                                controller: _ssidController,
                                label: "WiFi SSID",
                                readOnly: !_isManualSsid,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(
                                        r'''[a-zA-Z0-9 !@#\$%^&*()_\-=\[\]{};:'",.<>?/\\|`~]'''),
                                  ),
                                  LengthLimitingTextInputFormatter(32),
                                ],
                                maxLength: 32,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isManualSsid)
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: AppColors.red, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _isManualSsid = false;
                                            if (_accessPoints.isNotEmpty) {
                                              String? firstSsid;
                                              for (var ap in _accessPoints) {
                                                if (ap.ssid.isNotEmpty) {
                                                  firstSsid = ap.ssid;
                                                  break;
                                                }
                                              }
                                              _ssidController.text =
                                                  firstSsid ?? "";
                                            } else {
                                              _ssidController.clear();
                                            }
                                          });
                                        },
                                        tooltip: "Back to list",
                                      ),
                                    if (_isScanning)
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.blue,
                                          ),
                                        ),
                                      )
                                    else if (!_isManualSsid)
                                      IconButton(
                                        icon: const Icon(Icons.refresh,
                                            color: AppColors.white, size: 20),
                                        onPressed: _scanWifiNetworks,
                                        tooltip: "Refresh WiFi list",
                                      ),
                                    if (!_isManualSsid)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: AppColors.white),
                                        onSelected: (String ssid) {
                                          if (ssid == "manual") {
                                            setState(() {
                                              _isManualSsid = true;
                                              _ssidController.clear();
                                            });
                                          } else {
                                            setState(() {
                                              _ssidController.text = ssid;
                                            });
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          List<PopupMenuEntry<String>> items =
                                              [];
                                          if (_accessPoints.isNotEmpty) {
                                            items.addAll(_accessPoints
                                                .where(
                                                    (ap) => ap.ssid.isNotEmpty)
                                                .map((ap) {
                                              return PopupMenuItem<String>(
                                                value: ap.ssid,
                                                child: Text(ap.ssid),
                                              );
                                            }).toList());
                                            items.add(const PopupMenuDivider());
                                          }
                                          items.add(const PopupMenuItem<String>(
                                            value: "manual",
                                            child: Text("Other / Manual Type"),
                                          ));
                                          return items;
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 30, left: 30),
                              child: PasswordTextFieldAddDevice(
                                controller: _passwordController,
                                label: "Password",
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const QrScannerForManualyScreen(),
                                  ),
                                );

                                // result contains SSID & Password
                                if (result != null &&
                                    result is Map<String, String>) {
                                  setState(() {
                                    _ssidController.text = result['ssid'] ?? '';
                                    _passwordController.text =
                                        result['password'] ?? '';
                                  });
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.only(right: 30, left: 30),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: const Color(0xFFFF6B00), width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner,
                                      color: AppColors.blue,
                                      size: 25,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Scan QR Code",
                                      style: TextStyle(
                                        color: const Color(0xFFFF6B00),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (isLoading) const CircularProgressIndicator(),
                            if (!isLoading)
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10, right: 30, left: 30),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    String ssid = _ssidController.text;
                                    String password = _passwordController.text;
                                    if (ssid.isNotEmpty) {
                                      if (password.isNotEmpty) {
                                        _connectToServer();
                                        // showMacDialog(context,
                                        //     "98:3d:ae:f5:06:35", "version");
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'please enter wifi password')));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'please enter wifi ssid')));
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: AppColors.blue),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.connect_without_contact,
                                            color: Colors.white),
                                        SizedBox(width: 5),
                                        Text(
                                          'Connect Inverter',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Text(
                              _status,
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.white),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Response: $_message",
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isLoading1 = false;

  void showMacDialog(BuildContext context, String macAddress, String version, String ratedPower) {
    TextEditingController nameController = TextEditingController();
    TextEditingController powerController = TextEditingController(text: ratedPower);
    TextEditingController macController =
        TextEditingController(text: macAddress);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int maxPowerLimit = 5;
        int maxnameLimit = 15;
        int maxmacLimit = 17;
        return AlertDialog(
          title: const Text(
            "Inverter Data",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  maxLength: maxnameLimit,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        text: 'Enter Name',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // labelText: "Enter Name",
                    labelStyle:
                        const TextStyle(color: AppColors.black, fontSize: 14),
                    hintText: "Enter Inverter/Floor/Room Name",
                    hintStyle:
                        const TextStyle(color: AppColors.gray3, fontSize: 13),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: powerController,
                  readOnly: ratedPower.isNotEmpty,
                  keyboardType: TextInputType.number,
                  maxLength: maxPowerLimit,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        text: 'Inverter Power',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // labelText: "Inverter Power",
                    labelStyle:
                        const TextStyle(color: AppColors.black, fontSize: 14),
                    hintText: "Rated Power (W)",
                    hintStyle:
                        const TextStyle(color: AppColors.gray3, fontSize: 13),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  readOnly: true,
                  controller: macController,
                  maxLength: maxmacLimit,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(17),
                  ],
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        text: 'MAC Address',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // labelText: "MAC Address",
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 5),
                if (isLoading) ...[
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, left: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Green background
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(7), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5), // Increase button height
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text color
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, left: 0),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading1 = true;
                        });
                        String enteredName = nameController.text;
                        String powerkv = powerController.text;
                        String enteredMac = macController.text;

                        if (enteredName.isNotEmpty && powerkv.isNotEmpty) {
                          int powerKvInt = int.parse(powerkv);
                          // viewModel.addMacAddress(
                          //     enteredMac, enteredName, powerKvInt, context);

                          if (powerKvInt == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid power value"),
                              ),
                            );
                            return;
                          }

                          setState(() => isLoading1 = true);

                          // bool success = await viewModel.addMacAddress(
                          //     enteredMac, enteredName, powerKvInt, context);

                          final message = await viewModel.addMacAddress(
                              enteredMac, enteredName, powerKvInt, context);

                          final deviceId =
                              viewModel.deviceModelReponse?.deviceId;

                          if (message == null) {
                            setState(() => isLoading1 = false);
                            Fluttertoast.showToast(msg: "Something went wrong");
                            return;
                          }
                          if (message.contains("Added")) {
                            Navigator.of(context).pop();
                            // Refresh all relevant views
                            Future.microtask(() {
                              final deviceViewModel =
                                  Provider.of<DeviceViewModel>(context,
                                      listen: false);
                              deviceViewModel.fetchDevices();

                              final inverterViewModel =
                                  Provider.of<InverterViewModel>(context,
                                      listen: false);
                              inverterViewModel.fetchInverterData();
                              inverterViewModel.startAutoRefresh();

                              final inverterViewModel1 =
                                  Provider.of<InverterViewModel1>(context,
                                      listen: false);
                              inverterViewModel1.fetchInverterData("daily",
                                  macAddress: enteredMac);
                              inverterViewModel1.startAutoRefresh("daily",
                                  macAddress: enteredMac);

                              SharedPreferencesHelper.saveVersionData(version);
                              SharedPreferencesHelper.saveMacData(
                                  enteredMac, enteredName, powerKvInt);
                              // DeviceMonitoringService.startMonitoring();

                              final selectedDeviceProvider =
                                  Provider.of<SelectedDeviceProvider>(context,
                                      listen: false);
                              selectedDeviceProvider.setDevice(
                                  enteredMac, enteredName, powerKvInt);
                            });

                            setState(() {
                              isLoading1 = false;
                            });

                            // Optionally show bottom sheet or update UI
                            // _buildDevicesBottomSheet4(context);
                            Fluttertoast.showToast(
                                msg: "Device Added Successfully");
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const Mainbottomnavigationview(),
                              ),
                            );
                          } else if (message.contains("Not Unique")) {
                            Navigator.of(context).pop();
                            setState(() => isLoading1 = false);
                            // Fluttertoast.showToast(
                            //     msg: "This MAC address is already registered.");
                            // _buildDevicesBottomSheet5(context);

                            final prov = Provider.of<ProvisioningProvider>(
                                context,
                                listen: false);
                            prov.resetState();

                            print("Response data1: ${deviceId}");

                            _showDeviceExistsDialog(
                                context,
                                deviceId!,
                                viewModel,
                                enteredMac,
                                enteredName,
                                powerKvInt,
                                version);
                          } else {
                            setState(() => isLoading1 = false);
                            Fluttertoast.showToast(
                                msg: message ?? "Something went wrong.");
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill the required fields"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00), // Green background
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(7), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text color
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    _buildDevicesBottomSheet2(context);
  }

  void _showDeviceExistsDialog(
      BuildContext parentContext,
      int deviceId,
      MacViewModel viewModel,
      String enteredMac,
      String enteredName,
      int powerKvInt,
      String version) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: Provider.of<ProvisioningProvider>(context, listen: false),
          child: Consumer<ProvisioningProvider>(
            builder: (context, prov, _) {
              return AlertDialog(
                title: const Text("Device Already Exists"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'This Device Already Exists. Do you want to delete it and add again'),
                    const SizedBox(
                      height: 15,
                    ),
                    if (prov.isLoading) const CircularProgressIndicator(),
                    if (prov.errorMessage != null)
                      Text(
                        prov.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    if (prov.successMessage != null)
                      Text(
                        prov.successMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: prov.isLoading
                        ? null
                        : () {
                            prov.clearMessages();
                            Navigator.of(context).pop();
                          },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: prov.isLoading
                        ? null
                        : () async {
                            await prov.deleteDevice(deviceId);
                            if (prov.successMessage != null) {
                              String? message = await viewModel.addMacAddress(
                                  enteredMac, enteredName, powerKvInt, context);

                              // VERY IMPORTANT
                              prov.clearMessages();
                              prov.resetState();

                              // CLOSE DIALOG (ROOT NAVIGATOR)
                              // Navigator.of(context, rootNavigator: true).pop();

                              // UI update
                              if (mounted) {
                                setState(() => isLoading1 = false);
                              }

                              if (message!.contains("Added")) {
                                Fluttertoast.showToast(
                                    msg: "Device Added Successfully");
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Mainbottomnavigationview(),
                                  ),
                                );
                                // Refresh all relevant views
                                Future.microtask(() {
                                  final deviceViewModel =
                                      Provider.of<DeviceViewModel>(context,
                                          listen: false);
                                  deviceViewModel.fetchDevices();

                                  final inverterViewModel =
                                      Provider.of<InverterViewModel>(context,
                                          listen: false);
                                  inverterViewModel.fetchInverterData();
                                  inverterViewModel.startAutoRefresh();

                                  final inverterViewModel1 =
                                      Provider.of<InverterViewModel1>(context,
                                          listen: false);
                                  inverterViewModel1.fetchInverterData("daily",
                                      macAddress: enteredMac);
                                  inverterViewModel1.startAutoRefresh("daily",
                                      macAddress: enteredMac);

                                  SharedPreferencesHelper.saveVersionData(
                                      version);
                                  SharedPreferencesHelper.saveMacData(
                                      enteredMac, enteredName, powerKvInt);
                                  // DeviceMonitoringService.startMonitoring();

                                  final selectedDeviceProvider =
                                      Provider.of<SelectedDeviceProvider>(
                                          context,
                                          listen: false);
                                  selectedDeviceProvider.setDevice(
                                      enteredMac, enteredName, powerKvInt);
                                });
                              }
                            }
                          },
                    child: const Text('Delete and Add'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
