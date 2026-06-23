import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threepol_inverter_flutter/utils/toast_util.dart';

import '../../../utils/SharedPreferencesHelper.dart';
import '../../data/models/inverter_data_model.dart';
import '../../domain/usecases/get_inverter_data_usecase.dart';

class InverterViewModel1 extends ChangeNotifier {
  final FetchInverterDataUseCase _fetchInverterDataUseCase;
  List<InverterDataModel> _inverterData = [];
  Map<String, List<InverterDataModel>> _inverterDataCache = {};
  String? errorMessage;
  bool isLoading = false;
  Timer? _timer;
  String _currentFilter = "daily";

  // Statistics
  double totalEnergy = 0.0;
  double averagePower = 0.0;
  double peakPower = 0.0;

  final ValueNotifier<String?> toastMessage = ValueNotifier(null);

  InverterViewModel1(this._fetchInverterDataUseCase) {
    // initialize();
  }

  void initialize() {
    fetchInverterData("daily"); // Initial data fetch
    startAutoRefresh("daily"); // Start auto-refresh
  }

  List<InverterDataModel> get inverterData => _inverterData;

  String? _selectedMac;
  Future<void> setSelectedMac(String? macAddress) async {
    _selectedMac = macAddress;
    if (macAddress == null) {
      cleardata();
    } else {
      await fetchInverterData(_currentFilter, macAddress: macAddress);
      await startAutoRefresh(_currentFilter, macAddress: macAddress);
    }
  }

  Future<void> fetchInverterData(String filter, {String? macAddress}) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();
    try {
      String? mac = macAddress ??
          _selectedMac ??
          await SharedPreferencesHelper.getMacData();

      if (mac == null || mac.isEmpty) {
        errorMessage = "MAC Address not found";
        _inverterData = [];
        notifyListeners();
        return;
      }

      List<InverterDataModel> fetchedData =
          await _fetchInverterDataUseCase.execute2(filter, mac!);

      // List<InverterDataModel> fetchedData =
      //     await _fetchInverterDataUseCase.execute("daily", "48:27:e2:83:6d:d0");
      // await _fetchInverterDataUseCase.execute("daily", "48:27:e2:83:61:fc");

      if (filter == "daily") {
        // Filter only last 7 days' data
        final now = DateTime.now();
        _inverterData = fetchedData.where((data) {
          final diff = now.difference(data.createdAt).inDays;
          return diff >= 0 && diff <= 6;
        }).toList();
      } else {
        _inverterData = fetchedData;
      }

      if (fetchedData.isEmpty) {
        errorMessage = "No data available";
        _inverterData = [];
        toastMessage.value = "No data available.";
      } else {
        errorMessage = null;
        _inverterData = fetchedData;
        toastMessage.value = "${_inverterData.last.createdAt}";
      }

      // Trigger toast only if data exists
      if (_inverterData.isNotEmpty) {
        // Sort just in case the list isn't ordered
        _inverterData.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        toastMessage.value = "${_inverterData.last.createdAt}";
      } else {
        toastMessage.value = "No data available.";
      }

      // _calculateStatistics();
      // errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      _inverterData = [];
      // _inverterDataCache[filter] = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startAutoRefresh(String filter, {String? macAddress}) async {
    stopAutoRefresh();
    _currentFilter = filter;
    try {
      await fetchInverterData(filter, macAddress: macAddress);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(hours: 1), (timer) {
        fetchInverterData(filter, macAddress: macAddress);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error during auto-refresh: $e");
    }
  }

  void _calculateStatistics() {
    if (_inverterData.isEmpty) {
      totalEnergy = 0.0;
      averagePower = 0.0;
      peakPower = 0.0;
      return;
    }

    totalEnergy = _inverterData.fold(
        0.0, (sum, data) => _inverterData.last.energyConsumed);
    averagePower = totalEnergy / _inverterData.length;
    peakPower = _inverterData
        .map((data) => data.genPower)
        .reduce((a, b) => a > b ? a : b);

    notifyListeners();
  }

  void cleardata() {
    _inverterData = [];
    totalEnergy = 0.0;
    averagePower = 0.0;
    peakPower = 0.0;
    errorMessage = null;
    notifyListeners();
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
