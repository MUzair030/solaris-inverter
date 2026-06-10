class ChangePasswordModel {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool forgetPassword;

  ChangePasswordModel({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.forgetPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      'forgetPassword': forgetPassword,
    };
  }
}
