import 'package:threepol_inverter_flutter/core/network/api_endpoints.dart';
import 'package:threepol_inverter_flutter/core/network/dio_client.dart';

import '../../domain/repositories/UserRepository.dart';
import '../models/UserDetailsModel.dart';

class UserRepositoryImpl implements UserRepository {
  final DioClient dio;

  UserRepositoryImpl(this.dio);

  @override
  Future<UserDetailsModel> getUserDetails() async {
    try {
      final response = await dio.get(ApiEndpoints.user_detail);
      return UserDetailsModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to load user details: $e");
    }
  }
}
