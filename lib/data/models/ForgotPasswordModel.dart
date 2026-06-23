class ForgotPasswordModel {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool forgetPassword;

  ForgotPasswordModel({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.forgetPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': "",
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      'forgetPassword': forgetPassword,
    };
  }
}
