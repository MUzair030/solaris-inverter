class MacResponseModel {
  final String message;
  final int? deviceId;

  MacResponseModel({required this.message, required this.deviceId});

  factory MacResponseModel.fromJson(Map<String, dynamic> json) {
    return MacResponseModel(
        message: json['message']?.toString() ?? '',
        deviceId:
            json['id'] != null ? int.tryParse(json['id'].toString()) : null);
  }
}
