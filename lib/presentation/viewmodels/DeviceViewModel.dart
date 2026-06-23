import 'package:flutter/cupertino.dart';

import '../../data/models/DeviceModel.dart';
import '../../domain/usecases/FetchDevicesUseCase.dart';

class DeviceViewModel extends ChangeNotifier {
  final FetchDevicesUseCase fetchDevicesUseCase;

  DeviceViewModel({required this.fetchDevicesUseCase});

  List<DeviceModel> devices = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isMounted = true; // Custom mounted flag

  bool get hasDevices => devices.isNotEmpty;

  @override
  void dispose() {
    _isMounted = false; // Mark as unmounted
    super.dispose();
  }

  Future<void> fetchDevices() async {
    isLoading = true;
    notifyListeners();

    if (_isMounted) notifyListeners(); // Check before notifying
    try {
      devices = await fetchDevicesUseCase.execute();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      devices = [];
    } finally {
      isLoading = false;
      if (_isMounted) notifyListeners();
    }
  }
}
