import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/core/network/dio_client.dart';
import 'package:threepol_inverter_flutter/main.dart';
import 'package:threepol_inverter_flutter/presentation/pages/EmailScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/FirstScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/MainBottomNavigationView.dart';
import '../../../utils/SharedPreferencesHelper.dart';
import '../../data/models/LoginRequestModel.dart';
import '../../domain/usecases/LoginUseCase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../data/models/signup_request_model.dart';

import '../pages/LoginScreen.dart';
import 'DeviceViewModel.dart';

class AuthViewModel extends ChangeNotifier {
  final SignupUseCase _signupUseCase;
  final LoginUseCase _loginUseCase;

  AuthViewModel(this._signupUseCase, this._loginUseCase);

  String? successMessage;
  String? errorMessage;
  String? loginsuccessMessage;
  String? loginerrorMessage;
  bool isLoading = false;
  bool isLoggedIn = false;

  final DioClient dioClient = DioClient();

  DeviceViewModel? viewModel;

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup("google.com")
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Signup - no BuildContext; navigation uses navigatorKey (safe on Android 15)
  Future<void> signup(SignupRequestModel request) async {
    try {
      bool isConnected = await _checkInternet();
      if (!isConnected) {
        loginerrorMessage = "Network is not connected";
        notifyListeners();
        Future.delayed(const Duration(seconds: 2), clearMessages);
        return;
      }
      isLoading = true;
      notifyListeners();

      final response = await _signupUseCase.execute(request);

      if (response.message.contains("Error:")) {
        errorMessage = response.message.replaceFirst("Error: ", "").trim();
        successMessage = null;
      } else {
        successMessage = response.message;
        errorMessage = null;
        Future.delayed(const Duration(milliseconds: 1000), () {
          clearMessages();
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        });
      }
    } catch (e) {
      errorMessage =
          e.toString().replaceAll(RegExp(r'Exception: |Error: '), '').trim();
      successMessage = null;
      Future.delayed(const Duration(seconds: 2), clearMessages);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Login - no BuildContext; navigation uses navigatorKey (safe on Android 15)
  Future<void> login(LoginRequestModel request) async {
    try {
      bool isConnected = await _checkInternet();
      if (!isConnected) {
        loginerrorMessage = "Network is not connected";
        notifyListeners();
        return;
      }
      isLoading = true;
      notifyListeners();

      final response = await _loginUseCase.execute(request);
      loginsuccessMessage = "Login successful!";
      loginerrorMessage = loginsuccessMessage;
      isLoggedIn = true;

      await SharedPreferencesHelper.saveLoginData(response.id,
          response.username, response.email, request.password, response.token);

      await dioClient.refreshToken();

      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        viewModel ??= Provider.of<DeviceViewModel>(ctx, listen: false);
        await viewModel?.fetchDevices();
      }

      Future.delayed(const Duration(milliseconds: 1000), () {
        clearMessages();
        if (viewModel?.hasDevices == true) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => Mainbottomnavigationview()),
          );
        } else {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => FirstScreen()),
          );
        }
      });

      loginerrorMessage = null;
    } catch (e) {
      loginerrorMessage = e.toString().replaceAll("Exception:", "").trim();
      loginsuccessMessage = null;
      isLoggedIn = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    successMessage = null;
    errorMessage = null;
    loginsuccessMessage = null;
    loginerrorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  void clearMessages1() {
    successMessage = null;
    errorMessage = null;
    loginsuccessMessage = null;
    loginerrorMessage = null;
    isLoading = false;
  }

  void navigateToEmail(BuildContext context) {
    clearMessages();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => EmailScreen()),
    );
  }
}
