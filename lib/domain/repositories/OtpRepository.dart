abstract class OtpRepository {
  Future<bool> verifyOtp(String email, String emailOtp);
}
