import '../../data/models/UserDetailsModel.dart';

abstract class UserRepository {
  Future<UserDetailsModel> getUserDetails();
}
