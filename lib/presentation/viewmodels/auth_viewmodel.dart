import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/core/network/dio_client.dart';
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

  Future<void> signup(BuildContext context, SignupRequestModel request) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        loginerrorMessage = "Network is not connected";
        notifyListeners();
        Future.delayed(const Duration(seconds: 2), () {
          clearMessages();
        });
        return;
      }
      isLoading = true;
      notifyListeners();

      final response = await _signupUseCase.execute(request);

      if (response.message.contains("Error:")) {
        // errorMessage = response.message
        //     .replaceFirst("Error: ", "")
        //     .trim(); // Extract error message
        // successMessage = null;
        errorMessage = response.message.replaceFirst("Error: ", "").trim();
        successMessage = null;
        print("Signup Error: $errorMessage");
      } else {
        successMessage = response.message;
        errorMessage = response.message;
        print("Signup Success: $successMessage");

        // Delay navigation by 1 second
        Future.delayed(const Duration(milliseconds: 1000), () {
          _navigateToLogin(context);
          clearMessages();
        });
        errorMessage = null;
      }
    } catch (e) {
      errorMessage =
          e.toString().replaceAll(RegExp(r'Exception: |Error: '), '').trim();
      successMessage = null;
      // print("Signup Exception: $errorMessage");
      Future.delayed(const Duration(seconds: 2), () {
        clearMessages();
      });
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(BuildContext context, LoginRequestModel request) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        loginerrorMessage = "Network is not connected";
        notifyListeners();
        // Future.delayed(const Duration(seconds: 2), () {
        //   clearMessages();
        // });
        return;
      }
      isLoading = true;
      notifyListeners();

      final response = await _loginUseCase.execute(request);
      loginsuccessMessage = "Login successful!";
      loginerrorMessage = loginsuccessMessage;
      isLoggedIn = true;

      // Save the token first
      await SharedPreferencesHelper.saveLoginData(response.id,
          response.username, response.email, request.password, response.token);

      // 🔥 Refresh Dio with the new token immediately
      await dioClient.refreshToken();

      // print("🔵 Token updated in DioClient!");

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        viewModel ??= Provider.of<DeviceViewModel>(context, listen: false);
        await viewModel?.fetchDevices();
        // Provider.of<InverterViewModel>(context, listen: false)
        //     .fetchInverterData(context);
        // Delay navigation by 1 second
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (viewModel?.hasDevices == true) {
            _navigateToHome(context);
          } else {
            _navigateToFirstScreen(context);
          }
          // Clear messages after navigation
          clearMessages();
        });
      });

      loginerrorMessage = null;
    } catch (e) {
      loginerrorMessage = e.toString().replaceAll("Exception:", "").trim();
      // loginerrorMessage = "Wrong credentials";
      loginsuccessMessage = null;
      isLoggedIn = false;
      // Future.delayed(const Duration(seconds: 2), () {
      //   clearMessages();
      // });
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

  void _navigateToLogin(BuildContext context) {
    clearMessages();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _navigateToHome(BuildContext context) {
    clearMessages();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Mainbottomnavigationview()),
    );
  }

  void _navigateToFirstScreen(BuildContext context) {
    clearMessages();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FirstScreen()),
    );
  }

  void navigateToEmail(BuildContext context) {
    clearMessages();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EmailScreen()),
    );
  }
}
