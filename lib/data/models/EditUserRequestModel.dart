class EditUserRequestModel {
  final int id;
  final String username;
  final String lastName;
  final String address;
  final String city;
  final String country;
  final String email;
  final String password;
  final String phone;
  final String postalCode;

  EditUserRequestModel({
    required this.id,
    required this.username,
    required this.lastName,
    required this.address,
    required this.city,
    required this.country,
    required this.email,
    required this.password,
    required this.phone,
    required this.postalCode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'lastName': lastName,
        'address': address,
        'city': city,
        'country': country,
        'email': email,
        'password': password,
        'phone': phone,
        'postalCode': postalCode,
      };
}
