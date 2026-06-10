import 'package:flutter/material.dart';
import 'package:threepol_inverter_flutter/data/models/ChangePasswordModel.dart';
import 'package:threepol_inverter_flutter/domain/usecases/ForgotPasswordUseCase.dart';

import '../../data/models/ForgotPasswordRequest.dart';
import '../../domain/entities/ForgotPasswordResponse.dart';
import '../../domain/usecases/ChangePasswordUseCase.dart';
import '../pages/LoginScreen.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordUseCase useCase;

  ForgotPasswordViewModel(this.useCase);

  bool isLoading = false;
  String? successMessage;
  String? errorMessage;

  Future<void> changePassword(
      BuildContext context, ForgotPasswordRequest request) async {
    isLoading = true;
    successMessage = null;
    errorMessage = null;
    notifyListeners();

    try {
      ForgotPasswordResponse response = await useCase.execute(request);
      successMessage = response.message;

      Future.delayed(const Duration(seconds: 1), () {
        clearMessages();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      });
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      Future.delayed(const Duration(seconds: 4), () {
        clearMessages();
      });
    } finally {
      isLoading = false;
      notifyListeners();
      Future.delayed(const Duration(seconds: 4), () {
        clearMessages();
      });
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    isLoading = false;
    notifyListeners();
  }

  void clearMessages1() {
    errorMessage = null;
    successMessage = null;
    isLoading = false;
  }
}
