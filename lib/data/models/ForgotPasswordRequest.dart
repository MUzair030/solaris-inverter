class ForgotPasswordRequest {
  final String email;
  final String newPassword;
  final String confirmPassword;

  ForgotPasswordRequest({
    required this.email,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}
