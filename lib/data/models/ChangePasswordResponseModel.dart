class ChangePasswordResponseModel {
  final String message;

  ChangePasswordResponseModel({required this.message});

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponseModel(
        message: json['message'] ?? 'Password changed successfully.'
        // message: json.toString() ?? 'Incorrect Password'
        );
  }
}
