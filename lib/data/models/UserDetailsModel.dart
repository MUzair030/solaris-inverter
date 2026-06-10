class UserDetailsModel {
  final int? id;
  final String? username;
  final String? email;
  final String? lastName;
  final String? address;
  final String? postalCode;
  final String? city;
  final String? country;
  final int? phone;
  final List<Role> roles;

  UserDetailsModel({
    required this.id,
    required this.username,
    required this.email,
    required this.lastName,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.country,
    required this.phone,
    required this.roles,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      lastName: json['lastName'],
      address: json['address'],
      postalCode: json['postalCode'],
      city: json['city'],
      country: json['country'],
      phone: json['phone'],
      roles: (json['roles'] as List)
          .map((roleJson) => Role.fromJson(roleJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'lastName': lastName,
      'address': address,
      'postalCode': postalCode,
      'city': city,
      'country': country,
      'phone': phone,
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
