// class ForgotPasswordResponseModel {
//   final String message;
//
//   ForgotPasswordResponseModel({required this.message});
//
//   factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
//     return ForgotPasswordResponseModel(
//         message: json['message'] ?? 'Password changed successfully.'
//         // message: json.toString() ?? 'Incorrect Password'
//         );
//   }
// }

// class ForgotPasswordResponseModel {
//   final String message;
//
//   ForgotPasswordResponseModel({required this.message});
//
//   factory ForgotPasswordResponseModel.fromJson(dynamic json) {
//     return ForgotPasswordResponseModel(message: json.toString());
//   }
// }

import '../../domain/entities/ForgotPasswordResponse.dart';

class ForgotPasswordResponseModel {
  final String message;

  ForgotPasswordResponseModel({required this.message});

  factory ForgotPasswordResponseModel.fromJson(dynamic json) {
    return ForgotPasswordResponseModel(message: json.toString());
  }

  // ✅ Mapping function
  ForgotPasswordResponse toEntity() {
    return ForgotPasswordResponse(message: message);
  }
}
