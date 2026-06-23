import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../data/models/ChangePasswordModel.dart';
import '../../domain/usecases/ChangePasswordUseCase.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordUseCase _changePasswordUseCase;

  bool _isLoading = false;
  String? _message;
  String? _error;
  bool isSuccess = false;
  String? errorMessage;
  String? successMessage;

  bool get isLoading => _isLoading;
  String? get message => _message;
  String? get error => _error;

  ChangePasswordViewModel(this._changePasswordUseCase);

  Future<void> changePassword(ChangePasswordModel model) async {
    _isLoading = true;
    _message = null;
    _error = null;
    isSuccess = false;
    notifyListeners();

    try {
      final response = await _changePasswordUseCase.execute(model);

      _isLoading = false;

      if (response.message.toLowerCase().contains('incorrect')) {
        // Handle incorrect password as failure
        // errorMessage = response.message;
        // _error = response.message;
        errorMessage = "Incorrect old password";
        _error = response.message;
        isSuccess = false;
      } else {
        _message = response.message;
        successMessage = response.message;
        isSuccess = true;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      isSuccess = false;
    }

    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    errorMessage = null;
    successMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearMessages1() {
    _error = null;
    errorMessage = null;
    successMessage = null;
    _isLoading = false;
  }
}
