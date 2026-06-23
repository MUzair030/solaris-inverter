class SignupResponseModel {
  final String message;

  SignupResponseModel({required this.message});

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(message: json["message"]);
    // return SignupResponseModel(
    //   message: json['message'] ?? '',
    // );
  }
  // factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
  //   final message = json['message'];
  //
  //   if (message is List && message.isNotEmpty) {
  //     return SignupResponseModel(message: message.first.toString());
  //   } else if (message is Map && message.isNotEmpty) {
  //     final firstKey = message.keys.first;
  //     final value = message[firstKey];
  //     return SignupResponseModel(
  //         message: value is List ? value.first.toString() : value.toString());
  //   } else {
  //     return SignupResponseModel(message: message?.toString() ?? '');
  //   }
  // }
}
