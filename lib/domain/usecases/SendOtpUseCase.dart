import '../repositories/ISendOtpRepository.dart';

class SendOtpUseCase {
  final ISendOtpRepository repository;

  SendOtpUseCase(this.repository);

  Future<String> execute(String email) {
    return repository.sendEmailOtp(email);
  }
}
