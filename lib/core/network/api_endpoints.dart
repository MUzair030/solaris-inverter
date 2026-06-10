class ApiEndpoints {
  static const String baseUrl = "http://db.3pol.com:24301/api";
  static const String signup1 = "$baseUrl/auth/signup";
  static const String signup = 'auth/signup';
  static const String signin = 'auth/signin';
  static const String getAllInverterData =
      '$baseUrl/inverter/getAllInverterData'; // both apis works
  // static const String getAllInverterData = 'inverter/getAllInverterData';
  // MAC Address API (GET request with query parameters)
  // static const String addMacAddress = "$baseUrl/auth/macaddress";
  // MAC Address API (PUT request)
  static const String addMacAddress = "$baseUrl/auth/macaddress";
  static const String devicesList = "$baseUrl/user/devices";
  static const String deletedevice = "$baseUrl/user/delete-device";
  static const String edituser = "$baseUrl/auth/edituser";
  static const String changepassword = "$baseUrl/auth/changepassword";
  static const String forgotpassword = "$baseUrl/auth/forgotpassword";
  static const String user_detail = "$baseUrl/auth/user-details";
  static const String send_otp = "$baseUrl/auth/send-otp";
  static const String verify_otp = "$baseUrl/auth/validate-otp";
  static const String provisioningDeleteDevice = "user/delete-device";
}
