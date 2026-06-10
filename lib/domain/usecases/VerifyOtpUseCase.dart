import '../repositories/OtpRepository.dart';

class VerifyOtpUseCase {
  final OtpRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<bool> execute(String email, String emailOtp) {
    return repository.verifyOtp(email, emailOtp);
  }
}
