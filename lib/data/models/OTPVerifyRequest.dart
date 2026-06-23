class OTPVerifyRequest {
  final String email;
  final String code;

  OTPVerifyRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {
        "email": email,
        "code": code,
      };
}
