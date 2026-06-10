class DeleteResponse {
  final String message;

  DeleteResponse({required this.message});

  // factory DeleteResponse.fromJson(Map<String, dynamic> json) {
  //   return DeleteResponse(
  //     message: json['message'] ?? 'Unknown response',
  //   );
  // }
  factory DeleteResponse.fromJson(dynamic json) {
    return DeleteResponse(
        message: json.toString()); // because response is "Device Deleted"
  }
}
