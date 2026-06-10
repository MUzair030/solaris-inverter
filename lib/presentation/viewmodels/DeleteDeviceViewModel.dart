import 'package:flutter/cupertino.dart';

import '../../data/models/DeleteResponse.dart';
import '../../domain/usecases/DeleteDeviceUseCase.dart';

class DeleteDeviceViewModel extends ChangeNotifier {
  final DeleteDeviceUseCase deleteUseCase;

  DeleteDeviceViewModel({required this.deleteUseCase});

  bool isLoading = false;
  DeleteResponse? response;
  String? error;

  Future<void> deleteDevice(int deviceId) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await deleteUseCase(deviceId);
      response = result;
      error = null;
    } catch (e) {
      error = e.toString();
      response = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
