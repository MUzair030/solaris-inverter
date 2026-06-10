import 'dart:async';

import 'package:flutter/material.dart';
import 'package:threepol_inverter_flutter/data/models/geyser_history_response_model.dart';

import '../../data/models/geyser_history_request_model.dart';
import '../../domain/entities/geyser_history_data_entity.dart';
import '../../domain/usecases/fetch_geyser_history_data_usecase.dart';
import '../../services/NotificationService.dart';
import '../../utils/SharedPreferencesHelper.dart';

class GeyserHistoryViewModel extends ChangeNotifier {
  final FetchGeyserHistoryDataUseCase useCase;

  GeyserHistoryViewModel(this.useCase);

  bool isLoading = false;
  String? errorMessage;

  Timer? _timer;
  bool _isRefreshing = false;

  String? displayedDate;

  int? _lastNotifiedErrorCode;
  bool _notificationShown = false;
  bool _deviceStableNotified = false;
  String? _errorTypeMessage;
  String? get errorTypeMessage => _errorTypeMessage;

  // List<GeyserHistoryDataEntity> geyserData = [];
  // List<GeyserHistoryDataEntity> get inverterData => geyserData;

  List<GeyserHistoryResponseModel> geyserData = [];
  List<GeyserHistoryResponseModel> get inverterData => geyserData;

  late BuildContext _context;
  void setContext(BuildContext context) {
    _context = context;
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
        geyserData = [];
        notifyListeners();
        return;
      }

      // if (mac == null) {
      //   mac = "48:27:e2:83:61:fc";
      //   await SharedPreferencesHelper.saveMacData(mac, "abc", 10);
      // }

      isLoading = true;
      notifyListeners();
      final request = GeyserHistoryRequestModel(
        macAddress: mac,
        perday: false,
        perweek: false,
        permonth: false,
        peryear: false,
        completereport: true,
      );
      List<GeyserHistoryResponseModel> fetchedData =
          await useCase.execute(request);

      // List<InverterDataModel> fetchedData =
      //     await _fetchInverterDataUseCase.execute("daily", "48:27:e2:83:61:fc");

      print("object: $fetchedData");

      if (fetchedData.isEmpty) {
        errorMessage = "No data available";
        geyserData = [];
        displayedDate = null;
      } else {
        errorMessage = null;
        geyserData = fetchedData;
        // geyserData = fetchedData.map((entity) {
        //   return GeyserHistoryResponseModel(
        //     id: entity.id,
        //     deviceName: entity.deviceName,
        //     macAddress: entity.macAddress,
        //     version: entity.version,
        //     error: entity.error,
        //     energyConsumed: entity.energyConsumed,
        //     genPower: entity.genPower,
        //     pvVoltage: entity.pvVoltage,
        //     outputVoltage: entity.outputVoltage,
        //     outputCurrent: entity.outputCurrent,
        //     createdAt: entity.createdAt,
        //   );
        // }).toList();

        DateTime apiTime = inverterData.last.createdAt;
        // Update _lastUpdateTime to now when data is fetched
        _lastUpdateTime = DateTime.now();

        final apiInSeconds =
            apiTime.hour * 3600 + apiTime.minute * 60 + apiTime.second;
        final nowInSeconds = _lastUpdateTime!.hour * 3600 +
            _lastUpdateTime!.minute * 60 +
            _lastUpdateTime!.second;

        final differenceInSeconds = (nowInSeconds - apiInSeconds).abs();

        final int errorCode = geyserData.last.error;
        _errorTypeMessage = getErrorMessageFromCode(errorCode);

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
            NotificationService.showNotification(
              "⚠️ Device Offline",
              "The inverter is not sending updated data.",
            );
            _lastNotifiedErrorCode = -1;
            _notificationShown = true;
            _deviceStableNotified = false;
          }
        } else {
          _status = "Online";

          // Device just came online from offline
          if (wasOffline) {
            NotificationService.showNotification(
              "🟢 Device Online",
              "The inverter is now online.",
            );
            _deviceStableNotified = false;
            _lastNotifiedErrorCode = 0;
            _notificationShown = false;
          }

          // If previously errored or offline, notify stable
          if (!_deviceStableNotified && !wasError) {
            NotificationService.showNotification(
              "✅ Device Stable",
              "System is working normally.",
            );
            _deviceStableNotified = true;
            _lastNotifiedErrorCode = 0;
            _notificationShown = false;
          }
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      geyserData = [];
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
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
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

  // Future<void> fetchInverterData(
  //     {String macAddress = "48:27:e2:83:61:fc"}) async {
  //   isLoading = true;
  //   errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final request = GeyserHistoryRequestModel(
  //       macAddress: macAddress,
  //       perday: false,
  //       perweek: false,
  //       permonth: false,
  //       peryear: false,
  //       completereport: true,
  //     );
  //
  //     final result = await useCase.execute(request);
  //     geyserData = result;
  //   } catch (e) {
  //     errorMessage = e.toString();
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  GeyserHistoryResponseModel? get latestData {
    if (geyserData.isEmpty) return null;
    geyserData.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return geyserData.first;
  }

  DateTime? _lastUpdateTime;
  String _status = "Offline";

  String? devicestate = "Device Stable";

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
}
