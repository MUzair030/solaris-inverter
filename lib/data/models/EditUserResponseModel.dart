class EditUserResponseModel {
  final String message;

  EditUserResponseModel({required this.message});

  // Factory constructor to handle both String and Map response types
  factory EditUserResponseModel.fromJson(dynamic data) {
    if (data is String) {
      return EditUserResponseModel(message: data);
    } else if (data is Map<String, dynamic>) {
      return EditUserResponseModel(message: data['message'] ?? '');
    } else {
      return EditUserResponseModel(message: 'Unknown response format');
    }
  }
  // factory EditUserResponseModel.fromJson(Map<String, dynamic> json) {
  //   return EditUserResponseModel(
  //     message: json['message'] ?? '',
  //   );
  // }
}
