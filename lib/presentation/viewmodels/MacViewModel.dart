import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threepol_inverter_flutter/core/network/api_endpoints.dart';
import 'package:threepol_inverter_flutter/utils/SharedPreferencesHelper.dart';
import '../../../core/network/dio_client.dart';

import '../../../utils/toast_util.dart';
import '../../data/models/MacResponseModel.dart';
import '../../domain/usecases/AddMacUseCase.dart';

class MacViewModel extends ChangeNotifier {
  final DioClient dioClient = DioClient(); // Access singleton instance
  final AddMacUseCase addMacUseCase;
  bool isLoading = false;
  String? message;
  String? errorMessage;

  MacViewModel({required this.addMacUseCase});

  MacResponseModel? deviceModelReponse;
  int? deviceID;

  Future<String?> addMacAddress(String macAddress, String inverterName,
      int inverterPower, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response =
            await addMacUseCase(macAddress, inverterName, inverterPower);
        
        deviceModelReponse = response;
        deviceID = response.deviceId;
        
        print("Response data: ${response.deviceId}");
        isLoading = false;
        notifyListeners();
        return response.message;
      } catch (e) {
        print("Attempt ${retryCount + 1} failed: $e");
        
        // If it's the last attempt, return the error
        if (retryCount == maxRetries - 1) {
          isLoading = false;
          notifyListeners();
          
          // Clean up the error message
          String errorMsg = e.toString();
          // Remove common exception prefixes
          errorMsg = errorMsg.replaceAll("Exception: ", "");
          errorMsg = errorMsg.replaceAll("Error Occurred: ", "");
          // Remove any leading "Error: " if present from other layers
          if (errorMsg.startsWith("Error: ")) {
             errorMsg = errorMsg.substring(7);
          }
          
          return errorMsg; 
        }
        
        // Wait before retrying (exponential backoff or fixed delay)
        await Future.delayed(const Duration(seconds: 2));
        retryCount++;
      }
    }
    
    isLoading = false;
    notifyListeners();
    return "Failed to connect after attempts";
  }
  // Future<bool> addMacAddress(String macAddress, String inverterName,
  //     int inverterPower, BuildContext context) async {
  //   isLoading = true;
  //   notifyListeners();
  //
  //   print("🔵 Adding MAC Address: $macAddress, Inverter: $inverterName");
  //
  //   try {
  //     // await dioClient.refreshToken(); // Ensure token is fresh
  //
  //     final response =
  //         await addMacUseCase(macAddress, inverterName, inverterPower);
  //     print("🟢 API Response: ${response.message}");
  //
  //     await SharedPreferencesHelper.saveMacData(
  //         macAddress, inverterName, inverterPower);
  //     Fluttertoast.showToast(msg: "${response.message}");
  //
  //     return true;
  //   } catch (e) {
  //     print("⚠️ Error: $e");
  //     Fluttertoast.showToast(msg: "Error Occurred: ${e.toString()}");
  //
  //     return false;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
