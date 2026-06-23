class ProvisioningDeleteResponse {
  final bool success;
  final String message;

  ProvisioningDeleteResponse({required this.success, required this.message});

  factory ProvisioningDeleteResponse.fromPlainText(String text) {
    return ProvisioningDeleteResponse(
        success: text.toLowerCase().contains('deleted'), message: text);
  }
}
