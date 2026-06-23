import 'package:threepol_inverter_flutter/data/models/ForgotPasswordModel.dart';

import '../../data/models/ForgotPasswordRequest.dart';
import '../../data/models/ForgotPasswordResponseModel.dart';
import '../entities/ForgotPasswordResponse.dart';
import '../repositories/ForgotPasswordRepository.dart';

class ForgotPasswordUseCase {
  final ForgotPasswordRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<ForgotPasswordResponse> execute(ForgotPasswordRequest request) {
    return repository.changePassword(request);
  }
}
