import 'package:threepol_inverter_flutter/core/network/api_endpoints.dart';

import '../../core/network/dio_client.dart';
import '../../domain/repositories/OtpRepository.dart';

class OtpRepositoryImpl implements OtpRepository {
  final DioClient dioClient;

  OtpRepositoryImpl(this.dioClient);

  @override
  Future<bool> verifyOtp(String email, String emailOtp) async {
    try {
      final response = await dioClient.getPlainText(
        ApiEndpoints.verify_otp,
        queryParams: {
          'email': email,
          'emailOtp': emailOtp,
        },
      );

      // If API returns plain "true" or JSON with { result: true }
      //   if (response is bool) {
      //     return response;
      //   }
      //
      //   if (response.toString().toLowerCase().contains('true')) {
      //     return true;
      //   } else {
      //     throw Exception("Please Enter Valid OTP");
      //   }
      // } catch (e) {
      //   throw Exception("OTP Verification failed: ${e.toString()}");
      // }
      if (response.toLowerCase() == 'true') {
        return true;
      } else {
        throw Exception(response); // "Please Enter Valid OTP"
      }
    } catch (e) {
      throw Exception("OTP Verification Failed: ${e.toString()}");
    }
  }
}
