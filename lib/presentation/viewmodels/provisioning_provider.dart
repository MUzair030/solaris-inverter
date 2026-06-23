import 'package:flutter/cupertino.dart';

import '../../domain/usecases/provisioning_delete_usecase.dart';

class ProvisioningProvider extends ChangeNotifier {
  final ProvisioningDeleteDeviceUseCase deleteUseCase;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  ProvisioningProvider(this.deleteUseCase);

  Future<void> deleteDevice(int deviceId) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final response = await deleteUseCase(deviceId);
      if (response.success) {
        successMessage = response.message;
      } else {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  void resetState() {
    errorMessage = null;
    successMessage = null;
    isLoading = false;
    notifyListeners();
  }
}
