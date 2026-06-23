class LoginResponseModel {
  final String token;
  final String type;
  final int id;
  final String username;
  final String email;
  final List<String> roles;

  LoginResponseModel({
    required this.token,
    required this.type,
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json["token"],
      type: json["type"],
      id: json["id"],
      username: json["username"],
      email: json["email"],
      roles: List<String>.from(json["roles"]),
    );
  }
}
