import '../../data/models/EditUserRequestModel.dart';
import '../../data/models/EditUserResponseModel.dart';

abstract class EditUserRepository {
  Future<EditUserResponseModel> editUser(EditUserRequestModel requestModel);
}
