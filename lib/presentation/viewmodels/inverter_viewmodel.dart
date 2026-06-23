import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/utils/toast_util.dart';

import '../../../utils/SharedPreferencesHelper.dart';
import '../../data/models/inverter_data_model.dart';
import '../../domain/usecases/get_inverter_data_usecase.dart';
import '../../services/NotificationService.dart';
import 'SelectedDeviceProvider.dart';

class InverterViewModel extends ChangeNotifier {
  final FetchInverterDataUseCase _fetchInverterDataUseCase;
  List<InverterDataModel> _inverterData = [];
  String? errorMessage;
  bool isLoading = false;
  Timer? _timer;
  bool _isRefreshing = false;

  String? displayedDate;

  String? devicestate = "Device Stable";

  String? _errorTypeMessage;
  String? get errorTypeMessage => _errorTypeMessage;
  int? _lastErrorCode;
  int? _lastNotifiedErrorCode;
  bool _notificationShown = false;
  bool _deviceStableNotified = false;
  static bool isBackgroundServiceActive = false;

  InverterViewModel(this._fetchInverterDataUseCase) {
    // _initializeNotifications();
    // initialize();
  }

  late BuildContext _context;
  void setContext(BuildContext context) {
    _context = context;
  }

  List<InverterDataModel> get inverterData => _inverterData;

  void initialize() {
    fetchInverterData();
    startAutoRefresh();
  }

  DateTime? _lastUpdateTime;
  String _status = "Offline";

  String get status => _status;

  String getErrorMessageFromCode(int code) {
    switch (code) {
      case 1:
        return "Solar Over Voltage";
      case 2:
        return "Solar Under Voltage";
      case 4:
        return "Overload";
      case 5:
        return "Over Temperature";
      case 6:
        return "Short Circuit";
      case 0:
        return devicestate!;
        return "Normal";
      default:
        return "Unknown Error";
    }
  }

  Future<void> fetchInverterData() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();
    try {
      // final mac =
      // Provider.of<SelectedDeviceProvider>(context, listen: false).mac;
      String? mac = await SharedPreferencesHelper.getMacData();

      if (mac == null || mac.isEmpty) {
        errorMessage = "MAC Address not found";
        _inverterData = [];
        notifyListeners();
        return;
      }

      // if (mac == null) {
      //   mac = "48:27:e2:83:61:fc";
      //   await SharedPreferencesHelper.saveMacData(mac, "abc", 10);
      // }

      isLoading = true;
      notifyListeners();

      List<InverterDataModel> fetchedData =
          await _fetchInverterDataUseCase.execute("daily", mac);

      // List<InverterDataModel> fetchedData =
      //     await _fetchInverterDataUseCase.execute("daily", "48:27:e2:83:6d:d0");
      // await _fetchInverterDataUseCase.execute("daily", "48:27:e2:83:61:fc");

      if (fetchedData.isEmpty) {
        errorMessage = "No data available";
        _inverterData = [];
        displayedDate = null;
      } else {
        errorMessage = null;
        _inverterData = fetchedData;

        DateTime apiTime = inverterData.last.createdAt;
        // Update _lastUpdateTime to now when data is fetched
        _lastUpdateTime = DateTime.now();

        final apiInSeconds =
            apiTime.hour * 3600 + apiTime.minute * 60 + apiTime.second;
        final nowInSeconds = _lastUpdateTime!.hour * 3600 +
            _lastUpdateTime!.minute * 60 +
            _lastUpdateTime!.second;

        final differenceInSeconds = (nowInSeconds - apiInSeconds).abs();

        final int errorCode = _inverterData.last.error;
        _errorTypeMessage = getErrorMessageFromCode(errorCode);

        // Fluttertoast.showToast(msg: "inverter viewmodel: $errorCode");

        // bool isOffline = differenceInSeconds >= 62;

        final Duration timeDifference =
            _lastUpdateTime!.difference(apiTime).abs();
        const Duration offlineThreshold = Duration(seconds: 62);
        final bool isOffline = timeDifference >= offlineThreshold;

        final wasOffline = _status == "Offline";
        final wasError =
            _lastNotifiedErrorCode != null && _lastNotifiedErrorCode != 0;

        if (errorCode != 0) {
          _status = "Offline";
          // _status = "Online";
          _errorTypeMessage = getErrorMessageFromCode(errorCode);

          if (_lastNotifiedErrorCode != errorCode || !_notificationShown) {
            NotificationService.showNotification(
              "🔴 Device Error",
              _errorTypeMessage!,
            );
            _lastNotifiedErrorCode = errorCode;
            _notificationShown = true;
            _deviceStableNotified = false;
          }
          // } else if (differenceInSeconds >= 62) {
        } else if (isOffline) {
          _status = "Offline";

          if (_lastNotifiedErrorCode != -1) {
            if (!InverterViewModel.isBackgroundServiceActive) {
              NotificationService.showNotification("⚠️ Device Offline",
                  "The inverter is not sending updated data.");
            }
            _lastNotifiedErrorCode = -1;
            _notificationShown = true;
            _deviceStableNotified = false;
          }
        } else {
          _status = "Online";

          // Device just came online from offline
          if (wasOffline) {
            if (!InverterViewModel.isBackgroundServiceActive) {
              NotificationService.showNotification(
                  "🟢 Device Online", "The inverter is now online.");
            }
            _deviceStableNotified = false;
            _lastNotifiedErrorCode = 0;
            _notificationShown = false;
          }

          // If previously errored or offline, notify stable
          if (!_deviceStableNotified && !wasError) {
            if (!InverterViewModel.isBackgroundServiceActive) {
              NotificationService.showNotification(
                  "✅ Device Stable", "System is working normally.");
            }
            _deviceStableNotified = true;
            _lastNotifiedErrorCode = 0;
            _notificationShown = false;
          }
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      _inverterData = [];
      displayedDate = null;
      _status = "Offline";
    } finally {
      isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> startAutoRefresh() async {
    stopAutoRefresh();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      fetchInverterData();
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
