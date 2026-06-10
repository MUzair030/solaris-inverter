import '../../data/models/ChangePasswordModel.dart';
import '../../data/models/ChangePasswordResponseModel.dart';

abstract class ChangePasswordRepository {
  Future<ChangePasswordResponseModel> changePassword(ChangePasswordModel model);
}
