import 'package:flutter/cupertino.dart';

import '../../domain/usecases/VerifyOtpUseCase.dart';

class VerifyOtpViewModel extends ChangeNotifier {
  final VerifyOtpUseCase _verifyOtpUseCase;

  VerifyOtpViewModel(this._verifyOtpUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _otpVerified = false;
  bool get otpVerified => _otpVerified;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _email;
  String? get email => _email;

  void setEmail(String email) {
    _email = email;
  }

  void setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<void> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _verifyOtpUseCase.execute(email, otp);
      _otpVerified = result;
      _successMessage = "OPT Verified Successfully";
    } catch (e) {
      _otpVerified = false;
      // _errorMessage = e.toString();
      _errorMessage = "OTP verification Failed, provide correct OTP";
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearMessages1() {
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
  }
}
