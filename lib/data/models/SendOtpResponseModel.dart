class SendOtpResponseModel {
  final String message;

  SendOtpResponseModel({required this.message});

  factory SendOtpResponseModel.fromPlainText(String response) {
    return SendOtpResponseModel(message: response);
  }
  // factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
  //   return SendOtpResponseModel(
  //     message: json['message'] ?? 'Mail Sent Successfully',
  //   );
  // }
  // factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
  //   if (!json.containsKey('message')) {
  //     throw Exception("Invalid response: 'message' key is missing");
  //   }
  //
  //   return SendOtpResponseModel(
  //     message: json['message'],
  //   );
  // }
  // factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
  //   return SendOtpResponseModel(
  //     message: json['message'] ?? 'Mail Sent Successfully',
  //   );
  // }
}
