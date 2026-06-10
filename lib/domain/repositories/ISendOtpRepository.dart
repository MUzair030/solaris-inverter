abstract class ISendOtpRepository {
  Future<String> sendEmailOtp(String email);
}
