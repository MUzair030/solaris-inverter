class SignupRequestModel {
  final String address;
  final String city;
  final String country;
  final String email;
  final String password;
  final String phone;
  final String postalCode;
  final String username;
  final String lastname;

  SignupRequestModel({
    required this.address,
    required this.city,
    required this.country,
    required this.email,
    required this.password,
    required this.phone,
    required this.postalCode,
    required this.username,
    required this.lastname,
  });

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "city": city,
      "country": country,
      "email": email,
      "password": password,
      "phone": phone,
      "postalCode": postalCode,
      "username": username,
      "lastName": lastname,
    };
  }
}
