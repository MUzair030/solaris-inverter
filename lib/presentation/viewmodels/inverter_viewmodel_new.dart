import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/inverter_request_model.dart';
import '../../data/models/inverter_response_model.dart';
import '../../domain/usecases/fetch_inverter_data_usecase.dart';
import '../../utils/SharedPreferencesHelper.dart';

class InverterViewModelNew extends ChangeNotifier {
  final FetchInverterDataUseCase1 fetchUseCase;

  List<InverterResponseModel> inverterData = [];
  bool isLoading = false;
  String? errorMessage;

  Timer? _timer;

  InverterViewModelNew(this.fetchUseCase);

  Future<void> fetchInverterData({String filter = "weekly"}) async {
    print('🔹 fetchInverterData() called');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    String? mac = await SharedPreferencesHelper.getMacData();

    if (mac == null || mac.isEmpty) {
      errorMessage = "MAC Address not found";
      inverterData = [];
      notifyListeners();
      return;
    }

    final request = InverterRequestModel(
      macAddress: mac,
      perday: filter == "daily",
      perweekl: filter == "weekly",
      permonthy: filter == "monthly",
      peryear: filter == "yearly",
      completereport: filter == "complete",
    );
    print('🔹 fetchInverterData() $request');

    try {
      inverterData = await fetchUseCase(request);
      print('🔹 fetchInverterData() $inverterData');
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void startAutoRefresh() {
    stopAutoRefresh();
    _timer = Timer.periodic(const Duration(seconds: 50), (_) {
      fetchInverterData();
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
  }
}
