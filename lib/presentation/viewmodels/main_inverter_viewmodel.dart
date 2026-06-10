import 'dart:async';
import 'package:flutter/material.dart';

import '../../../utils/SharedPreferencesHelper.dart';
import '../../data/models/inverter_data_model.dart';
import '../../domain/usecases/get_main_inverter_data_usecase.dart';

class MainInverterViewModel extends ChangeNotifier {
  final FetchMainInverterDataUseCase _fetchInverterDataUseCase;
  List<InverterDataModel> _inverterData = [];
  String? errorMessage;
  bool _isLoading = false;
  Timer? _timer;

  InverterDataModel? latestInverter;

  MainInverterViewModel(this._fetchInverterDataUseCase);

  List<InverterDataModel> get inverterData => _inverterData;

  bool get isLoading => _isLoading;

  Future<void> fetchInverterData() async {
    _isLoading = true;
    notifyListeners();

    String? token = await SharedPreferencesHelper.getToken();
    String? macAddress = await SharedPreferencesHelper.getMacData();

    if (token == null) {
      return;
    }

    // if (macAddress == null) {
    //   macAddress = "48:27:e2:83:61:fc"; // Default value
    //   await SharedPreferencesHelper.saveMacData(macAddress, "abc", 10);
    // }

    try {
      List<InverterDataModel>? data =
          await _fetchInverterDataUseCase(macAddress!);

      if (data != null && data.isNotEmpty) {
        latestInverter = data.reduce(
          (a, b) => a.createdAt.compareTo(b.createdAt) > 0 ? a : b,
        );
        _inverterData = data;
      } else {
        _inverterData = [];
        errorMessage = "No data received.";
      }
    } catch (e) {
      errorMessage = "Failed to fetch data: $e";
      _inverterData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    // List<InverterDataModel>? data =
    //     await _fetchInverterDataUseCase(macAddress!);
    //
    // if (data != null && data.isNotEmpty) {
    //   latestInverter =
    //       data.reduce((a, b) => a.createdAt.compareTo(b.createdAt) > 0 ? a : b);
    // } else {}
    //
    // _isLoading = false;
    // notifyListeners();
  }

  // Future<void> fetchInverterData() async {
  //   try {
  //     String? mac = await SharedPreferencesHelper.getMacData();
  //     if (mac == null || mac.isEmpty) {
  //       throw Exception("MAC address not found.");
  //     }
  //     _isLoading = true;
  //     notifyListeners();
  //
  //     _inverterData = await _fetchInverterDataUseCase.call("48:27:e2:83:62:24");
  //
  //     if (_inverterData.isEmpty) {
  //       throw Exception("No data available.");
  //     }
  //
  //     // Get today's date
  //     // DateTime today = DateTime.now();
  //     // List<InverterDataModel> todayData = _inverterData.where((data) {
  //     //   DateTime dataDate = DateTime.parse("${data.createdAt}");
  //     //   return dataDate.year == today.year &&
  //     //       dataDate.month == today.month &&
  //     //       dataDate.day == today.day;
  //     // }).toList();
  //     //
  //     // // Use today's data if available; otherwise, use the latest available data
  //     // _inverterData = todayData.isNotEmpty ? todayData : [_inverterData.first];
  //
  //     errorMessage = null;
  //     _isLoading = false;
  //   } catch (e) {
  //     errorMessage = e.toString();
  //     _inverterData = [];
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> startAutoRefresh() async {
    await fetchInverterData();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        await fetchInverterData();
      } catch (e) {
        debugPrint("Error refreshing data: $e");
      }
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
