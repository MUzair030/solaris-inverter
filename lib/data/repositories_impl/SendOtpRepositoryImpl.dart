import 'package:threepol_inverter_flutter/core/network/api_endpoints.dart';

import '../../core/network/dio_client.dart';
import '../../domain/repositories/ISendOtpRepository.dart';
import '../models/SendOtpResponseModel.dart';

class SendOtpRepositoryImpl implements ISendOtpRepository {
  final DioClient dioClient;

  SendOtpRepositoryImpl(this.dioClient);

  @override
  Future<String> sendEmailOtp(String email) {
    return dioClient
        .getPlainText(ApiEndpoints.send_otp, queryParams: {'email': email});
  }

  // @override
  // Future<SendOtpResponseModel> sendOtp(String email) async {
  //   try {
  //     final response = await dioClient.get(
  //       ApiEndpoints.send_otp,
  //       queryParams: {"email": email},
  //     );
  //
  //     // return SendOtpResponseModel(message: response.data.toString());
  //     return SendOtpResponseModel.fromPlainText(response.data.toString());
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
