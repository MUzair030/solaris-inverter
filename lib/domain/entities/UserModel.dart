class UserModel {
  final int id;
  final String username;
  final String email;
  final String address;
  final String phone;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.address,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0, // Default ID
      username: json['username'] ?? 'Unknown', // Default username
      email: json['email'] ?? 'unknown@example.com', // Default email
      address: json['address'] ?? 'Unknown', // Default address
      phone:
          json['phone']?.toString() ?? '0000000000', // Ensure phone is String
    );
  }

  /// Default user instance
  static UserModel defaultUser() {
    return UserModel(
      id: 0,
      username: 'Unknown',
      email: 'unknown@example.com',
      address: 'Unknown',
      phone: '0000000000',
    );
  }
}
