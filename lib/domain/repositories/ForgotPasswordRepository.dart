import 'package:threepol_inverter_flutter/data/models/ForgotPasswordModel.dart';

import '../../data/models/ForgotPasswordRequest.dart';
import '../../data/models/ForgotPasswordResponseModel.dart';
import '../../data/repositories_impl/ForgotPasswordRepositoryImpl.dart';
import '../entities/ForgotPasswordResponse.dart';

abstract class ForgotPasswordRepository {
  Future<ForgotPasswordResponse> changePassword(ForgotPasswordRequest request);
}
