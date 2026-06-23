import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/ISendOtpRepository.dart';
import '../../domain/usecases/SendOtpUseCase.dart';

class SendOtpViewModel extends ChangeNotifier {
  final SendOtpUseCase useCase;
  // final ISendOtpRepository _repository;

  SendOtpViewModel(this.useCase);

  bool isLoading = false;
  String? message;
  String? error;

  Future<void> sendOtp(String email) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      final response = await useCase.execute(email);
      // print("Raw OTP API response: '$response'");
      // message = "Email Send To ${email} Successfully...";
      // message = response;
      final lowerResponse = response.toLowerCase().trim();

      // print("Raw OTP API response: '$lowerResponse'");

      if (lowerResponse.contains("user not found")) {
        error = "User not found!";
      } else if (lowerResponse.contains("error while sending mail")) {
        error = "Email could not be sent. Please try again.";
      } else if (lowerResponse.contains("mail sent successfully")) {
        // message = "Email sent to $email successfully.";
        message = "OTP sent to $email successfully.";
      } else {
        error = "Unexpected server response: $response";
      }

      // final lowerResponse = response.toLowerCase().trim();
      //
      // print("Raw OTP API response: '$response'");
      //
      // if (lowerResponse.contains("user not found")) {
      //   error = "User not found!";
      // } else if (lowerResponse.contains("error while sending mail")) {
      //   error = "Email could not be sent. Please try again.";
      // } else if (lowerResponse
      //     .endsWith("Email Send To ${email} Mail Sent Successfully...")) {
      //   message = "Email sent to $email successfully.";
      // } else {
      //   error = "Unexpected server response: $response";
      // }
    } catch (e) {
      error = e.toString();
      print("OTP Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setError(String msg) {
    error = msg;
    notifyListeners();
  }

  void clearMessages() {
    error = null;
    message = null;
    isLoading = false;
    notifyListeners();
  }

  void clearMessages1() {
    error = null;
    message = null;
    isLoading = false;
  }
}
